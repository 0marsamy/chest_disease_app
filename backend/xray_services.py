"""
Chest X-ray OOD validation and classification services.
Calls Hugging Face Spaces for OOD detection, Segmentation, and main classification/heatmap.
"""

import logging
import os
import time
import base64
from typing import Any

from gradio_client import Client, handle_file

logger = logging.getLogger(__name__)

OOD_THRESHOLD = float(os.getenv("OOD_XRAY_THRESHOLD", "0.8"))

# ֳ׃דֱַ ַבÜ Spaces ָÊַÚÊß Úבל Hugging Face
OOD_CLIENT_NAME = "Ibrahim2002/xray-ood-detector"
SEG_CLIENT_NAME = "Ibrahim2002/lung-segmentation"
CLASS_CLIENT_NAME = "Ibrahim2002/Lung-seg-classify-heatmap" # ַב׃ָם׃ ַבֳ־םֹׁ ַבבם Úדבהַוַ

REQUEST_TIMEOUT = 120.0
MAX_RETRIES = 3


def _get_client(client_name: str) -> Client:
    try:
        return Client(client_name)
    except Exception as e:
        logger.error("Failed to create client for %s: %s", client_name, e)
        raise

def validate_xray(image_path: str, threshold: float | None = None) -> bool:
    """
    Validate that the image is a chest X-ray using the OOD model.
    (This function remains exactly as your working logic).
    """
    logger.info("Starting OOD validation for image: %s", image_path)
    thresh = threshold if threshold is not None else OOD_THRESHOLD
    
    try:
        client = _get_client(OOD_CLIENT_NAME)
        # Assuming your OOD space uses /predict
        result = client.predict(handle_file(image_path), api_name="/predict")
        
        # ַ׃Ê־ַּׁ ַבהÊםֹּ דה ַבÜ Dictionary ַבבם ַּׁÚ
        if isinstance(result, dict) and "X-ray" in result:
             xray_conf = float(result.get("X-ray", 0))
        elif isinstance(result, list) and len(result) > 0 and isinstance(result[0], dict):
             xray_conf = float(result[0].get("X-ray", 0))
        else:
             logger.error("OOD API returned unexpected format: %s", result)
             xray_conf = 0.0

        is_valid = xray_conf >= thresh
        logger.info("OOD validation %s (Confidence: %.2f)", "PASSED" if is_valid else "FAILED", xray_conf)
        
        return is_valid
        
    except Exception as e:
        logger.error("OOD validation failed: %s", e)
        raise


def classify_xray(image_path: str) -> dict[str, Any]:
    """
    Orchestrates the Segmentation and Classification/Heatmap pipeline.
    """
    logger.info("Starting full classification pipeline for image: %s", image_path)
    
    try:
        # ==========================================
        # 1. דֽׁבֹ ַבÜ Segmentation (Þױ ַבֶֹׁ)
        # ==========================================
        logger.info("Calling Segmentation Model...")
        seg_client = _get_client(SEG_CLIENT_NAME)
        seg_img_path = seg_client.predict(
            image=handle_file(image_path),
            api_name="/segment"
        )
        logger.info("Segmentation successful. Image saved temporarily at: %s", seg_img_path)

        # ---> ַבֵײַÝֹ ַבּֿםֹֿ: Êֽזםב ױזֹׁ ַב׃ּדהÊםװה בÜ Base64 Ýזַׁנ <---
        segmented_b64 = None
        if seg_img_path and os.path.exists(seg_img_path):
            with open(seg_img_path, "rb") as f:
                segmented_b64 = base64.b64encode(f.read()).decode("utf-8")

        # ==========================================
        # 2. דֽׁבֹ ַבÊױהםÝ זׁ׃ד ַבÜ Heatmap
        # ==========================================
        logger.info("Calling Classification & Heatmap Model...")
        class_client = _get_client(CLASS_CLIENT_NAME)
        
        # ַב׃ָם׃ ַבֳ־םֹׁ ָÊּׁÚ 3 ַַּֽÊ (Dict ַבהÊםֹּ¡ ׁ׃ַבֹ Êֽ׀םׁ¡ ד׃ַׁ ַבוםÊ דַָ)
        result_tuple = class_client.predict(
            in_img=handle_file(seg_img_path),
            api_name="/analyze"
        )
        
        # Ýß ַבÜ Tuple
        labels_dict = result_tuple[0]
        warning_msg = result_tuple[1]
        heatmap_path = result_tuple[2]

        # ==========================================
        # 3. ÊּדםÚ ַבהÊֶַּ זÊּוםׂ ַבÜ Base64 בבוםÊ דַָ
        # ==========================================
        prediction_str = "Unknown"
        confidence = 0.0
        
        # ֽ׃ַָ ֳÚבל ה׃ָֹ
        if isinstance(labels_dict, dict):
            items = [(k, float(v)) for k, v in labels_dict.items() if isinstance(v, (int, float))]
            if items:
                top_class, top_prob = max(items, key=lambda x: x[1])
                prediction_str = top_class
                confidence = round(top_prob * 100, 1)

        # Êּוםׂ ַבזױÝ
        description = f"Result: {prediction_str} ({confidence}%)"
        if warning_msg and warning_msg.strip():
            description = f"{warning_msg} | {description}"

        # Êֽזםב ױזֹׁ ַבוםÊ דַָ בÜ Text (Base64) Úװַה ַבדזַָםב
        heatmap_b64 = None
        if heatmap_path and os.path.exists(heatmap_path):
            with open(heatmap_path, "rb") as f:
                heatmap_b64 = base64.b64encode(f.read()).decode("utf-8")

        logger.info("Pipeline complete. Prediction: %s", prediction_str)

        return {
            "prediction": prediction_str,
            "confidence": confidence,
            "description": description,
            "segmented_base64": segmented_b64,  # ַבֽÞב ַבּֿםֿ ַבבם ַהײַÝ
            "heatmap_base64": heatmap_b64,
        }
        
    except Exception as e:
        logger.error("Classification Pipeline failed: %s", e)
        raise