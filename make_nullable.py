import re

with open('db_structure.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# Patterns to make nullable
patterns = [
    # Change NOT NULL to NULL (except for PRIMARY KEY, IDENTITY, and foreign keys)
    (r'(\w+)\s+(NVARCHAR\(\d+\)|NVARCHAR\(MAX\)|INT|DECIMAL\(\d+,\s*\d+\)|BIT|DATETIME2)\s+NOT NULL(?!\s+DEFAULT|\s+IDENTITY|\s+PRIMARY|\s+REFERENCES)', r'\1 \2 NULL'),
    
    # Add DEFAULT '' for NVARCHAR columns that don't have it
    (r'(\w+)\s+(NVARCHAR\(\d+\)|NVARCHAR\(MAX\))\s+NULL(?!.*DEFAULT)', r'\1 \2 NULL DEFAULT \'\''),
    
    # Add DEFAULT 0 for INT/DECIMAL columns that don't have it (except IDENTITY)
    (r'(\w+)\s+(INT|DECIMAL\(\d+,\s*\d+\))\s+NULL(?!.*DEFAULT|.*IDENTITY)', r'\1 \2 NULL DEFAULT 0'),
    
    # Add DEFAULT 0 for BIT columns
    (r'(\w+)\s+(BIT)\s+NULL(?!.*DEFAULT)', r'\1 \2 NULL DEFAULT 0'),
    
    # Add DEFAULT GETUTCDATE() for DATETIME2
    (r'(\w+)\s+(DATETIME2)\s+NULL(?!.*DEFAULT)', r'\1 \2 NULL DEFAULT GETUTCDATE()'),
]

for pattern, replacement in patterns:
    content = re.sub(pattern, replacement, content)

with open('db_structure.sql', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ All columns made nullable with default values")
