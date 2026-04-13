---
name: org-todo-agent
description: Record, triage, and reorganize Org agenda tasks in this Emacs setup from natural-language requests. Use when a user describes work they need to do, wants an AI agent to create or reschedule TODOs in Org, asks for proactive inbox cleanup, or wants a review of open tasks with inferred schedule or deadline.
---

# Org Todo Agent

Use the existing Org workflow in this repo instead of inventing a parallel task system.

The command entry points are:

- `bin/org-ai-capture`
- `bin/org-ai-tasks`
- `bin/org-ai-update`

The backing Emacs Lisp lives in:

- `lisp/feature/init-org-ai.el`
- `lisp/feature/init-org.el`

## Workflow

### 1. Decide the action

- Create a task when the user describes new work.
- Review tasks when the user asks what is pending, what should be done today, or asks for cleanup.
- Update tasks when a task already exists and needs a new state, schedule, or deadline.

Treat short natural-language messages as commands, not discussion prompts.

- "提醒我明天交作业" -> create
- "把今天太满的任务挪一下" -> review and reorganize
- "这个先等对方回复" -> update to `WAIT`
- "今天我该先做什么" -> review and suggest, then update if the user asked you to actually arrange tasks

### 2. Normalize the task

- Write a short imperative title.
- Put extra context in `--note`, not in the title.
- Add tags only when they improve later filtering. Good defaults: `quick`, `deep`, `meeting`, `errand`.
- Preserve explicit user wording for dates and times whenever possible.

### 3. Infer time intentionally

When the user gives explicit time:

- Use it directly.
- Use `--schedule` for a time block, meeting, or “start/do at”.
- Use `--deadline` for “must finish by”.
- If both are implied, set both.

When the user does not give explicit time, infer conservatively:

- Time-specific event or meeting: schedule at the stated event time or the next plausible matching slot.
- Hard deliverable: set a deadline; if effort is non-trivial, also schedule an earlier work block.
- Small admin task, reply, form, payment, booking, or errand: prefer the next workday `10:00` or `14:00`.
- Deep work, writing, coding, studying, or anything likely to need uninterrupted focus: prefer the next workday morning, usually `09:30` or `10:00`.
- Waiting on others: create as `WAIT`; only schedule when there is a real follow-up date.
- Vague backlog item with no urgency: keep as unscheduled `TODO`.

Do not fabricate urgency. If timing is genuinely ambiguous, capture the task and note the assumption briefly.

### 4. Write through the command wrappers

Create:

```bash
bin/org-ai-capture --title "提交报销" --schedule "<2026-04-14 Tue 10:00>" --tags "quick,errand"
```

Review:

```bash
bin/org-ai-tasks
```

Update:

```bash
bin/org-ai-update --id "<org-id>" --state NEXT --schedule "<2026-04-15 Wed 09:30>"
```

The wrappers return JSON. Read it and report the important result back to the user.

## Prompt Pattern

When the user is simply describing work in natural language, follow this compact loop:

1. Extract one or more concrete tasks.
2. Infer `state`, `schedule`, `deadline`, and tags.
3. Write tasks with `bin/org-ai-capture`, or update with `bin/org-ai-update`.
4. Reply with the result and any scheduling assumptions.

Use this response shape:

- `已记录：<title>`
- `安排：<scheduled/deadline 或 未安排>`
- `假设：<only when you inferred time>`

Examples:

- 用户: `明天下午提醒我给导师发邮件，确认 meeting 时间`
- 动作: `bin/org-ai-capture --title "给导师发邮件确认 meeting 时间" --schedule "<2026-04-14 Tue 14:00>" --tags "quick,meeting"`

- 用户: `下周之前把实验报告写完，最好周三先起个草稿`
- 动作: set a deadline for next week and a scheduled work block on Wednesday.

- 用户: `把还没安排时间但应该尽快推进的事情整理一下`
- 动作: read tasks, convert appropriate unscheduled `TODO` items to `NEXT`, and assign realistic time blocks.

## Review Rules

When asked to proactively organize tasks:

- Run `bin/org-ai-tasks`.
- Group by `state`, `scheduled`, and `deadline`.
- Find unscheduled `TODO` items that should become `NEXT`.
- Find items scheduled too aggressively for the same day and move lower-priority work out.
- Move blocked items to `WAIT` when the user is waiting on someone else.
- Prefer a small number of realistic scheduled blocks over stuffing the calendar.

Apply updates with `bin/org-ai-update`. Do not rewrite Org files manually unless the command wrappers are insufficient.

## Agenda Views

This config adds an `A` agenda command: `AI Task Board`.

Use it when working inside Emacs and you want:

- unscheduled AI inbox items
- current AI next actions
- the next 7 days of AI-scheduled work
- AI waiting items

## Communication

- State explicit assumptions when you inferred time.
- If you changed existing tasks, summarize the changed IDs or titles.
- If there is scheduling risk or overload, say so directly.
- Keep the user-facing reply short unless they explicitly ask for a full task review.
