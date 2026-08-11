import os
import re

lib_dir = 'lib'

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # We want to replace any LinearGradient that uses theme_color1, theme_color2, primaryOrange, gbnew_theme
    # or hardcoded orange hex colors with the new gradient.
    
    # To be safe and simple, we can replace the entire LinearGradient(...) block
    # if it contains the orange colors.
    
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
            if re.search(r'(theme_color1|theme_color2|gbnew_theme|0xFFD55C26|0xFFF19D38)', gradient_content):
                # Replace with the new gradient
                replacement = '''LinearGradient(
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

