import re

with open('lib/home_screen_content.dart', 'r') as f:
    content = f.read()

# 1. Update text colors to white for headers
content = content.replace("color: Colors.black,", "color: Colors.white,")
content = content.replace("color: Colors.black87", "color: Colors.white")
content = content.replace("color: Colors.black54", "color: Colors.white70")

# 2. Update toggle bar colors
content = content.replace("gbnew_theme", "Color(0xFFA773F7)")
content = content.replace("theme_color1", "Color(0xFFA773F7)")
content = content.replace("theme_color2", "Color(0xFFA773F7)")

# 3. Fix the Search Bar 'GO' button and styling
# Find container backgrounds that were white and make them translucent black
content = content.replace("backgroundColor: Colors.white,", "backgroundColor: Colors.black.withOpacity(0.5),")
content = content.replace("color: Colors.white,", "color: Colors.transparent,")

# Oh wait, making all Colors.white transparent will ruin text!
# Let's not do blanket replace for color: Colors.white
