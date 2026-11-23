#!/bin/bash
# System 1: Insurance Claims Intake Agent - Run Script
set -e

SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution"
EVIDENCE_DIR="/voc/work/py3.13-exercises-and-project/Project-Harness Engineering with Claude and Claude Code/evidence/system-1"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$WORK_DIR/logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "================================"
echo "System 1: Claims Intake Agent"
echo "Running tests and system..."
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

# Run the system end-to-end
echo ""
echo "2. Running claims intake agent..."
python -m claims_intake.run --all 2>&1 | tee "$LOG_DIR/run_output_$TIMESTAMP.log"
cp "$LOG_DIR/run_output_$TIMESTAMP.log" "$EVIDENCE_DIR/run_output_$TIMESTAMP.log"

# Collect run artifacts
if [ -d "runs" ]; then
    latest_run=$(ls -td runs/*/ 2>/dev/null | head -1)
    if [ -n "$latest_run" ]; then
        echo "3. Collecting run artifacts from: $latest_run"
        cp -r "$latest_run" "$EVIDENCE_DIR/latest_run_$TIMESTAMP/"

        # Extract key files for reference
        if [ -f "$latest_run/summary.md" ]; then
            cp "$latest_run/summary.md" "$EVIDENCE_DIR/summary_$TIMESTAMP.md"
        fi

        # Copy first trace file as example
        trace_file=$(ls "$latest_run/traces/"*.jsonl 2>/dev/null | head -1)
        if [ -n "$trace_file" ]; then
            cp "$trace_file" "$EVIDENCE_DIR/sample_trace_$TIMESTAMP.jsonl"
        fi
    fi
fi

echo ""
echo "✓ System 1 execution complete!"
echo "Evidence collected to: $EVIDENCE_DIR"
