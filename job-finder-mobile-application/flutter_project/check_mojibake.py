import os
import re

directory = r'lib'
count_files_with_mojibake = 0
total_replacements = 0
examples = []

def fix_mojibake(match):
    global total_replacements
    mojibake = match.group(0)
    try:
        corrected = mojibake.encode('cp1252').decode('utf-8')
        total_replacements += 1
        return corrected
    except Exception as e:
        return mojibake

# Match sequences of à¤ or à¥ followed by more mojibake characters 
# which usually make up a Nepali string.
pattern = re.compile(r'à[¤¥][\x80-\xFFa-zA-Z0-9\s\.,\?\!\-\(\)\:\'\"]+')

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            if 'à¤' in content or 'à¥' in content:
                count_files_with_mojibake += 1
                
                # Print a few examples from this file
                matches = pattern.findall(content)
                for m in matches:
                    if len(examples) < 15:
                        try:
                            corrected = m.encode('cp1252').decode('utf-8')
                            examples.append(f'File: {file} | Original: {m} | Corrected: {corrected}')
                        except Exception as e:
                            examples.append(f'File: {file} | Error converting {m}: {e}')

                # Actually, let's just do the replacement in memory and see how many we fix
                new_content = pattern.sub(fix_mojibake, content)
                
                # Just counting for now, NOT writing
                # with open(path, 'w', encoding='utf-8') as f:
                #     f.write(new_content)

print(f'Files with mojibake: {count_files_with_mojibake}')
print(f'Total replacements possible found: {total_replacements}')
print('Examples:')
for ex in examples:
    print(ex)
