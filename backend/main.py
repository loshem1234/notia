from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import anthropic
import os
from datetime import datetime

app = FastAPI(title="Notia API", version="1.0.0")

# CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Claude client
claude_client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

# --- Request/Response Models ---

class CategorizeRequest(BaseModel):
    text: str
    is_developed: bool = False

class CategorizeResponse(BaseModel):
    category: str
    confidence: float
    suggested_tags: Optional[List[str]] = None

class HealthResponse(BaseModel):
    status: str
    timestamp: str

# --- Routes ---

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint for Railway"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.post("/api/categorize", response_model=CategorizeResponse)
async def categorize_note(request: CategorizeRequest):
    """
    Categorize a note using Claude.
    
    Phase 1: Returns a simple category label.
    Later phases will add project assignment, tag extraction, etc.
    """
    try:
        # Prompt Claude to categorize
        message = claude_client.messages.create(
               model="claude-3-5-sonnet-20241022",
            max_tokens=500,
            temperature=0.3,
            system="""You are a note categorization assistant for Notia, a personal idea capture app.

Your job: read a user's note and assign ONE category from this list:
- To-Do (actionable tasks)
- Business Idea (entrepreneurial concepts, business opportunities)
- Philosophical (reflections, abstract thinking, wisdom)
- Technical (code, tools, engineering notes)
- Creative (writing, art, design ideas)
- Personal (journal, feelings, private thoughts)
- Learning (things to research, study notes)
- Finance (money, taxes, investments)
- Health (fitness, medical, wellness)
- Other (if truly none of the above fit)

Rules:
1. Return ONLY the category name, nothing else
2. Be decisive - pick the best fit even if imperfect
3. Default to "Other" only if genuinely ambiguous

Respond with just the category name.""",
            messages=[
                {
                    "role": "user",
                    "content": f"Categorize this note:\n\n{request.text}"
                }
            ]
        )
        
        category = message.content[0].text.strip()
        
        # Basic confidence heuristic (Phase 1 - simple)
        # Later: use Claude to return confidence score
        confidence = 0.85 if len(request.text.split()) > 5 else 0.70
        
        return {
            "category": category,
            "confidence": confidence,
            "suggested_tags": None  # Phase 2 feature
        }
        
    except anthropic.APIError as e:
        raise HTTPException(status_code=500, detail=f"Claude API error: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Categorization failed: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "app": "Notia API",
        "version": "1.0.0",
        "phase": "1 - MVP",
        "docs": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
