#!/bin/bash
# Master orchestration script - Set up and run all four systems
# This script will:
# 1. Set up all system venvs and install dependencies
# 2. Run all test suites
# 3. Execute all systems end-to-end
# 4. Collect evidence artifacts

set -e

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_LOG="$WORK_DIR/BUILD_LOG.md"

# Initialize build log
cat > "$BUILD_LOG" << 'LOGHEADER'
# Build & Execution Log

**Start time:** $(date)

## System Status

| System | Setup | Tests | Run | Evidence |
|--------|-------|-------|-----|----------|
| 1 - Claims Intake | [ ] | [ ] | [ ] | [ ] |
| 2 - Retail Context | [ ] | [ ] | [ ] | [ ] |
| 3 - E-Commerce Config | [ ] | [ ] | [ ] | [ ] |
| 4 - Shift Monitoring | [ ] | [ ] | [ ] | [ ] |

## System Details

LOGHEADER

echo "================================"
echo "Harness Engineering Capstone"
echo "Building All Four Systems"
echo "================================"
echo ""
echo "Build log: $BUILD_LOG"
echo ""

# Function to run system
run_system() {
    local system_num=$1
    local system_name=$2
    local system_dir=$3

    echo ""
    echo "================================"
    echo "System $system_num: $system_name"
    echo "================================"

    # Setup
    echo "Setting up venv and dependencies..."
    if bash "$WORK_DIR/systems/$system_dir/setup.sh"; then
        echo "✓ Setup complete"
    else
        echo "✗ Setup failed for System $system_num"
        return 1
    fi

    # Run
    echo ""
    echo "Running tests and system..."
    if bash "$WORK_DIR/systems/$system_dir/run.sh"; then
        echo "✓ System $system_num complete"
    else
        echo "✗ Execution failed for System $system_num"
        return 1
    fi

    echo ""
}

# System 1
if run_system 1 "Claims Intake Agent" "01-claims-intake"; then
    echo "✓ System 1 succeeded"
else
    echo "✗ System 1 failed"
fi

# System 2
if run_system 2 "Retail Context Strategy" "02-retail-context"; then
    echo "✓ System 2 succeeded"
else
    echo "✗ System 2 failed"
fi

# System 3
if run_system 3 "E-Commerce Config" "03-ecommerce-config"; then
    echo "✓ System 3 succeeded"
else
    echo "✗ System 3 failed"
fi

# System 4
if run_system 4 "Shift Monitoring" "04-shift-monitor"; then
    echo "✓ System 4 succeeded"
else
    echo "✗ System 4 failed"
fi

echo ""
echo "================================"
echo "Build Complete"
echo "================================"
echo ""
echo "Evidence collected to: $WORK_DIR/evidence/"
echo ""
echo "Next steps:"
echo "1. Review evidence files in evidence/ directory"
echo "2. Fill in reflection-brief-template.md with findings"
echo "3. Review Build_LOG.md for execution details"
