# Rubric Deep Dive - What to Submit & How

This document maps each rubric criterion to specific evidence you need to collect and cite.

---

## CRITERION 1: Stop-reason-driven Agentic Loop with Integrated Tools

**Rubric requires:**

### 1.1 Test Suite Passing (30 tests)
**What to show:** `pytest tests/ -v` output showing 30 passed

**Evidence file:** `evidence/system-1/test_output_*.log`

**What to cite in reflection:**
```
System 1 tests: 30 passed, 0 failed
Citation: evidence/system-1/test_output_20261123.log line 1-50
```

### 1.2 Run Artifact with End-to-End Claims
**What to show:** Processing claims through routing/escalation

**Evidence files:**
- `evidence/system-1/summary_*.md` - table of claim outcomes
- `evidence/system-1/latest_run_*/` - full runs directory

**What to cite in reflection:**
```
8 claims processed:
- 5 routed to queues (order_placement, claims, escalation_review, etc)
- 3 escalated
Citation: evidence/system-1/summary_20261123.md, table rows 1-8
```

### 1.3 Turn-by-Turn Trace with Stop_reason Values
**What to show:** One claim's execution showing stop_reason per turn

**Evidence file:** `evidence/system-1/sample_trace_*.jsonl`

**Expected pattern:**
```json
{"turn": 1, "action": "tool_use", "stop_reason": "tool_use"}
{"turn": 2, "action": "tool_use", "stop_reason": "tool_use"}
{"turn": 3, "action": "none", "stop_reason": "end_turn"}
```

**What to cite in reflection:**
```
Example trace (Claim ID: xyz):
- Turn 1: stop_reason = "tool_use" (extract data)
- Turn 2: stop_reason = "tool_use" (validate)
- Turn 3: stop_reason = "end_turn" (terminate, routed to queue)
Citation: evidence/system-1/sample_trace_20261123.jsonl lines 1-10
```

### 1.4 Reflection Brief - Two Elements

#### Element 1: Loop Termination Decision (by file and function)
**What to explain:** Where loop termination is decided in code

**Task:** Find the code
```bash
# In System 1 source:
grep -n "end_turn\|stop_reason.*end" claims_intake/agent.py
```

**What to cite:**
```
Loop termination is decided in:
- File: claims_intake/agent.py
- Function: process_claim()
- Lines: 142-156
- Logic: while True: ... if stop_reason == "end_turn": break

Specific code:
    if response.stop_reason == "end_turn":
        # Route or escalate the claim
        return finalize_claim(claim, state)

Citation: claims_intake/agent.py:150-152
```

#### Element 2: One Anti-pattern Avoided
**What to identify:** A problematic pattern the loop prevents

**Examples from Harness Engineering:**
1. **Infinite loops** - absence of termination condition
   - How it's avoided: "Loop checks stop_reason each iteration"

2. **Lost context** - state not preserved between turns
   - How it's avoided: "Claim object updated with each turn's result"

3. **Unhandled tool failures** - crash instead of graceful degradation
   - How it's avoided: "try/except blocks catch tool errors, route to escalation"

4. **Missed escalations** - decisions not recorded
   - How it's avoided: "Every claim outcome written to escalations.jsonl or queue file"

**What to cite:**
```
Anti-pattern avoided: Unhandled tool failures

The loop avoids this by:
- Wrapping tool calls in try/except (lines 165-172)
- Routing failed claims to escalation (line 174)
- Logging every error to data/escalations.jsonl

Citation: claims_intake/agent.py lines 165-174
Evidence: evidence/system-1/latest_run_20261123/escalations.jsonl
(shows claims routed due to tool failures)
```

---

## CRITERION 2: Layer 3 Orchestration with Tiered State & Crash Recovery

**Rubric requires:**

### 2.1 Test Suite Passing (33 tests)
**Evidence file:** `evidence/system-4/test_output_*.log`

**What to cite:**
```
System 4 tests: 33 passed, 0 failed
Citation: evidence/system-4/test_output_20261123.log
```

### 2.2 Run Artifact Using SQL-Filtered Warm Tier
**What to show:** Shift processed using filtered defects, not full history

**Evidence file:** `evidence/system-4/run_output_*.log`

**What to look for in output:**
- Warm DB query with WHERE clause
- Specific subset of defects analyzed
- Hot state updated with decisions

**What to cite:**
```
Shift C processing demonstrates warm-tier filtering:
- Total defects in warm DB: 1,247
- Defects matching shift C filter: 42
- Decisions made based on filtered 42, not full 1,247
- SQL query example: SELECT * FROM defects WHERE shift='C'

Citation: evidence/system-4/run_output_20261123.log lines 15-20
```

### 2.3 Hot State File Size Evidence
**What to show:** Hot state stays <5KB after run

**Evidence file:** `evidence/system-4/hot_state_size_*.txt`

**What to cite:**
```
Hot state file size after shift processing:
- Size: 3,847 bytes (3.75 KB)
- Under 5 KB budget: ✓
- File: data/hot_state.json
- Timestamp: 2026-11-23T09:45:12

Citation: evidence/system-4/hot_state_size_20261123.txt
         evidence/system-4/hot_state_20261123.json (inspect structure)
```

**Inspection tip:** Check what's in hot state
```bash
jq . evidence/system-4/hot_state_*.json
```
Should show: current shift, recent decisions, last-updated timestamp (not full history)

### 2.4 Reflection Brief - Two Elements

#### Element 1: Resume vs. Fresh Recovery Decision
**What to explain:**
- When does system resume an existing session?
- What staleness threshold triggers fresh recovery?

**Task:** Find the decision logic in code

**What to cite:**
```
Resume vs. Fresh Recovery in shift_monitor/orchestration.py:

The system makes the decision at lines 234-250:

    staleness_threshold = 3600  # 1 hour
    last_update = hot_state.get("last_updated")
    if last_update and (now - last_update) < staleness_threshold:
        # Resume existing session
        state = load_hot_state(hot_state)
    else:
        # Fresh recovery - warm tier is authoritative
        state = fresh_recovery(warm_db)

Decision criteria:
- If hot state is <1 hour old: RESUME it
- If hot state is >1 hour old: FRESH recovery from warm DB
- Rationale: Hot state may have uncommitted decisions; staleness means commit to warm

Citation: shift_monitor/orchestration.py lines 234-250
Evidence: evidence/system-4/hot_state_20261123.json shows "last_updated": timestamp
```

#### Element 2: Forked Investigation Isolation
**What to explain:** How forked sessions stay isolated from main state

**Task:** Find fork mechanism in code and evidence

**What to cite:**
```
Forked Scratchpad Isolation in shift_monitor/scratchpad.py:

When a fork is created (line 456):
    fork_id = uuid.uuid4()
    fork_scratchpad = []  # New scratchpad per fork
    fork_state = copy.deepcopy(hot_state)  # Isolated copy

Each fork writes to its own scratchpad line:
    "fork_id": "abc-123",
    "investigation": "hypothesis about defect cluster",
    "decisions": [...]

Main vs. Forked:
- Main state: fork_id = None, decisions logged to shift_scratchpad.jsonl
- Fork 1: fork_id = "abc-123", decisions logged separately
- Fork 2: fork_id = "xyz-789", decisions logged separately

Evidence from shift_scratchpad_*.jsonl:
  {"fork_id": null, "decision": "investigate order-123"}
  {"fork_id": "abc-123", "decision": "confirm hypothesis A"}
  {"fork_id": "xyz-789", "decision": "confirm hypothesis B"}

Result: 1 main decision + 2 fork decisions in separate scopes
Main state never modified by fork decisions

Citation: shift_monitor/scratchpad.py lines 450-470
         evidence/system-4/shift_scratchpad_20261123.jsonl
```

---

## CRITERION 3: Context Strategy Reducing Token Load

**Rubric requires:**

### 3.1 Test Suite Passing (30 tests)
**Evidence file:** `evidence/system-2/test_output_*.log`

**What to cite:**
```
System 2 tests: 30 passed, 0 failed
Citation: evidence/system-2/test_output_20261123.log
```

### 3.2 Budget.json Showing ≥50% Reduction
**What to show:** Token accounting in budget.json

**Evidence file:** `evidence/system-2/budget_*.json`

**What to cite:**
```
Context assembly achieves 54.8% token reduction:

Baseline (raw conversation):
  - Total tokens: 47,250
  - Breakdown: messages 32,100 + order history 8,500 + policies 6,650

Assembled context:
  - Total tokens: 21,340
  - Breakdown: extracted facts 15,200 + summarized history 3,500 + policies 2,640

Reduction:
  - Absolute: 47,250 - 21,340 = 25,910 tokens
  - Percentage: (25,910 / 47,250) × 100 = 54.8%
  - Goal: ≥50% ✓

Citation: evidence/system-2/budget_20261123.json
Full breakdown visible in file
```

### 3.3 Evaluation Results (≥5/6 questions passing)
**What to show:** 6 evaluation questions answered by assembled context

**Evidence files:**
- `evidence/system-2/eval_*.jsonl` - full context evals
- `evidence/system-2/eval_control_*.jsonl` - control evals

**What to cite:**
```
Evaluation against assembled context: 5/6 questions passed

Questions tested:
1. "What is the customer's preferred shipping method?" → PASS
2. "How many returns has this customer made?" → PASS
3. "What is our return policy for electronics?" → PASS
4. "What was the customer's issue with order #XYZ?" → PASS
5. "When did the customer last purchase?" → FAIL (timestamp summarized away)
6. "What products has customer viewed but not purchased?" → PASS

Pass rate: 5/6 = 83.3% (goal: ≥83%, ≥5/6)

Citation: evidence/system-2/eval_20261123.jsonl
(Shows each question with success true/false)
```

### 3.4 Control Variant Results (≥1 regression)
**What to show:** Performance drops when removing critical context

**Evidence file:** `evidence/system-2/eval_control_*.jsonl`

**What to cite:**
```
Control test: Assembled context WITHOUT "Case Facts" section

Result: 4/6 questions passed (down from 5/6)

Regressions:
- Question 2 "How many returns?" now FAILS
  Reason: Case Facts contained "Customer has 3 previous returns"
  When removed: system inferred from conversation (incorrect)

Explanation:
The Case Facts section, though only X% of tokens, contained
critical factual summary that the conversation didn't explicitly state.
Removing it caused 1 direct question regression.

Citation: evidence/system-2/eval_control_20261123.jsonl
         Comparison: Question 2 success false (vs. true in full eval)
```

### 3.5 Reflection Brief - Two Elements

#### Element 1: What Was Summarized vs. Preserved
**What to explain:** Which information types were summarized vs. kept verbatim

**Task:** Examine context.md and explain choices

**What to cite:**
```
Information handling in context assembly:

SUMMARIZED (reduced to key facts):
- Order history: 15 previous orders → "Customer has purchased 15 times,
  average order value $125, typical categories: electronics, home"
  Reduction: 850 tokens → 45 tokens (95% reduction)
  Reason: Individual order details not needed for current issue
  Citation: evidence/system-2/context_20261123.md lines 23-28

- Support tickets: 8 previous tickets → "Previous issues: 2 shipping
  delays, 1 wrong item, 5 resolved quickly"
  Reduction: 620 tokens → 38 tokens
  Reason: Pattern matters, not every detail
  Citation: evidence/system-2/context_20261123.md lines 45-50

PRESERVED VERBATIM:
- Current issue description: "Package arrived with damage to corner,
  USB ports not functioning"
  Size: Full 220 tokens
  Reason: Specific current problem; nuance critical for diagnosis
  Citation: evidence/system-2/context_20261123.md lines 12-20

- Return policy: Exact policy text
  Size: Full 180 tokens
  Reason: Legal/factual; paraphrasing risks miscommunication
  Citation: evidence/system-2/context_20261123.md lines 61-75

Decision rationale:
- Summarize where patterns matter more than details
- Preserve where accuracy/authority required
- Budget allocated to current issue (220 tokens) > historical patterns (83 tokens)
```

**Numbers to cite from your run:**
```
Evidence: budget_*.json showing token allocation per section
Example:
  "summarized_order_history_tokens": 45,
  "verbatim_current_issue_tokens": 220,
  "total_savings": 25910
```

#### Element 2: Cross-System Context Comparison
**What to explain:** How System 2 and System 4 handle context differently

**What to cite:**
```
Context management comparison: System 2 vs. System 4

SYSTEM 2 (Token budget):
- Challenge: Long conversation grows unbounded
- Solution: Hierarchical summarization of conversation history
- Example: 47k tokens → 21k tokens (54% reduction)
- Mechanism: Identify repeating patterns, summarize to key facts
- Key metric: tokens from budget.json
- Citation: evidence/system-2/budget_20261123.json

SYSTEM 4 (State size):
- Challenge: Session state can grow unbounded across shifts
- Solution: Hot tier (5KB) + warm tier (SQL), not full history in memory
- Example: hot_state.json kept to 3.8KB across full shift
- Mechanism: Only current decisions in hot tier, historical in warm tier
- Key metric: bytes from hot_state_size_*.txt (3847 bytes = 3.75KB)
- Citation: evidence/system-4/hot_state_size_20261123.txt

Comparison:
- Both reduce information scope (token budgets vs. file size budgets)
- System 2 optimizes by summarization (fold many tokens into fewer)
- System 4 optimizes by tiering (keep only current state hot, archive warm)
- System 2 applies at request time (before Claude sees it)
- System 4 applies across time (session boundary: hot vs. warm)
- When to use System 2 approach: single long conversation needing context compression
- When to use System 4 approach: continuous sessions needing bounded memory

Both reduce token *on the wire* but through different mechanisms:
- System 2: "Compress conversation history"
- System 4: "Tiered storage, don't keep full history loaded"
```

---

## CRITERION 4: Claude Code Harness with Hierarchy & Path-scoped Rules

**Rubric requires:**

### 4.1 Configuration Validator Passing
**What to show:** Validator runs and reports "OK", exit code 0

**Evidence file:** `evidence/system-3/validator_output_*.log`

**Expected output:**
```
OK
(exit code 0)
```

**What to cite:**
```
Configuration validator: PASS
Output: "OK"
Exit code: 0
Citation: evidence/system-3/validator_output_20261123.log
```

### 4.2 Test Suite Passing (35 tests)
**Evidence file:** `evidence/system-3/test_output_*.log`

**What to cite:**
```
System 3 tests: 35 passed, 0 failed
Citation: evidence/system-3/test_output_20261123.log
```

### 4.3 Configuration Structure
**What to show:** .claude/ directory with modular structure

**Evidence files:**
- `evidence/system-3/.claude_*/CLAUDE.md` - main config
- `evidence/system-3/.claude_*/rules/` - path-scoped rules
- `evidence/system-3/.claude_*/commands/` - commands
- `evidence/system-3/.claude_*/skills/` - skills

**What to cite:**
```
Configuration hierarchy verified:

Main CLAUDE.md imports modular standards:
  @path: .claude/standards/api.md
  @path: .claude/standards/testing.md
  @path: .claude/standards/database.md

Directory structure:
  .claude/
  ├── CLAUDE.md              (main config, imports standards)
  ├── standards/
  │   ├── api.md             (@imported)
  │   ├── testing.md         (@imported)
  │   └── database.md        (@imported)
  ├── rules/
  │   ├── backend.md         (glob: src/backend/**)
  │   ├── frontend.md        (glob: src/frontend/**)
  │   └── database.md        (glob: src/db/**)
  ├── commands/
  │   └── review.md          (/review slash command)
  └── skills/
      └── deploy-check.md    (context: fork, read-only tools)

Citation: evidence/system-3/.claude_20261123/ directory structure
```

### 4.4 Path-scoped Rules with Glob Frontmatter
**What to show:** Rules with YAML glob patterns

**Evidence files:** `evidence/system-3/.claude_*/rules/*.md`

**Example rule file:**
```yaml
---
glob: "src/components/**/*.tsx"
---
# Rule content
```

**What to cite:**
```
Path-scoped rule example:

File: .claude/rules/frontend.md
Frontmatter:
  ---
  glob: "src/frontend/**/*.{ts,tsx}"
  ---

Applies to: All TypeScript files in frontend source

Content: 1) Use functional components
         2) Props must be typed with interfaces
         3) State managed with Context API
         etc.

Benefit: Rules apply only where needed (src/frontend),
         not globally, reducing noise in backend/database code

Citation: evidence/system-3/.claude_20261123/rules/frontend.md
```

### 4.5 Slash Command
**What to show:** Project-scoped `/review` command

**Evidence files:** `evidence/system-3/.claude_*/commands/`

**What to cite:**
```
Project command defined:

File: .claude/commands/review.md
Trigger: /review (project scope)
Description: Review pull request changes against standards
Allowed tools: file-read, diagnostics
Default context: Include recent commits, PR diff

Usage in harness:
  User types: /review
  Claude Code loads: command config
  Executes: PR review workflow

Citation: evidence/system-3/.claude_20261123/commands/review.md
```

### 4.6 Skill with Context: Fork
**What to show:** Skill that runs in forked context

**Evidence files:** `evidence/system-3/.claude_*/skills/`

**Example skill file:**
```yaml
name: deploy-check
context: fork
allowed-tools:
  - read (file system only)
  - run-command (dry-run only)
```

**What to cite:**
```
Skill with forked context:

File: .claude/skills/deploy-check.md
Configuration:
  name: deploy-check
  context: fork
  allowed-tools:
    - read-only
    - run-command (marked: --dry-run only)

What this means:
- Skill runs in isolated fork (not main stream)
- Can read files but not modify
- Can run commands in dry-run mode only
- Changes don't affect main state

Citation: evidence/system-3/.claude_20261123/skills/deploy-check.md
```

### 4.7 Reflection Brief - Two Elements

#### Element 1: Why Path-scoped Rules Over Directory-level
**What to explain:** Architectural preference

**What to cite:**
```
Path-scoped rules preferred over directory-level CLAUDE.md:

Scenario: Backend and frontend have conflicting style preferences
  - Backend: REST endpoints, error middleware
  - Frontend: React components, state management

DIRECTORY-LEVEL (not ideal):
  - One CLAUDE.md at repo root
  - Rules apply globally
  - Conflict resolution: unclear which rule wins
  - Maintenance: single file grows to 500+ lines
  - Citation location: hard to find relevant rule for a file

PATH-SCOPED (preferred):
  - .claude/rules/backend.md applies to src/backend/**
  - .claude/rules/frontend.md applies to src/frontend/**
  - Rules automatically scoped by glob pattern
  - Maintenance: each rule file small and focused
  - Citation location: easy (file name matches directory)

Benefits over directory-level:
  1. Scalability: rules don't conflict, each scope has own rules
  2. Maintenance: rules co-locate with relevant code
  3. Clarity: glob pattern explicitly shows scope
  4. Flexibility: easy to apply same rule to multiple paths
     (e.g., both src/api and services/api can share one rule)

Evidence: evidence/system-3/.claude_20261123/rules/
  - Three separate files clear the purpose:
    - backend.md: "applies to src/backend/**"
    - frontend.md: "applies to src/frontend/**"
    - database.md: "applies to src/db/**"
  - Instead of one CLAUDE.md with three sections
```

#### Element 2: Why Skill Uses Forked Context
**What to explain:** Why deploy-check skill runs in fork

**What to cite:**
```
Skill `deploy-check` runs in forked context for safety:

Scenario: Skill performs pre-deployment checks
  - Reads Dockerfile, kubernetes config, test results
  - Could hypothetically modify files (dangerous)
  - Needs to run commands to verify state

Design decision: context: fork

Rationale:
1. ISOLATION: Skill's actions don't affect main conversation
   - If skill modifies a file by mistake, fork is discarded
   - Main stream unaffected
   - User can retry safely

2. PERMISSION SCOPING: Skill has read-only allowed-tools
   - Can inspect files
   - Cannot modify them
   - Run-command restricted to --dry-run only
   - Mitigates accidental destructive actions

3. FAIL-SAFE: If skill encounters error
   - Fork is rolled back
   - Main stream continues
   - User not blocked by deployment check failure

Contrast with main context:
  - Main context modifications would affect conversation
  - Errors could corrupt state
  - User would need to restart conversation

Evidence: evidence/system-3/.claude_20261123/skills/deploy-check.md
  context: fork        (isolation)
  allowed-tools:
    - read-only        (safe read)
    - run-command      (dry-run safety)
```

---

## CRITERION 5: Verification - All Tests Passing

**What to show:** Combined test results for all four systems

**Evidence files:**
- `evidence/system-1/test_output_*.log` → 29 passed
- `evidence/system-2/test_output_*.log` → 30 passed
- `evidence/system-3/test_output_*.log` → 35 passed
- `evidence/system-4/test_output_*.log` → 33 passed

**What to cite in reflection:**
```
Complete test suite verification: 127/127 passed

System 1 (Claims Intake):       29 passed ✓
System 2 (Retail Context):       30 passed ✓
System 3 (E-Commerce Config):    35 passed ✓
System 4 (Shift Monitoring):     33 passed ✓
────────────────────────────────────────
TOTAL:                          127 passed ✓

All log files: evidence/system-N/test_output_*.log
Run date: 2026-11-23
Build status: COMPLETE
```

### Test Suite Guarantees (What manual inspection cannot verify)

**What to explain:** One behavior guaranteed by tests but not visible in a single run

**Examples:**
1. **System 1 - Deterministic routing:** A specific claim type always routes to the same queue
   - Single run: Might see claim routed to Order Placement queue
   - Test suite: 29 tests verify same claim type always routes consistently
   - Citation: "29 tests cover routing determinism; individual run shows only one routing"

2. **System 2 - Token consistency:** Context assembly always produces ≥50% reduction
   - Single run: Shows 54.8% reduction for one conversation
   - Test suite: 30 tests verify reduction across different conversation types
   - Citation: "30 tests cover various conversation lengths; run shows only one assembly"

3. **System 3 - Configuration validity:** All rules are syntactically correct and scoped correctly
   - Single run: Validator passes
   - Test suite: 35 tests verify every rule, command, skill individually
   - Citation: "35 tests check each config component; run only validates once"

4. **System 4 - State consistency:** Hot state never exceeds 5KB under any shift type
   - Single run: Shows 3.75KB for one shift
   - Test suite: 33 tests verify size limit across different shift types/defect patterns
   - Citation: "33 tests cover different shifts; run shows only one shift execution"

**What to cite:**
```
Test suites guarantee deterministic behavior that single runs cannot demonstrate:

Example (System 1):
  Single run: 8 claims processed, all routed successfully
  Test suite: 29 tests verify:
    - Each claim type always routes to correct queue
    - Escalation triggers consistently for specific conditions
    - Multiple runs of same claim produce identical routing

Manual inspection shows: "These claims routed here"
Test suite proves: "These claims ALWAYS route here under identical conditions"

Citation: "29 tests provide coverage" - evidence/system-1/test_output_*.log
```

---

## CRITERION 6: Cross-Project Synthesis

### Three Layers Identification

**What to show:** Each layer appears in at least one system

**Model Layer (AI Decision-making):**
- System 1: `claims_intake.agent.process_claim()` - loop makes routing decisions
- System 4: `shift_monitor.orchestration.analyze_shift()` - Claude calls make investigation decisions

**Harness Layer (Tool & Config):**
- System 1: Tool definitions for data extraction, validation
- System 3: Claude Code configuration hierarchy, path-scoped rules, skills
- System 4: Tool definitions + configuration

**Orchestration Layer (State Management):**
- System 2: Context assembly with token budgeting
- System 4: Hot/warm state tiering, session management

**What to cite:**
```
Three-layer architecture visible across projects:

MODEL LAYER (AI reasoning):
  File: claims_intake/agent.py (System 1)
  Function: process_claim() - Claude evaluates claim and decides routing

HARNESS LAYER (Tool specification):
  File: .claude/skills/deploy-check.md (System 3)
  Defines: Which tools available, permissions, context mode

ORCHESTRATION LAYER (State continuity):
  File: shift_monitor/orchestration.py (System 4)
  Mechanism: Hot state <5KB, warm history in SQL, session resume logic
```

---

## SUBMISSION CHECKLIST

Before submitting reflection brief:

- [ ] All test outputs captured (127 tests total)
- [ ] Evidence artifacts located (run IDs, file sizes, eval scores)
- [ ] All answers cite specific artifacts (never generic)
- [ ] File paths relative to evidence/ directory
- [ ] Token counts extracted from budget.json
- [ ] Test counts verified in test_output_*.log
- [ ] Cross-system patterns identified with examples
- [ ] Anti-patterns explained with evidence
- [ ] Three layers identified in named files
- [ ] Deterministic vs. prompt examples compared
- [ ] Context strategies contrasted with numbers

---

**Use ANALYSIS_TEMPLATE.md to systematically extract evidence.**
**Use this document to understand what each citation should contain.**
