"""
Chest X-ray OOD validation and classification services.
Calls Hugging Face Spaces for OOD detection and main classification.
"""

import logging
import os
import time
from typing import Any

from gradio_client import Client

logger = logging.getLogger(__name__)

# Configurable via environment variable
OOD_THRESHOLD = float(os.getenv("OOD_XRAY_THRESHOLD", "0.8"))
OOD_CLIENT = Client("Ibrahim2002/xray-ood-detector")
MAIN_CLIENT = Client("Ibrahim2002/xray_ai")
REQUEST_TIMEOUT = 120.0
RATE_LIMIT_DELAY = 1.0  # seconds between calls
RETRY_DELAY = 2.0  # seconds before retry


def _call_gradio_with_retry(client: Client, image_path: str, label: str) -> dict[str, Any]:
    """
    Call a Gradio client with retry logic for rate limiting.
    Returns the raw JSON response. Raises on failure.
    """
    max_retries = 1
    
    for attempt in range(max_retries + 1):
        try:
            logger.info("%s: Calling Gradio API (attempt %d)", label, attempt + 1)
            
            # Predict using gradio_client
            result = client.predict(
                image_path,  # image input
                api_name="/predict"
            )
            
            logger.info("%s response: %s", label, result)
            return {"data": [result]}
            
        except Exception as e:
            if "Too many requests" in str(e).lower() and attempt < max_retries:
                logger.warning("%s: Rate limited, retrying in %d seconds...", label, RETRY_DELAY)
                time.sleep(RETRY_DELAY)
                continue
            else:
                logger.error("%s: API call failed: %s", label, e)
                raise


def validate_xray(image_path: str, threshold: float | None = None) -> bool:
    """
    Validate that the image is a chest X-ray using the OOD model.
    Returns True if "X-ray" confidence >= threshold, else False.
    """
    thresh = threshold if threshold is not None else OOD_THRESHOLD
    data = _call_gradio_with_retry(OOD_CLIENT, image_path, "OOD")

    if "data" not in data or not data["data"]:
        logger.error("OOD API returned unexpected format: %s", data)
        raise ValueError("OOD API returned unexpected response format")

    first = data["data"][0]
    if not isinstance(first, dict):
        logger.error("OOD API data[0] is not a dict: %s", first)
        raise ValueError("OOD API returned unexpected response format")

    xray_conf = float(first.get("X-ray", 0))
    not_xray_conf = float(first.get("Not X-ray", 0))
    logger.info("OOD scores: X-ray=%.2f, Not X-ray=%.2f, threshold=%.2f", xray_conf, not_xray_conf, thresh)

    return xray_conf >= thresh


def classify_xray(image_path: str) -> dict[str, Any]:
    """
    Call the main classification model. Returns dict with:
    prediction, confidence, description (and optionally heatmap_base64).
    """
    # Add rate limiting delay
    time.sleep(RATE_LIMIT_DELAY)
    
    data = _call_gradio_with_retry(MAIN_CLIENT, image_path, "Main model")

    if "data" not in data or not data["data"]:
        logger.error("Main model returned unexpected format: %s", data)
        raise ValueError("Main model returned unexpected response format")

    result = data["data"][0]
    prediction_str = "Unknown"
    confidence = 0.0
    heatmap_base64 = None

    if isinstance(result, dict):
        items = [(k, float(v)) for k, v in result.items() if isinstance(v, (int, float))]
        if items:
            top_class, top_prob = max(items, key=lambda x: x[1])
            prediction_str = top_class
            confidence = round(top_prob * 100, 1)
    elif isinstance(result, (list, tuple)) and result:
        prediction_str = str(result[0])
    else:
        prediction_str = str(result) if result is not None else "Unknown"

    description = f"Result from X-ray AI: {prediction_str} ({confidence}%)"
    return {
        "prediction": prediction_str,
        "confidence": confidence,
        "description": description,
        "heatmap_base64": heatmap_base64,
    }
