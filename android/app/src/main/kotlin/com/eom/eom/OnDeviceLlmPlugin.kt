package com.eom.eom

import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.GenerateContentRequest
import com.google.mlkit.genai.prompt.GenerateContentResponse
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.PromptPrefix
import com.google.mlkit.genai.prompt.TextPart
import com.google.mlkit.genai.prompt.generateContentRequest
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Method channel for OS-managed on-device generation (ML Kit GenAI Prompt / AICore).
 *
 * Channel: `com.eom.eom/on_device_llm`
 */
class OnDeviceLlmPlugin(
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val replied = AtomicBoolean(false)

        fun succeed(value: Any?) {
            if (replied.compareAndSet(false, true)) result.success(value)
        }

        fun fail(
            code: String,
            message: String?,
        ) {
            if (replied.compareAndSet(false, true)) {
                result.error(code, message, null)
            }
        }

        when (call.method) {
            "availability" ->
                scope.launch {
                    try {
                        succeed(NanoEngine.availability())
                    } catch (e: Throwable) {
                        fail("on_device", e.message ?: "availability failed")
                    }
                }
            "prepare" ->
                scope.launch {
                    try {
                        NanoEngine.prepare()
                        succeed(null)
                    } catch (e: Throwable) {
                        fail("on_device", e.message ?: "prepare failed")
                    }
                }
            "generate" -> {
                val system = call.argument<String>("systemPrompt") ?: ""
                val user = call.argument<String>("userMessage") ?: ""
                @Suppress("UNCHECKED_CAST")
                val history =
                    call.argument<List<Map<String, Any>>>("history") ?: emptyList()
                scope.launch {
                    try {
                        succeed(NanoEngine.generate(system, user, history))
                    } catch (e: Throwable) {
                        fail("on_device", e.message ?: "generate failed")
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val CHANNEL = "com.eom.eom/on_device_llm"

        fun registerWith(messenger: BinaryMessenger): OnDeviceLlmPlugin = OnDeviceLlmPlugin(messenger)
    }
}

/**
 * Gemini Nano via ML Kit GenAI Prompt API (AICore).
 *
 * Input must stay under 4000 tokens (~3000 English words). [getTokenLimit] is
 * input + output; [maxOutputTokens] is set so the prompt still fits. The
 * compact system prompt stays in [PromptPrefix] (prefix cache); vault +
 * thought live in the dynamic suffix.
 */
internal object NanoEngine {
    private val model by lazy { Generation.getClient() }

    suspend fun availability(): Map<String, Any?> =
        withContext(Dispatchers.IO) {
            try {
                when (model.checkStatus()) {
                    FeatureStatus.AVAILABLE -> mapOf("status" to "available")
                    FeatureStatus.DOWNLOADABLE -> mapOf("status" to "downloadable")
                    FeatureStatus.DOWNLOADING -> mapOf("status" to "downloading")
                    else ->
                        mapOf(
                            "status" to "unavailable",
                            "reason" to "Gemini Nano is not available on this device",
                        )
                }
            } catch (e: Throwable) {
                mapOf(
                    "status" to "unavailable",
                    "reason" to (e.message ?: "On-device model unavailable"),
                )
            }
        }

    suspend fun prepare() =
        withContext(Dispatchers.IO) {
            when (model.checkStatus()) {
                FeatureStatus.AVAILABLE -> {
                    try {
                        model.warmup()
                    } catch (_: Throwable) {
                        // warmup is best-effort
                    }
                    return@withContext
                }
                FeatureStatus.UNAVAILABLE ->
                    throw IllegalStateException("On-device Error: model unavailable")
                else -> {
                    model.download().collect { status ->
                        if (status is DownloadStatus.DownloadFailed) {
                            throw IllegalStateException(
                                "On-device Error: ${status.e.message ?: "download failed"}",
                            )
                        }
                    }
                    try {
                        model.warmup()
                    } catch (_: Throwable) {
                        // warmup is best-effort
                    }
                }
            }
        }

    suspend fun generate(
        system: String,
        user: String,
        history: List<Map<String, Any>>,
    ): String =
        withContext(Dispatchers.IO) {
            val folded = foldHistory(user, history)
            val (prefix, clipped) = clipToWordBudget(system, folded)
            var suffix = clipped
            var request = buildRequest(prefix, suffix)
            val fitted = fitToTokenLimit(prefix, suffix, request)
            request = fitted.first
            suffix = fitted.second
            val response =
                try {
                    model.generateContent(request)
                } catch (_: Throwable) {
                    val combined = listOf(prefix, suffix).filter { it.isNotBlank() }.joinToString("\n\n")
                    model.generateContent(combined)
                }
            extractText(response)
        }

    private suspend fun fitToTokenLimit(
        prefix: String,
        suffix: String,
        initial: GenerateContentRequest,
    ): Pair<GenerateContentRequest, String> {
        var request = initial
        var clippedSuffix = suffix
        try {
            val limit = model.getTokenLimit()
            val budget =
                (limit - MAX_OUTPUT_TOKENS)
                    .coerceAtMost(DOCUMENTED_INPUT_TOKEN_CAP)
                    .coerceAtLeast(64)
            var tokens = model.countTokens(request).totalTokens
            var words = wordCount(clippedSuffix)
            while (tokens > budget && words > 16) {
                words = (words * 4) / 5
                clippedSuffix = takeWords(clippedSuffix, words)
                request = buildRequest(prefix, clippedSuffix)
                tokens = model.countTokens(request).totalTokens
            }
        } catch (_: Throwable) {
            // countTokens / getTokenLimit failed — word clip already applied.
        }
        return request to clippedSuffix
    }

    private fun buildRequest(
        prefix: String,
        suffix: String,
    ) = generateContentRequest(TextPart(suffix.ifBlank { " " })) {
        if (prefix.isNotBlank()) promptPrefix = PromptPrefix(prefix)
        maxOutputTokens = MAX_OUTPUT_TOKENS
    }

    private fun extractText(response: GenerateContentResponse): String {
        val text = response.candidates.firstOrNull()?.text
        if (text.isNullOrBlank()) {
            throw IllegalStateException("On-device Error: empty response")
        }
        return text
    }
}

/** ML Kit Prompt API: input < 4000 tokens (~3000 English words). */
internal const val MAX_INPUT_WORDS = 3000
internal const val DOCUMENTED_INPUT_TOKEN_CAP = 4000
internal const val MAX_OUTPUT_TOKENS = 768

internal fun wordCount(text: String): Int =
    text.trim().split(Regex("\\s+")).count { it.isNotEmpty() }

internal fun takeWords(
    text: String,
    maxWords: Int,
): String {
    if (maxWords <= 0) return ""
    val words = text.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
    if (words.size <= maxWords) return text.trim()
    return words.take(maxWords).joinToString(" ")
}

internal fun clipToWordBudget(
    prefix: String,
    suffix: String,
    maxWords: Int = MAX_INPUT_WORDS,
): Pair<String, String> {
    val prefixWords = wordCount(prefix)
    if (prefixWords >= maxWords) return takeWords(prefix, maxWords) to ""
    return prefix to takeWords(suffix, maxWords - prefixWords)
}

internal fun foldHistory(
    user: String,
    history: List<Map<String, Any>>,
): String {
    if (history.isEmpty()) return user
    val prior =
        history.joinToString("\n") { turn ->
            val role = turn["role"] as? String ?: "user"
            val content = turn["content"] as? String ?: ""
            "$role: $content"
        }
    return "$prior\n\n$user"
}
