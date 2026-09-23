#!/bin/bash

set -u

SCRIPT="$1"

if [ -z "$SCRIPT" ]; then
    echo "ERROR: Student script was not specified."
    exit 1
fi

if [ ! -f "$SCRIPT" ]; then
    echo "ERROR: Student script not found: $SCRIPT"
    exit 1
fi

# ------------------------------------------------------------
# Create a temporary mock firewall-cmd
# ------------------------------------------------------------

TEST_DIR="$(mktemp -d)"
MOCK_BIN="$TEST_DIR/bin"
STATE_DIR="$TEST_DIR/state"

mkdir -p "$MOCK_BIN"
mkdir -p "$STATE_DIR"

RUNTIME_FILE="$STATE_DIR/runtime_ports"
PERMANENT_FILE="$STATE_DIR/permanent_ports"
LOG_FILE="$STATE_DIR/commands.log"

touch "$RUNTIME_FILE"
touch "$PERMANENT_FILE"
touch "$LOG_FILE"

cat > "$MOCK_BIN/firewall-cmd" <<'EOF'
#!/bin/bash

STATE_DIR="${FIREWALL_TEST_STATE_DIR}"

RUNTIME_FILE="$STATE_DIR/runtime_ports"
PERMANENT_FILE="$STATE_DIR/permanent_ports"
LOG_FILE="$STATE_DIR/commands.log"

echo "firewall-cmd $*" >> "$LOG_FILE"

case "$1" in

    --add-port=*)
        PORT="${1#--add-port=}"

        if [ "${2:-}" = "--permanent" ]; then
            echo "$PORT" >> "$PERMANENT_FILE"
            echo "success"
        else
            echo "$PORT" >> "$RUNTIME_FILE"
            echo "success"
        fi
        ;;

    --remove-port=*)
        PORT="${1#--remove-port=}"

        grep -v "^${PORT}$" "$RUNTIME_FILE" > "$RUNTIME_FILE.tmp"
        mv "$RUNTIME_FILE.tmp" "$RUNTIME_FILE"

        echo "success"
        ;;

    --list-ports)
        sort -u "$RUNTIME_FILE"
        ;;

    --reload)
        # In this mock environment, reload is recorded but
        # does not modify the state.
        echo "success"
        ;;

    *)
        echo "Unknown firewall-cmd option: $*" >&2
        exit 1
        ;;
esac
EOF

chmod +x "$MOCK_BIN/firewall-cmd"

# ------------------------------------------------------------
# Run student program
# ------------------------------------------------------------

export FIREWALL_TEST_STATE_DIR="$STATE_DIR"
export PATH="$MOCK_BIN:$PATH"

echo "========================================"
echo "Running student firewall configuration"
echo "========================================"

bash "$SCRIPT"

STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "FAIL: Student script exited with status $STATUS"
    rm -rf "$TEST_DIR"
    exit 1
fi

# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------

contains() {
    grep -Fxq "$1" "$2"
}

count_command() {
    grep -Fc "$1" "$LOG_FILE" || true
}

# ------------------------------------------------------------
# Test 1: Port 8080 must be added
# ------------------------------------------------------------

echo
echo "Test 1: Open TCP port 8080"

if grep -Fxq "firewall-cmd --add-port=8080/tcp" "$LOG_FILE"; then
    echo "PASS"
else
    echo "FAIL: Port 8080 was not opened correctly."
    exit 1
fi

# ------------------------------------------------------------
# Test 2: Port 9000 must be added
# ------------------------------------------------------------

echo
echo "Test 2: Open TCP port 9000"

if grep -Fxq "firewall-cmd --add-port=9000/tcp" "$LOG_FILE"; then
    echo "PASS"
else
    echo "FAIL: Port 9000 was not opened correctly."
    exit 1
fi

# ------------------------------------------------------------
# Test 3: List ports
# ------------------------------------------------------------

echo
echo "Test 3: List configured ports"

if grep -Fxq "firewall-cmd --list-ports" "$LOG_FILE"; then
    echo "PASS"
else
    echo "FAIL: --list-ports was not executed."
    exit 1
fi

# ------------------------------------------------------------
# Test 4: Port 8080 must be removed
# ------------------------------------------------------------

echo
echo "Test 4: Remove TCP port 8080"

if grep -Fxq "firewall-cmd --remove-port=8080/tcp" "$LOG_FILE"; then
    echo "PASS"
else
    echo "FAIL: Port 8080 was not removed correctly."
    exit 1
fi

if contains "8080/tcp" "$RUNTIME_FILE"; then
    echo "FAIL: Port 8080 is still open."
    exit 1
fi

# ------------------------------------------------------------
# Test 5: Port 3000 must be permanently added
# ------------------------------------------------------------

echo
echo "Test 5: Permanently open TCP port 3000"

if grep -Fxq "firewall-cmd --add-port=3000/tcp --permanent" "$LOG_FILE"; then
    echo "PASS"
else
    echo "FAIL: Port 3000 was not added as a permanent rule."
    exit 1
fi

if contains "3000/tcp" "$PERMANENT_FILE"; then
    echo "Permanent rule confirmed."
else
    echo "FAIL: Port 3000 was not found in permanent configuration."
    exit 1
fi

# ------------------------------------------------------------
# Test 6: Firewall reload
# ------------------------------------------------------------

echo
echo "Test 6: Reload firewall"

if grep -Fxq "firewall-cmd --reload" "$LOG_FILE"; then
    echo "PASS"
else
    echo "FAIL: Firewall reload was not performed."
    exit 1
fi

# ------------------------------------------------------------
# Test 7: Final runtime state
# ------------------------------------------------------------

echo
echo "Test 7: Verify final runtime state"

if contains "9000/tcp" "$RUNTIME_FILE"; then
    echo "9000/tcp is open: PASS"
else
    echo "FAIL: 9000/tcp should remain open."
    exit 1
fi

if contains "8080/tcp" "$RUNTIME_FILE"; then
    echo "FAIL: 8080/tcp should not remain open."
    exit 1
else
    echo "8080/tcp is closed: PASS"
fi

echo
echo "========================================"
echo "ALL TESTS PASSED"
echo "========================================"

rm -rf "$TEST_DIR"

exit 0
