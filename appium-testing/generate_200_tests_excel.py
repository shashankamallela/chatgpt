import os
import sys
import pandas as pd

# Ensure we can import test_data
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from test_data import TEST_CASES

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
output_excel = os.path.join(base_dir, "200_e2e_security_test_cases.xlsx")

rows = []
test_id = 1

for platform in ["Mobile (Appium)", "Web (Selenium)", "Backend (Vulnerability)"]:
    for video_data, scenario in TEST_CASES:
        rows.append({
            "Test ID": f"TEST-{test_id:03d}",
            "Platform": platform,
            "Scenario": scenario,
            "Video ID": video_data.get("id"),
            "Video Title": video_data.get("title"),
            "Expected Result": "Flow executes securely without failure",
            "Status": "Pending"
        })
        test_id += 1

df = pd.DataFrame(rows)
df.to_excel(output_excel, index=False)

print(f"Successfully generated {len(rows)} test cases to {output_excel}")
