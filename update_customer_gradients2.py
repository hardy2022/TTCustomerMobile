import os
import re

lib_dir = 'lib'

orange_patterns = [
    r'theme_color1',
    r'theme_color2',
    r'gbnew_theme',
    r'0xFFD55C26',
    r'0xFFF19D38',
    r'0xFFF97316',
    r'0xFFEA580C',
    r'0xFFC2410C',
    r'0xFFFF6B00',
    r'0xFFFF8A5C',
    r'primaryOrange',
    r'themeColor1', # sometimes used as orange in the other app, let's include if it's an orange gradient
]

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = ""
    idx = 0
    while True:
        pos = content.find('LinearGradient', idx)
        if pos == -1:
            new_content += content[idx:]
            break
            
        new_content += content[idx:pos]
        
        paren_start = content.find('(', pos)
        if paren_start == -1:
            new_content += content[pos:pos+14]
            idx = pos + 14
            continue
            
        paren_count = 0
        paren_end = -1
        for i in range(paren_start, len(content)):
            if content[i] == '(':
                paren_count += 1
            elif content[i] == ')':
                paren_count -= 1
                if paren_count == 0:
                    paren_end = i
                    break
                    
        if paren_end != -1:
            gradient_content = content[pos:paren_end+1]
            is_orange = False
            for p in orange_patterns:
                if re.search(p, gradient_content):
                    is_orange = True
                    break
            
            if is_orange:
                # Replace with the new gradient
                replacement = '''LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        )'''
                new_content += replacement
                idx = paren_end + 1
            else:
                new_content += content[pos:paren_end+1]
                idx = paren_end + 1
        else:
            new_content += content[pos:pos+14]
            idx = pos + 14

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
