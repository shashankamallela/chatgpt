import os
import sys

# Ensure we can import test_data
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from test_data import TEST_CASES

import pandas as pd

base_dir = r"d:\chatgpt"
output_excel = os.path.join(base_dir, "100_e2e_test_cases.xlsx")

rows = []
test_id = 1

for platform in ["Mobile (Appium)", "Web (Selenium)"]:
    for video_data, scenario in TEST_CASES:
        rows.append({
            "Test ID": f"E2E-{test_id:03d}",
            "Platform": platform,
            "Scenario": scenario,
            "Video ID": video_data.get("id"),
            "Video Title": video_data.get("title"),
            "Expected Result": "Flow executes successfully without crash",
            "Status": "Pending"
        })
        test_id += 1

df = pd.DataFrame(rows)
df.to_excel(output_excel, index=False)

print(f"Successfully generated 100 test cases to {output_excel}")
