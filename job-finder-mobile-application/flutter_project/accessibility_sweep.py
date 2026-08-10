import os
import re

directory = r'lib'
files_modified = 0

def increase_font_size_and_contrast(content):
    # 1. Boost low-contrast slate colors in text to higher contrast
    content = re.sub(r'(color:\s*context\.appColors\.)slate400', r'\1slate600', content)
    content = re.sub(r'(color:\s*context\.appColors\.)slate500', r'\1slate700', content)
    
    # 2. Boost common small font sizes (9, 10, 11) up by 3-4 points for readability
    content = re.sub(r'fontSize:\s*9(\D)', r'fontSize: 13\1', content)
    content = re.sub(r'fontSize:\s*10(\D)', r'fontSize: 13\1', content)
    content = re.sub(r'fontSize:\s*11(\D)', r'fontSize: 14\1', content)
    
    # 3. Increase standard text from 12 -> 14, but carefully to avoid breaking large headers
    content = re.sub(r'fontSize:\s*12(\D)', r'fontSize: 14\1', content)
    
    return content

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = increase_font_size_and_contrast(content)
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                files_modified += 1
                print(f"Improved accessibility in {path}")

print(f"Total files modified: {files_modified}")
