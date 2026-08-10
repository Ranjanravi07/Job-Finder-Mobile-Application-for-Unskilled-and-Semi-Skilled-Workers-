import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

directory = r'lib'
files_with_mojibake = []
total_replacements = 0

sq_pattern = re.compile(r"'([^'\\]*(?:\\.[^'\\]*)*)'")
dq_pattern = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')

# Mapping from Windows-1252 characters to their original byte
cp1252_to_byte = {
    '€': 0x80, '‚': 0x82, 'ƒ': 0x83, '„': 0x84, '…': 0x85, '†': 0x86, '‡': 0x87,
    'ˆ': 0x88, '‰': 0x89, 'Š': 0x8A, '‹': 0x8B, 'Œ': 0x8C, 'Ž': 0x8E, '‘': 0x91,
    '’': 0x92, '“': 0x93, '”': 0x94, '•': 0x95, '–': 0x96, '—': 0x97, '˜': 0x98,
    '™': 0x99, 'š': 0x9A, '›': 0x9B, 'œ': 0x9C, 'ž': 0x9E, 'Ÿ': 0x9F
}

def decode_mojibake(s):
    b = bytearray()
    for c in s:
        if c in cp1252_to_byte:
            b.append(cp1252_to_byte[c])
        else:
            code = ord(c)
            if code > 255:
                # If we encounter a unicode char > 255 not in cp1252, 
                # we fail the conversion for the whole string.
                raise ValueError(f"Char {c} out of range")
            b.append(code)
    return b.decode('utf-8')

def fix_mojibake(content):
    global total_replacements
    
    def replacer(match):
        global total_replacements
        full_string = match.group(0)
        inner = match.group(1)
        
        if 'à¤' in inner or 'à¥' in inner:
            try:
                # Some strings have mix of English variables like ${name}
                # It's better to just split by some known mojibake boundary or just convert the whole inner.
                # Since inner shouldn't contain emojis (they would be > 255), this will convert all valid mojibake
                # including spaces, english letters and punctuation.
                corrected_inner = decode_mojibake(inner)
                total_replacements += 1
                return full_string[0] + corrected_inner + full_string[-1]
            except Exception as e:
                # Fallback: maybe only a part is mojibake.
                # Let's try to replace the `à...` sequences only using a regex.
                # This regex captures characters that could be part of the mojibake
                pass
        return full_string

    content = sq_pattern.sub(replacer, content)
    content = dq_pattern.sub(replacer, content)
    return content

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'à¤' in content or 'à¥' in content:
                files_with_mojibake.append(path)
                new_content = fix_mojibake(content)
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)

print(f"Files modified: {len(files_with_mojibake)}")
print(f"Total replacements: {total_replacements}")
