#!/bin/bash

set -u

STUDENT_SCRIPT="starter/firewall_config.sh"
TEST_SCRIPT="tests/test_firewall.sh"

echo "=========================================="
echo "Port-Based Firewall Configuration"
echo "Automated Grading"
echo "=========================================="

# Check student file
if [ ! -f "$STUDENT_SCRIPT" ]; then
    echo "ERROR: $STUDENT_SCRIPT not found."
    exit 1
fi

# Check test file
if [ ! -f "$TEST_SCRIPT" ]; then
    echo "ERROR: Test file not found."
    exit 1
fi

# Check Bash syntax
echo
echo "Checking Bash syntax..."

if bash -n "$STUDENT_SCRIPT"; then
    echo "Syntax check: PASS"
else
    echo "Syntax check: FAIL"
    exit 1
fi

# Run tests
echo
echo "Running automated tests..."
echo

bash "$TEST_SCRIPT" "$STUDENT_SCRIPT"

RESULT=$?

echo

if [ $RESULT -eq 0 ]; then
    echo "=========================================="
    echo "FINAL RESULT: PASS"
    echo "=========================================="
    exit 0
else
    echo "=========================================="
    echo "FINAL RESULT: FAIL"
    echo "=========================================="
    exit 1
fi
