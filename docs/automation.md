# Automation Pipeline

End-to-end loop for Puerto Ventura agent work. **ChatGPT** is the technical director (specs + next ticket). **Cursor** is the implementer. **GitHub Actions** bridges completion back toward the director.

Repository: `andyaleen/puerto-ventura` · default branch: `master`

## Pipeline

```
Issue Created
     ↓
agent go
     ↓
Cursor
     ↓
PR
     ↓
technical-director.yml
     ↓
Director API
     ↓
Next Issue
```

| Stage | Who | What happens |
|-------|-----|----------------|
| **Issue Created** | Director (ChatGPT) + human | Full ticket spec opened on GitHub (acceptance criteria, out of scope, required reading). |
| **`agent go`** | Human (or director via `gh`) | Exact comment `agent go` on the issue kicks off work. |
| **Cursor** | Cursor Automation (cloud agent) | Reads the issue + `AGENTS.md` / docs, implements only that ticket on a feature branch. |
| **PR** | Cursor | Opens a PR to `master` with the AGENTS completion sections. Must link the issue (`Closes #N`). |
| **`technical-director.yml`** | GitHub Actions | On PR opened / reopened / synchronize / ready_for_review, finds closing-linked issues and posts a ready marker comment. |
| **Director API** | Future / external | Consumes the ready marker (or PR metadata) so ChatGPT is notified that work is done. |
| **Next Issue** | Director (ChatGPT) | Reviews completion summary, writes the next issue, loop repeats. |

## Stage details

### 1. Issue Created

The director writes a complete specification. Prefer:

- Task type (docs vs implementation)
- Objective and acceptance criteria
- Required reading paths
- Out of scope
- Instruction to open a PR (never push straight to `master`)

Do **not** rely on assigning the issue to Cursor—Automations in this setup do not wake on assignee.

### 2. `agent go`

Kickoff is an **issue comment** whose body is exactly:

```text
agent go
```

Why comment (not label): the Cursor Automations UI available for this project supports **issue comment** and **PR label**, not **issue label**.

Related placeholder Action: `.github/workflows/cursor-start.yml` (echoes when an issue comment contains `agent go`).

### 3. Cursor

Cursor Automation instructions should:

1. Ignore comments other than exact `agent go`
2. Treat the parent issue as the full spec
3. Read `AGENTS.md` and listed docs before changing code
4. Stay inside acceptance criteria / out of scope
5. Branch → PR to `master`
6. Include in the PR body:

```markdown
## Summary
## Files Changed
## Architecture Changes
## New TODOs
## Technical Debt
```

7. List follow-ups under **New TODOs** for the director—do not open those issues unless the ticket says to
8. Stop after the PR is open

**Required for the notify stage:** the PR description (or GitHub UI) must include a closing reference, e.g. `Closes #1`, so Actions can discover linked issues.

### 4. PR

Human reviews the PR. Merge is a human decision. After merge, `project-sync.yml` runs on push to `master` (placeholder echo today).

### 5. `technical-director.yml`

File: `.github/workflows/technical-director.yml`

**Triggers:** `pull_request` → `opened`, `reopened`, `synchronize`, `ready_for_review`

**Behavior:**

1. Query the PR’s `closingIssuesReferences` (issues that will close when the PR merges).
2. If none → exit successfully, post nothing.
3. If one or more → on **each** linked issue, post exactly:

```text
technical-director-ready

PR: #<number>
Branch: <branch-name>
URL: <pr-url>
```

That comment is the durable “Cursor is done” signal on the issue timeline.

### 6. Director API

**Status:** not fully wired. Intended consumer of `technical-director-ready` (and/or PR events) so ChatGPT is notified without manually polling GitHub.

Until the API exists, the director (or human) can:

- Watch issue comments for `technical-director-ready`
- Or watch Actions / PR list for new agent PRs

### 7. Next Issue

Director reads the PR body’s Summary / New TODOs / Technical Debt, decides the next ticket, opens a new issue with a full spec, and waits for the next `agent go`.

## Roles

| Role | Responsibility |
|------|----------------|
| Technical director (ChatGPT) | Specs, sequencing, review of completion summaries, next issue |
| Implementer (Cursor Automation) | Execute one labeled/kicked-off issue; PR + stop |
| Human | Merge PRs, post `agent go`, fix permissions / flaky runs |
| GitHub Actions | Kickoff echo, completion comments, post-merge sync placeholders |

## Workflow files

| Workflow | Trigger | Purpose today |
|----------|---------|----------------|
| `cursor-start.yml` | Issue comment containing `agent go` | Placeholder kickoff log |
| `technical-director.yml` | PR opened / reopened / synchronize / ready_for_review | Post `technical-director-ready` on closing issues |
| `project-sync.yml` | Push to `master` | Placeholder post-merge sync |

## Verification checklist

1. Open a test issue with a clear body.
2. Comment `agent go` → Cursor Automation **Runs** shows a job; optional: Actions → `cursor-start`.
3. Agent opens a PR that includes `Closes #<issue>`.
4. Actions → `technical-director` succeeds; issue gains the `technical-director-ready` comment.
5. Director uses that signal (manual or API) to file the next issue.

## Known gaps

- Director API not implemented yet.
- `synchronize` may post duplicate ready comments on every PR push.
- Cursor Automations cannot use issue-label kickoff in the current UI; stick to `agent go`.
- This chat session is never auto-notified; only Cloud Automation runs are.
