#\!/usr/bin/env bash
# check-cpp20.sh - Check for C++20 features (we require C++17)
#
# Usage: ./check-cpp20.sh
#
# Output: JSON to stdout, exit code indicates success/failure

set -euo pipefail

# C++20 features to check for
CPP20_FEATURES=(
  "std::span"
  "std::ranges"
  "concept "
  "requires "
  "co_await"
  "co_return"
  "co_yield"
  "std::format"
  "std::jthread"
  "std::source_location"
)

# Repos to check (relative to parent directory)
REPOS=(
  "librssconnect"
  "gatekeeper"
  "audit"
)

# Find parent directory (where clients-tools and repos are siblings)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

violations=()
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
  
  # Find all C++ source files
  while IFS= read -r file; do
    ((files_checked++))
    
    # Check for each C++20 feature
    for feature in "${CPP20_FEATURES[@]}"; do
      while IFS=: read -r line_num line_content; do
        # Escape quotes in JSON
        escaped_content=$(echo "$line_content" | sed 's/"/\\"/g')
        escaped_file=$(echo "$file" | sed "s|$PARENT_DIR/||")
        
        violations+=("{\"file\":\"$escaped_file\",\"line\":$line_num,\"feature\":\"$feature\",\"content\":\"$escaped_content\"}")
      done < <(grep -n "$feature" "$file" 2>/dev/null || true)
    done
  done < <(find "$repo_path/src" "$repo_path/include" -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) 2>/dev/null || true)
done

# Determine status
if [[ ${#violations[@]} -eq 0 ]]; then
  status="success"
  exit_code=0
else
  status="error"
  exit_code=1
fi

# Build repos_checked JSON array
repos_json=$(printf ',"%s"' "${repos_checked[@]}")
repos_json="[${repos_json:1}]"

# Build violations JSON array
if [[ ${#violations[@]} -eq 0 ]]; then
  violations_json="[]"
else
  violations_json="[$(IFS=,; echo "${violations[*]}")]"
fi

# Output JSON
cat << EOJSON
{
  "status": "$status",
  "summary": "Checked $files_checked files across ${#repos_checked[@]} repos, found ${#violations[@]} C++20 violations",
  "details": {
    "files_checked": $files_checked,
    "repos_checked": $repos_json,
    "violations_count": ${#violations[@]}
  },
  "violations": $violations_json
}
EOJSON

exit $exit_code
