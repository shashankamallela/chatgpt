import json
import os

# Load the videos data
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INPUT_JSON = os.path.join(BASE_DIR, "automated testing", "input.json")

def load_videos():
    try:
        with open(INPUT_JSON, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

VIDEOS = load_videos()

# We will define 5 scenarios for each video to generate exactly 100 tests (5 * 10 * 2):
# 1. valid_user - User logged in normally
# 2. guest_user - User exploring without an account
# 3. offline_mode - Simulating no internet connection
# 4. invalid_data - Submitting malformed data or expecting error handling
# 5. slow_network - Simulating high latency or degraded network
SCENARIOS = ["valid_user", "guest_user", "offline_mode", "invalid_data", "slow_network"]

def get_frontend_test_cases():
    cases = []
    video_list = VIDEOS if VIDEOS else [{"id": i, "title": f"Dummy Video {i}"} for i in range(40)]
    # 20 videos * 5 scenarios = 100 test cases per frontend platform
    for video in video_list[:20]:
        for scenario in SCENARIOS:
            cases.append((video, scenario))
    return cases

def get_backend_test_cases():
    cases = []
    video_list = VIDEOS if VIDEOS else [{"id": i, "title": f"Dummy Video {i}"} for i in range(40)]
    # 40 videos * 5 scenarios = 200 test cases for backend platform
    for video in video_list[:40]:
        for scenario in SCENARIOS:
            cases.append((video, scenario))
    return cases

FRONTEND_TEST_CASES = get_frontend_test_cases()
BACKEND_TEST_CASES = get_backend_test_cases()
# Keep TEST_CASES for backward compatibility if needed, pointing to frontend
TEST_CASES = FRONTEND_TEST_CASES
