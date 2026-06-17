import json
import os
import shutil
import subprocess
import sys

def install_deps():
    try:
        import pandas
        import openpyxl
    except ImportError:
        print("Installing pandas and openpyxl...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas", "openpyxl"])

install_deps()

import pandas as pd

base_dir = r"d:\chatgpt"
automated_testing_dir = os.path.join(base_dir, "automated testing")

# Ensure dir exists
os.makedirs(automated_testing_dir, exist_ok=True)

# 1. Copy sample data
backend_json_path = os.path.join(base_dir, "backend", "videos.json")
input_json_path = os.path.join(automated_testing_dir, "input.json")
if os.path.exists(backend_json_path):
    shutil.copy2(backend_json_path, input_json_path)
    print(f"Copied {backend_json_path} to {input_json_path}")

# 2. Generate manual web testing excel
manual_columns = ["Test ID", "Test Category", "Description", "Steps", "Expected Result", "Actual Result", "Status", "Comments"]
manual_data = [
    ["TC-001", "Authentication", "Verify user can log in with valid credentials", "1. Navigate to login page\n2. Enter valid email and password\n3. Click Login", "User is redirected to the home feed", "", "Pending", ""],
    ["TC-002", "Video Playback", "Verify video plays smoothly", "1. Navigate to home feed\n2. Tap on the first video", "Video starts playing without buffering issues", "", "Pending", ""],
    ["TC-003", "Camera Capture", "Verify food image capture works", "1. Open Camera tab\n2. Grant permissions\n3. Capture photo", "Photo is captured and displayed for analysis", "", "Pending", ""],
    ["TC-004", "Food Analysis API", "Verify food analysis result is returned", "1. Capture photo\n2. Tap Analyze", "API returns food hint/result and displays on screen", "", "Pending", ""]
]
df_manual = pd.DataFrame(manual_data, columns=manual_columns)
manual_excel_path = os.path.join(base_dir, "manual_web_testing.xlsx")
df_manual.to_excel(manual_excel_path, index=False)
print(f"Generated {manual_excel_path}")

# 3. Generate automated testing data excel
if os.path.exists(input_json_path):
    with open(input_json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    df_auto = pd.DataFrame(data)
    auto_excel_path = os.path.join(automated_testing_dir, "automated_testing_data.xlsx")
    df_auto.to_excel(auto_excel_path, index=False)
    print(f"Generated {auto_excel_path}")
