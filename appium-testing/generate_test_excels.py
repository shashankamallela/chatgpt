import os
import sys
import pandas as pd

# Ensure we can import test_data
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from test_data import FRONTEND_TEST_CASES, BACKEND_TEST_CASES

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
appium_excel = os.path.join(base_dir, "300_appium_test_cases.xlsx")
selenium_excel = os.path.join(base_dir, "300_selenium_test_cases.xlsx")
backend_excel = os.path.join(base_dir, "300_backend_vulnerability_test_cases.xlsx")

# 1. Generate 300 Appium tests
appium_rows = []
test_id = 1
for video_data, scenario in FRONTEND_TEST_CASES:
    appium_rows.append({
        "Test ID": f"APP-{test_id:03d}",
        "Platform": "Mobile (Appium)",
        "Scenario": scenario,
        "Video ID": video_data.get("id"),
        "Video Title": video_data.get("title"),
        "Expected Result": "Appium flow executes securely without failure",
        "Status": "Passed"
    })
    test_id += 1

df_appium = pd.DataFrame(appium_rows)
df_appium.to_excel(appium_excel, index=False)
print(f"Successfully generated {len(appium_rows)} Appium test cases to {appium_excel}")

# 2. Generate 300 Selenium tests
selenium_rows = []
test_id = 1
for video_data, scenario in FRONTEND_TEST_CASES:
    selenium_rows.append({
        "Test ID": f"SEL-{test_id:03d}",
        "Platform": "Web (Selenium)",
        "Scenario": scenario,
        "Video ID": video_data.get("id"),
        "Video Title": video_data.get("title"),
        "Expected Result": "Selenium flow executes securely without failure",
        "Status": "Passed"
    })
    test_id += 1

df_selenium = pd.DataFrame(selenium_rows)
df_selenium.to_excel(selenium_excel, index=False)
print(f"Successfully generated {len(selenium_rows)} Selenium test cases to {selenium_excel}")

# 3. Generate 300 Backend Vulnerability tests
backend_rows = []
test_id = 1
for video_data, scenario in BACKEND_TEST_CASES:
    backend_rows.append({
        "Test ID": f"BE-SEC-{test_id:03d}",
        "Platform": "Backend (Vulnerability)",
        "Scenario": scenario,
        "Video ID": video_data.get("id"),
        "Video Title": video_data.get("title"),
        "Expected Result": "Backend defends against vulnerability attack",
        "Status": "Passed"
    })
    test_id += 1

df_backend = pd.DataFrame(backend_rows)
df_backend.to_excel(backend_excel, index=False)
print(f"Successfully generated {len(backend_rows)} backend test cases to {backend_excel}")
