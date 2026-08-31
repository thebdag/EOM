package com.eom.eom

import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.DownloadStatus
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.SystemInstruction
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

/** Gemini Nano via ML Kit GenAI Prompt API (AICore). */
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
                FeatureStatus.AVAILABLE -> return@withContext
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
            val response =
                try {
                    if (model.isSystemPromptAvailable()) {
                        model.generateContent(
                            generateContentRequest(
                                SystemInstruction(system),
                                TextPart(folded),
                            ),
                        )
                    } else {
                        model.generateContent("$system\n\n$folded")
                    }
                } catch (_: Throwable) {
                    model.generateContent("$system\n\n$folded")
                }
            extractText(response)
        }

    private fun foldHistory(
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

    private fun extractText(response: Any): String {
        val textGetter =
            response.javaClass.methods.firstOrNull {
                it.name == "getText" && it.parameterCount == 0
            }
        val direct = textGetter?.invoke(response) as? String
        if (!direct.isNullOrBlank()) return direct
        val candidates =
            response.javaClass.methods
                .firstOrNull { it.name == "getCandidates" && it.parameterCount == 0 }
                ?.invoke(response) as? List<*>
        val first = candidates?.firstOrNull()
        val fromCandidate =
            first
                ?.javaClass
                ?.methods
                ?.firstOrNull { it.name == "getText" && it.parameterCount == 0 }
                ?.invoke(first) as? String
        if (!fromCandidate.isNullOrBlank()) return fromCandidate
        throw IllegalStateException("On-device Error: empty response")
    }
}
