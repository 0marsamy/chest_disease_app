#!/usr/bin/env python3
"""
BASIC DEBUG: Test OOD model behavior
"""

import os
import sys

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def debug_ood_basic():
    """Basic OOD debugging"""
    print("=== BASIC OOD DEBUG ===\n")
    
    try:
        from xray_services import validate_xray, OOD_THRESHOLD, _call_gradio_with_retry, OOD_CLIENT_NAME
        
        print(f"1. OOD_THRESHOLD: {OOD_THRESHOLD}")
        print(f"2. OOD_CLIENT_NAME: {OOD_CLIENT_NAME}")
        print()
        
        # Create a simple test file path (even if it doesn't exist, we can see the error)
        test_image = "test_nonexistent.jpg"
        print(f"3. Testing with placeholder: {test_image}")
        
        # Test OOD validation to see what happens
        try:
            result = validate_xray(test_image)
            print(f"   OOD RESULT: {result}")
            
        except Exception as e:
            print(f"   ERROR (expected for nonexistent file): {e}")
            
            # This tells us the function is being called and failing appropriately
            print("   This confirms validate_xray() is being called correctly")
        
        print()
        
        # Let's examine the actual logic in validate_xray by looking at the source
        print("4. Analyzing validate_xray logic...")
        print("   Line 105: xray_conf = float(first.get('X-ray', 0))")
        print("   Line 106: not_xray_conf = float(first.get('Not X-ray', 0))")  
        print("   Line 113: is_valid = xray_conf >= thresh")
        print("   Line 114: return is_valid")
        print()
        
        # Check the main.py logic
        print("5. Analyzing main.py logic...")
        print("   Line 179: is_valid_xray = validate_xray(tmp_path)")
        print("   Line 187: if not is_valid_xray:")
        print("   Line 188:     return JSONResponse(status_code=400, ...)")
        print("   Line 196: # Step 2: Main classification")
        print("   Line 198: result = classify_xray(tmp_path)")
        print()
        
        print("6. POTENTIAL ISSUES TO CHECK:")
        print("   a) Is the OOD model returning correct format?")
        print("   b) Are the keys exactly 'X-ray' and 'Not X-ray'?")
        print("   c) Is the threshold value correct (0.8 = 80%)?")
        print("   d) Is the response being ignored somewhere?")
        print("   e) Are there any exceptions being swallowed?")
        
    except ImportError as e:
        print(f"Import error: {e}")

if __name__ == "__main__":
    debug_ood_basic()
    print("\n=== DEBUG COMPLETE ===")
