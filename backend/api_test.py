#!/usr/bin/env python3
"""
API TEST: Check actual response format from OOD model
"""

import os
import sys

# Add current directory to path
sys.path.insert(0, os.path.dirname(__file__))

def test_ood_api_directly():
    """Test OOD API directly to see response format"""
    print("=== OOD API RESPONSE TEST ===\n")
    
    try:
        from gradio_client import Client
        
        # Connect to OOD model
        client = Client("Ibrahim2002/xray-ood-detector")
        print("1. Connected to OOD model successfully")
        
        # Test with a simple request to see the API structure
        print("2. Testing API structure...")
        
        # Let's see what the actual API expects
        try:
            # Try to get API info
            print("   API endpoint names:")
            # This will show us what endpoints are available
            print("   Available endpoints might be: /predict, /run, etc.")
            
        except Exception as e:
            print(f"   Error getting API info: {e}")
        
        print()
        print("3. The issue might be:")
        print("   a) Wrong API endpoint name (not '/predict')")
        print("   b) Wrong input format (not file path)")
        print("   c) Wrong response parsing logic")
        print("   d) OOD model returning different format than expected")
        
        print()
        print("4. Current code assumes:")
        print("   - API endpoint: /predict")
        print("   - Input: image file path")
        print("   - Response: {'data': [{'X-ray': 0.9, 'Not X-ray': 0.1}]}")
        
        print()
        print("5. Let's check what the actual API expects...")
        
        # Try to inspect the client
        try:
            print(f"   Client type: {type(client)}")
            # Try different endpoint names
            for endpoint in ['/predict', '/run', '/classify', '/infer']:
                try:
                    print(f"   Trying endpoint: {endpoint}")
                    # This will likely fail but show us the error
                    # result = client.predict(endpoint=endpoint)
                except Exception as e:
                    print(f"     Error with {endpoint}: {e}")
        except Exception as e:
            print(f"   Error inspecting client: {e}")
            
    except Exception as e:
        print(f"Connection error: {e}")

if __name__ == "__main__":
    test_ood_api_directly()
    print("\n=== TEST COMPLETE ===")
