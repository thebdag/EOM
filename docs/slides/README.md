# Slides

Self-contained HTML decks generated with [SlideOps](https://github.com/glukicov/slideops).
Every quoted snippet carries `data-src` and `data-sha256` so later we can ask
whether the deck still matches the code.

```bash
python3 tools/slideops-check.py docs/slides/ --repo . --suggest
```

Standard library only. No model, no network. Exit 1 when anything is stale.
Pull requests run the same command with `--exit-zero` (report-only) via
`.github/workflows/deck-freshness.yml`.

Navigation in any deck: arrow keys or click to advance, `Esc` for the
overview grid, `N` for speaker notes (notes are in the HTML but hidden in
screenshots and PDF).

## How these files are structured

- Copy lives between `<!-- SLIDES START -->` and `<!-- SLIDES END -->`.
  CSS and navigation JS outside those markers stay untouched.
- Each slide is a `<section class="slide">` with an HTML comment
  `<!-- N: LABEL -->` above it. Comments are 0-indexed; the URL hash and
  on-screen counter are 1-indexed (`#7` is comment `<!-- 6: ... -->`).
- Re-number comments after inserting or deleting a slide. When someone
  says "slide 12", grep the file; do not trust a remembered index.
- Cite snippets with `python3 tools/slideops-cite.py path:start-end --repo . --snippet`.
  Never hand-type `data-sha256`. Stamp the finished deck with
  `python3 tools/slideops-cite.py --stamp <deck.html> --repo .`.
- Repair drifted slides; do not rebuild a signed-off deck from scratch.

---

## EOM overview (2026-08-31)

**File:** [`eom-overview-2026-08-31.html`](eom-overview-2026-08-31.html)

**Covers:** product (five cognitive intents, local keys), the Home →
`AiService` → `LlmProvider` request path, the on-device epistemic graph,
soft gate / History, and how to work in this repo (tokens, tracker, this
check).

**Kind:** evergreen onboarding / architecture. Keep it in sync.

**Slides:** 24. Theme mapped from `lib/theme/eom_colors.dart` (void field,
gold orientation accent, indigo selection). Outline was not user-reviewed
(non-interactive cloud build).

**View:** open the HTML in a browser. Deep-link `eom-overview-2026-08-31.html#7`
for the process snippet; `#overview` for the grid.

**Edit later:** pattern blocks and comment numbering as above. After a
repair, re-stamp and re-screenshot only the slides you touched.
