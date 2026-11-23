# Quick Start - 5 Minute Overview

## What You're Building

A capstone project analyzing 4 reference implementations from the Harness Engineering course:

| System | Focus | Evidence | Key Metric |
|--------|-------|----------|-----------|
| 1 | Stop-reason loops | Routing decisions, traces | 29 tests |
| 2 | Context compression | Token budget | 54% reduction |
| 3 | Config as code | Hierarchy, path-scoped rules | 35 tests |
| 4 | Orchestration | Hot state, session mgmt | 3.75 KB |

**Total:** 127 tests that must all pass

## Current Status

- ✅ Project structure created
- ✅ Documentation written (SETUP.md, PROJECT_GUIDE.md, ANALYSIS_TEMPLATE.md, RUBRIC_DEEP_DIVE.md)
- 🔄 Systems being installed (System 1 ✓, System 2-4 in progress)

## Next: When Setup Completes

### Step 1: Verify Tests (5 min)
```bash
# Check all tests passed
grep "passed" evidence/*/test_output*.log

# Expected: 29 + 30 + 35 + 33 = 127 total
```

### Step 2: Understand the Evidence (15 min)
- **System 1:** Look at `evidence/system-1/sample_trace_*.jsonl` to see how claims flow through the agent
- **System 2:** Check `evidence/system-2/budget_*.json` to see token reduction math
- **System 3:** Verify `evidence/system-3/validator_output_*.log` shows "OK"
- **System 4:** Confirm `evidence/system-4/hot_state_size_*.txt` shows <5KB

### Step 3: Analyze Evidence (1-2 hours)
Use `ANALYSIS_TEMPLATE.md` to systematically extract:
- Test counts
- Token/byte metrics
- File paths and line numbers
- Cross-system patterns

### Step 4: Write Reflection Brief (2-3 hours)
Use `reflection-brief-template.md` to answer prompts with **specific citations**

Example format:
```
Q: By file and function, where is loop termination decided?

A: In claims_intake/agent.py, function process_claim(), lines 150-152:

   if response.stop_reason == "end_turn":
       return finalize_claim(claim, state)

This check ensures the loop terminates when Claude signals end_turn.
Evidence: evidence/system-1/sample_trace_20261123.jsonl shows
3 turns ending with stop_reason = "end_turn"
```

## Document Guide

| Document | Use When | Read Time |
|----------|----------|-----------|
| **INDEX.md** | First - navigate and checklist | 5 min |
| **SETUP.md** | Setting up systems | 10 min |
| **PROJECT_GUIDE.md** | Understanding each system in depth | 30 min |
| **ANALYSIS_TEMPLATE.md** | Extracting evidence systematically | Use as reference |
| **RUBRIC_DEEP_DIVE.md** | Understanding what reflection brief needs | 20 min |
| **QUICK_START.md** | This file - 5 min overview | 5 min |

## Key Directories

```
.
├── evidence/           ← Your captured test outputs & artifacts
│   ├── system-1/      ← Claims intake results
│   ├── system-2/      ← Context strategy results
│   ├── system-3/      ← Config validation results
│   └── system-4/      ← Shift monitoring results
├── systems/           ← System venvs & logs
└── reflection/        ← Your reflection brief (after completion)
```

## Critical Success Factors

1. **All 127 tests must pass** - This is binary (all or none)
2. **Every answer must cite specific evidence** - Not generic explanations
3. **Cross-system synthesis required** - Show how Model, Harness, and Orchestration layers appear across systems
4. **Specific metrics must be quoted** - Token counts, file sizes, test results

## Common Mistakes to Avoid

❌ **Generic answers:** "The loop continues until termination"
✅ **Specific answers:** "The loop checks `if response.stop_reason == 'end_turn'` at claims_intake/agent.py:151"

❌ **Missing citations:** "Token reduction is about 50%"
✅ **Cited answers:** "Token reduction: 47,250 → 21,340 (54.8%). Source: evidence/system-2/budget_20261123.json"

❌ **Single-system focus:** "System 1 uses agentic loops"
✅ **Cross-system synthesis:** "Both System 1 and System 4 use loops, but System 1 controls routing (Model layer) while System 4 controls state decisions (Orchestration layer)"

## Submission Checklist

- [ ] All 127 tests verified passing
- [ ] All evidence files captured in `evidence/system-N/`
- [ ] `reflection-brief-template.md` completed
- [ ] Every answer has ≥1 cited artifact
- [ ] File paths are correct and artifact files exist
- [ ] Cross-system patterns explained with examples
- [ ] Three architectural layers identified
- [ ] Deterministic vs. prompt-based examples provided

## Time Budget

| Task | Time |
|------|------|
| Read documentation | 1 hour |
| Wait for setup | 20-30 min |
| Extract evidence | 1 hour |
| Analyze patterns | 1-2 hours |
| Write reflection brief | 2-3 hours |
| **Total** | **~6-8 hours** |

## If Setup Fails

1. Check Python version: `python3 --version` (need 3.10+)
2. Check API key: `echo $ANTHROPIC_API_KEY`
3. Check individual system: `cd systems/01-claims-intake/ && bash setup.sh`
4. See troubleshooting in PROJECT_GUIDE.md

## Ready?

1. Wait for setup to complete (monitor `/tmp/claude/.../tasks/baaf38b.output`)
2. Run: `grep "passed" evidence/*/test_output*.log`
3. Use ANALYSIS_TEMPLATE.md to extract evidence
4. Write reflection brief citing evidence

---

**You are on the right path.** The setup is running. When complete, you'll have:
- 4 fully configured systems
- 127 passing tests
- Evidence artifacts ready for analysis

Then you systematically extract evidence, analyze patterns, and write the reflection brief with citations.

**Estimated time to submission: 6-8 hours from now.**
