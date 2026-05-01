#!/usr/bin/env python3
"""
SIMPLE DEBUG: Test OOD model with actual image file
"""

import os
import sys

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def debug_ood_with_existing_image():
    """Debug OOD using any existing image file"""
    print("=== SIMPLE OOD DEBUG ===\n")
    
    try:
        from xray_services import validate_xray, OOD_THRESHOLD, _call_gradio_with_retry, OOD_CLIENT_NAME
        
        print(f"1. OOD_THRESHOLD: {OOD_THRESHOLD}")
        print(f"2. OOD_CLIENT_NAME: {OOD_CLIENT_NAME}")
        print()
        
        # Look for any image file in current directory
        test_image = None
        for file in os.listdir('.'):
            if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                test_image = file
                break
        
        if not test_image:
            print("❌ No image file found for testing")
            return
            
        print(f"3. Testing with image: {test_image}")
        
        # Test OOD validation
        try:
            result = validate_xray(test_image)
            print(f"   🎯 OOD RESULT: {result}")
            print(f"   Expected: False for non-X-ray, True for X-ray")
            
            if result:
                print("   ✅ Image PASSED OOD validation (treated as X-ray)")
            else:
                print("   ❌ Image FAILED OOD validation (treated as non-X-ray)")
                
        except Exception as e:
            print(f"   ❌ ERROR in validate_xray: {e}")
            import traceback
            traceback.print_exc()
            return
        
        print()
        
        # Debug raw response
        print("4. Checking raw API response...")
        try:
            raw_response = _call_gradio_with_retry(OOD_CLIENT_NAME, test_image, "DEBUG")
            print(f"   Raw response: {raw_response}")
            
            if "data" in raw_response and raw_response["data"]:
                first_item = raw_response["data"][0]
                print(f"   Response item type: {type(first_item)}")
                print(f"   Response item: {first_item}")
                
                if isinstance(first_item, dict):
                    print(f"   Dict keys: {list(first_item.keys())}")
                    xray_conf = first_item.get("X-ray", 0)
                    not_xray_conf = first_item.get("Not X-ray", 0)
                    print(f"   X-ray confidence: {xray_conf}")
                    print(f"   Not X-ray confidence: {not_xray_conf}")
                    print(f"   Threshold: {OOD_THRESHOLD}")
                    print(f"   xray_conf >= threshold: {xray_conf >= OOD_THRESHOLD}")
                    
                    # This is the key logic!
                    is_valid = xray_conf >= OOD_THRESHOLD
                    print(f"   Final decision (is_valid): {is_valid}")
                    
                    if xray_conf >= OOD_THRESHOLD and not is_valid:
                        print("   🚨 BUG: Logic error - should be True but got False")
                    elif xray_conf < OOD_THRESHOLD and is_valid:
                        print("   🚨 BUG: Logic error - should be False but got True")
                    else:
                        print("   ✅ Logic appears correct")
                        
                else:
                    print(f"   🚨 POTENTIAL BUG: Expected dict but got {type(first_item)}")
                    print(f"   This could cause parsing issues in validate_xray()")
            else:
                print(f"   🚨 BUG: Unexpected response format - missing 'data' key")
                
        except Exception as e:
            print(f"   ❌ ERROR in raw API call: {e}")
            import traceback
            traceback.print_exc()
            
    except ImportError as e:
        print(f"❌ Import error: {e}")

if __name__ == "__main__":
    debug_ood_with_existing_image()
    print("\n=== DEBUG COMPLETE ===")
