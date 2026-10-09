---
name: code-quality-review
description: "Use only when the user explicitly requests code-quality-review by name (for example, $code-quality-review). Find bugs and errors while assessing code quality, simplicity, and maintainability through four independent agents for a PR, uncommitted changes, or the whole repository. Produce an evidence-based report and ask which fixes or improvements the user wants; do not implement them during the assessment."
---

# Code Quality Review

Coordinate four independent reviewers to actively find bugs and errors and assess code quality, simplicity, and maintainability. Validate their findings and help the user choose fixes or improvements. Deliver the report in the user's language and preserve the project's code conventions.

## Establish the scope

The user must choose **a PR**, **uncommitted changes**, or **the whole repository** before code analysis or reviewer dispatch. Accept a choice already provided in the request or active conversation; do not ask again. Honor any explicitly requested path restrictions within that choice.

If no scope was provided, ask one concise question and wait. For a PT-BR conversation: "Qual é o escopo da avaliação: um PR, as alterações não commitadas ou o repositório inteiro?" Never silently default to the whole repository. Resolve repository or PR identity from available context; ask only for an identifier that remains missing or ambiguous.

Read applicable `AGENTS.md` instructions and enough project documentation, manifests, and test configuration to understand the code's purpose and conventions. Establish the same review boundary for every agent:

| Scope | Review boundary |
| --- | --- |
| PR | Identify the PR, target branch, base and head SHAs. Use provider metadata/diff or the merge-base-to-head diff of those revisions. Review the PR revision, keeping local worktree edits out of the assessment. Attribute findings to changes introduced or worsened by the PR. |
| Uncommitted changes | Record `HEAD`, staged and unstaged diffs, and non-ignored untracked files. Inspect both index and worktree states so staged-only changes are not missed. New untracked source files are part of the review even though ordinary `git diff` omits them. Attribute findings to these changes. |
| Whole repository | Review the current working tree, including non-ignored untracked source files, and record the revision and local-change state. Map the project's modules and first-party source, tests, and relevant configuration; cover each area systematically. Exclude generated output, vendored code, and build caches unless they are relevant to the request, and disclose exclusions. |

For change reviews, read surrounding code, callers, and tests as context without turning pre-existing issues into findings against the change. If the diff is empty, report that and ask whether the user wants a different scope; do not expand it automatically. If the needed revisions or PR access are unavailable, state what is missing instead of substituting another scope.

Keep the user's checkout and index intact. Read revision contents directly or use an isolated temporary checkout when needed; do not switch branches, reset, or stash the user's changes. If the code changes during review, reconcile affected findings against the new state or clearly report the reviewed snapshot.

## Delegate the review

Use four reviewer roles, dispatched as independent subagents with the available collaboration tools. Run them concurrently when capacity permits; otherwise schedule them in waves. The coordinator prepares context, checks coverage, and validates evidence while reviewers work. If subagents are unavailable, disclose the limitation and perform the four passes yourself without claiming independent review.

| Reviewer | Focus |
| --- | --- |
| Quality | Consistency with project requirements and API contracts, error-handling robustness, and whether relevant tests meaningfully exercise expected behavior and failure paths. |
| Simplicity | Unnecessary indirection, duplication with a shared reason to change, excessive branching, premature generalization, and abstractions whose cost exceeds their current benefit. Prefer the smallest change that preserves required behavior. |
| Maintainability | Cohesion, coupling, responsibility boundaries, state and dependency flow, naming that affects understanding, testability, and the likely effort and risk of future changes. |
| Bugs and logic | Actively search for and validate bugs, logic mistakes, runtime failures, regressions, and incorrect results. Trace triggering inputs and state through reachable code paths, compare expected and actual behavior, and check for protections in callers or dependencies. Support conclusions with code evidence or a focused reproduction. |

Give every reviewer the scope, revision or local-state description, file inventory, relevant project instructions, and its specific focus. For large repositories, partition the inventory into bounded batches while preserving all four perspectives across the covered areas. Do not share other reviewers' conclusions before their independent pass.

Instruct each reviewer to:

- Review only; do not edit project files, apply fixes, or publish comments. Return findings to the coordinator.
- Read actual code and relevant callers/tests. Ground criticism in this project's requirements and conventions, not a preferred architecture or style.
- Return a short assessment of its dimension, evidence-backed strengths, numbered candidate findings, and inspected areas and limitations.
- For each candidate, provide file and line references, a concrete trigger or maintenance scenario, its impact, a proportionate suggested improvement, priority, rough effort, and any uncertainty. Distinguish a demonstrated defect from an improvement opportunity.
- For a suspected bug or error, describe the triggering input or state, expected behavior, actual behavior, and supporting code path or focused reproduction. State whether the behavior was inferred from code or reproduced through execution.
- Avoid speculative problems, cosmetic preferences, unsupported claims about missing tests, and recommendations to introduce abstractions without a concrete benefit. An empty findings list is valid.

## Validate and synthesize

Wait for all four independent reviews. Then send suspected bugs, logic errors, and runtime failures reported by the other reviewers to the Bugs and logic reviewer for targeted validation. Have it return a verdict (supported, refuted, or unresolved), evidence, and any reproduction limitations for each candidate before synthesis. If subagents are unavailable, perform this validation pass yourself.

Check the reviewers' evidence against the reviewed code, verify important callers or contracts, merge duplicate root causes, and resolve contradictory recommendations. Do not present unverified reviewer claims as established defects. Use existing focused tests or checks when they materially resolve uncertainty; report what actually ran and what was only inspected.

Prioritize by observable impact and likelihood. Label findings as **high**, **medium**, or **low** priority with a reason, and estimate effort as **small**, **medium**, or **large**, noting material dependencies. Keep design opportunities distinct from correctness defects. Do not assign arbitrary numeric quality scores or equate file size, test coverage percentages, or the number of findings with quality.

Deliver one consolidated report in the conversation:

- **Scope and coverage:** the PR/revisions or local state, covered areas, meaningful exclusions, and checks performed. If coverage is partial, say so explicitly and identify what remains; do not claim a complete repository review based on sampling.
- **Overall assessment:** a concise judgment of quality, simplicity, maintainability, and behavioral correctness, supported by the reviewers' evidence. Include strengths when supported.
- **Numbered findings:** use one global sequence starting at 1, ordered by priority. Each item should make the location, evidence or scenario, impact, suggested change, priority, and effort easy to assess. Preserve these numbers in follow-up discussion; reviewer-local numbers are not user-facing IDs.
- **Suggested starting point:** recommend the item or small set with the best impact relative to effort, explaining any dependency between improvements.

Keep the synthesis concise enough to support a decision rather than pasting four raw reports. If no actionable findings survive validation, say so without manufacturing improvements. A report file is optional when requested or useful; do not add files to the repository merely to deliver the assessment.

End by asking what the user wants to improve, referencing the stable finding numbers. In PT-BR: "Quais desses itens você deseja melhorar? Pode indicar os números ou uma área para priorizar." If there are no findings, ask whether there is an area the user wants to explore further.

The assessment itself does not authorize code changes. Wait for the user's selection before implementing improvements. A subsequent clear request to fix selected items authorizes that work; do not ask for the same authorization again.
