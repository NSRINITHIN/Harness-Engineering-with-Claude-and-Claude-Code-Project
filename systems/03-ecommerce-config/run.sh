#!/bin/bash
# System 3: E-Commerce Team Claude Code Config - Run Script
set -e

SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Configure Claude Code for a Multi-Surface Monorepo Team/04-plan-mode-and-explore-decision-doc/solution"
EVIDENCE_DIR="/voc/work/py3.13-exercises-and-project/Project-Harness Engineering with Claude and Claude Code/evidence/system-3"
WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$WORK_DIR/logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "================================"
echo "System 3: E-Commerce Config"
echo "Running tests and validation..."
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

# Validate the configuration
echo ""
echo "2. Validating Claude Code configuration..."
python -m ecommerce_team_config . 2>&1 | tee "$LOG_DIR/validator_output_$TIMESTAMP.log"
cp "$LOG_DIR/validator_output_$TIMESTAMP.log" "$EVIDENCE_DIR/validator_output_$TIMESTAMP.log"

# Collect configuration artifacts
echo ""
echo "3. Collecting configuration artifacts..."
if [ -d ".claude" ]; then
    echo "   - Copying .claude/ directory"
    cp -r ".claude" "$EVIDENCE_DIR/.claude_$TIMESTAMP/"
fi

if [ -f "CLAUDE.md" ]; then
    echo "   - Copying CLAUDE.md"
    cp "CLAUDE.md" "$EVIDENCE_DIR/CLAUDE_$TIMESTAMP.md"
fi

echo ""
echo "✓ System 3 execution complete!"
echo "Evidence collected to: $EVIDENCE_DIR"
