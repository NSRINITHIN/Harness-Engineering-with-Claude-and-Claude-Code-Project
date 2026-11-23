#!/bin/bash
# System 4: Multi-Shift Quality Monitoring - Run Script
set -e

SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Build a Multi-Shift Quality Monitoring System with Claude Orchestration/04-fork-scratchpad/solution"
EVIDENCE_DIR="/voc/work/py3.13-exercises-and-project/Project-Harness Engineering with Claude and Claude Code/evidence/system-4"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$WORK_DIR/logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "================================"
echo "System 4: Multi-Shift Monitoring"
echo "Running tests and shift monitoring..."
echo "================================"
echo ""

cd "$SYSTEM_PATH"

# Check if venv exists
if [ ! -d ".venv" ]; then
    echo "ERROR: Virtual environment not found. Run setup.sh first."
    exit 1
fi

source .venv/bin/activate

# Run tests
echo "1. Running test suite..."
pytest tests/ -v 2>&1 | tee "$LOG_DIR/test_output_$TIMESTAMP.log"
cp "$LOG_DIR/test_output_$TIMESTAMP.log" "$EVIDENCE_DIR/test_output_$TIMESTAMP.log"

# Initialize warm database if needed
echo ""
echo "2. Checking warm database..."
if [ ! -f "data/warm.sqlite" ]; then
    echo "   - Initializing warm database..."
    python -c "import json; from pathlib import Path; from shift_monitor.warm import WarmStore; \
w=WarmStore(Path('data/warm.sqlite')); w.initialize(); \
w.insert_many(json.load(open('fixtures/defects.json')))" 2>&1 | tee -a "$LOG_DIR/warm_init_$TIMESTAMP.log"
else
    echo "   - Warm database already initialized"
fi

# Run a shift with recorded response (no API spend)
echo ""
echo "3. Running shift monitoring..."
python -m shift_monitor run-shift --shift C --warm-db data/warm.sqlite \
  --recorded-response fixtures/recorded_responses/shift_C_2026-04-30.json 2>&1 | tee "$LOG_DIR/run_output_$TIMESTAMP.log"
cp "$LOG_DIR/run_output_$TIMESTAMP.log" "$EVIDENCE_DIR/run_output_$TIMESTAMP.log"

# Collect state artifacts
echo ""
echo "4. Collecting state artifacts..."
if [ -f "data/hot_state.json" ]; then
    echo "   - Copying hot_state.json"
    cp "data/hot_state.json" "$EVIDENCE_DIR/hot_state_$TIMESTAMP.json"

    # Check file size
    size=$(wc -c < "data/hot_state.json")
    echo "   - Hot state size: $size bytes (should be < 5KB)"
    echo "$size bytes" > "$EVIDENCE_DIR/hot_state_size_$TIMESTAMP.txt"
fi

if [ -f "data/shift_scratchpad.jsonl" ]; then
    echo "   - Copying shift_scratchpad.jsonl"
    cp "data/shift_scratchpad.jsonl" "$EVIDENCE_DIR/shift_scratchpad_$TIMESTAMP.jsonl"
fi

echo ""
echo "✓ System 4 execution complete!"
echo "Evidence collected to: $EVIDENCE_DIR"
