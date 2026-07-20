#!/usr/bin/env bash
set -euo pipefail

# The paths for these scripts will need to be changed as per.

PROJECTS_JSON="/home/tony/Desktop/Projects/Project.json"
SIGNING_SCRIPT="/home/tony/Desktop/Projects/SignWork.sh" 

log() {
echo "[$(date -u +%FT%TZ)] [ABSTRACTION] $*"
}

usage() {
echo "Usage: $0 <project_id> <input_file> [output_file]"
exit 1
}

if [ "$#" -lt 2 ]; then
usage
fi

PROJECT_ID="$1"
INPUT_FILE="$2"
OUTPUT_FILE="${3:-signed-$(basename "$INPUT_FILE")}"

[ -f "$INPUT_FILE" ] || {
echo "Input file not found: $INPUT_FILE"
exit 1
}

jq empty "$PROJECTS_JSON" >/dev/null

PROJECT_JSON=$(jq -r --arg p "$PROJECT_ID" '.[$p]' "$PROJECTS_JSON")

if [ "$PROJECT_JSON" = "null" ]; then
echo "Unknown project: $PROJECT_ID"
exit 1
fi

LOGICAL_KEY_ID=$(echo "$PROJECT_JSON" | jq -r '.logical_key_id')
# ALGORITHM=$(echo "$PROJECT_JSON" | jq -r '.algorithm') These have been commented out for now but may be required in the future.
FORMAT=$(echo "$PROJECT_JSON" | jq -r '.format')

log "Project: $PROJECT_ID"
log "Logical Key: $LOGICAL_KEY_ID"
# log "Algorithm: $ALGORITHM" These have been commented out for now but may be required in the future.
log "Format: $FORMAT"

"$SIGNING_SCRIPT" "$PROJECT_ID" "$LOGICAL_KEY_ID" "$INPUT_FILE" "$OUTPUT_FILE"
