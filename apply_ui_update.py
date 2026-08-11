import os
import re

filepath = 'lib/home_screen_content.dart'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Replace all orange colors with the new purple
oranges = [
    r'Color\(0xFFF97316\)',
    r'Color\(0xFFEA580C\)',
    r'Color\(0xFFC2410C\)',
    r'Color\(0xFFFF6B00\)',
    r'theme_color1',
    r'theme_color2',
    r'gbnew_theme'
]
for orange in oranges:
    content = re.sub(orange, 'Color(0xFFA773F7)', content)

# 2. Make the cards and specific containers dark translucent instead of white
# E.g. Container( decoration: BoxDecoration( color: Colors.white,
content = content.replace("color: Colors.white,", "color: Colors.black.withOpacity(0.3),")

# However, some text might become invisible. We need to replace black text with white text in the file.
content = content.replace("color: Colors.black,", "color: Colors.white,")
content = content.replace("color: Colors.black87,", "color: Colors.white,")
content = content.replace("color: Color(0xFF111827),", "color: Colors.white,") # dark grey
content = content.replace("color: Color(0xFF4B5563),", "color: Colors.white70,") # grey
content = content.replace("color: Color(0xFF6B7280),", "color: Colors.white60,")
content = content.replace("color: Color(0xFF9CA3AF),", "color: Colors.white54,")
content = content.replace("color: Color(0xFF374151),", "color: Colors.white,")

# 3. For the toggle bar (_buildSegmentedControlItem), since the active background is now black with opacity,
# active text color should be white, not purple if it's on purple, but wait:
# The active container color was `isSelected ? Colors.white : Colors.transparent`.
# Since we replaced `Colors.white,` with `Colors.black.withOpacity(0.3),` it actually missed `Colors.white` (no comma).
# Let's manually fix the toggle bar active background:
content = content.replace("color: isSelected ? Colors.white : Colors.transparent,", "color: isSelected ? Color(0xFFA773F7) : Colors.transparent,")
# The text color for toggle bar:
content = content.replace("color: isSelected ? Color(0xFFA773F7) : Colors.white,", "color: isSelected ? Colors.white : Colors.white70,")

# 4. Search bar background. The search bar is inside a TextField.
content = content.replace("fillColor: Colors.white,", "fillColor: Colors.black.withOpacity(0.4),")
content = content.replace("color: Colors.black.withOpacity(0.3),\n                                        borderRadius: BorderRadius.circular(16),", "color: Colors.transparent,\n                                        borderRadius: BorderRadius.circular(16),")

# 5. Badges and chips
content = content.replace("backgroundColor: Colors.black.withOpacity(0.3),\n                                            shape: RoundedRectangleBorder", "backgroundColor: Color(0xFFA773F7),\n                                            shape: RoundedRectangleBorder")

with open(filepath, 'w') as f:
    f.write(content)
print("Updated home_screen_content.dart")
