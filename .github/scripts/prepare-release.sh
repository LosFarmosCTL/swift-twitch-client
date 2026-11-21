#!/usr/bin/env bash
set -euo pipefail

# The first versioned section is the proposed release.
VERSION=$(awk '
  /^## / && $0 != "## Unreleased" {
    sub(/^## /, "")
    print
    exit
  }
' CHANGELOG.md)
export VERSION

if [[ ! "$VERSION" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  echo "Expected an X.Y.Z version heading in CHANGELOG.md" >&2
  exit 1
fi

# Never change an existing version tag.
for tag in "$VERSION" "v$VERSION"; do
  if git show-ref --verify --quiet "refs/tags/$tag"; then
    echo "$tag already exists; skipping."
    exit 0
  fi
done

notes=$(mktemp)
trap 'rm -- "$notes"' EXIT

# Extract this version's notes, stopping at the next release heading.
awk -v heading="## $VERSION" '
  $0 == heading { found = 1; next }
  found && /^## / { exit }
  found { print }
' CHANGELOG.md > "$notes"

if ! grep -q '[^[:space:]]' "$notes"; then
  echo "Release notes are empty." >&2
  exit 1
fi

# Find an existing release for this version so we can update its draft
# or leave a published release unchanged.
matches=$(gh api \
  "repos/$GITHUB_REPOSITORY/releases?per_page=100" \
  --paginate \
  --jq '.[] |
    select(.tag_name == env.VERSION or .tag_name == ("v" + env.VERSION)) |
    [.id, .draft] | @tsv')

if [[ "$matches" == *$'\n'* ]]; then
  echo "Multiple releases match $VERSION; resolve them first." >&2
  exit 1
fi

if [[ -n "$matches" ]]; then
  read -r release_id draft <<< "$matches"

  if [[ "$draft" != true ]]; then
    echo "$VERSION is already published; skipping."
    exit 0
  fi

  gh api --method PATCH \
    "repos/$GITHUB_REPOSITORY/releases/$release_id" \
    -f "target_commitish=$GITHUB_SHA" \
    -F "body=@$notes" \
    -F draft=true
else
  gh release create "$VERSION" \
    --title "swift-twitch-client $VERSION" \
    --target "$GITHUB_SHA" \
    --notes-file "$notes" \
    --draft
fi
