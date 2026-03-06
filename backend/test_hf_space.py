"""Quick test: what does Ibrahim2002/xray_ai actually return? Run: python test_hf_space.py"""
from gradio_client import Client, handle_file

# Use a public test image URL (Gradio accepts file path or URL)
client = Client("Ibrahim2002/xray_ai")
result = client.predict(
    image=handle_file("https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png"),
    api_name="/predict",
)
print("Type:", type(result))
print("Value:", result)
print("Repr:", repr(result))
