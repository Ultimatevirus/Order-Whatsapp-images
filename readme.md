# Whatsapp image metadata fixer
I've been running into issues with my phone, namely every time I switch Android phones the metatadata from my Whatsapp photo's seems to get messed up.

To fix this I made two (very mediocre, but functional) scripts, a python script to alter the metadata according to the Whatsapp picture name. And a Powershell script that moves the photos back to the phone.

## Requirements:
1. An Android Phone with Developer USB debugging mode enabled
2. A Windows PC with ADB installed

## How to use:
1. Copy the Whatsapp Images folder from your phone to the project folder.

2. Set the correct folder path in "script.py"

3. Run script.py

4. Set the correct folder paths in sync.ps1

5. Run sync.ps1

It may take a while, but eventually the album app in my phone recognizes the new metadata and ordens them correctly according to the date.

>[!CAUTION]
>**ALWAYS BACK EVERYTHING UP, I DON'T ACTIVELY CHECK OR MAINTAIN THIS CODE!**