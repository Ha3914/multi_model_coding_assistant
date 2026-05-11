from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from app.config import get_settings
from app.schemas import AssistRequest, AssistResponse, HealthResponse
from app.services.orchestrator import CodingAssistantOrchestrator

settings = get_settings()
app = FastAPI(title=settings.app_name)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

web_dir = Path(__file__).parent / "web"
app.mount("/static", StaticFiles(directory=web_dir), name="static")


@app.get("/", include_in_schema=False)
async def home():
    return FileResponse(web_dir / "index.html")


@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(app_name=settings.app_name, env=settings.app_env)


@app.post("/api/v1/assist/code", response_model=AssistResponse)
async def assist_code(request: AssistRequest):
    try:
        orchestrator = CodingAssistantOrchestrator(settings)
        return await orchestrator.run(request)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"执行失败: {exc}") from exc
