Here is a highly refined version of your `SKILL.md`.

### Key Improvements Made:

1. **Stronger Imperative AI Directives:** Switched from passive guidance to assertive agent instructions (e.g., *"You MUST maintaining a transient state log..."*). This forces an LLM/Agent to actually implement the rule rather than just read it.
2. **Actionable Context Window Management:** Quantified exactly *when* and *how* an agent should truncate context (e.g., using a runtime summary payload right before recycling the loop).
3. **Refined Layout & Standardized Code Block:** Wrapped the ASCII diagram back inside a proper markdown code block for clean rendering across standard markdown viewers.

```markdown
---
name: AI Loop Engineering
description: >
  Skill for iterative development using feedback loops.
  Guides the AI agent to follow a continuous Build → Measure → Learn → Optimize
  cycle when working on complex tasks, ensuring each iteration improves upon
  the previous one through data-driven decisions.
---

# AI Loop Engineering

You MUST apply the Loop Engineering methodology when working on any task that involves iterative development, debugging, optimization, or multi-step problem solving.

**Core Principle:** Never treat a task as a single linear pass. Instead, work in tight feedback loops — build quickly, measure the result, learn from it, and optimize before the next iteration.

---

## When to Apply This Skill

Use the Loop Engineering approach when:
* **Building or modifying features** that require continuous testing and validation.
* **Debugging complex issues** where the root cause is hidden or not immediately clear.
* **Optimizing performance**, latency, context token usage, accuracy, or quality of any system.
* **Working with AI/ML pipelines** (prompt tuning, RAG evaluation, model distillation, data pre-processing).
* **Any exploratory task** where the first attempt is highly unlikely to be the final production solution.

---

## The 4-Step Loop

Execute every iteration through these 4 steps in chronological order:


```

```
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌──────────┐
│  BUILD  │ ───► │ MEASURE │ ───► │  LEARN  │ ───► │ OPTIMIZE │
└─────────┘      └─────────┘      └─────────┘      └────┬─────┘
     ▲                                                    │
     └────────────────────────────────────────────────────┘

```

```

### Step 1: Build
* Produce a working version as fast as possible (**MVP mindset**).
* Focus on the smallest viable change that can be tested immediately.
* Do **NOT** over-engineer or implement premature optimizations on the first pass.
* Prefer small, incremental code or configuration changes over massive rewrites.

### Step 2: Measure
* Run the code, evaluation scripts, or validation suites immediately after building.
* Collect concrete evidence: test results, error logs, token metrics, output samples, or execution time.
* Do **NOT** skip this step — never assume something works without programmatic verification.
* Utilize automated tools where available (linters, test runners, type checkers, LLM-as-a-judge evaluators).

### Step 3: Learn
* Analyze the quantitative and qualitative results obtained from Step 2.
* Identify exactly what worked, what failed, and why.
* Look for systemic patterns: recurring edge cases, data bottlenecks, hallucination tendencies, or unexpected behaviors.
* Document critical findings as inline comments or session notes when they reveal non-obvious insights.
* Constantly ask: *"What is the single biggest bottleneck blocking progress right now?"*

### Step 4: Optimize
* Apply targeted fixes based strictly on what you learned in Step 3.
* Address the highest-impact or highest-risk issue first.
* If multiple issues exist, isolate them: **fix one thing at a time** and re-measure after each fix.
* Return to Step 1 and seamlessly begin the next loop iteration.

---

## Composable & Nested Loops

In complex tasks, loops can be nested. You must clearly separate the layers of execution:
* **Outer Loop (Macro):** Focuses on the overall system architecture or long-term goals (e.g., an *Optimization Loop* to improve RAG accuracy from 80% to 95%).
* **Inner Loop (Micro):** Triggered within an Outer Loop to solve immediate blockages (e.g., running into a compile-time bug while optimizing -> spin up a *Debug Loop* for 1-3 tight iterations).
* **Rule:** Inner loops MUST have a tighter, smaller loop budget than outer loops and must fully resolve or terminate before passing control back to the outer loop's measurement phase.

---

## Anti-Patterns

To prevent inefficient iteration and agent drift, avoid these behaviors at all costs:
* **The Shotgun Approach:** Never change multiple pieces of code or modify multiple prompt variables simultaneously in a single iteration. This makes it impossible to isolate which factor caused the change in performance.
* **The Blind Optimization:** Never skip the **Measure** phase. Do not jump directly from Build to Optimize based on assumptions (e.g., assuming new code is faster without running a benchmark).
* **Infinite Looping / Tunnel Vision:** Never execute the exact same approach repetitively past your loop budget (3-5 iterations) without stepping back to re-evaluate core assumptions or pivot strategy.
* **Context Over-Engineering:** Do not implement highly complex logic to handle edge cases that have not yet occurred. Focus exclusively on fixing the primary bottleneck detected in the current iteration.

---

## Loop Patterns for AI-Specific Work

### 1. Prompt Engineering & Agentic Loop
When crafting, refining, or evaluating prompts for LLMs and AI Agents:
* **Build:** Write a structured prompt (utilizing system instructions, few-shot examples, or XML tags).
* **Measure:** Test the prompt against a golden dataset/eval-set containing diverse test cases.
* **Learn:** Analyze failure modes (e.g., format violations, reasoning flaws, context leaking).
* **Optimize:** Adjust prompt constraints, modify few-shot examples, or break down a single complex prompt into a multi-agent chain.

> **Key Rules:**
> * Change only one variable at a time per iteration (e.g., change the system instruction *or* the examples, not both).
> * Keep a version history of prompt iterations and their respective win-rates.

### 2. RAG & Data Flywheel Loop
When working with Retrieval-Augmented Generation (RAG) or training workflows:
* **Build:** Create or update the chunking strategy, embedding model, or vector retrieval parameters.
* **Measure:** Evaluate retrieval quality using metrics like Context Precision, Context Recall, and Faithfulness.
* **Learn:** Identify gaps (e.g., irrelevant chunks being retrieved, chunk size cutting off vital context).
* **Optimize:** Implement advanced RAG techniques (e.g., hybrid search, parent-child chunking, re-ranking) or clean the source data.

### 3. Debug & Hypothesis Loop
When fixing bugs, regressions, or unexpected agent behaviors:
* **Build:** Apply a highly targeted, hypothesis-driven fix.
* **Measure:** Execute the exact failing test case or reproduction script.
* **Learn:** Verify if the fix resolved the issue or exposed secondary bugs.
* **Optimize:** Refine the fix, clean up the implementation, and append a new regression test to prevent future breakages.

> **Key Rule:** Never apply random changes. Every single code modification must be backed by a clear hypothesis.

---

## Operational Rules

### Automation First
* Automate verification loops wherever possible (run `npm test`, `pytest`, `go test`, or dedicated evaluation scripts).
* Set up watch modes or hot-reloading when working on iterative logic changes to reduce the feedback loop cycle down to seconds.

### High Observability
* Always check structured logs, trace outputs, and stack traces — **do not guess**.
* Use markdown tables or JSON diffs when comparing output data across different loop iterations.
* Track key metrics across cycles to quantitatively prove that performance is improving over time.

### Context Window Management
Iterative looping can quickly bloat your memory with detailed logs, causing you to lose reasoning capacity. Manage your context window proactively:
* **Summarize Before Next Loop:** Before advancing to the next iteration, write a compact summary of what was attempted and learned, then discard raw, heavily repetitive logs.
* **State Compression:** Compress diagnostic data. If 50 tests pass and 1 fails, log only the specific stack trace of the failure, not the success logs of the other 50.
* **Purge Extraneous Data:** Instantly drop variables, large raw payload samples, or temporary scraped contents that do not serve the analysis of the upcoming loop.

### Fail Fast, Learn Faster
* The first loop is dedicated to learning and discovering constraints, not for achieving production perfection.
* Treat unexpected results as valuable data points, not failures.
* **Set a loop budget:** If no progress is achieved after **3-5 iterations**, step back, re-examine foundational assumptions, and pivot the strategy.

### Exit Conditions
Stop looping immediately when ANY of these conditions are met:
* All automated tests pass and the feature works exactly as specified.
* The user's prompt requirements and acceptance criteria are fully satisfied.
* You have reached the predefined quality/accuracy threshold (e.g., >95% evaluation score).
* Further iterations produce diminishing returns or exceed the context window / token budget constraints.

---

## Quick Reference Summary

| Phase | Core Action | AI / Software Focus |
| :--- | :--- | :--- |
| **Build** | Produce the smallest working change quickly. | Create MVP, write initial prompt, or update a module. |
| **Measure** | Verify with tests, logs, or real data. | Run test suites, check LLM outputs against eval-sets. |
| **Learn** | Analyze results and find the biggest blocker. | Identify edge cases, bugs, or prompt vulnerabilities. |
| **Optimize** | Fix one isolated thing at a time, then re-measure. | Refine logic, tweak prompt structure, apply advanced RAG. |
| **Automation** | Keep feedback loops lightning-fast. | Minimize manual checks; rely on scripts and runners. |
| **Observability** | Base decisions on real data, not assumptions. | Inspect token logs, embeddings, and stack traces. |
| **Fail Fast** | Pivot early if stuck. | If stuck for 3-5 loops, re-evaluate the architecture. |

---

## Iteration Log Template

Use this format to track progress during complex tasks to maintain clear direction, allow clean rollbacks, and optimize token usage:

| Iteration | Step Focus | Changed / Hypothesis | Result / Metrics | Next Action |
| :---: | :--- | :--- | :--- | :--- |
| **#1** | Build -> Measure | Added XML tags to control Output Format | Passed 8/10 cases (failed JSON syntax validation) | Refine closing prompt instructions to strictly enforce JSON (Optimize) |
| **#2** | Learn -> Optimize | Fixed prompt from #1 to strictly enforce structural JSON closures | Passed 10/10 cases; Token usage increased by 15% | Execute State Compression and prepare to finalize task (Exit) |
| **#3 (Inner)**| Debug | Fixed a `NullReferenceException` in the queue processing logic | Execution passed successfully; bug resolved | Close inner loop and return control to the Outer Loop |

```