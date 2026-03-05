param(
    [string]$type = "patch"
)

# Bump version
python scripts/bump_version.py $type

# Get new version
$version = python -c "import yaml; print(yaml.safe_load(open('pubspec.yaml'))['version'])"

# Tag version
git add pubspec.yaml
git commit -m "chore(release): v$version"
git tag "v$version"

# Generate changelog
npx conventional-changelog-cli -p angular -i CHANGELOG.md -s

# Amend
git add CHANGELOG.md
git commit --amend --no-edit

# Build
flutter build appbundle --release