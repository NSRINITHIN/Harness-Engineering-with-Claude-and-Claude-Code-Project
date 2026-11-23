# Capstone Project Index

## Quick Start

1. **Setup all systems:**
   ```bash
   python3 setup_all_systems.py
   ```

2. **Review evidence:**
   - `evidence/system-1/` - Claims intake artifacts
   - `evidence/system-2/` - Context strategy artifacts
   - `evidence/system-3/` - Config validation artifacts
   - `evidence/system-4/` - Shift monitoring artifacts

3. **Fill in reflection brief:**
   - Use `reflection-brief-template.md`
   - Cite specific evidence from your runs
   - See `PROJECT_GUIDE.md` for detailed prompts

## Project Structure

| File/Folder | Purpose |
|-------------|---------|
| `README.md` | Original project description from course |
| `SETUP.md` | Setup instructions and system locations |
| `PROJECT_GUIDE.md` | **Comprehensive guide** - read this first! |
| `setup_all_systems.py` | **Automated setup** - runs all 4 systems |
| `systems/` | System venvs and execution logs |
| `evidence/` | Captured test outputs and run artifacts |
| `reflection/` | Your reflection briefs (after completion) |
| `reflection-brief-template.md` | Template to fill in |

## The Four Systems

### 1. Claims Intake Agent (Stop-reason Loops)
**Key Pattern:** Explicit loop termination via `stop_reason`

- **Location:** `../Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution/`
- **Tests:** 29 expected
- **Evidence:** Traces showing turn-by-turn stop_reason values
- **Analysis:** Loop termination logic and anti-patterns

### 2. Retail Context Strategy (Token Efficiency)
**Key Pattern:** Hierarchical context summarization

- **Location:** `../Engineer a Long-Conversation Context Strategy for a Retail Support Copilot/04-assemble-and-locate/solution/`
- **Tests:** 30 expected
- **Evidence:** budget.json showing ≥50% token reduction
- **Analysis:** What was summarized vs. preserved, control regressions

### 3. E-Commerce Claude Code Config (Configuration as Code)
**Key Pattern:** Hierarchical rules with path-scoped enforcement

- **Location:** `../Configure Claude Code for a Multi-Surface Monorepo Team/04-plan-mode-and-explore-decision-doc/solution/`
- **Tests:** 35 expected
- **Evidence:** Validator output "OK", .claude/ directory structure
- **Analysis:** Path-scoped rules vs. directory-level configs, skill context isolation

### 4. Multi-Shift Quality Monitoring (Orchestration)
**Key Pattern:** Layer 3 orchestration with hot/warm state

- **Location:** `../Build a Multi-Shift Quality Monitoring System with Claude Orchestration/04-fork-scratchpad/solution/`
- **Tests:** 33 expected
- **Evidence:** hot_state.json (<5KB), scratchpad isolation
- **Analysis:** Resume vs. fresh recovery, forked state isolation

## Total Test Coverage

- **Expected:** 29 + 30 + 35 + 33 = **127 tests**
- **All must pass** for submission

## Reflection Brief Requirements

Your analysis must:

1. **Cite specific artifacts** from your runs:
   - Run IDs and timestamps
   - File paths and line numbers
   - Token counts (System 2)
   - Test counts (all systems)
   - Decision outcomes (System 1)

2. **Explain architectural trade-offs:**
   - Deterministic logic vs. prompt guidance (with examples)
   - State design choices (hot vs. warm, file size budgets)
   - Configuration hierarchy benefits

3. **Cross-system synthesis:**
   - Identify all three layers in each system
   - Compare context strategies (Systems 2 & 4)
   - Show deterministic enforcement vs. guidance patterns

## Checklist Before Submission

- [ ] `python3 setup_all_systems.py` completes successfully
- [ ] All 127 tests pass (see `evidence/system-*/test_output*.log`)
- [ ] Evidence artifacts collected:
  - [ ] System 1: summary.md, trace file, test output
  - [ ] System 2: budget.json, context.md, eval*.jsonl, test output
  - [ ] System 3: validator output, .claude/ directory, test output
  - [ ] System 4: hot_state.json (<5KB), scratchpad, test output
- [ ] `reflection-brief-template.md` completed with:
  - [ ] Every answer cites at least one artifact
  - [ ] Cross-project synthesis covers all 3 layers
  - [ ] Trade-off analysis includes examples
  - [ ] Specific numbers cited throughout

## Key Metrics to Track

| System | Key Metric | Expected | Your Result |
|--------|-----------|----------|------------|
| 1 | Tests passed | 29 | [ ] |
| 1 | Loop termination | stop_reason → end_turn | [ ] |
| 2 | Tests passed | 30 | [ ] |
| 2 | Token reduction | ≥50% | [ ] |
| 2 | Eval pass rate | ≥5/6 | [ ] |
| 2 | Control regression | ≥1 question fails | [ ] |
| 3 | Tests passed | 35 | [ ] |
| 3 | Validator result | OK (exit 0) | [ ] |
| 4 | Tests passed | 33 | [ ] |
| 4 | Hot state size | <5KB | [ ] |

## Next Steps

1. **Read** `PROJECT_GUIDE.md` for detailed system descriptions
2. **Run** `python3 setup_all_systems.py` to set up all systems
3. **Review** evidence artifacts as they're collected
4. **Analyze** the evidence using the reflection brief template
5. **Write** your reflection brief with cited evidence

---

**Questions?** See troubleshooting in `PROJECT_GUIDE.md` or the README.
