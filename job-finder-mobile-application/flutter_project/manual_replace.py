import os

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
            if code > 255: return s  # failed
            b.append(code)
    try:
        return b.decode('utf-8')
    except:
        return s

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Just search and replace the specific strings
    replacements = {
        "ðŸ“ ": decode_mojibake("ðŸ“ "),
        "à¤¨à¤•à¥ à¤¸à¤¾à¤®à¤¾ à¤¨à¤œà¤¿à¤•à¥ˆà¤•à¤¾ à¤•à¤¾à¤®à¤¹à¤°à¥‚": decode_mojibake("à¤¨à¤•à¥ à¤¸à¤¾à¤®à¤¾ à¤¨à¤œà¤¿à¤•à¥ˆà¤•à¤¾ à¤•à¤¾à¤®à¤¹à¤°à¥‚"),
        "à¤¸à¤•à¥ à¤°à¤¿à¤¯": decode_mojibake("à¤¸à¤•à¥ à¤°à¤¿à¤¯"),
        "à¤ªà¥‡à¤¨à¥ à¤¡à¤¿à¤™": decode_mojibake("à¤ªà¥‡à¤¨à¥ à¤¡à¤¿à¤™"),
        "à¤¨à¤¿à¤·à¥ à¤•à¥ à¤°à¤¿à¤¯": decode_mojibake("à¤¨à¤¿à¤·à¥ à¤•à¥ à¤°à¤¿à¤¯"),
        "à¤®à¥‚à¤²à¥ à¤¯à¤¾à¤‚à¤•à¤¨": decode_mojibake("à¤®à¥‚à¤²à¥ à¤¯à¤¾à¤‚à¤•à¤¨")
    }

    new_content = content
    for old, new in replacements.items():
        if old != new:
            new_content = new_content.replace(old, new)
            print(f"Replaced {old[:5]}... with {new[:5]}...")

    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {path}")

process_file(r'lib\screens\worker_home.dart')
process_file(r'lib\widgets\profile_summary_card.dart')
