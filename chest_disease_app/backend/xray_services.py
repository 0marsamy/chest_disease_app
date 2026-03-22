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
# Initialize clients lazily to avoid startup issues
OOD_CLIENT_NAME = "Ibrahim2002/xray-ood-detector"
MAIN_CLIENT_NAME = "Ibrahim2002/xray_ai"
REQUEST_TIMEOUT = 120.0
RATE_LIMIT_DELAY = 3.0  # seconds between OOD and classification
RETRY_DELAY = 3.0  # seconds between retries
MAX_RETRIES = 3  # maximum retry attempts


def _get_client(client_name: str) -> Client:
    """Get or create a Gradio client instance."""
    try:
        return Client(client_name)
    except Exception as e:
        logger.error("Failed to create client for %s: %s", client_name, e)
        raise


def _call_gradio_with_retry(client_name: str, image_path: str, label: str) -> dict[str, Any]:
    """
    Call a Gradio client with robust retry logic for rate limiting.
    Returns the raw JSON response. Raises on failure after all retries.
    """
    client = _get_client(client_name)
    
    for attempt in range(MAX_RETRIES):
        try:
            logger.info("%s: Calling Gradio API (attempt %d/%d)", label, attempt + 1, MAX_RETRIES)
            
            # Predict using gradio_client
            result = client.predict(
                image_path,  # image input
                api_name="/predict"
            )
            
            logger.info("%s: Successfully got response on attempt %d", label, attempt + 1)
            logger.debug("%s response: %s", label, result)
            return {"data": [result]}
            
        except Exception as e:
            error_msg = str(e).lower()
            is_rate_limit = any(phrase in error_msg for phrase in [
                "too many requests", "rate limit", "429", "quota exceeded"
            ])
            
            if is_rate_limit and attempt < MAX_RETRIES - 1:
                logger.warning(
                    "%s: Rate limited on attempt %d, retrying in %d seconds... Error: %s",
                    label, attempt + 1, RETRY_DELAY, e
                )
                time.sleep(RETRY_DELAY)
                continue
            elif attempt < MAX_RETRIES - 1:
                logger.warning(
                    "%s: Request failed on attempt %d, retrying in %d seconds... Error: %s",
                    label, attempt + 1, RETRY_DELAY, e
                )
                time.sleep(RETRY_DELAY)
                continue
            else:
                logger.error(
                    "%s: All %d attempts failed. Final error: %s",
                    label, MAX_RETRIES, e
                )
                raise


def validate_xray(image_path: str, threshold: float | None = None) -> bool:
    """
    Validate that the image is a chest X-ray using the OOD model.
    Returns True if "X-ray" confidence >= threshold, else False.
    """
    logger.info("Starting OOD validation for image: %s", image_path)
    
    thresh = threshold if threshold is not None else OOD_THRESHOLD
    
    try:
        data = _call_gradio_with_retry(OOD_CLIENT_NAME, image_path, "OOD Validation")
        
        if "data" not in data or not data["data"]:
            logger.error("OOD API returned unexpected format: %s", data)
            raise ValueError("OOD API returned unexpected response format")
        
        first = data["data"][0]
        if not isinstance(first, dict):
            logger.error("OOD API data[0] is not a dict: %s", first)
            raise ValueError("OOD API returned unexpected response format")
        
        xray_conf = float(first.get("X-ray", 0))
        not_xray_conf = float(first.get("Not X-ray", 0))
        
        logger.info(
            "OOD validation result - X-ray: %.2f%%, Not X-ray: %.2f%%, Threshold: %.2f",
            xray_conf * 100, not_xray_conf * 100, thresh
        )
        
        is_valid = xray_conf >= thresh
        logger.info("OOD validation %s", "PASSED" if is_valid else "FAILED")
        
        return is_valid
        
    except Exception as e:
        logger.error("OOD validation failed: %s", e)
        raise


def classify_xray(image_path: str) -> dict[str, Any]:
    """
    Call the main classification model. Returns dict with:
    prediction, confidence, description (and optionally heatmap_base64).
    """
    logger.info("Starting classification for image: %s", image_path)
    
    # Add rate limiting delay between OOD and classification
    logger.info("Waiting %d seconds to avoid rate limiting...", RATE_LIMIT_DELAY)
    time.sleep(RATE_LIMIT_DELAY)
    
    try:
        data = _call_gradio_with_retry(MAIN_CLIENT_NAME, image_path, "Classification")
        
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
        
        logger.info(
            "Classification result - Prediction: %s, Confidence: %.1f%%",
            prediction_str, confidence
        )
        
        return {
            "prediction": prediction_str,
            "confidence": confidence,
            "description": description,
            "heatmap_base64": heatmap_base64,
        }
        
    except Exception as e:
        logger.error("Classification failed: %s", e)
        raise
