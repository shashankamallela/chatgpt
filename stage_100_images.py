import os
import subprocess

dataset_dir = r"d:\chatgpt\backend\uploads\food_dataset"
limit_per_folder = 100

print("Cleaning up any git locks...")
lock_file = r"d:\chatgpt\.git\index.lock"
if os.path.exists(lock_file):
    try:
        os.remove(lock_file)
    except Exception as e:
        print("Could not remove lock file:", e)

print("Unstaging all currently staged files in the dataset to start fresh...")
subprocess.run(["git", "reset", dataset_dir], cwd=r"d:\chatgpt", check=False)

if not os.path.exists(dataset_dir):
    print(f"Dataset directory not found: {dataset_dir}")
    exit(1)

folders = [os.path.join(dataset_dir, f) for f in os.listdir(dataset_dir) if os.path.isdir(os.path.join(dataset_dir, f))]
print(f"Found {len(folders)} food category folders.")

files_to_add = []

for folder in folders:
    files = [os.path.join(folder, f) for f in os.listdir(folder) if f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp'))]
    files.sort()  # deterministic
    files_to_add.extend(files[:limit_per_folder])

print(f"Total images to force track: {len(files_to_add)}")

# Stage files in chunks to avoid Windows command line length limits
chunk_size = 50
for i in range(0, len(files_to_add), chunk_size):
    chunk = files_to_add[i:i+chunk_size]
    # Use relative paths or exact absolute paths
    subprocess.run(["git", "add", "-f"] + chunk, cwd=r"d:\chatgpt", check=True)
    if (i // chunk_size) % 20 == 0:
        print(f"Progress: Staged {min(i + chunk_size, len(files_to_add))} / {len(files_to_add)} files...")

print("\nSuccessfully staged all 100 images per category!")
