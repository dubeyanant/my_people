import re
import sys

version_type = sys.argv[1] if len(sys.argv) > 1 else 'patch'

with open('pubspec.yaml', 'r') as f:
    content = f.read()

# Extract current version
match = re.search(r'version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)', content)
if not match:
    print("Could not find version in pubspec.yaml")
    sys.exit(1)

major, minor, patch, build = map(int, match.groups())

if version_type == 'major':
    major += 1; minor = patch = 0
elif version_type == 'minor':
    minor += 1; patch = 0
else:
    patch += 1

build += 1

new_version = f"{major}.{minor}.{patch}+{build}"
content = re.sub(r'version:\s+\d+\.\d+\.\d+\+\d+', f'version: {new_version}', content)

with open('pubspec.yaml', 'w') as f:
    f.write(content)

print(f"Version bumped to {new_version}")