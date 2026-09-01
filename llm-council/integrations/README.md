# Council → Branded DOCX bridge

Runs any source `.docx` through the **LLM Council** and renders the synthesized
rewrite into a **DAN-branded `.docx`** using the shared template engine.

```
source .docx
  → council_client.py   extract text → Council (Stage 1-3) → constrained markdown
  → render_docx.cjs      markdown → DAN template (dan_template.js) → branded .docx
```

The Council produces four independent rewrites, anonymously ranks them, and the
chairman synthesizes the best one — a higher-quality, audit-defensible rewrite
than any single pass.

## Files

| File | Role |
|------|------|
| `manifest.json` | The documents to process (code, doc no., title, source path, output folder) |
| `council_client.py` | Extract docx text, prompt the Council, return rewrite + full transcript |
| `render_docx.cjs` | Parse the Council's constrained markdown → branded `.docx` |
| `dan_template.js` | DAN brand template engine (cover, control block, header/footer, helpers) |
| `dan-logo.png` | DAN logo embedded on every cover |
| `run_all.py` | Orchestrator: loops the manifest, writes to `build/` |

## Requirements

- Backend deps installed (`pip install -r ../requirements.txt`) and an
  `OPENROUTER_API_KEY` in `../.env` — the Council makes real API calls.
- Node deps for rendering: `npm install` in this folder (installs `docx`).

## Usage

Run from the **llm-council project root** (so `backend` imports resolve):

```bash
cd llm-council
npm --prefix integrations install          # one-time: docx for the renderer
python -m integrations.run_all             # all docs → integrations/build/
python -m integrations.run_all --only GEN  # a single document
python -m integrations.run_all --apply     # also copy results into the IMS folders
```

Outputs per document in `integrations/build/`:
- `<CODE>.md` — the Council's synthesized rewrite (constrained markdown)
- `<CODE>.council.json` — full transcript (stage1, stage2, stage3, metadata) for audit
- `<DOCNO>_R00.docx` — the final branded document

## Render-only (no API key)

The rendering half is independent and verifiable without the Council. Given a
markdown body + a meta file it produces a branded document:

```bash
node render_docx.cjs build/GEN.md build/GEN.meta.json build/GEN_R00.docx
```

Constrained markdown the renderer understands:
`#`/`##`/`###` headings, `- ` bullets, `> Note:` notes, `| … |` tables, and
blank-line-separated paragraphs.
```
