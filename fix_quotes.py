import re

with open('db_structure.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace \' with '
content = content.replace("\\'", "'")

with open('db_structure.sql', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Fixed escaped quotes")
