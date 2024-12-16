import os

def erase_files_in_directories(directories):
    for directory in directories:
        # Check if the directory exists
        if not os.path.isdir(directory):
            print(f"Directory not found: {directory}")
            continue
        
        # Iterate over all files in the directory
        for file_name in os.listdir(directory):
            file_path = os.path.join(directory, file_name)
            try:
                # Check if it's a file (not a subdirectory)
                if os.path.isfile(file_path):
                    os.remove(file_path)  # Delete the file
                    print(f"Deleted: {file_path}")
                else:
                    print(f"Skipped (not a file): {file_path}")
            except Exception as e:
                print(f"Failed to delete {file_path}: {e}")

# List of directories to clean
directories_to_clean = [
    "C:/Users/toom/Desktop/uneven_bars/data/FairFace-master/detected_faces"
]

# Call the function
erase_files_in_directories(directories_to_clean)
