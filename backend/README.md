# Notia Backend API

FastAPI backend for Notia's AI categorization and future agent features.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Create `.env` file:
```bash
cp .env.example .env
# Add your ANTHROPIC_API_KEY
```

3. Run locally:
```bash
python main.py
```

API will be available at `http://localhost:8000`

## Deploy to Railway

1. Push this repo to GitHub
2. Create new Railway project
3. Connect GitHub repo
4. Add environment variable: `ANTHROPIC_API_KEY`
5. Railway auto-deploys on push

## API Endpoints

- `GET /health` - Health check
- `POST /api/categorize` - Categorize a note
  - Request: `{"text": "note content", "is_developed": false}`
  - Response: `{"category": "To-Do", "confidence": 0.85, "suggested_tags": null}`

## Phase 1 Features

- ✅ Basic note categorization
- ✅ 10 default categories
- ✅ CORS enabled for Flutter app
- ✅ Railway-ready (PORT env var)

## Future Phases

- Phase 2: Project assignment, tag extraction, category hierarchy
- Phase 3: Chat threads, follow-up agent, digest generation
