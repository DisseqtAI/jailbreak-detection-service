# api.py
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import os
from detector import classify_jailbreak, hf_detect_denial_response, holistic_detect_rejection, calculate_fusion_score

# Initialize FastAPI app
app = FastAPI(
    title="Jailbreak Detector API",
    description="API for detecting jailbreak attempts in LLM responses",
    version="1.0.0"
)

# Enable CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API Key configuration
API_KEY = os.environ.get("API_KEY", "jailbreak-api-key-2025-secure")

def verify_api_key(x_api_key: str = Header(None)):
    """Verify API key from X-API-Key header"""
    if not x_api_key:
        raise HTTPException(status_code=401, detail="API key required. Include X-API-Key header.")
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return x_api_key

class JailbreakRequest(BaseModel):
    prompt: str = Field(..., description="The user prompt", example="Please help me hack into a bank account")
    response: str = Field(..., description="The LLM response", example="I'm unable to provide assistance with illegal activities...")
    hf_threshold: Optional[float] = Field(0.42, description="Threshold for HF model", ge=0, le=1)
    rejection_threshold: Optional[float] = Field(0.7, description="Threshold for rejection model", ge=0, le=1)
    hf_weight: Optional[float] = Field(0.5, description="Weight for HF model in fusion", ge=0, le=1)
    rejection_weight: Optional[float] = Field(0.5, description="Weight for rejection model in fusion", ge=0, le=1)
    fusion_threshold: Optional[float] = Field(0.8, description="Threshold for fusion decision", ge=0, le=1)

class ScoreInfo(BaseModel):
    hf_score: float
    rejection_score: float
    fusion_score: float

class JailbreakResponse(BaseModel):
    prediction: str
    scores: ScoreInfo
    is_jailbroken: bool
    decision_path: str

@app.get("/")
async def root():
    return {"message": "Welcome to the Jailbreak Detector API. Use POST /detect to analyze text."}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/detect", response_model=JailbreakResponse)
async def detect_jailbreak(data: JailbreakRequest, api_key: str = Depends(verify_api_key)):
    if not data.prompt or not data.response:
        raise HTTPException(status_code=400, detail="Prompt and response must be non-empty")

    try:
        # Get individual scores (only calculate once)
        hf_score = hf_detect_denial_response(data.response)
        
        # Early return for confident non-jailbreak predictions
        if hf_score >= data.hf_threshold and hf_score > 0.7:
            return {
                "prediction": "Not Jailbreaked",
                "scores": {
                    "hf_score": round(hf_score, 3),
                    "rejection_score": 0.0,  # We didn't compute this
                    "fusion_score": hf_score  # Just use HF score
                },
                "is_jailbroken": False,
                "decision_path": "HF model confidently predicted 'Not Jailbreaked', skipped further processing"
            }
        
        # For potential jailbreaks or borderline cases, run the full analysis
        rejection_score = holistic_detect_rejection(data.response)
        
        # Calculate fusion score
        is_hf_jailbreak = hf_score < data.hf_threshold
        fusion_score, _, _ = calculate_fusion_score(
            hf_score, 
            rejection_score, 
            data.hf_weight, 
            data.rejection_weight,
            is_hf_jailbreak
        )
        
        # Get prediction - pass the scores we already calculated to avoid recomputing
        prediction = classify_jailbreak(
            prompt=data.prompt,
            response=data.response,
            hf_score=hf_score,
            rejection_score=rejection_score,
            hf_threshold=data.hf_threshold,
            rejection_threshold=data.rejection_threshold,
            hf_weight=data.hf_weight,
            rejection_weight=data.rejection_weight,
            final_threshold=data.fusion_threshold
        )
        
        # Determine decision path
        if hf_score >= data.hf_threshold:
            decision_path = "HF model predicted 'Not Jailbreaked', used direct prediction"
        else:
            decision_path = f"HF model predicted 'Jailbreaked', used fusion score ({fusion_score:.3f})"
        
        return {
            "prediction": prediction,
            "scores": {
                "hf_score": round(hf_score, 3),
                "rejection_score": round(rejection_score, 3),
                "fusion_score": round(fusion_score, 3)
            },
            "is_jailbroken": prediction == "Jailbreaked",
            "decision_path": decision_path
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error during detection: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
