#!/usr/bin/env bash
# Build public symbol graphs and compile the repository's DocC catalog.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

archive_path="${1:-$repo_root/.build/documentation/Twitch.doccarchive}"
# Empty for a local archive; /swift-twitch-client for docs.chatless.app.
hosting_base_path="${2:-}"
# SwiftPM reports the graph location, including custom build-path configuration.
graph_output="$(swift package dump-symbol-graph --skip-synthesized-members)"
printf '%s\n' "$graph_output"
graph_directory="${graph_output##*Files written to }"
if [[ ! -f "$graph_directory/Twitch.symbols.json" ]]; then
  printf 'Could not locate Twitch.symbols.json in SwiftPM output.\n' >&2
  exit 1
fi

if command -v xcrun >/dev/null 2>&1; then
  docc_command=(xcrun docc)
else
  docc_command=(docc)
fi

mkdir -p "$(dirname "$archive_path")"

"${docc_command[@]}" convert Sources/Twitch/Twitch.docc \
  --additional-symbol-graph-dir "$graph_directory" \
  --output-path "$archive_path" \
  --fallback-display-name Twitch \
  --fallback-bundle-identifier com.swift-twitch-client.Twitch \
  --transform-for-static-hosting \
  --hosting-base-path "$hosting_base_path" \
  --analyze \
  --warnings-as-errors

# DocC serves the API reference at documentation/twitch/index.html. Write an
# entry page so /swift-twitch-client/ redirects to that reference automatically.
# The relative target also works when the archive is hosted at the domain root.
cat > "$archive_path/index.html" <<'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="refresh" content="0; url=./documentation/twitch/">
    <title>Twitch documentation</title>
  </head>
  <body><a href="./documentation/twitch/">Open Twitch documentation</a></body>
</html>
HTML

printf 'Documentation archive: %s\n' "$archive_path"
