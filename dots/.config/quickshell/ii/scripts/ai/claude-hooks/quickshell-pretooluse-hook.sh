#!/usr/bin/env bash
# QuickShell PreToolUse Hook for Claude Code
# File-based IPC between Claude CLI and QuickShell QML sidebar
set -euo pipefail

HOOK_DIR="/tmp/quickshell/claude-hooks"
PENDING_DIR="${HOOK_DIR}/pending"
RESPONSE_DIR="${HOOK_DIR}/responses"
TIMEOUT_SECONDS=300  # 5 dakika timeout
POLL_INTERVAL=0.1    # 100ms polling

# Onay gerektiren tehlikeli araçlar
DANGEROUS_TOOLS=("Edit" "Write" "Bash" "NotebookEdit" "MultiEdit")

# Dizinleri oluştur
mkdir -p "${PENDING_DIR}" "${RESPONSE_DIR}"

# Stdin'den hook input'u oku
HOOK_INPUT=$(cat)

# Tool bilgilerini parse et
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Eğer env'den gelmediyse JSON'dan parse et
if [[ -z "$TOOL_NAME" ]]; then
    TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // .name // empty' 2>/dev/null || echo "")
fi

if [[ -z "$TOOL_INPUT" ]]; then
    TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -c '.tool_input // .input // {}' 2>/dev/null || echo "{}")
fi

# Benzersiz istek ID'si oluştur
REQUEST_ID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || date +%s%N)

# Onay gerekli mi kontrol et
requires_approval() {
    local tool="$1"
    for dangerous in "${DANGEROUS_TOOLS[@]}"; do
        if [[ "$tool" == "$dangerous" ]]; then
            return 0
        fi
    done
    return 1
}

# Güvenli araçları otomatik onayla
if ! requires_approval "$TOOL_NAME"; then
    exit 0
fi

# Timeout zamanını hesapla
TIMEOUT_AT=$(($(date +%s) + TIMEOUT_SECONDS))

# Pending istek dosyasını yaz
PENDING_FILE="${PENDING_DIR}/${REQUEST_ID}.json"
cat > "$PENDING_FILE" << EOF
{
    "id": "${REQUEST_ID}",
    "tool_name": "${TOOL_NAME}",
    "tool_input": ${TOOL_INPUT},
    "timestamp": $(date +%s),
    "timeout_at": ${TIMEOUT_AT}
}
EOF

# Response dosyasını bekle (polling)
RESPONSE_FILE="${RESPONSE_DIR}/${REQUEST_ID}.json"
ELAPSED=0
MAX_ITERATIONS=$((TIMEOUT_SECONDS * 10))  # 100ms * 10 = 1s

for ((i=0; i<MAX_ITERATIONS; i++)); do
    if [[ -f "$RESPONSE_FILE" ]]; then
        # Response'u oku
        APPROVED=$(jq -r '.approved // false' "$RESPONSE_FILE" 2>/dev/null || echo "false")

        # Temizlik
        rm -f "$PENDING_FILE" "$RESPONSE_FILE" 2>/dev/null || true

        # Karar
        if [[ "$APPROVED" == "true" ]]; then
            exit 0  # İzin ver
        else
            exit 2  # Reddet
        fi
    fi

    sleep "$POLL_INTERVAL"
done

# Timeout - pending dosyasını temizle ve reddet
rm -f "$PENDING_FILE" 2>/dev/null || true
exit 2
