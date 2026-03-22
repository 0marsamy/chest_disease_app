"""
Chest X-ray OOD validation and classification services.
Calls Hugging Face Spaces for OOD detection and main classification.
"""

import base64
import logging
import os
from typing import Any

import httpx

logger = logging.getLogger(__name__)

# Configurable via environment variable
OOD_THRESHOLD = float(os.getenv("OOD_XRAY_THRESHOLD", "0.8"))
OOD_API_URL = "https://ibrahim2002-xray-ood-detector.hf.space/run/predict"
MAIN_API_URL = "https://ibrahim2002-xray-ai.hf.space/run/predict"

REQUEST_TIMEOUT = 120.0


def _image_to_base64_data_url(image_path: str, mime: str = "image/jpeg") -> str:
    """Read image file and return as base64 data URL."""
    with open(image_path, "rb") as f:
        raw = f.read()
    b64 = base64.b64encode(raw).decode("utf-8")
    return f"data:{mime};base64,{b64}"


def _call_gradio_predict(api_url: str, image_path: str, label: str) -> dict[str, Any]:
    """
    Call a Gradio /run/predict endpoint with an image.
    Returns the raw JSON response. Raises on failure.
    """
    ext = os.path.splitext(image_path)[1].lower()
    mime = "image/png" if ext == ".png" else "image/jpeg"
    data_url = _image_to_base64_data_url(image_path, mime)

    payload = {"data": [data_url]}
    logger.info("%s: POST %s", label, api_url)

    with httpx.Client(timeout=REQUEST_TIMEOUT) as client:
        resp = client.post(api_url, json=payload)
        resp.raise_for_status()
        data = resp.json()
        logger.info("%s response: %s", label, data)
        return data


def validate_xray(image_path: str, threshold: float | None = None) -> bool:
    """
    Validate that the image is a chest X-ray using the OOD model.
    Returns True if "X-ray" confidence >= threshold, else False.
    """
    thresh = threshold if threshold is not None else OOD_THRESHOLD
    data = _call_gradio_predict(OOD_API_URL, image_path, "OOD")

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
    data = _call_gradio_predict(MAIN_API_URL, image_path, "Main model")

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
