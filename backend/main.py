"""
NeuroLearn FastAPI Backend - Simplified Version
Speech-to-Text Analysis for Dyslexia Screening
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from datetime import datetime
import logging
import httpx

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI
app = FastAPI(
    title="NeuroLearn API",
    description="Speech-to-Text Analysis for Dyslexia Screening",
    version="1.0.0"
)

# CORS Configuration (Allow Flutter web app)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Supabase configuration
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Pydantic Models
class SpeechAnalysisResponse(BaseModel):
    success: bool
    transcription: str
    user_id: str
    confidence: float
    message: str

class HealthResponse(BaseModel):
    status: str
    message: str
    timestamp: str

# ============================================
# ENDPOINTS
# ============================================

@app.get("/", response_model=HealthResponse)
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "message": "NeuroLearn API is running 🚀",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Detailed health check"""
    try:
        # Test Supabase connection
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{SUPABASE_URL}/rest/v1/users?select=id&limit=1",
                headers={
                    "apikey": SUPABASE_KEY,
                    "Authorization": f"Bearer {SUPABASE_KEY}"
                }
            )
            if response.status_code == 200:
                return {
                    "status": "healthy",
                    "message": "API and Database connected ✅",
                    "timestamp": datetime.now().isoformat()
                }
            else:
                raise Exception("Database connection failed")
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(status_code=503, detail="Service unavailable")

@app.post("/api/speech-to-text", response_model=SpeechAnalysisResponse)
async def speech_to_text(
    audio_file: UploadFile = File(...),
    user_id: str = None
):
    """
    Convert speech audio to text and store in database
    
    Parameters:
    - audio_file: Audio file (WAV, MP3, etc.)
    - user_id: User ID from Supabase auth
    
    Returns:
    - Transcription text
    - Confidence score
    - Storage confirmation
    """
    
    if not user_id:
        raise HTTPException(status_code=400, detail="user_id is required")
    
    logger.info(f"Processing speech for user: {user_id}")
    
    try:
        # Read audio file
        content = await audio_file.read()
        
        # Placeholder transcription (integrate real speech-to-text later)
        transcription = f"Test transcription for {audio_file.filename}"
        confidence = 0.85
        
        logger.info(f"Audio file received: {audio_file.filename}, size: {len(content)} bytes")
        
        # Store in Supabase using REST API
        try:
            data = {
                "user_id": user_id,
                "transcription": transcription,
                "confidence": float(confidence),
                "audio_filename": audio_file.filename,
                "created_at": datetime.now().isoformat()
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{SUPABASE_URL}/rest/v1/speech_transcriptions",
                    json=data,
                    headers={
                        "apikey": SUPABASE_KEY,
                        "Authorization": f"Bearer {SUPABASE_KEY}",
                        "Content-Type": "application/json",
                        "Prefer": "return=representation"
                    }
                )
                
                if response.status_code in [200, 201]:
                    logger.info(f"Stored transcription in database for user {user_id}")
                    
                    return {
                        "success": True,
                        "transcription": transcription,
                        "user_id": user_id,
                        "confidence": confidence,
                        "message": "Speech processed and stored successfully ✅"
                    }
                else:
                    logger.error(f"Database error: {response.text}")
                    raise HTTPException(
                        status_code=500,
                        detail=f"Failed to store transcription: {response.text}"
                    )
            
        except Exception as db_error:
            logger.error(f"Database error: {str(db_error)}")
            raise HTTPException(
                status_code=500,
                detail=f"Failed to store transcription: {str(db_error)}"
            )
    
    except Exception as e:
        logger.error(f"Speech processing error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to process speech: {str(e)}"
        )

@app.get("/api/transcriptions/{user_id}")
async def get_user_transcriptions(user_id: str):
    """
    Get all speech transcriptions for a user
    
    Parameters:
    - user_id: User ID from Supabase auth
    
    Returns:
    - List of transcriptions
    """
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{SUPABASE_URL}/rest/v1/speech_transcriptions?user_id=eq.{user_id}&order=created_at.desc",
                headers={
                    "apikey": SUPABASE_KEY,
                    "Authorization": f"Bearer {SUPABASE_KEY}"
                }
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    "success": True,
                    "user_id": user_id,
                    "transcriptions": data,
                    "count": len(data)
                }
            else:
                raise Exception(f"Failed to fetch: {response.text}")
        
    except Exception as e:
        logger.error(f"Failed to fetch transcriptions: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch transcriptions: {str(e)}"
        )

# ============================================
# Run with: python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
# ============================================
