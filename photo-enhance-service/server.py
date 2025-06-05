import os
import logging
from fastapi import FastAPI
from dotenv import load_dotenv
from src.routes.enhance_route import router as enhance_router
import uvicorn
from contextlib import asynccontextmanager

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

# Lifespan event handler
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up photo enhancement server...")
    yield  # Điểm phân chia giữa startup và shutdown
    logger.info("Shutting down photo enhancement server...")

app = FastAPI(
    lifespan=lifespan,
    title="Photo Enhancement API",
    description="API for enhancing and converting images to anime style",
    version="1.0.0"
)

app.include_router(enhance_router, prefix="")

if __name__ == "__main__":
    # Lấy biến môi trường với giá trị mặc định
    port = int(os.getenv("SERVER_PORT", 8000))
    host = os.getenv("SERVER_HOST", "0.0.0.0")
    
    # Kiểm tra các biến môi trường cần thiết
    required_env_vars = ["SERVER_PORT", "SERVER_HOST"]
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    if missing_vars:
        logger.warning(f"Missing environment variables: {', '.join(missing_vars)}. Using defaults.")

    # Cấu hình số lượng worker dựa trên môi trường
    workers = int(os.getenv("UVICORN_WORKERS", 1))
    
    logger.info(f"Starting server on {host}:{port} with {workers} workers")
    uvicorn.run(
        app,
        host=host,
        port=port,
        workers=workers,
        log_level="info"
    )