#!/usr/bin/env bash
set -euo pipefail

KEYS_JSON="/home/tony/Desktop/Projects/keys.json"
PKCS11_MODULE="/usr/lib64/pkcs11/libsofthsm2.so"
# KEYS_JSON="/opt/signing/keys.json"
# PKCS11_MODULE="/usr/safenet/lunaclient/lib/libCryptoki2.so"

##############################################################################
# Load HSM Credentials
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIAL_FILE="${SCRIPT_DIR}/HSM-Credential.conf"

if [[ ! -f "$CREDENTIAL_FILE" ]]; then
    echo "ERROR: HSM credential file not found:"
    echo "       $CREDENTIAL_FILE"
    exit 1
fi

# Load credentials
source "$CREDENTIAL_FILE"

log() {
echo "[$(date -u +%FT%TZ)] [SIGNER] $*"
}

cleanup() {
rm -f "${DIGEST_FILE:-}" "${SIG_FILE:-}"
}

trap cleanup EXIT


if [ "$#" -ne 4 ]; then
echo "Usage: $0 <project_id> <logical_key_id> <input_file> <output_file>"
exit 1
fi

PROJECT_ID="$1"
LOGICAL_KEY_ID="$2"
INPUT_FILE="$3"
OUTPUT_FILE="$4"

jq empty "$KEYS_JSON" >/dev/null

KEY_JSON=$(jq -r --arg k "$LOGICAL_KEY_ID" '.[$k]' "$KEYS_JSON")

if [ "$KEY_JSON" = "null" ]; then
echo "Unknown logical key: $LOGICAL_KEY_ID"
exit 1
fi

PARTITION_LABEL=$(echo "$KEY_JSON" | jq -r '.partition_label')
KEY_LABEL=$(echo "$KEY_JSON" | jq -r '.key_label')
ALGORITHM=$(echo "$KEY_JSON" | jq -r '.algorithm')
USAGE=$(echo "$KEY_JSON" | jq -r '.usage[]')

if ! echo "$USAGE" | grep -q sign; then
echo "Key not authorised for signing"
exit 1
fi

case "$ALGORITHM" in
RSA_3072_SHA256)
MECHANISM="SHA256-RSA-PKCS"
;;
ECDSA_P256_SHA256)
MECHANISM="ECDSA"
;;
*)
echo "Unsupported algorithm: $ALGORITHM"
exit 1
;;
esac

log "Project: $PROJECT_ID"
log "Logical Key: $LOGICAL_KEY_ID"
log "Partition: $PARTITION_LABEL"

DIGEST_FILE=$(mktemp)
SIG_FILE=$(mktemp)

openssl dgst -sha256 -binary "$INPUT_FILE" > "$DIGEST_FILE"

PKCS11_CMD=(
pkcs11-tool
--module "$PKCS11_MODULE"
--token-label "$PARTITION_LABEL"
--sign
--mechanism "$MECHANISM"
--label "$KEY_LABEL"
--input-file "$DIGEST_FILE"
--output-file "$SIG_FILE"
)

if [ -n "${HSM_PIN:-}" ]; then
PKCS11_CMD+=(--login --pin "$HSM_PIN")
fi

log "Submitting signing request to HSM"

"${PKCS11_CMD[@]}"

cp "$INPUT_FILE" "$OUTPUT_FILE"
cp "$SIG_FILE" "${OUTPUT_FILE}.sig"

log "Signing completed"
