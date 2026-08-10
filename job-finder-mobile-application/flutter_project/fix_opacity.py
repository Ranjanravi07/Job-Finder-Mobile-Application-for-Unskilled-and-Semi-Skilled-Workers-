import os
import re

directory = r'lib'
files_modified = 0

# Replace .withOpacity(x) with .withValues(alpha: x)
opacity_pattern = re.compile(r'\.withOpacity\(([^)]+)\)')

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = opacity_pattern.sub(r'.withValues(alpha: \1)', content)
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                files_modified += 1
                print(f"Fixed withOpacity in {path}")

print(f"Total files modified: {files_modified}")
