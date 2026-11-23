#!/bin/bash
# System 2: Retail Support Context Strategy - Run Script
set -e

SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Engineer a Long-Conversation Context Strategy for a Retail Support Copilot/04-assemble-and-locate/solution"
EVIDENCE_DIR="/voc/work/py3.13-exercises-and-project/Project-Harness Engineering with Claude and Claude Code/evidence/system-2"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$WORK_DIR/logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "================================"
echo "System 2: Retail Context Strategy"
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
echo "2. Running context strategy..."
python -m retail_context.run --all 2>&1 | tee "$LOG_DIR/run_output_$TIMESTAMP.log"
cp "$LOG_DIR/run_output_$TIMESTAMP.log" "$EVIDENCE_DIR/run_output_$TIMESTAMP.log"

# Collect run artifacts
if [ -d "runs" ]; then
    latest_run=$(ls -td runs/*/ 2>/dev/null | head -1)
    if [ -n "$latest_run" ]; then
        echo "3. Collecting run artifacts from: $latest_run"
        cp -r "$latest_run" "$EVIDENCE_DIR/latest_run_$TIMESTAMP/"

        # Extract key files for reference
        if [ -f "$latest_run/budget.json" ]; then
            cp "$latest_run/budget.json" "$EVIDENCE_DIR/budget_$TIMESTAMP.json"
        fi

        if [ -f "$latest_run/context.md" ]; then
            cp "$latest_run/context.md" "$EVIDENCE_DIR/context_$TIMESTAMP.md"
        fi

        if [ -f "$latest_run/eval.jsonl" ]; then
            cp "$latest_run/eval.jsonl" "$EVIDENCE_DIR/eval_$TIMESTAMP.jsonl"
        fi

        if [ -f "$latest_run/eval_control.jsonl" ]; then
            cp "$latest_run/eval_control.jsonl" "$EVIDENCE_DIR/eval_control_$TIMESTAMP.jsonl"
        fi
    fi
fi

echo ""
echo "✓ System 2 execution complete!"
echo "Evidence collected to: $EVIDENCE_DIR"
