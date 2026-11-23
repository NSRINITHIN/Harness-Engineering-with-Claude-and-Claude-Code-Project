# Harness Engineering Capstone - Project Guide

This document provides a comprehensive guide to the capstone project, its structure, and execution.

## Project Overview

This is an integrative capstone project for the **Harness Engineering** course. Rather than implementing new systems from scratch, this project **builds, runs, and verifies four reference implementations** from the course, then analyzes the architectural decisions through evidence-grounded reflection.

The four systems demonstrate distinct architectural patterns:

1. **Stop-reason-driven agentic loops** - structured decision-making with explicit termination conditions
2. **Context-efficient state management** - token optimization in long conversations
3. **Configuration as code** - harness specification and hierarchical rules
4. **Multi-tier orchestration** - session management with hot/warm state separation

## Project Structure

```
capstone/
├── systems/                          # System setup and state
│   ├── 01-claims-intake/            # System 1 venv & logs
│   ├── 02-retail-context/           # System 2 venv & logs
│   ├── 03-ecommerce-config/         # System 3 venv & logs
│   └── 04-shift-monitor/            # System 4 venv & logs
├── evidence/                         # Captured test outputs & artifacts
│   ├── system-1/
│   ├── system-2/
│   ├── system-3/
│   └── system-4/
├── reflection/                       # Reflection briefs
├── setup_all_systems.py             # Master setup script
├── SETUP.md                         # Setup instructions
├── PROJECT_GUIDE.md                 # This file
└── BUILD_LOG.md                     # Execution log
```

## System Details

### System 1: Insurance Claims Intake Agent
**Location:** Build a Claims Intake Agent with a stop_reason-Driven Loop → exercises/03-dynamic-decomposition/solution

**What it does:** Processes insurance claims through a stop_reason-driven agentic loop. Each claim flows through tool-using turns until termination (either routed to a queue or escalated).

**Key architectural pattern:** Explicit loop termination via `stop_reason`
- Continues on `tool_use`
- Terminates on `end_turn`
- Tests verify loop behavior and routing decisions

**Evidence to capture:**
- pytest output (expect 29 passed)
- `runs/<timestamp>/summary.md` - routing outcomes
- `runs/<timestamp>/traces/<claim_id>.jsonl` - turn-by-turn execution trace
- Escalations and routed queues

**Run command:** `python -m claims_intake.run --all`

---

### System 2: Retail Support Context Strategy
**Location:** Engineer a Long-Conversation Context Strategy for a Retail Support Copilot → 04-assemble-and-locate/solution

**What it does:** Implements token-efficient context assembly for a long retail support conversation. Assembles context from raw conversation history, achieving ≥50% token reduction while preserving answerability.

**Key architectural pattern:** Hierarchical context summarization
- Summarizes repetitive sections
- Preserves critical facts verbatim
- Tracks token budget across iterations

**Evidence to capture:**
- pytest output (expect 30 passed)
- `runs/<run_id>/budget.json` - token accounting
- `runs/<run_id>/context.md` - assembled context
- `runs/<run_id>/eval.jsonl` and `eval_control.jsonl` - evaluation results with/without case facts

**Run command:** `python -m retail_context.run --all`

---

### System 3: E-Commerce Team Claude Code Config
**Location:** Configure Claude Code for a Multi-Surface Monorepo Team → 04-plan-mode-and-explore-decision-doc/solution

**What it does:** Specifies Claude Code configuration with hierarchy, path-scoped rules, project commands, and skills. Validates that the configuration conforms to the specification.

**Key architectural pattern:** Configuration-as-code with governance
- Main CLAUDE.md imports modular standards via `@path/references`
- Path-scoped rules apply glob patterns to enforce conventions
- Skills declare execution context and allowed tools
- Validator checks structure

**Evidence to capture:**
- pytest output (expect 35 passed)
- Validator output (must print "OK", exit 0)
- `.claude/` directory structure (rules, commands, skills)
- CLAUDE.md showing imports

**Run command:** `python -m ecommerce_team_config .`

---

### System 4: Multi-Shift Quality Monitoring
**Location:** Build a Multi-Shift Quality Monitoring System with Claude Orchestration → 04-fork-scratchpad/solution

**What it does:** Monitors quality across shifts using Claude orchestration with layered state management. Maintains a hot state file (<5KB) for real-time decisions and a warm tier for historical context. Demonstrates state isolation when forking investigations.

**Key architectural pattern:** Layer 3 orchestration with hot/warm state
- Hot state (data/hot_state.json) - current shift decisions, kept under 5KB
- Warm tier (SQLite) - full defect history, indexed for filtering
- Session forking - isolated scratchpad per investigation hypothesis
- Resume vs. fresh recovery decisions

**Evidence to capture:**
- pytest output (expect 33 passed)
- Shift execution output
- `data/hot_state.json` and its size (must be <5KB)
- `data/shift_scratchpad.jsonl` - decision log
- Warm DB state

**Run command:**
```bash
# Initialize warm tier (once)
python -c "import json; from pathlib import Path; from shift_monitor.warm import WarmStore; \
w=WarmStore(Path('data/warm.sqlite')); w.initialize(); \
w.insert_many(json.load(open('fixtures/defects.json')))"

# Run shift with recorded response (no API spend)
python -m shift_monitor run-shift --shift C --warm-db data/warm.sqlite \
  --recorded-response fixtures/recorded_responses/shift_C_2026-04-30.json
```

---

## Setup & Execution

### Automated Setup (Python)

```bash
python3 setup_all_systems.py
```

This script will:
1. Create virtual environments for each system
2. Install dependencies
3. Run test suites
4. Collect evidence to `evidence/`

### Manual Setup per System

```bash
# System N (1-4)
cd systems/0N-name/
bash setup.sh      # Creates venv, installs dependencies
bash run.sh        # Runs tests and system, collects artifacts
```

### Environment Variables

Required for Systems 1, 2, 4:
```bash
export ANTHROPIC_API_KEY="sk-..."
```

System 3 (Claude Code Config) does not require the API.

**Cost estimate:** ~$1–$5 total on Haiku/Sonnet. System 4 can run entirely offline with recorded responses.

---

## Evidence Collection

Each system produces specific artifacts that must be captured:

### System 1 Evidence

```
evidence/system-1/
├── test_output_<timestamp>.log       # pytest output
├── run_output_<timestamp>.log         # Execution log
├── summary_<timestamp>.md             # Routing decisions
├── sample_trace_<timestamp>.jsonl     # One claim's execution trace
└── latest_run_<timestamp>/            # Full runs/ directory
```

**Key metrics to extract:**
- Test count: `29 passed` (expected)
- Claim processing: 8 claims → routed or escalated
- stop_reason transitions: tool_use → end_turn

### System 2 Evidence

```
evidence/system-2/
├── test_output_<timestamp>.log       # pytest output
├── run_output_<timestamp>.log         # Execution log
├── budget_<timestamp>.json           # Token accounting
├── context_<timestamp>.md             # Assembled context
├── eval_<timestamp>.jsonl             # 6 eval questions
├── eval_control_<timestamp>.jsonl     # Control variant (no case facts)
└── latest_run_<timestamp>/            # Full runs/ directory
```

**Key metrics to extract:**
- Test count: `30 passed` (expected)
- Token reduction: ≥50% from ~47k baseline
- Eval pass rate: ≥5/6 questions
- Control regression: ≥1 question fails without case facts

### System 3 Evidence

```
evidence/system-3/
├── test_output_<timestamp>.log       # pytest output
├── validator_output_<timestamp>.log   # Validator output (must print "OK")
├── CLAUDE_<timestamp>.md              # Main configuration
└── .claude_<timestamp>/               # Configuration directory
    ├── CLAUDE.md                      # Imports modular standards
    ├── rules/                         # Path-scoped rules with glob frontmatter
    ├── commands/                      # Project commands (e.g., /review)
    └── skills/                        # Skills with context declarations
```

**Key metrics to extract:**
- Test count: `35 passed` (expected)
- Validator: `OK` message, exit code 0
- Config structure: Path-scoped rules, commands, skills present

### System 4 Evidence

```
evidence/system-4/
├── test_output_<timestamp>.log       # pytest output
├── run_output_<timestamp>.log         # Shift execution
├── hot_state_<timestamp>.json         # State file
├── hot_state_size_<timestamp>.txt     # Size in bytes (must be <5KB)
└── shift_scratchpad_<timestamp>.jsonl # Decision log
```

**Key metrics to extract:**
- Test count: `33 passed` (expected)
- Hot state size: bytes (goal: <5KB)
- Shift processing: defects analyzed and decisions recorded
- Scratchpad isolation: fork decisions don't affect main state

---

## Reflection Brief Template

Fill in `reflection-brief-template.md` with evidence-grounded analysis:

### Section 1: Stop_reason-Driven Agentic Loop

**Q: By file and function, where is loop termination decided?**
- Look at `claims_intake/agent.py` or similar, find the loop function
- Identify where stop_reason is checked
- Cite line numbers

**Q: Name one anti-pattern the loop avoids.**
- Examples: infinite loops, missed escalations, unhandled tool failures
- Explain the safeguard

### Section 2: Layer 3 Orchestration

**Q: Explain the resume-vs-fresh recovery decision and staleness threshold.**
- When does the system prefer to resume an existing session?
- What staleness threshold triggers fresh recovery?
- Cite from code or test evidence

**Q: How do forked investigations stay isolated?**
- Look at shift_monitor scratchpad handling
- Show that fork state ≠ main state
- Cite state file sizes or scratchpad entries

### Section 3: Context Strategy

**Q: Which information was summarized vs. preserved verbatim?**
- Identify summarization patterns in context assembly
- Explain why certain facts were kept verbatim
- Cite token counts from budget.json

**Q: Which question regressed in the control variant?**
- Run eval.jsonl vs. eval_control.jsonl
- Identify which question failed without case facts
- Explain why that information was critical

### Section 4: Claude Code Harness

**Q: Why is a path-scoped rule preferred over a directory-level CLAUDE.md?**
- Compare approaches
- Explain scaling and maintenance benefits

**Q: Why does the skill run in a forked context?**
- Discuss isolation and safety
- Cite the skill declaration

### Cross-Project Synthesis

**Layer identification:**
- **Model Layer:** Where does the agentic loop appear? (System 1, 4)
- **Harness Layer:** Configuration and tool setup (Systems 3, 4)
- **Orchestration Layer:** State and session management (Systems 2, 4)

**Deterministic vs. prompt-based:**
- Cite one example of deterministic enforcement (e.g., loop termination logic)
- Cite one example of prompt-based guidance (e.g., tool instructions)
- Contrast effectiveness

**Context management comparison:**
- System 2: Token budget tracking in context assembly
- System 4: Hot/warm state separation for scalability
- Cite numbers: System 2 token reduction, System 4 file sizes

---

## Submission Checklist

- [ ] All 4 systems set up and venvs created
- [ ] All pytest suites pass (29 + 30 + 35 + 33 = 127 tests total)
- [ ] Evidence collected to `evidence/` for all 4 systems
- [ ] `reflection-brief-template.md` filled in with:
  - [ ] At least one cited artifact per answer
  - [ ] File paths and line numbers where relevant
  - [ ] Token counts, test counts, run IDs
  - [ ] Cross-system comparisons with evidence
- [ ] BUILD_LOG.md documents execution

---

## Troubleshooting

### Virtual Environment Issues

**Problem:** `ensurepip` fails during venv creation

**Solution:** Create venv without pip, bootstrap manually:
```bash
python3 -m venv .venv --without-pip
curl https://bootstrap.pypa.io/get-pip.py | .venv/bin/python3
.venv/bin/pip install -e ".[dev]"
```

### API Key Issues

**Problem:** "ANTHROPIC_API_KEY not found"

**Solution:** Export API key:
```bash
export ANTHROPIC_API_KEY="sk-..."
python setup_all_systems.py
```

### Path Length Issues

Some systems have deep directory paths (spaces in folder names). If you encounter issues:
```bash
# Use variables to avoid quoting errors
SYSTEM_PATH="/voc/work/py3.13-exercises-and-project/Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution"
cd "$SYSTEM_PATH"
```

---

## References

- **Course Repo:** cd15315 Claude AI Engineer Harness Engineering
- **Cost Calculator:** Each system uses Haiku/Sonnet by default. System 4 can run offline with `--recorded-response`
- **Python Version:** 3.10+ (3.13 preferred)

---

**Last updated:** 2026-11-23
