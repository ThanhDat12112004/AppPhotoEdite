import cv2
import os
import time
import random
import shutil
import logging
import numpy as np
from fastapi import HTTPException, UploadFile
from PIL import Image
from skimage import restoration, filters, exposure
import onnxruntime as ort

# Cấu hình logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def basic_image_enhancement(image_array):
    """
    Nâng cấp ảnh cơ bản sử dụng OpenCV và scikit-image
    """
    try:
        # Chuyển đổi sang float32 để xử lý
        img_float = image_array.astype(np.float32) / 255.0
        
        # Noise reduction
        denoised = restoration.denoise_bilateral(img_float, sigma_color=0.05, sigma_spatial=15)
        
        # Sharpen the image
        kernel = np.array([[-1,-1,-1], 
                          [-1, 9,-1], 
                          [-1,-1,-1]])
        sharpened = cv2.filter2D((denoised * 255).astype(np.uint8), -1, kernel)
        
        # Enhance contrast
        enhanced = exposure.equalize_adapthist(sharpened / 255.0, clip_limit=0.03)
        
        # Convert back to uint8
        result = (enhanced * 255).astype(np.uint8)
        
        # Upscale using OpenCV (simple interpolation)
        height, width = result.shape[:2]
        upscaled = cv2.resize(result, (width * 2, height * 2), interpolation=cv2.INTER_CUBIC)
        
        return upscaled
        
    except Exception as e:
        logger.error(f"Error in basic enhancement: {e}")
        # Fallback to simple upscaling
        height, width = image_array.shape[:2]
        return cv2.resize(image_array, (width * 2, height * 2), interpolation=cv2.INTER_CUBIC)

# Khởi tạo upsampler với function cơ bản
upsampler = basic_image_enhancement
logger.info("Basic image enhancement initialized successfully")

# Thư mục tạm
TEMP_DIR = "./temp"
if not os.path.exists(TEMP_DIR):
    os.makedirs(TEMP_DIR)

# Đường dẫn mô hình AnimeGAN
MODEL_PATHS = {
    "Hayao": "./weights/AnimeGANv3_Hayao_36.onnx",
    "Shinkai": "./weights/AnimeGANv3_Shinkai_37.onnx"
}

async def enhance_image(image: UploadFile) -> str:
    # Logic hiện có của bạn
    temp_input_path = ""
    output_path = ""
    try:
        if not image.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail={"message": "Invalid image file"})
        logger.info(f"Nhận được ảnh với content-type: {image.content_type}")
        unique_suffix = f"{int(time.time() * 1000)}-{random.randint(0, 10**9)}"
        temp_input_filename = f"{unique_suffix}.PNG"
        temp_input_path = os.path.join(TEMP_DIR, temp_input_filename)
        with open(temp_input_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
        logger.info(f"Lưu file tạm đầu vào: {temp_input_path}")
        
        img = cv2.imread(temp_input_path, cv2.IMREAD_UNCHANGED)
        if img is None:
            raise HTTPException(status_code=500, detail={"message": "Failed to read image"})
        logger.info(f"Đọc ảnh thành công: {temp_input_path}")

        # Sử dụng basic enhancement function
        enhanced_img = upsampler(img)
        logger.info("Nâng cấp ảnh thành công")

        output_filename = f"{unique_suffix}_enhanced.PNG"
        output_path = os.path.join(TEMP_DIR, output_filename)
        cv2.imwrite(output_path, enhanced_img)
        logger.info(f"Lưu ảnh đã nâng cấp: {output_path}")

        if not os.path.exists(output_path):
            logger.error(f"File đầu ra không tồn tại: {output_path}")
            raise HTTPException(status_code=500, detail={"message": f"File đầu ra không tồn tại: {output_path}"})

        return output_path

    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Lỗi không mong muốn: {str(e)}")
        raise HTTPException(status_code=500, detail={"message": f"Image enhancement failed: {str(e)}"})
    finally:
        if os.path.exists(temp_input_path):
            try:
                os.remove(temp_input_path)
                logger.info(f"Đã xóa file đầu vào: {temp_input_path}")
            except Exception as e:
                logger.error(f"Lỗi khi xóa file đầu vào {temp_input_path}: {str(e)}")

async def convert_to_anime_image(image: UploadFile, model: str = "Hayao") -> str:
    temp_input_path = ""
    output_path = ""
    try:
        # Kiểm tra định dạng file
        if not image.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail={"message": "Invalid image file"})
        logger.info(f"Nhận được ảnh với content-type: {image.content_type}")

        # Kiểm tra mô hình
        if model not in MODEL_PATHS:
            raise HTTPException(status_code=400, detail={"message": "Invalid model! Choose 'Hayao' or 'Shinkai'"})

        model_path = MODEL_PATHS[model]
        if not os.path.exists(model_path):
            raise HTTPException(status_code=500, detail={"message": f"Model file not found: {model_path}"})

        # Tạo tên file tạm
        unique_suffix = f"{int(time.time() * 1000)}-{random.randint(0, 10**9)}"
        temp_input_filename = f"{unique_suffix}.PNG"
        temp_input_path = os.path.join(TEMP_DIR, temp_input_filename)
        with open(temp_input_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)
        logger.info(f"Lưu file tạm đầu vào: {temp_input_path}")

        # Đọc và tiền xử lý ảnh
        img = cv2.imread(temp_input_path, cv2.IMREAD_COLOR)  # Đọc ở chế độ RGB
        if img is None:
            raise HTTPException(status_code=500, detail={"message": "Failed to read image"})

        # Đảm bảo ảnh có 3 kênh (RGB)
        if img.shape[2] != 3:
            logger.warning(f"Ảnh có {img.shape[2]} kênh, chuyển đổi sang RGB")
            img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR if img.shape[2] == 4 else cv2.COLOR_GRAY2BGR)

        # Tiền xử lý ảnh
       
        original_height, original_width = img.shape[:2]
        
        new_width, new_height = original_width, original_height

        # Thêm padding để tạo ảnh vuông, làm tròn lên bội số của 16
        fixed_dimension = int(np.ceil(max(new_width, new_height) / 16) * 16)
        padding_x_left = (fixed_dimension - new_width) // 2
        padding_x_right = fixed_dimension - new_width - padding_x_left
        padding_y_top = (fixed_dimension - new_height) // 2
        padding_y_bottom = fixed_dimension - new_height - padding_y_top

        img_padded = cv2.copyMakeBorder(
            img,
            padding_y_top,
            padding_y_bottom,
            padding_x_left,
            padding_x_right,
            cv2.BORDER_CONSTANT,
            value=[0, 0, 0]  # Pixel trống màu đen
        )
        logger.info(f"Kích thước ảnh sau padding: {img_padded.shape}")

        # Chuẩn hóa dữ liệu
        img_float = img_padded.astype(np.float32) / 127.5 - 1.0
        input_data = img_float[np.newaxis, ...]  # Thêm batch dimension [1, H, W, C]
        logger.info(f"Kích thước input_data: {input_data.shape}")

        # Kiểm tra kích thước đầu vào
        if input_data.shape[3] != 3:
            raise HTTPException(status_code=500, detail={"message": f"Invalid input dimensions: expected 3 channels, got {input_data.shape[3]}"})

        # Chạy mô hình ONNX
        session = ort.InferenceSession(model_path)
        input_name = session.get_inputs()[0].name
        output_name = session.get_outputs()[0].name
        outputs = session.run([output_name], {input_name: input_data})
        output_data = outputs[0][0]  # [H, W, C]

        # Xử lý đầu ra
        output_data = (output_data + 1) * 127.5  # Chuyển từ [-1, 1] về [0, 255]
        output_data = np.clip(output_data, 0, 255).astype(np.uint8)

        # Cắt bỏ padding để trở về kích thước ban đầu
        output_data = output_data[padding_y_top:padding_y_top + new_height, padding_x_left:padding_x_left + new_width]
        logger.info(f"Kích thước ảnh đầu ra sau cắt: {output_data.shape}")

        # Lưu ảnh đầu ra
        output_filename = f"{unique_suffix}_anime.jpg"
        output_path = os.path.join(TEMP_DIR, output_filename)
        cv2.imwrite(output_path, output_data, [int(cv2.IMWRITE_JPEG_QUALITY), 85])
        logger.info(f"Lưu ảnh đã chuyển đổi: {output_path}")

        if not os.path.exists(output_path):
            logger.error(f"File đầu ra không tồn tại: {output_path}")
            raise HTTPException(status_code=500, detail={"message": f"File đầu ra không tồn tại: {output_path}"})

        return output_path

    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Lỗi không mong muốn: {str(e)}")
        raise HTTPException(status_code=500, detail={"message": f"Anime conversion failed: {str(e)}"})
    finally:
        if os.path.exists(temp_input_path):
            try:
                os.remove(temp_input_path)
                logger.info(f"Đã xóa file đầu vào: {temp_input_path}")
            except Exception as e:
                logger.error(f"Lỗi khi xóa file đầu vào {temp_input_path}: {str(e)}")
def delete_file(file_path: str):
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            logger.info(f"Đã xóa file đầu ra: {file_path}")
        else:
            logger.warning(f"File không tồn tại khi cố xóa: {file_path}")
    except Exception as e:
        logger.error(f"Lỗi khi xóa file {file_path}: {str(e)}")