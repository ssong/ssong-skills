---
name: things-skill
description: "Manage Things 3 tasks on macOS — view lists, create tasks with deadlines and tags, complete tasks, move between projects, set due dates, search, and organize. This skill should be used when the user mentions Things 3, wants to manage tasks or to-dos, asks about their inbox, today, upcoming, or someday tasks, wants to create, complete, move, or delete tasks, discusses projects or task management, or says things like 'add a task', 'show my inbox', 'what do I need to do today', 'mark it done', 'my to-do list'."
---

# Things 3 Task Manager

Manage Things 3 tasks on macOS using AppleScript via `osascript`. Zero external dependencies.

## Prerequisites

- macOS with Things 3 installed
- Things 3 will auto-launch if not running when commands are executed

## Helper Scripts

This skill includes two shell scripts in `scripts/` relative to this SKILL.md file. Determine the absolute path to the scripts directory from this file's location.

**Always use these helper scripts for all Things 3 operations.** Do not use raw `osascript` commands when a helper script covers the operation — the scripts handle JSON output, error handling, and ambiguity detection. This applies whether running commands directly or generating shell scripts for the user. When writing a shell script that interacts with Things 3, call these helper scripts from within it.

### Reading Tasks — `scripts/things-query.sh`

```bash
# List tasks in built-in views
things-query.sh today          # Today's tasks
things-query.sh inbox          # Inbox tasks
things-query.sh upcoming       # Upcoming tasks
things-query.sh anytime        # Anytime tasks
things-query.sh someday        # Someday tasks
things-query.sh tomorrow       # Tomorrow's tasks
things-query.sh logbook        # Completed tasks

# Projects, tags, areas
things-query.sh projects       # All projects (with child tasks)
things-query.sh project "Name" # Tasks in a specific project
things-query.sh tags           # All tags
things-query.sh areas          # All areas

# Search
things-query.sh search "term"  # Search tasks by name
```

All commands output JSON arrays. Parse the JSON and present results as clean markdown tables or lists.

### Writing Tasks — `scripts/things-create.sh`

```bash
# Create a task
things-create.sh task "Buy groceries"
things-create.sh task "Review PR" --notes "Check the auth changes" --due "2026-04-01" --tags "Work" --project "Sprint 12" --list "Today"

# Create a project
things-create.sh project "Q2 Planning" --notes "Quarterly goals" --area "Work"

# Complete a task
things-create.sh complete "Buy groceries"

# Move a task
things-create.sh move "Review PR" --list "Today"
things-create.sh move "Review PR" --project "Sprint 12"

# Delete a task
things-create.sh delete "Old task"
```

All write commands return JSON. **Always capture and inspect the JSON output** to check for success or errors:
- On success, creation commands return the task/project JSON with `name`, `id`, `status` fields.
- On success, `complete` returns `{"completed": "Task Name"}`.
- On error (e.g., ambiguous name match), returns `{"error": "..."}` with details. Parse the error and display the matching task names to the user.

## Workflow Guidelines

1. **Show before modifying**: Always call `things-query.sh` to read the relevant list(s) before any write operations. Display the current state as markdown before making changes.

2. **Inspect every return value**: Capture the JSON output of every `things-create.sh` call. Check for the `error` key — if present, parse it and display the matching task names to the user. Never ignore script output.

3. **Handle ambiguity**: When `things-create.sh` returns an error listing multiple matches, display all matching names and ask the user to clarify before retrying.

4. **Verify mutations**: After creating, moving, or completing tasks, always call `things-query.sh` to confirm changes took effect and display the verified state:
   - After creating tasks in a project → `things-query.sh project "Name"`
   - After completing tasks → `things-query.sh logbook`
   - After moving tasks → query the destination list

   **Report content must come from query output.** When generating any report or summary file, capture `things-query.sh` output into a variable and parse it with `jq` to build the report. Never hardcode or echo the creation parameters into the report — the report must reflect what Things 3 actually contains.

## Advanced Usage

For operations not covered by the helper scripts (e.g., bulk operations, complex queries, checklist items), compose AppleScript directly using `osascript -e`. See [references/applescript-api.md](references/applescript-api.md) for the full API reference including all properties, date handling patterns, and common pitfalls.
