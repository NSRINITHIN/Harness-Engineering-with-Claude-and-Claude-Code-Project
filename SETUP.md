# Project Setup & Execution Guide

This capstone project builds, runs, and verifies four interconnected systems from the Harness Engineering course.

## Project Structure

```
.
├── systems/                    # Setup and state for each system
│   ├── 01-claims-intake/      # System 1: Stop-reason agentic loop
│   ├── 02-retail-context/     # System 2: Context strategy
│   ├── 03-ecommerce-config/   # System 3: Claude Code configuration
│   └── 04-shift-monitor/      # System 4: Orchestration with state mgmt
├── evidence/                   # Captured test outputs & run artifacts
│   ├── system-1/
│   ├── system-2/
│   ├── system-3/
│   └── system-4/
├── reflection/                 # Reflection briefs
├── SETUP.md                    # This file
└── BUILD_LOG.md               # Execution log
```

## System Locations

All four systems are reference implementations from the course repo:

| # | System | Location |
|---|--------|----------|
| 1 | Claims Intake Agent | `Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution` |
| 2 | Retail Context Strategy | `Engineer a Long-Conversation Context Strategy for a Retail Support Copilot/04-assemble-and-locate/solution` |
| 3 | E-Commerce Claude Code Config | `Configure Claude Code for a Multi-Surface Monorepo Team/04-plan-mode-and-explore-decision-doc/solution` |
| 4 | Multi-Shift Quality Monitoring | `Build a Multi-Shift Quality Monitoring System with Claude Orchestration/04-fork-scratchpad/solution` |

## Quick Start

### Prerequisites
- Python 3.10+
- `ANTHROPIC_API_KEY` exported (for Systems 1, 2, 4)
- git and bash

### Run All Systems

```bash
# From project root
bash build-all-systems.sh
```

This will:
1. Set up each system's venv
2. Install dependencies
3. Run test suites
4. Execute end-to-end runs
5. Collect artifacts to `evidence/`

### Run Individual System

```bash
# System 1: Claims Intake
bash systems/01-claims-intake/setup.sh && bash systems/01-claims-intake/run.sh

# System 2: Retail Context
bash systems/02-retail-context/setup.sh && bash systems/02-retail-context/run.sh

# System 3: E-Commerce Config
bash systems/03-ecommerce-config/setup.sh && bash systems/03-ecommerce-config/run.sh

# System 4: Shift Monitoring
bash systems/04-shift-monitor/setup.sh && bash systems/04-shift-monitor/run.sh
```

## Evidence Collection

Each system produces artifacts that must be captured:

**System 1 (Claims Intake):**
- Test output: `pytest tests/ -v`
- Run artifact: `runs/<timestamp>/summary.md`
- Trace file: `runs/<timestamp>/traces/<claim_id>.jsonl`

**System 2 (Retail Context):**
- Test output: `pytest tests/ -v`
- Context assembly: `runs/<run_id>/context.md`
- Budget report: `runs/<run_id>/budget.json`
- Eval results: `runs/<run_id>/eval.jsonl` and `eval_control.jsonl`

**System 3 (E-Commerce Config):**
- Test output: `pytest tests/ -v`
- Validator output: `python -m ecommerce_team_config .`
- Configuration files: `.claude/` directory structure

**System 4 (Shift Monitoring):**
- Test output: `pytest tests/ -v`
- Shift output: stdout/stderr log
- State file: `data/hot_state.json` (must stay <5KB)
- Scratchpad: `data/shift_scratchpad.jsonl`

## Reflection Brief

Fill in `reflection-brief-template.md` with:
- Evidence-grounded analysis of each system
- Cross-project synthesis of the three layers
- Trade-off explanations with specific artifacts
- Comparisons between deterministic and prompt-based guidance

Every answer must cite specific numbers, file paths, test counts, or outcomes from your runs.
