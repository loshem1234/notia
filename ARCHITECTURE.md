# Notia Architecture

## System Architecture (Phase 1)

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                      │
│                    (iOS / Android)                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Home Screen  │  │Capture Screen│  │ Note Details │     │
│  │              │  │              │  │              │     │
│  │ • Notes List │  │ • Voice Input│  │ • Full Text  │     │
│  │ • Search     │  │ • Text Input │  │ • Metadata   │     │
│  │ • Filter     │  │ • Quick Save │  │ • Category   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘     │
│         │                  │                                │
│         └──────────┬───────┘                                │
│                    │                                        │
│         ┌──────────▼──────────┐                            │
│         │   NotesProvider     │  (State Management)        │
│         │   • Add Note        │                            │
│         │   • Update Note     │                            │
│         │   • Delete Note     │                            │
│         │   • Search/Filter   │                            │
│         └──────┬──────┬───────┘                            │
│                │      │                                     │
│       ┌────────┘      └────────┐                           │
│       │                         │                           │
│ ┌─────▼────────┐         ┌─────▼─────────┐                │
│ │ Database     │         │  API Service  │                │
│ │ Service      │         │               │                │
│ │              │         │ • Categorize  │                │
│ │ • SQLite     │         │ • Health      │                │
│ │ • CRUD ops   │         │               │                │
│ │ • Search     │         └───────┬───────┘                │
│ │ • Indexes    │                 │                         │
│ └──────────────┘                 │                         │
│                                  │ HTTPS                   │
└──────────────────────────────────┼─────────────────────────┘
                                   │
                                   │
                           ┌───────▼────────┐
                           │  RAILWAY API   │
                           │  (Backend)     │
                           ├────────────────┤
                           │                │
                           │  FastAPI       │
                           │  • /health     │
                           │  • /categorize │
                           │                │
                           └───────┬────────┘
                                   │
                                   │ API Call
                                   │
                           ┌───────▼────────┐
                           │ Claude API     │
                           │ (Anthropic)    │
                           │                │
                           │ Sonnet 4       │
                           │ Categorization │
                           └────────────────┘
```

## Data Flow: Capturing a Note

```
User Taps Mic
     │
     ▼
Speech-to-Text (Device, Offline)
     │
     ▼
Text → NotesProvider
     │
     ├─────────────────────┐
     │                     │
     ▼                     ▼
SAVE TO SQLITE      Background API Call
(INSTANT)           (Non-blocking)
     │                     │
     ▼                     ▼
Note appears        Railway → Claude
in UI with              │
"Categorizing..."       ▼
                   Category returned
                        │
                        ▼
                   Update SQLite
                        │
                        ▼
                   Update UI
                   (Category badge)
```

**Key Design Decision:** Save locally FIRST, categorize SECOND.  
This ensures capture is never blocked by network/AI latency.

## Database Schema (SQLite)

```sql
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT NOT NULL,
    createdAt TEXT NOT NULL,          -- ISO 8601 timestamp
    isDeveloped INTEGER NOT NULL,     -- 0 or 1 (boolean)
    category TEXT,                    -- Nullable until categorized
    categoryConfidence REAL           -- 0.0 to 1.0
);

CREATE INDEX idx_createdAt ON notes(createdAt DESC);
CREATE INDEX idx_category ON notes(category);
```

## API Contract

### POST /api/categorize

**Request:**
```json
{
    "text": "Buy groceries tomorrow",
    "is_developed": false
}
```

**Response:**
```json
{
    "category": "To-Do",
    "confidence": 0.85,
    "suggested_tags": null
}
```

**Categories (Phase 1):**
- To-Do
- Business Idea
- Philosophical
- Technical
- Creative
- Personal
- Learning
- Finance
- Health
- Other

## Offline Behavior

| Scenario | Behavior |
|----------|----------|
| Capture note while offline | ✅ Saves to SQLite immediately |
| Category while offline | ⏳ Shows "Uncategorized" |
| Come back online | ✅ Can manually trigger re-categorization (Phase 2) |
| Search while offline | ✅ Full search over local SQLite |
| View notes while offline | ✅ All data in local database |

## State Management

```
NotesProvider (ChangeNotifier)
    │
    ├─ _notes: List<Note>        (in-memory cache)
    ├─ _isLoading: bool
    ├─ _searchQuery: string
    │
    ├─ loadNotes()               → Read all from SQLite
    ├─ addNote()                 → Save to SQLite → categorize in background
    ├─ updateNote()              → Update SQLite + memory
    ├─ deleteNote()              → Delete from SQLite + memory
    ├─ setSearchQuery()          → Filter in-memory
    └─ getCategoryCounts()       → Aggregate in-memory
```

## Security (Phase 1)

| Component | Security Measure |
|-----------|------------------|
| Backend API | HTTPS (Railway default) |
| Database | Local SQLite (sandboxed by OS) |
| API Key | Server-side only (never in app) |
| CORS | Wildcard (⚠️ restrict in Phase 2) |
| Auth | None (⚠️ add in Phase 2) |

## Performance Targets

| Operation | Target | Actual |
|-----------|--------|--------|
| Capture to save | < 1s | ~200ms (SQLite write) |
| Background categorization | 2-5s | ~3s (Claude API latency) |
| Search | < 100ms | ~20ms (indexed SQLite) |
| App startup | < 2s | ~1s (load from SQLite) |
| Notes list scroll | 60fps | 60fps (Material widgets) |

## Phase 2 Additions (Future)

```
┌─────────────────────────────────────┐
│  Add to Current Architecture:       │
├─────────────────────────────────────┤
│                                     │
│  • Hierarchical Categories Table   │
│    (parent_id foreign key)          │
│                                     │
│  • Projects Table                   │
│    (separate from categories)       │
│                                     │
│  • Tags Table (many-to-many)        │
│                                     │
│  • Cloud Backup (PostgreSQL)        │
│    (sync via Railway)               │
│                                     │
│  • Weekly Consolidation Agent       │
│    (cron job on Railway)            │
│                                     │
└─────────────────────────────────────┘
```

## Phase 3 Additions (Future)

```
┌─────────────────────────────────────┐
│  Add to Current Architecture:       │
├─────────────────────────────────────┤
│                                     │
│  • ChatThreads Table                │
│    (foreign key to notes)           │
│                                     │
│  • Messages Table                   │
│    (conversation history)           │
│                                     │
│  • DigestEntries Table              │
│    (nudges, patterns, merges)       │
│                                     │
│  • Background Agent Service         │
│    (follows up on developed notes)  │
│                                     │
└─────────────────────────────────────┘
```

---

**Current Phase 1 Architecture is:**
- ✅ Simple (easy to understand/debug)
- ✅ Fast (local-first, indexed queries)
- ✅ Reliable (offline-capable)
- ✅ Scalable (can add features without breaking existing code)
