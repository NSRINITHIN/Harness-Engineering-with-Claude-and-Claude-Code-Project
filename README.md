# Harness Engineering Capstone — Reflection Brief & Evidence

This repository contains the completed capstone project submission for **Harness Engineering with Claude and Claude Code**.

## 📋 Submission Contents

### 1. **Reflection Brief** (Primary Deliverable)
- **`REFLECTION_BRIEF.md`** — Complete analysis answering all 20 rubric questions with specific evidence citations
  - **Part 1:** Per-system analysis (Systems 1–4)
  - **Part 2:** Cross-system synthesis and architectural patterns
  - Every answer cites specific file paths, line numbers, test results, and artifacts

### 2. **Evidence of All Four Systems**
Organized by system with test output logs proving all tests pass:

| System | Evidence | Tests | Status |
|--------|----------|-------|--------|
| System 1: Claims Intake Loop | `evidence/1-claims-intake/test_output.log` | **30 passed** | ✅ |
| System 2: Context Strategy | `evidence/2-retail-context/test_output.log` | **28 passed, 2 skipped** | ✅ |
| System 3: Claude Code Config | `evidence/3-ecommerce-config/test_output.log` | **35 passed** | ✅ |
| System 4: Shift Monitoring | `evidence/4-shift-monitor/test_output.log` | **33 passed** | ✅ |
| **TOTAL** | **4 evidence files** | **126 passed** | ✅ |

## 🎯 How to Review

1. **Start with the reflection brief:**
   ```bash
   cat REFLECTION_BRIEF.md
   ```

2. **Verify evidence for each system:**
   ```bash
   cat evidence/1-claims-intake/test_output.log
   cat evidence/2-retail-context/test_output.log
   cat evidence/3-ecommerce-config/test_output.log
   cat evidence/4-shift-monitor/test_output.log
   ```

3. **Check test counts:**
   ```bash
   grep -E "passed|skipped" evidence/*/test_output.log
   ```

## 📁 Repository Structure

```
.
├── REFLECTION_BRIEF.md              ⭐ Main deliverable (20 questions, all cited)
├── evidence/
│   ├── 1-claims-intake/
│   │   └── test_output.log          (30 tests ✅)
│   ├── 2-retail-context/
│   │   └── test_output.log          (28 tests ✅, 2 skipped)
│   ├── 3-ecommerce-config/
│   │   └── test_output.log          (35 tests ✅)
│   └── 4-shift-monitor/
│       └── test_output.log          (33 tests ✅)
├── QUICK_START.md                   (5-min overview)
├── PROJECT_GUIDE.md                 (System explanations)
├── ANALYSIS_TEMPLATE.md             (Evidence extraction)
├── RUBRIC_DEEP_DIVE.md              (Citation requirements)
├── INDEX.md                         (Navigation guide)
├── SETUP.md                         (Setup reference)
├── STATUS.md                        (Progress notes)
├── PROGRESS.txt                     (Timeline)
├── setup_all_systems.py             (Build automation)
├── build-all-systems.sh             (Shell orchestration)
└── .gitignore                       (Excludes .venv, systems/)
```

## ✨ Key Results

- **All 126 tests passing** across 4 independent systems
- **Reflection brief** answers all 20 rubric questions with specific evidence
- **Zero production issues** in evidence runs
- **Clean submission** focused on requirements only

## 📖 Rubric Coverage

The reflection brief addresses all required topics:

### Part 1: Per-System Analysis
- ✅ System 1: Loop control, anti-patterns, tool design, test results
- ✅ System 2: Token reduction strategy, summarization vs. preservation, facts block
- ✅ System 3: Path-scoped rules, forked skills, configuration hierarchy
- ✅ System 4: Warm-tier indexing, crash recovery, bounded state

### Part 2: Cross-System Synthesis
- ✅ Three-layer architecture (Model, Harness, Orchestration)
- ✅ Deterministic enforcement vs. prompt-based guidance with examples
- ✅ Context management strategies (within-session vs. across-invocations)
- ✅ Test-based reliability guarantees
- ✅ Blast radius and fault isolation

## 🔗 External Reference

**Course repositories** (not included, see course materials):
- Build a Claims Intake Agent with a stop_reason-Driven Loop
- Engineer a Long-Conversation Context Strategy for a Retail Support Copilot
- Configure Claude Code for an E-Commerce Site
- Design a Multi-Shift Quality Monitoring System

---

**Submission Date:** 2026-11-23
**Status:** ✅ Complete and ready for review
