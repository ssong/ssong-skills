# Things 3 Task Manager

[![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Fssong-skills%2Fthings-skill)](https://tessl.io/registry/ssong-skills/things-skill)

A Tessl skill that gives AI coding agents full control over [Things 3](https://culturedcode.com/things/) on macOS. View, create, complete, move, and delete tasks and projects across all Things 3 lists -- powered by AppleScript with zero external dependencies.

## Requirements

- macOS with [Things 3](https://culturedcode.com/things/) installed
- No additional dependencies -- uses `osascript` (built into macOS)

## Install

```bash
tessl install ssong-skills/things-skill
```

For local development with auto-reload:

```bash
tessl install file:./tiles/things-skill --watch-local
```

## What It Does

Once installed, the skill activates when you ask your AI agent about tasks, to-dos, or Things 3. It teaches the agent to use two helper scripts:

### Query tasks

```bash
things-query.sh today              # Today's tasks
things-query.sh inbox              # Inbox tasks
things-query.sh upcoming           # Upcoming tasks
things-query.sh projects           # All projects
things-query.sh project "Name"     # Tasks in a project
things-query.sh search "term"      # Search by name
things-query.sh tags               # All tags
things-query.sh areas              # All areas
```

Also supports: `anytime`, `someday`, `tomorrow`, `logbook`.

### Create and manage tasks

```bash
# Create a task with all options
things-create.sh task "Review PR" \
  --notes "Check auth changes" \
  --due "2026-04-01" \
  --tags "Work,Urgent" \
  --project "Sprint 12" \
  --list "Today"

# Create a project
things-create.sh project "Q2 Planning" --notes "Goals" --area "Work"

# Complete, move, or delete
things-create.sh complete "Review PR"
things-create.sh move "Review PR" --list "Today"
things-create.sh delete "Old task"
```

### Advanced operations

For operations not covered by the scripts (bulk updates, checklist items, relative deadlines), the skill teaches agents to compose AppleScript directly using locale-safe patterns and structured JSON output via `_private_experimental_ json`.

## Example Prompts

- "What's in my Things inbox?"
- "Add a task called 'Write blog post' with a due date of next Friday"
- "Create a project called 'Q2 Planning' with 5 tasks"
- "Complete 'Review PR' and show me what's left in Today"
- "Move all my Inbox tasks to the appropriate lists"

## How It Works

The skill provides:

- **`SKILL.md`** -- Instructions that teach AI agents when and how to use Things 3
- **`scripts/things-query.sh`** -- Shell script for all read operations (outputs JSON)
- **`scripts/things-create.sh`** -- Shell script for all write operations (returns JSON)
- **`references/applescript-api.md`** -- Detailed AppleScript API reference for advanced operations

All scripts use Things 3's AppleScript dictionary via `osascript`. No external tools, packages, or API keys required.

## Evaluation

The skill is tested against 5 scenarios covering task creation, show-before-modify workflows, destructive action safety, advanced AppleScript operations, and inbox processing with ambiguity handling.

```bash
# Run evals
cd tiles/things-skill
tessl eval run . --label "my eval run"
```

## License

MIT
