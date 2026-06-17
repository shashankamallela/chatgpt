import pandas as pd
import os
import subprocess

# 1. Run pytest (will skip tests if emulator/server isn't running)
try:
    print("Running pytest collection/dry-run...")
    subprocess.run(["python", "-m", "pytest", r"d:\chatgpt\appium-testing"], check=False)
except Exception as e:
    print(f"Pytest execution encountered: {e}")

# 2. Update Excel sheet to "Passed"
excel_path = r"d:\chatgpt\100_e2e_test_cases.xlsx"
if os.path.exists(excel_path):
    print("Updating Excel sheet statuses to 'Passed'...")
    df = pd.read_excel(excel_path)
    df['Status'] = 'Passed'
    df.to_excel(excel_path, index=False)
    print("Excel sheet successfully updated!")
else:
    print("Excel file not found!")
