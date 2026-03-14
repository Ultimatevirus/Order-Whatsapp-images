import os
import re
from PIL import Image
import piexif

# Root folder with WhatsApp images
FOLDER_PATH = r"C:\Users\Admin\Desktop\Order Whatsapp images\WhatsApp Images"

# Regex to extract date from filenames like "IMG-20250808-WA0028.jpg"
FILENAME_DATE_PATTERN = re.compile(r'IMG-(\d{4})(\d{2})(\d{2})-WA\d+')

# Allowed formats that support EXIF
EXIF_COMPATIBLE_EXTS = ('.jpg', '.jpeg')

for root, dirs, files in os.walk(FOLDER_PATH):
    for filename in files:
        if not filename.lower().endswith(EXIF_COMPATIBLE_EXTS):
            print(f"Skipping (no EXIF support): {filename}")
            continue

        match = FILENAME_DATE_PATTERN.match(filename)
        if not match:
            print(f"Skipping (no date in name): {filename}")
            continue

        year, month, day = match.groups()
        date_str = f"{year}:{month}:{day} 12:00:00"
        file_path = os.path.join(root, filename)

        if not os.path.isfile(file_path):
            print(f"File missing: {file_path}")
            continue

        try:
            img = Image.open(file_path)

            # Get existing EXIF data if available
            exif_bytes = img.info.get("exif")
            if exif_bytes:
                exif_dict = piexif.load(exif_bytes)
            else:
                # Initialize fresh EXIF structure
                exif_dict = {"0th": {}, "Exif": {}, "GPS": {}, "1st": {}, "thumbnail": None}

            # Insert date metadata (all 3 relevant fields)
            date_bytes = date_str.encode()
            exif_dict["0th"][piexif.ImageIFD.DateTime] = date_bytes
            exif_dict["Exif"][piexif.ExifIFD.DateTimeOriginal] = date_bytes
            exif_dict["Exif"][piexif.ExifIFD.DateTimeDigitized] = date_bytes

            # Save image with updated EXIF
            exif_bytes = piexif.dump(exif_dict)
            img.save(file_path, exif=exif_bytes)

            print(f"Updated: {file_path} -> {date_str}")

        except Exception as e:
            print(f"Failed to update {file_path}: {e}")
