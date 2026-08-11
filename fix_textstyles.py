import re
filepath = 'lib/home_screen_content.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Replace any TextStyle(...) containing color: Colors.black.withOpacity(0.3) 
# back to color: Colors.white
def replacer(match):
    return match.group(0).replace('color: Colors.black.withOpacity(0.3)', 'color: Colors.white')

content = re.sub(r'TextStyle\([^)]*color:\s*Colors\.black\.withOpacity\(0\.3\)[^)]*\)', replacer, content)

with open(filepath, 'w') as f:
    f.write(content)
print("Fixed TextStyles")
