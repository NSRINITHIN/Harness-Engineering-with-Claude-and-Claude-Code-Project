# Evidence Analysis Template

This template helps you analyze the evidence from each system and extract key metrics for your reflection brief.

## System 1: Claims Intake Agent - Analysis

### Test Results
```bash
grep "passed\|failed" evidence/system-1/test_output_*.log
```

**Expected:** 29 passed, 0 failed

| Metric | Value | Notes |
|--------|-------|-------|
| Total tests | [ ] | From pytest output |
| Passed | [ ] | Should be 29 |
| Failed | [ ] | Should be 0 |

### Stop-reason Transitions
Extract from `sample_trace_*.jsonl`:

```bash
jq '.stop_reason' evidence/system-1/sample_trace_*.jsonl | sort | uniq -c
```

**Analysis questions:**
- What stop_reason values appear? (Expected: `tool_use`, `end_turn`)
- How many tool_use turns before end_turn?
- Does the loop terminate correctly?

### Routing Decisions
From `summary_*.md`:

| Claim ID | Outcome | Queue/Reason |
|----------|---------|--------------|
| [ ] | routed / escalated | [ ] |
| [ ] | routed / escalated | [ ] |

**Key metric:** Total claims processed: [ ] / 8

### Loop Termination Logic

**Task:** Find where loop termination is decided

```bash
# In the system path:
grep -n "stop_reason" claims_intake/agent.py 2>/dev/null | head -20
```

**To cite:**
- File: `claims_intake/agent.py`
- Function: `[ ]`
- Line number: [ ]
- Logic: [ describe the termination check ]

### Anti-pattern Avoided

**Analysis:** What problematic pattern does the loop avoid?

Options to consider:
- Infinite loops (no termination condition)
- Missed escalations (decisions not recorded)
- Unhandled tool failures (crashes instead of routing)
- Loss of context (no state maintained between turns)

**Your finding:** The loop avoids [ ] by [ ].

---

## System 2: Retail Context Strategy - Analysis

### Test Results
```bash
grep "passed\|failed" evidence/system-2/test_output_*.log
```

**Expected:** 30 passed, 0 failed

| Metric | Value |
|--------|-------|
| Total tests | [ ] |
| Passed | [ ] |
| Failed | [ ] |

### Token Accounting
```bash
jq '.' evidence/system-2/budget_*.json | head -50
```

**Key metrics to extract:**

| Metric | Baseline | Assembled | % Reduction |
|--------|----------|-----------|------------|
| Total tokens | [ ] | [ ] | [ ]% |
| Context tokens | [ ] | [ ] | [ ]% |
| Compression | - | - | ≥50% goal |

**Calculation:**
```
% Reduction = ((Baseline - Assembled) / Baseline) * 100
```

### Evaluation Results
```bash
# Count passing evals
grep -c '"success": true' evidence/system-2/eval_*.jsonl

# Count control evals
grep -c '"success": true' evidence/system-2/eval_control_*.jsonl
```

**Results:**

| Test Set | Questions | Passed | Failed | Pass Rate |
|----------|-----------|--------|--------|-----------|
| Full context | 6 | [ ] | [ ] | [ ]% |
| Control (no case facts) | 6 | [ ] | [ ] | [ ]% |

**Goal:** ≥5/6 passed on full, ≥1 regression on control

### Information Preservation Decision

**Task:** Identify what was summarized vs. preserved

From `context_*.md`, analyze sections:

| Section | Type | Reason |
|---------|------|--------|
| Order history | summarized/verbatim | [ ] |
| Returns policy | [ ] | [ ] |
| Customer preferences | [ ] | [ ] |
| Timestamps | [ ] | [ ] |
| [ ] | [ ] | [ ] |

**Citation:** Lines [ ] - [ ] in `evidence/system-2/context_*.md`

### Control Regression Analysis

**Question:** Which evaluation question failed in the control variant?

```bash
# Extract question text and results
jq '.question, .success' evidence/system-2/eval_*.jsonl
jq '.question, .success' evidence/system-2/eval_control_*.jsonl
```

**Finding:**
- Question that regressed: [ ]
- Why this information was critical: [ ]

---

## System 3: E-Commerce Config - Analysis

### Test Results
```bash
grep "passed\|failed" evidence/system-3/test_output_*.log
```

**Expected:** 35 passed, 0 failed

| Metric | Value |
|--------|-------|
| Total tests | [ ] |
| Passed | [ ] |
| Failed | [ ] |

### Validator Output
```bash
cat evidence/system-3/validator_output_*.log | tail -20
```

**Expected output:** `OK` with exit code 0

**Verification:**
- [ ] Validator prints "OK"
- [ ] Exit code is 0
- [ ] No validation errors

### Configuration Structure
```bash
tree evidence/system-3/.claude_*/
```

**Expected files:**
- [ ] CLAUDE.md (main config with imports)
- [ ] rules/ (path-scoped rules)
- [ ] commands/ (project commands)
- [ ] skills/ (skill definitions)

### Path-scoped Rules Analysis

**Task:** Examine one path-scoped rule

```bash
head -30 evidence/system-3/.claude_*/rules/*.md
```

**Example rule structure:**
```
---
glob: "src/components/**/*.tsx"
---
# Rule content
```

**Citation:**
- File: `evidence/system-3/.claude_*/rules/[ ].md`
- Glob pattern: [ ]
- Purpose: [ ]

### Why Path-scoped Over Directory-level

**Analysis:** Compare approaches

| Aspect | Path-scoped | Directory-level |
|--------|------------|-----------------|
| Scope | [ ] | [ ] |
| Maintenance | [ ] | [ ] |
| Scaling | [ ] | [ ] |
| Conflicts | [ ] | [ ] |

**Your conclusion:** Path-scoped is preferred because [ ].

### Skill Context Declaration

**Task:** Find a skill with `context: fork`

```bash
grep -A 5 "context:" evidence/system-3/.claude_*/skills/*.md
```

**Example:**
```yaml
context: fork
allowed-tools:
  - read-only
```

**Citation:**
- Skill: [ ]
- Context mode: fork
- Allowed tools: [ ]
- Why fork context: [ ]

---

## System 4: Shift Monitoring - Analysis

### Test Results
```bash
grep "passed\|failed" evidence/system-4/test_output_*.log
```

**Expected:** 33 passed, 0 failed

| Metric | Value |
|--------|-------|
| Total tests | [ ] |
| Passed | [ ] |
| Failed | [ ] |

### Hot State File Size
```bash
cat evidence/system-4/hot_state_size_*.txt
```

**Verification:**
- Size in bytes: [ ]
- Size in KB: [ ]
- Under 5KB goal: [ ] ✓/✗

**Citation:** From `evidence/system-4/hot_state_size_*.txt`

### Hot State Content
```bash
jq . evidence/system-4/hot_state_*.json | head -30
```

**Key fields to identify:**
- Shift ID: [ ]
- Current decisions: [ ]
- Last updated: [ ]
- State fields: [ ]

### Scratchpad Isolation

**Task:** Show that forked scratchpads are isolated

```bash
# Check scratchpad entries
jq '.fork_id, .investigation' evidence/system-4/shift_scratchpad_*.jsonl
```

**Analysis:**
- Main state entries: [ ] count
- Forked investigation entries: [ ] count
- Isolation verified: [ ] ✓/✗

**Citation:** From `evidence/system-4/shift_scratchpad_*.jsonl`

### Resume vs. Fresh Recovery Decision

**Task:** Find where this decision is made

```bash
# Search for recovery logic in code
grep -n "resume\|fresh\|staleness" shift_monitor/orchestration.py 2>/dev/null | head -20
```

**Key questions:**
- When does system resume an existing session?
- What is the staleness threshold?
- File location: [ ]
- Function: [ ]
- Line: [ ]

**Citation:**
- Resume threshold: [ ]
- Staleness trigger: [ ]
- Decision logic: [ ]

---

## Cross-System Analysis

### Three Layers Identification

#### Model Layer (AI Decision-making)
- System 1: [ ] (loop function/file)
- System 4: [ ] (Claude calls/file)
- Citation: [ ]

#### Harness Layer (Tool & Config)
- System 3: [ ] (config files)
- System 4: [ ] (tool definitions/file)
- Citation: [ ]

#### Orchestration Layer (State Management)
- System 2: [ ] (context assembly/file)
- System 4: [ ] (state management/file)
- Citation: [ ]

### Deterministic vs. Prompt-based Examples

#### Deterministic Enforcement
**Example 1:** [ system ] [ what ]
- File: [ ]
- Logic: [ lines/code ]
- Why deterministic: [ ]

**Example 2:** [ system ] [ what ]
- File: [ ]
- Logic: [ ]
- Why deterministic: [ ]

#### Prompt-based Guidance
**Example 1:** [ system ] [ what ]
- File: [ ]
- Guidance: [ prompt snippet ]
- Why prompt-based: [ ]

**Example 2:** [ system ] [ what ]
- File: [ ]
- Guidance: [ ]
- Why prompt-based: [ ]

### Context Management Comparison

#### System 2 Approach
- Strategy: [ ]
- Token budget tracked: [ ]
- Key metric: [ ] tokens/KB
- Citation: `evidence/system-2/budget_*.json`

#### System 4 Approach
- Strategy: [ ]
- State size managed: [ ]
- Key metric: [ ] bytes/KB
- Citation: `evidence/system-4/hot_state_size_*.txt`

**Comparison:**
- Similarity: [ ]
- Difference: [ ]
- When to use each: [ ]

---

## Submission Checklist

- [ ] All 127 tests verified passing
- [ ] Evidence files reviewed and located
- [ ] Run IDs/timestamps recorded
- [ ] Token counts extracted (System 2)
- [ ] File paths and line numbers noted
- [ ] Cross-system patterns identified
- [ ] All citations formatted correctly
- [ ] Reflection brief completed

---

## Citation Format Examples

**File path:**
```
File: evidence/system-1/sample_trace_20261123-093415.jsonl
Lines: 1-50
```

**Run artifact:**
```
Run ID: 2026-11-23T09:34:15
Evidence: evidence/system-1/summary_20261123-093415.md
```

**Metric:**
```
Token reduction: 47,250 → 21,340 (54.8% reduction)
Budget: evidence/system-2/budget_20261123-093415.json
```

**Code citation:**
```
Function: claims_intake.agent.process_claim()
File: claims_intake/agent.py
Lines: 142-156
Logic: Check stop_reason == "end_turn" to exit loop
```
