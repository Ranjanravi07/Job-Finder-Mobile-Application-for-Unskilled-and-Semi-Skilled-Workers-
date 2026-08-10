import os
import re

directory = r'lib'
sq_pattern = re.compile(r"'([^'\\]*(?:\\.[^'\\]*)*)'")
dq_pattern = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')

failed = []

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            for m in sq_pattern.finditer(content):
                inner = m.group(1)
                if 'à¤' in inner or 'à¥' in inner:
                    try:
                        inner.encode('cp1252').decode('utf-8')
                    except Exception as e:
                        failed.append(f"cp1252 failed on {file}: {repr(inner)} - {e}")
            for m in dq_pattern.finditer(content):
                inner = m.group(1)
                if 'à¤' in inner or 'à¥' in inner:
                    try:
                        inner.encode('cp1252').decode('utf-8')
                    except Exception as e:
                        failed.append(f"cp1252 failed on {file}: {repr(inner)} - {e}")

if failed:
    for f in failed:
        print(f)
else:
    print("No strings failed cp1252 conversion.")
