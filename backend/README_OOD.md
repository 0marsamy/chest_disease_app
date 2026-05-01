# OOD Validation Implementation

## Overview
The backend now includes OOD (Out-of-Distribution) validation to ensure only valid chest X-ray images are processed by the main classification model.

## Flow
1. **Image Upload** → Flutter app sends image to `/api/ChestScan/upload`
2. **OOD Validation** → Image sent to `Ibrahim2002/xray-ood-detector`
3. **Validation Check** → If "X-ray" confidence >= 0.8 → continue, else reject
4. **Rate Limiting Delay** → Wait 1 second to avoid rate limits
5. **Classification** → Send to `Ibrahim2002/xray_ai` for diagnosis
6. **Response** → Return prediction or error

## Key Features

### ✅ Rate Limiting Protection
- **1-second delay** between OOD and classification calls
- **Retry logic**: If rate limited, retry once after 2 seconds
- **Graceful fallback**: Return HTTP 500 if retries fail

### ✅ Error Handling
- **Invalid images**: HTTP 400 with `{"status": "invalid_image", "message": "..."}`
- **Service failures**: HTTP 500 with user-friendly messages
- **Comprehensive logging** for debugging

### ✅ Configuration
```bash
# Set OOD threshold (default: 0.8)
export OOD_XRAY_THRESHOLD=0.8

# Rate limiting delays (in xray_services.py)
RATE_LIMIT_DELAY = 1.0  # seconds between calls
RETRY_DELAY = 2.0       # seconds before retry
```

## Testing

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Start Server
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Test with curl

#### Valid X-ray Test
```bash
curl -X POST "http://localhost:8000/api/ChestScan/upload" \
  -F "image=@test_xray.jpg" \
  -F "Longitude=31.2357" \
  -F "Latitude=30.0444"
```

#### Invalid Image Test
```bash
curl -X POST "http://localhost:8000/api/ChestScan/upload" \
  -F "image=@cat_photo.jpg"
```

### 4. Expected Responses

#### Valid X-ray (Success)
```json
{
  "prediction": "Normal",
  "confidence": 95.2,
  "description": "Result from X-ray AI: Normal (95.2%)",
  "heatmap_base64": null,
  "imagePath": "/uploads/scan_123456_test_xray.jpg",
  "id": 1
}
```

#### Invalid Image (HTTP 400)
```json
{
  "status": "invalid_image",
  "message": "Please upload a valid chest X-ray image."
}
```

#### Service Error (HTTP 500)
```json
{
  "detail": "OOD validation service failed. Please try again later."
}
```

### 5. Run Test Script
```bash
python test_ood_flow.py
```

## Implementation Details

### Files Modified
- **`xray_services.py`**: Updated to use `gradio_client` instead of HTTP endpoints
- **`requirements.txt`**: Added `gradio_client>=0.6.0`
- **`test_ood_flow.py`**: Test script for validation

### Key Functions
```python
# OOD validation
validate_xray(image_path) -> bool

# Main classification (with built-in delay)
classify_xray(image_path) -> dict

# Internal retry logic
_call_gradio_with_retry(client, image_path, label) -> dict
```

### Rate Limiting Strategy
1. **OOD call** → immediate
2. **1-second delay** → avoid Hugging Face rate limits
3. **Classification call** → after delay
4. **Retry on 429** → wait 2 seconds, retry once
5. **Fail gracefully** → return HTTP 500

## Production Notes
- Monitor logs for rate limiting warnings
- Adjust `RATE_LIMIT_DELAY` if needed
- Set `OOD_XRAY_THRESHOLD` based on validation accuracy
- Consider caching OOD results for identical images

## Flutter Integration
No changes needed! The Flutter app will automatically:
- Receive HTTP 400 for invalid images
- Continue normal flow for valid X-rays
- Handle responses exactly as before
