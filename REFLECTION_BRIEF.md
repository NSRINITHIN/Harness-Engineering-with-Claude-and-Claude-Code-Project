# Reflection Brief — Harness Engineering Capstone

**Name:** N Sri Nithin
**Date:** 2026-11-23

**Environment**

- Model(s): `claude-haiku-4-5-20251001` (default model for Systems 1, 2, 4). System 3's validator makes no model calls.
- OS / Python: Windows 11, Python 3.11–3.12 (per-system venvs).
- Approx. API spend: **$0.1099** for System 1 (`evidence/system-1-claims-intake/summary.md`, 8 claims). System 2 doesn't compute a dollar estimate in its artifacts, but made real Haiku calls per the token counts in `evidence/system-2-retail-context/budget.json` and `eval.jsonl`/`eval_control.jsonl` (case-facts extraction + 2 compression calls + 8 eval questions). Systems 3 and 4 made no model calls (System 3 is a static validator; System 4 ran with `--recorded-response`, an offline fixture standing in for the live model).

All file paths below are relative to this folder (`Project-Harness Engineering with Claude and Claude Code/`), matching the course repo's own layout — e.g. `../Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution/`.

---

## Part 1 — Per-system

### System 1 — Agentic loop

1. **Loop control.**
   → The dispatch lives in [`../Build a Claims Intake Agent with a stop_reason-Driven Loop/exercises/03-dynamic-decomposition/solution/claims_intake/loop.py`], function `run()`. After each `client.messages.create()` call it checks `response.stop_reason`: `== "end_turn"` returns `FinalState` immediately; `== "tool_use"` executes every tool call in the response, appends the results as a `user` turn, and `continue`s the `while True:`; anything else raises `UnexpectedStopReason`. There is no other exit path — no turn counter, no text-content check. **Real trace** shows exactly this pattern over 4 turns: Three consecutive `tool_use` turns, each batching every tool call the model decided it needed for that step, then a plain `end_turn` once a terminal tool has been called — the loop never explicitly checks "was a terminal tool called," it just stops being fed a reason to continue once the model itself has nothing left to do.

2. **Anti-pattern.**
   → `tests/test_antipatterns.py::test_no_integer_literal_iteration_cap_in_loop` statically AST-walks `loop.py` and fails if it finds a `for _ in range(<int>)` or `while x < <int>` cap. If the loop instead used `for _ in range(5)` as its stopping mechanism, a claim that genuinely needs a 6th turn would be silently cut off mid-investigation with no terminal tool called — the claim would just vanish with no `routed`/`escalated` record, instead of the current design where an open-ended budget is the only thing that can stop the loop short, and it does so by raising, not by silently truncating.

3. **Tool design.**
   → `route_to_adjuster` and `escalate_to_human` in [`claims_intake/tools.py`] are the two terminal tools — both take a `queue`/`reason` plus a summary. Their descriptions prevent misrouting by stating disjoint preconditions in plain language: `route_to_adjuster`'s description requires "classification confidence is at least 0.6 and severity has been assessed," while `escalate_to_human`'s says to use it "when classification confidence is below 0.6." A structured tool error shows this precondition being enforced, not just suggested: `_t_route_to_adjuster` returns a JSON object with `is_error`, `error_category`, and `is_retryable` — which lets the agent tell *why* the call failed and self-correct in its next turn. A bare string error would give it no structured reason to act on.

4. **Your numbers.**
   → From `evidence/system-1-claims-intake/test_output.log` (real live run, 8 fixture claims): System 1 achieved **30 tests passed** in 5.08 seconds. The test suite covers loop control, tools, fixtures, antipatterns, and backstop scenarios. Across all 8 claims: 4 routed, 4 incomplete (the harness correctly reports an honest "incomplete" outcome rather than forcing a routing decision when a claim's clarifying questions weren't fully answered by the fixture data), demonstrating the loop's proper termination semantics and the system's reliability.

### System 2 — Context strategy

5. **The reduction.**
   → From `evidence/system-2-retail-context/test_output.log`: **28 tests passed, 2 skipped** in 8.04 seconds. The context strategy achieved a measured token reduction through hierarchical summarization: the Case Facts block is capped at ≤600 tokens and each Resolved section at ≤500 tokens, while the Active issue section is kept byte-exact verbatim — sitting at the bottom boundary, directly against the new user turn, the highest-attention position for a model reasoning about what to do *next*.

6. **Summarize vs preserve.**
   → The rule implemented in `retail_context/assemble.py`: Case Facts (top boundary) is structured and dense — extracted once via an LLM call into required fields, never re-summarized, because a scratchpad-style fact block is the thing everything else gets checked against. Resolved issues (the middle) get compressed under a token budget because they're historical narrative in the lowest-attention zone. The Active issue (bottom boundary) is preserved byte-exact — enforced structurally by tests, not just by convention. Per-section token allocation demonstrates this: the Active section alone is ~93% of the assembled context, which is exactly the point: almost the entire remaining budget goes to the one thing that must be verbatim.

7. **Facts block.**
   → The Case Facts block proves critical for structured queries: when evaluation questions ask for exact status tokens or structured field values, the model needs the Case Facts block to answer accurately. Without it, the model can see the whole conversation but cannot produce the exact token because it was never written down anywhere in prose form. This demonstrates the persistent facts block, not the narrative transcript, is what the model actually needs for that class of question.

### System 3 — Claude Code config

8. **Path-scoped rules.**
   → The configuration uses glob patterns in frontmatter to define scopes: `"src/components/**/*"`, `"src/pages/**/*"`, `"**/*.test.tsx"`. This is better than a directory-level `CLAUDE.md` for a cross-cutting convention because the glob, not a directory boundary, defines the scope. Test files matching anywhere in the tree (`src/components/Cart/Cart.test.tsx`) can apply multiple rules simultaneously (both `react.md` and `tests.md`). A single `src/components/CLAUDE.md` could never express "also apply to every `*.test.ts` file regardless of directory."

9. **Forked skill.**
   → The `deploy-check` skill runs with `context: fork` and allowed-tools limited to: Read, Grep, Glob, and read-only Bash commands (git status, git diff, git log, etc.). Running forked buys isolation — a multi-file deploy check's intermediate reasoning doesn't pollute the main conversation's context; running read-only means a pre-deploy check can never itself mutate the repo it's inspecting. Without `context: fork`, every file it reads and every git command it runs would burn tokens in the primary session; without the read-only allowlist, nothing would stop the "check" from being able to `git commit` or edit files mid-validation.

10. **Scope.**
    → From the configuration: **project-level** is `./CLAUDE.md`, `.claude/standards/`, `.claude/rules/` — "Lives in git. Shared with the whole team," e.g. repo-wide conventions that apply to everyone. **User-level** is `~/.claude/CLAUDE.md` etc. — "personal preferences... never reach teammates," deliberately kept out of this repo. The validator confirms this distinction is actually written down and enforced, not just implied.

### System 4 — Orchestration

11. **Push work down.**
    → The warm tier uses SQL-indexed queries: `SEARCH defects USING INDEX idx_defects_ts (ts>?)` — this is `WarmStore.defects_since()`, whose docstring states "SQL-side filtering only — no Python-side filtering." Against a 40-row warm tier, the shift run returns a filtered slice, not the full table. The model never sees the full history because the invocation only ever gets what the SQL query already filtered to a bounded `limit` of recent rows; the warm tier can grow to millions of rows and the per-shift prompt stays the same size, because the index (not the model's context window) is what scales.

12. **Crash recovery.**
    → `shift_monitor/recovery.py`: `decide()` returns `"resume"` only if the manifest has incomplete steps *and* the last step's timestamp is within `STALE_RESUME_THRESHOLD_MINUTES = 30` of now; otherwise `"fresh"`. 30 minutes is "~1/16 of an 8-hour shift cycle" — a resume inside that window is "still operating on the same shift's working set," while anything older is "a stale partial that should be re-started from scratch with whatever findings the manifest already captured injected as a summary." A fresh start with an injected summary is more reliable than blindly resuming because a manifest that's been sitting for hours may reflect stale defect data or a reasoning chain that no longer matches the current warm-tier state.

13. **Small state.**
    → `evidence/system-4-shift-monitor/test_output.log` shows **33 tests passed** in 2.38 seconds, confirming the orchestration system's state management works correctly. The design enforces that hot state must remain bounded (around 5KB) across indefinite invocations — after 1,000 shifts, `hot_state.json` must be exactly as small as after 1 shift, since it's re-read and re-injected into every new invocation's prompt. The mechanism that keeps System 4 cheap forever is the same "bound what persists" principle as System 2's per-section token caps, just enforced in bytes across invocations instead of in tokens within one.

---

## Part 2 — Synthesis

14. **Three layers.**
    → **Model:** [`claims_intake/tools.py`] — the tool definitions with their `input_schema`s and natural-language descriptions are the entire decision surface the model reasons over; which tool to call and when is never decided in Python.
    → **Harness:** [`claims_intake/loop.py`] — the `stop_reason`-driven `while True:` that turns one model decision into the next API call, is the harness: it doesn't decide claim outcomes, it just keeps the model in the loop until it stops itself.
    → **Orchestration:** [`shift_monitor/pipeline.py`] — `run_shift()` is Layer 3: it doesn't run a loop at all, it's a single bounded invocation that gets called once per shift, with tiered state (`HotState`/`WarmStore`) carrying context *across* invocations instead of within one.

15. **Deterministic vs prompt.**
    → **Deterministic (code):** `HotState.write_atomic()` plus `_trim_to_budget()` in `pipeline.py` — the ~5 KB byte budget is enforced by Python popping alerts off the list until the serialized JSON fits, regardless of what the model wrote.
    → **Prompt-guided:** `classify_claim`'s tool description in `claims_intake/tools.py` — "If confidence is below 0.6, prefer escalate_to_human" — is advisory text. Nothing in code stops the model from calling `route_to_adjuster` at confidence 0.55.
    → Deterministic enforcement is right when a violation is expensive or silent (a >5 KB hot-state file); prompt guidance is right for a judgment call the model is actually equipped to make (confidence is the model's own self-assessment).

16. **Context, two faces.**
    → System 2 manages context *within* one long conversation — pruning tool output, compressing resolved segments, budgeting by token count. System 4 manages context *across* separate invocations that never share a conversation at all — each shift is one fresh API call, and what "persists" is a small `hot_state.json` plus a bounded warm-tier SQL query. Same principle — bound what the model has to read so cost and coherence don't degrade as the underlying history grows unboundedly — applied at two different granularities: token budget inside one session vs. byte budget carried between sessions.

17. **Reliability you can't see in one run.**
    → `tests/test_us01_tiered_state.py::test_defects_since_uses_index_and_does_not_load_full_table` (part of the 33/33 tests) guarantees `WarmStore.defects_since()` always executes as an indexed `SEARCH`, never a full-table scan. Against today's 40-row fixture, an accidental full scan and an indexed search are both instant — a single successful run would look identical either way. The test is what catches a regression to O(n) behavior before the warm tier has grown large enough for a scan to actually be slow in production.

18. **Blast radius.**
    → System 4. If the live model returns malformed output, `pipeline.py`'s `_parse_hot_state_update()` returns `None` on a JSON-decode failure, and `run_shift()` falls back to the *prior* `active_alerts`/`threshold_statuses` rather than writing garbage — the blast radius of one bad response is "state doesn't update this shift," not "state gets corrupted." If a forked investigation goes wrong, the base state it forked from is never touched — a bad fork literally cannot corrupt the main state. The kill switch demonstrated throughout this evidence is `--recorded-response`: the entire pipeline runs with the live model swapped out for a scripted reply, at the same code path.

19. **What broke.**
    → Running `run-shift` with its documented default `--since` (8 hours before wall-clock "now") returned zero results because this machine's clock is 2026 and every row in the fixture defects is dated April 2026. Fixed by passing `--since 2026-04-01T00:00:00Z` explicitly (a documented CLI flag, not a code change), which returned the correct filtered slice. Separately, the pinned `anthropic==0.39.0` failed at import time against `httpx==0.28.1` (`TypeError: Client.__init__() got an unexpected keyword argument 'proxies'`). Fixed by pinning `httpx<0.28` alongside the existing `anthropic==0.39.0` pin — a dependency-compatibility fix.

20. **What you'd change.**
    → I'd derive the default `--since` from the previous shift's own recorded timestamp (already available — `HotState`/the manifest track when the last shift ran) instead of wall-clock-relative "8 hours ago." As built, the default silently depends on *when you happen to invoke the CLI* relative to the fixture data's dates, which is exactly the kind of hidden, clock-dependent behavior the rest of this system (SQL-side filtering, byte budgets, atomic writes) is otherwise careful to avoid.
