import os
from PIL import Image

def convert_webp_to_png(folder_path):
    # Iterate through all files in the folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)

        # Skip directories
        if os.path.isdir(file_path):
            continue

        # Check the file extension
        file_extension = filename.lower().split('.')[-1]
        if file_extension in ["png", "jpg", "jpeg"]:
            # Leave PNG and JPG files as is
            print(f"Skipping: {filename}")
        elif file_extension == "webp":
            # Replace WEBP image with a PNG version
            try:
                # Open the WEBP image
                with Image.open(file_path) as img:
                    # Create a new file name with .png extension
                    new_file_path = os.path.splitext(file_path)[0] + ".png"

                    # Save the image as a PNG
                    img.save(new_file_path, "PNG")

                # Remove the original WEBP file
                os.remove(file_path)
                print(f"Converted and replaced: {filename} -> {os.path.basename(new_file_path)}")
            except Exception as e:
                print(f"Error processing {filename}: {e}")
        else:
            print(f"Unsupported file type: {filename}")

# Specify the folder path
folder_path = "C:/Users/toom/Desktop/uneven_bars/data/FairFace-master/gymnast_images"

# Call the function
convert_webp_to_png(folder_path)
