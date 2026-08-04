# Drew's Global Context

## Model Orchestration

**Route by verifiability, escalate on failure.** Cheaply verifiable (tests exist, diff
reviewable in a minute) → cheapest model that can do it. Model must guarantee quality
itself → route up. Never start at the top tier; escalate when a cheaper tier
demonstrably fails. On Max, tokens are rate-limit budget: Fable burns ~5x Sonnet.

| Role | Model | Default effort |
| --- | --- | --- |
| Orchestrate: shape, decompose, delegate, judge summaries | Fable 5 or Opus 5 | high |
| Execute autonomously from a plan; deep debugging; substantive review | Opus 5 | high |
| Scoped, mechanical, verifiable tasks; exploration for the orchestrator | Sonnet 5 | medium |

Hard rules (always apply):

- Protect the orchestrator's context: subagents explore and return summaries — never
  transcripts or file dumps.
- Every delegation ships scope, acceptance criteria, and a return format. Can't state
  the acceptance criteria → not scoped enough to delegate; groom it first.
- A diff is never a Fable input. Fable reviews designs and architecture; Opus reviews code.
- Security-adjacent work goes straight to Opus (Fable reroutes it anyway).
- Escalation: Sonnet fails twice → Opus with failure notes → re-scope. A well-scoped
  task failing at Opus means the scoping is wrong, not the model.
- Effort moves cost more than model choice. Don't crank Sonnet to max — move up a tier.
  Don't start high "to be safe."

## Code Reviews

**IMPORTANT**: The built in code review workflow pins to the current model. Never run code reviews with the `fable` model. Instead, **explicitly pin the code-review workflow to either an `opus` model, or lower if the task is more mechanical**.

- Before any task completes that is writing code, and it is pushed as a PR, run an adversarial review against it.
