# LLM Council

A 3-stage deliberation system where multiple LLMs collaboratively answer a
question. The key idea is **anonymized peer review** in Stage 2 — models rank
each other's answers without knowing whose is whose, which prevents favoritism.

```
User Query
  ↓  Stage 1  parallel queries → individual responses
  ↓  Stage 2  anonymize (Response A/B/C…) → parallel ranking → evaluations + parsed rankings
  ↓  Aggregate → average rank position per response
  ↓  Stage 3  chairman synthesizes the final answer
  → { stage1, stage2, stage3, metadata }
```

## Setup

### Backend (port 8001)

```bash
cd llm-council
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # add your OPENROUTER_API_KEY
python -m backend.main        # run from the project root, not backend/
```

Verify model identifiers before adding them to the council:

```bash
python -m backend.test_openrouter            # tests all configured models
python -m backend.test_openrouter openai/gpt-5.1
```

### Frontend (port 5173)

```bash
cd llm-council/frontend
npm install
npm run dev
```

## Configuration

- Models are hardcoded in `backend/config.py` (`COUNCIL_MODELS`, `CHAIRMAN_MODEL`).
- The chairman defaults to Gemini and may be the same as, or different from, the
  council members.
- Backend port is **8001** (not 8000). If you change it, update both
  `backend/config.py` and `frontend/src/api.js`.

## Design notes

- **Graceful degradation:** a single model failure returns `None` and is
  filtered out; the request never fails because of one model.
- **De-anonymization** happens client-side for display only — evaluators always
  saw anonymous labels. Parsed rankings are shown beneath each raw evaluation so
  users can validate the parsing.
- **Metadata** (`label_to_model`, `aggregate_rankings`) is ephemeral: returned by
  the API but not persisted to `data/conversations/`.
- All backend modules use **relative imports**, so run as `python -m backend.main`
  from the project root.
