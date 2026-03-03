param(
    [string]$type = "patch"
)

# Bump version
python scripts/bump_version.py $type

# Get new version
$version = python -c "import yaml; print(yaml.safe_load(open('pubspec.yaml'))['version'])"

# Generate changelog
npx conventional-changelog-cli -p angular -i CHANGELOG.md -s

# Commit
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): v$version"

# Build
flutter build appbundle --release