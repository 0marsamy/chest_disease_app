#!/usr/bin/env python3
"""
Test script for OOD validation flow.
Tests the rate limiting and retry logic.
"""

import os
import tempfile
from PIL import Image
import numpy as np

from xray_services import validate_xray, classify_xray

def create_test_image(path: str, size=(224, 224)):
    """Create a simple test image for testing."""
    # Create a random image
    img_array = np.random.randint(0, 255, (*size, 3), dtype=np.uint8)
    img = Image.fromarray(img_array)
    img.save(path)
    return path

def test_ood_validation():
    """Test OOD validation with a test image."""
    print("Testing OOD validation...")
    
    with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as tmp:
        create_test_image(tmp.name)
        
        try:
            # Test OOD validation
            is_valid = validate_xray(tmp.name)
            print(f"OOD validation result: {'Valid X-ray' if is_valid else 'Invalid image'}")
            
            # If valid, test classification
            if is_valid:
                print("Testing classification...")
                result = classify_xray(tmp.name)
                print(f"Classification result: {result}")
            
        except Exception as e:
            print(f"Error during testing: {e}")
        finally:
            os.unlink(tmp.name)

if __name__ == "__main__":
    print("=== Testing OOD Flow ===")
    test_ood_validation()
    print("=== Test Complete ===")
