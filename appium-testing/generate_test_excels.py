import os
import sys
import pandas as pd

# Ensure we can import test_data
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from test_data import FRONTEND_TEST_CASES, BACKEND_TEST_CASES

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
frontend_excel = os.path.join(base_dir, "200_frontend_test_cases.xlsx")
backend_excel = os.path.join(base_dir, "200_backend_vulnerability_test_cases.xlsx")

# Generate 200 Frontend tests (100 Appium + 100 Selenium)
frontend_rows = []
test_id = 1
for platform in ["Mobile (Appium)", "Web (Selenium)"]:
    for video_data, scenario in FRONTEND_TEST_CASES:
        frontend_rows.append({
            "Test ID": f"FE-{test_id:03d}",
            "Platform": platform,
            "Scenario": scenario,
            "Video ID": video_data.get("id"),
            "Video Title": video_data.get("title"),
            "Expected Result": "Frontend flow executes securely without failure",
            "Status": "Pending"
        })
        test_id += 1

df_frontend = pd.DataFrame(frontend_rows)
df_frontend.to_excel(frontend_excel, index=False)
print(f"Successfully generated {len(frontend_rows)} frontend test cases to {frontend_excel}")

# Generate 200 Backend Vulnerability tests
backend_rows = []
test_id = 1
for platform in ["Backend (Vulnerability)"]:
    for video_data, scenario in BACKEND_TEST_CASES:
        backend_rows.append({
            "Test ID": f"BE-SEC-{test_id:03d}",
            "Platform": platform,
            "Scenario": scenario,
            "Video ID": video_data.get("id"),
            "Video Title": video_data.get("title"),
            "Expected Result": "Backend defends against vulnerability attack",
            "Status": "Pending"
        })
        test_id += 1

df_backend = pd.DataFrame(backend_rows)
df_backend.to_excel(backend_excel, index=False)
print(f"Successfully generated {len(backend_rows)} backend test cases to {backend_excel}")
