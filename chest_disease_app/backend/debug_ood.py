#!/usr/bin/env python3
"""
DEBUG SCRIPT: Analyze OOD model behavior without modifying main code
"""

import os
import sys
import tempfile
from PIL import Image
import numpy as np
import logging

# Set up logging to see all details
logging.basicConfig(level=logging.DEBUG, format='%(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def create_test_image(path: str, is_xray: bool = True):
    """Create a test image - either X-ray-like or non-X-ray"""
    if is_xray:
        # Create grayscale image (more X-ray like)
        img_array = np.random.randint(50, 200, (224, 224), dtype=np.uint8)
    else:
        # Create color image (less X-ray like - selfie)
        img_array = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
    
    img = Image.fromarray(img_array)
    img.save(path)
    return path

def debug_ood_validation():
    """Debug the OOD validation step by step"""
    print("=== DEBUGGING OOD VALIDATION ===\n")
    
    try:
        # Import the actual function
        from xray_services import validate_xray, OOD_THRESHOLD, _call_gradio_with_retry, OOD_CLIENT_NAME
        
        print(f"1. OOD_THRESHOLD: {OOD_THRESHOLD}")
        print(f"2. OOD_CLIENT_NAME: {OOD_CLIENT_NAME}")
        print()
        
        # Test with non-X-ray image
        print("3. Testing with NON-X-ray image (color selfie-like)...")
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as tmp:
            create_test_image(tmp.name, is_xray=False)
            print(f"   Created test image: {tmp.name}")
            
            try:
                # Call the actual OOD validation
                result = validate_xray(tmp.name)
                print(f"   🚨 OOD RESULT: {result} (should be False for non-X-ray)")
                
                if result:
                    print("   ❌ BUG: Non-X-ray image PASSED OOD validation!")
                else:
                    print("   ✅ CORRECT: Non-X-ray image FAILED OOD validation")
                    
            except Exception as e:
                print(f"   ❌ ERROR in validate_xray: {e}")
                import traceback
                traceback.print_exc()
            finally:
                os.unlink(tmp.name)
        
        print()
        
        # Test with X-ray-like image
        print("4. Testing with X-ray-like image (grayscale)...")
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as tmp:
            create_test_image(tmp.name, is_xray=True)
            print(f"   Created test image: {tmp.name}")
            
            try:
                result = validate_xray(tmp.name)
                print(f"   OOD RESULT: {result} (should be True for X-ray)")
                
                if result:
                    print("   ✅ CORRECT: X-ray-like image PASSED OOD validation")
                else:
                    print("   ❌ UNEXPECTED: X-ray-like image FAILED OOD validation")
                    
            except Exception as e:
                print(f"   ❌ ERROR in validate_xray: {e}")
                import traceback
                traceback.print_exc()
            finally:
                os.unlink(tmp.name)
        
        print()
        
        # Debug the raw API call
        print("5. Testing raw API call to see actual response format...")
        with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as tmp:
            create_test_image(tmp.name, is_xray=False)
            
            try:
                raw_response = _call_gradio_with_retry(OOD_CLIENT_NAME, tmp.name, "DEBUG OOD")
                print(f"   Raw response type: {type(raw_response)}")
                print(f"   Raw response: {raw_response}")
                
                if "data" in raw_response and raw_response["data"]:
                    first_item = raw_response["data"][0]
                    print(f"   First item type: {type(first_item)}")
                    print(f"   First item: {first_item}")
                    
                    if isinstance(first_item, dict):
                        print(f"   Dict keys: {list(first_item.keys())}")
                        xray_conf = first_item.get("X-ray", 0)
                        not_xray_conf = first_item.get("Not X-ray", 0)
                        print(f"   X-ray confidence: {xray_conf}")
                        print(f"   Not X-ray confidence: {not_xray_conf}")
                        print(f"   Should be valid: {xray_conf >= OOD_THRESHOLD}")
                    else:
                        print(f"   ❌ BUG: Expected dict but got {type(first_item)}")
                else:
                    print(f"   ❌ BUG: No 'data' key or empty data in response")
                    
            except Exception as e:
                print(f"   ❌ ERROR in raw API call: {e}")
                import traceback
                traceback.print_exc()
            finally:
                os.unlink(tmp.name)
                
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return

if __name__ == "__main__":
    debug_ood_validation()
    print("\n=== DEBUG COMPLETE ===")
