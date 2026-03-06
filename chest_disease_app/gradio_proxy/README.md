# Gradio proxy for X-ray AI (Hugging Face)

This small server receives an image from the Flutter app and calls your Hugging Face Space **Ibrahim2002/xray_ai** via `gradio_client`, then returns JSON to the app.

## Setup

```bash
cd gradio_proxy
pip install -r requirements.txt
python server.py
```

Server runs at **http://localhost:5000**.

## Flutter app configuration

- **Android emulator**: the app uses `http://10.0.2.2:5000` by default (see `lib/foundations/app_urls.dart`).
- **iOS simulator**: change `gradioProxyBaseUrl` to `http://localhost:5000`.
- **Physical device**: use your machine’s LAN IP, e.g. `http://192.168.1.4:5000`, and ensure the device and PC are on the same network.

## Endpoints

- `POST /predict` — body: multipart form with `image` file. Returns `{ "prediction", "confidence", "description", "heatmap_base64" }`.
- `GET /health` — returns `{ "status": "ok" }`.
