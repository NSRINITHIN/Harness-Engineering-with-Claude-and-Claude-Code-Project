#!/bin/bash
# System 1: Insurance Claims Intake Agent - Setup Script
# Stop on error
set -e

SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$WORK_DIR/logs"

echo "================================"
echo "System 1: Claims Intake Agent"
echo "================================"
echo "Path: $SYSTEM_PATH"
echo "Work Dir: $WORK_DIR"
echo ""

# Check if system exists
if [ ! -d "$SYSTEM_PATH" ]; then
    echo "ERROR: System path not found: $SYSTEM_PATH"
    exit 1
fi

# Create venv
echo "1. Creating virtual environment..."
cd "$SYSTEM_PATH"
python3 -m venv .venv --upgrade-deps 2>&1 | tee -a "$LOG_DIR/setup.log"
source .venv/bin/activate

# Install dependencies
echo "2. Installing dependencies..."
python -m pip install --upgrade pip setuptools wheel 2>&1 | tee -a "$LOG_DIR/setup.log"
pip install -e ".[dev]" 2>&1 | tee -a "$LOG_DIR/setup.log"

echo "✓ Setup complete. Ready to run tests and system."
echo ""
echo "Next steps:"
echo "  cd '$SYSTEM_PATH'"
echo "  source .venv/bin/activate"
echo "  pytest tests/ -v"
echo "  python -m claims_intake.run --all"
