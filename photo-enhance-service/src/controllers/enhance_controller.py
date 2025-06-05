from fastapi import HTTPException, UploadFile, BackgroundTasks
from fastapi.responses import FileResponse
from src.services.enhance_service import enhance_image, delete_file, convert_to_anime_image
import os
import logging

logger = logging.getLogger(__name__)

async def enhance(image: UploadFile, background_tasks: BackgroundTasks):
    output_path = ""
    try:
        # Gọi service để nâng cấp ảnh
        output_path = await enhance_image(image)

        # Kiểm tra file đầu ra tồn tại
        if not os.path.exists(output_path):
            logger.error(f"File đầu ra không tồn tại: {output_path}")
            raise HTTPException(status_code=500, detail=f"Output file not found: {output_path}")

        # Thêm tác vụ xóa file vào background tasks
        background_tasks.add_task(delete_file, output_path)

        # Trả về file ảnh đã nâng cấp
        logger.info(f"Chuẩn bị trả về FileResponse cho file: {output_path}")
        return FileResponse(output_path, media_type="image/png", filename=os.path.basename(output_path))

    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Lỗi khi xử lý yêu cầu: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Request failed: {str(e)}")

async def convert_to_anime(image: UploadFile, model: str, background_tasks: BackgroundTasks):
    output_path = ""
    try:
        # Gọi service để chuyển đổi ảnh sang anime
        output_path = await convert_to_anime_image(image, model)

        # Kiểm tra file đầu ra tồn tại
        if not os.path.exists(output_path):
            logger.error(f"File đầu ra không tồn tại: {output_path}")
            raise HTTPException(status_code=500, detail=f"Output file not found: {output_path}")

        # Thêm tác vụ xóa file vào background tasks
        background_tasks.add_task(delete_file, output_path)

        # Trả về file ảnh đã chuyển đổi
        logger.info(f"Chuẩn bị trả về FileResponse cho file: {output_path}")
        return FileResponse(output_path, media_type="image/png", filename=os.path.basename(output_path))

    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Lỗi khi xử lý yêu cầu: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Request failed: {str(e)}")