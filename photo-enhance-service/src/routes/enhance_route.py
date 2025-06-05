from fastapi import APIRouter, UploadFile, BackgroundTasks
from src.controllers.enhance_controller import enhance, convert_to_anime

router = APIRouter()

@router.post("/enhance")
async def enhance_image(image: UploadFile, background_tasks: BackgroundTasks):
    return await enhance(image, background_tasks)

@router.post("/convert-to-anime")
async def convert_anime_image(image: UploadFile, background_tasks: BackgroundTasks, model: str = "Hayao"):
    return await convert_to_anime(image, model, background_tasks)