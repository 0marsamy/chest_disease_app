"""
Gradio proxy server for Flutter scan flow.
Calls Hugging Face Space:
  Client("Ibrahim2002/chest-x-ray-ai-with-heatmap"), api_name="/predict"
and returns normalized JSON (prediction + optional heatmap_base64).
"""

import base64
import os
import tempfile
from flask import Flask, request, jsonify
from gradio_client import Client, handle_file

app = Flask(__name__)
# New Hugging Face Space with heatmap output
HF_SPACE = "Ibrahim2002/chest-x-ray-ai-with-heatmap"
API_NAME = "/predict"

# Optional: increase for large images / slow HF response
REQUEST_TIMEOUT = 120


def _format_prediction_label(value: str | None) -> str:
    if not value:
        return "Unknown"

    text = value.strip()
    compact = text.lower().replace(" ", "").replace("_", "").replace("-", "")
    if compact in {"covid", "covid19", "coronavirus"}:
        return "COVID-19"
    return text


def _encode_file_to_base64(path: str) -> str | None:
    """Read image file and return base64 string."""
    if not path or not os.path.exists(path):
        return None
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")


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

        # Log full response structure for debugging/integration checks.
        print(f"[predict] result type: {type(result)}")
        print(f"[predict] result value: {result}")

        # Expected shape from this Space is tuple:
        # (
        #   {'label': 'COVID-19', 'confidences': [{'label': 'COVID-19', 'confidence': 0.47}, ...]},
        #   '/tmp/gradio/.../image.webp'
        # )
        label_output = None
        heatmap_path = None
        if isinstance(result, tuple):
            if len(result) > 0:
                label_output = result[0]
            if len(result) > 1 and isinstance(result[1], str):
                heatmap_path = result[1]
        elif isinstance(result, list):
            if len(result) > 0:
                label_output = result[0]
            if len(result) > 1 and isinstance(result[1], str):
                heatmap_path = result[1]
        else:
            label_output = result

        prediction_str = "Unknown"
        confidence = 0.0

        # Parse gr.Label output
        if isinstance(label_output, dict):
            # Prefer label/confidences structure
            if isinstance(label_output.get("label"), str):
                prediction_str = label_output["label"]

            confidences = label_output.get("confidences")
            if isinstance(confidences, list) and confidences:
                valid = [
                    (
                        c.get("label"),
                        float(c.get("confidence")),
                    )
                    for c in confidences
                    if isinstance(c, dict)
                    and isinstance(c.get("label"), str)
                    and isinstance(c.get("confidence"), (int, float))
                ]
                if valid:
                    top_label, top_prob = max(valid, key=lambda x: x[1])
                    prediction_str = top_label
                    confidence = round(top_prob * 100, 1)

        # Fallback: dict class->probability format
        if confidence == 0.0 and isinstance(label_output, dict):
            items = [
                (k, float(v))
                for k, v in label_output.items()
                if isinstance(v, (int, float))
            ]
            if items:
                top_class, top_prob = max(items, key=lambda x: x[1])
                prediction_str = top_class
                confidence = round(top_prob * 100, 1)

        if prediction_str == "Unknown" and label_output is not None:
            prediction_str = str(label_output)

        prediction_str = _format_prediction_label(prediction_str)
        heatmap_base64 = _encode_file_to_base64(heatmap_path) if heatmap_path else None

        return jsonify({
            "prediction": prediction_str,
            "confidence": confidence,
            "description": (
                f"The model detected findings consistent with {prediction_str} "
                f"with {confidence}% confidence."
            ),
            "heatmap_base64": heatmap_base64,
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
