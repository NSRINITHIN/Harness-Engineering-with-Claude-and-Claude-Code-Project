#!/bin/bash
# System 4: Multi-Shift Quality Monitoring - Setup Script
set -e

SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Build a Multi-Shift Quality Monitoring System with Claude Orchestration/04-fork-scratchpad/solution"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$WORK_DIR/logs"

echo "================================"
echo "System 4: Multi-Shift Monitoring"
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
echo ""
echo "To initialize the warm database (required once):"
echo "  python -c \"import json; from pathlib import Path; from shift_monitor.warm import WarmStore; \\"
echo "  w=WarmStore(Path('data/warm.sqlite')); w.initialize(); \\"
echo "  w.insert_many(json.load(open('fixtures/defects.json')))\""
echo ""
echo "Then run a shift:"
echo "  python -m shift_monitor run-shift --shift C --warm-db data/warm.sqlite \\"
echo "    --recorded-response fixtures/recorded_responses/shift_C_2026-04-30.json"
