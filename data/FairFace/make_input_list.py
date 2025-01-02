import os
import csv

def get_relative_file_paths(directory, output_csv):
    """
    Get the relative paths of all files in a directory and write them to a CSV file.

    :param directory: The directory to scan for files.
    :param output_csv: The path to the output CSV file.
    """
    try:
        # List to store relative file paths
        file_paths = []

        # Walk through the directory
        for root, _, files in os.walk(directory):
            for file in files:
                # Get relative path and add to the list
                relative_path = os.path.relpath(os.path.join(root, file), start=directory)
                true_path = f'gymnast_images/{relative_path}'
                file_paths.append(true_path)

        # Write the file paths to the CSV
        with open(output_csv, mode='w', newline='', encoding='utf-8') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerow(["img_path"])
            for path in file_paths:
                writer.writerow([path])

        print(f"File paths have been written to {output_csv}")

    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
directory_to_scan = "./gymnast_images"  # Replace with your target directory
output_csv_file = "input_csv.csv"  # Replace with your desired output CSV file name

get_relative_file_paths(directory_to_scan, output_csv_file)
