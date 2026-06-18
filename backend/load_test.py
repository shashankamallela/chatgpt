import time
import requests
import threading
import pandas as pd

URL = "http://127.0.0.1:5000/videos"
NUM_USERS = 100
DURATION_SECONDS = 60

results = []
running = True

def user_task():
    global running
    session = requests.Session()
    while running:
        start_time = time.time()
        try:
            response = session.get(URL, timeout=5)
            status_code = response.status_code
        except Exception:
            status_code = 500
        
        end_time = time.time()
        response_time_ms = (end_time - start_time) * 1000
        
        results.append({
            "timestamp": time.time(),
            "status_code": status_code,
            "response_time_ms": response_time_ms
        })

print(f"Starting Load Test with {NUM_USERS} users for {DURATION_SECONDS} seconds...")

threads = []
for _ in range(NUM_USERS):
    t = threading.Thread(target=user_task)
    t.start()
    threads.append(t)

time.sleep(DURATION_SECONDS)
running = False

for t in threads:
    t.join()

print("Load Test Finished. Processing results...")

df = pd.DataFrame(results)
total_requests = len(df)
success_requests = len(df[df['status_code'] == 200])

if total_requests > 0:
    min_time = df['response_time_ms'].min()
    max_time = df['response_time_ms'].max()
    avg_time = df['response_time_ms'].mean()
    rps = total_requests / DURATION_SECONDS
else:
    min_time = max_time = avg_time = rps = 0

summary = {
    "Total Requests": total_requests,
    "Successful Requests": success_requests,
    "RPS (Requests Per Second)": rps,
    "Min Response Time (ms)": min_time,
    "Max Response Time (ms)": max_time,
    "Avg Response Time (ms)": avg_time,
}

for key, value in summary.items():
    print(f"{key}: {value:.2f}" if isinstance(value, float) else f"{key}: {value}")

excel_file = "load_test_results.xlsx"
df_summary = pd.DataFrame([summary])

with pd.ExcelWriter(excel_file) as writer:
    df_summary.to_excel(writer, sheet_name="Summary", index=False)
    if not df.empty:
        df.head(100).to_excel(writer, sheet_name="Raw_Data_Sample", index=False)

print(f"Results saved to {excel_file}")
