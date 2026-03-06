"""
Gradio proxy server: accepts image upload and calls Hugging Face Space
Ibrahim2002/xray_ai via gradio_client, returns JSON for the Flutter app.
Run: pip install flask gradio_client
     python server.py
Then from Flutter use base URL http://10.0.2.2:5000 (Android emulator) or http://localhost:5000
"""

import os
import tempfile
from flask import Flask, request, jsonify
from gradio_client import Client, handle_file

app = Flask(__name__)
# Hugging Face Space (same as in your Python snippet)
HF_SPACE = "Ibrahim2002/xray_ai"
API_NAME = "/predict"

# Optional: increase for large images / slow HF response
REQUEST_TIMEOUT = 120


@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "Missing 'image' file"}), 400

    file = request.files["image"]
    if file.filename == "":
        return jsonify({"error": "No file selected"}), 400

    suffix = os.path.splitext(file.filename)[1] or ".png"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
        file.save(tmp.name)
        tmp_path = tmp.name

    try:
        client = Client(HF_SPACE)
        result = client.predict(
            image=handle_file(tmp_path),
            api_name=API_NAME,
        )
        # Your Space returns gr.Label = dict like {"Covid": 0.1, "Lung Cancer": 0.2, "Normal": 0.6, "Pneumonia": 0.1}
        prediction_str = "Unknown"
        confidence = 0.0
        if isinstance(result, dict):
            # Dict of class_name -> probability: pick top class
            items = [(k, float(v)) for k, v in result.items() if isinstance(v, (int, float))]
            if items:
                top_class, top_prob = max(items, key=lambda x: x[1])
                prediction_str = top_class
                confidence = round(top_prob * 100, 1)
        elif isinstance(result, (list, tuple)) and result:
            prediction_str = str(result[0])
        else:
            prediction_str = str(result) if result is not None else "Unknown"

        return jsonify({
            "prediction": prediction_str,
            "confidence": confidence,
            "description": f"Result from X-ray AI: {prediction_str} ({confidence}%)",
            "heatmap_base64": None,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        try:
            os.unlink(tmp_path)
        except Exception:
            pass


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
