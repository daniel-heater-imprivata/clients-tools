#\!/usr/bin/env bash
# find-todos.sh - Find all TODO/FIXME/HACK comments across repos
#
# Usage: ./find-todos.sh
#
# Output: JSON to stdout, exit code indicates success/failure

set -euo pipefail

# Comment markers to search for
MARKERS=(
  "TODO"
  "FIXME"
  "HACK"
  "XXX"
  "NOTE"
)

# Repos to check (relative to parent directory)
REPOS=(
  "librssconnect"
  "gatekeeper"
  "audit"
)

# Find parent directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

items=()
files_checked=0
repos_checked=()

# Check each repo
for repo in "${REPOS[@]}"; do
  repo_path="$PARENT_DIR/$repo"
  
  # Skip if repo doesn't exist
  if [[ \! -d "$repo_path" ]]; then
    continue
  fi
  
  repos_checked+=("$repo")
  
  # Find all source files
  while IFS= read -r file; do
    ((files_checked++))
    
    # Check for each marker
    for marker in "${MARKERS[@]}"; do
      while IFS=: read -r line_num line_content; do
        # Extract comment text after marker
        comment=$(echo "$line_content" | sed -n "s/.*$marker[: ]*\(.*\)/\1/p" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        # Escape quotes in JSON
        escaped_comment=$(echo "$comment" | sed 's/"/\\"/g' | sed "s/'/\\'/g")
        escaped_file=$(echo "$file" | sed "s|$PARENT_DIR/||")
        
        items+=("{\"file\":\"$escaped_file\",\"line\":$line_num,\"marker\":\"$marker\",\"comment\":\"$escaped_comment\"}")
      done < <(grep -n "\b$marker\b" "$file" 2>/dev/null || true)
    done
  done < <(find "$repo_path" -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.c" -o -name "*.sh" -o -name "*.py" -o -name "*.zig" \) 2>/dev/null || true)
done

# Determine status (warnings, not errors)
if [[ ${#items[@]} -eq 0 ]]; then
  status="success"
  exit_code=0
else
  status="warning"
  exit_code=2
fi

# Build repos_checked JSON array
repos_json=$(printf ',"%s"' "${repos_checked[@]}")
repos_json="[${repos_json:1}]"

# Build items JSON array
if [[ ${#items[@]} -eq 0 ]]; then
  items_json="[]"
else
  items_json="[$(IFS=,; echo "${items[*]}")]"
fi

# Output JSON
cat << EOJSON
{
  "status": "$status",
  "summary": "Found ${#items[@]} TODO/FIXME/HACK comments across ${#repos_checked[@]} repos",
  "details": {
    "files_checked": $files_checked,
    "repos_checked": $repos_json,
    "items_count": ${#items[@]}
  },
  "items": $items_json
}
EOJSON

exit $exit_code
