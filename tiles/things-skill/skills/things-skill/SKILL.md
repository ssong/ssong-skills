---
name: things-skill
description: "Manage Things 3 tasks on macOS -- view lists, create tasks with deadlines and tags, complete tasks, move between projects, set due dates, search, and organize. This skill should be used when the user mentions Things 3, wants to manage tasks or to-dos, asks about their inbox, today, upcoming, or someday tasks, wants to create, complete, move, or delete tasks, discusses projects or task management, or says things like 'add a task', 'show my inbox', 'what do I need to do today', 'mark it done', 'my to-do list'."
---

# Things 3 Task Manager

Manage Things 3 tasks on macOS using AppleScript via `osascript`. Zero external dependencies. Requires macOS with Things 3 installed (auto-launches if not running).

## Helper Scripts

This skill includes two shell scripts in `scripts/` relative to this SKILL.md file. Determine the absolute path to the scripts directory from this file's location.

**Always use these helper scripts for all Things 3 operations.** Do not use raw `osascript` when a helper script covers the operation. This applies whether running commands directly or generating shell scripts. When writing a shell script that interacts with Things 3, call these helper scripts from within it.

### Reading Tasks -- `scripts/things-query.sh`

```bash
things-query.sh today              # Today's tasks
things-query.sh inbox              # Inbox tasks
things-query.sh upcoming           # Upcoming tasks
things-query.sh anytime            # Anytime tasks
things-query.sh someday            # Someday tasks
things-query.sh tomorrow           # Tomorrow's tasks
things-query.sh logbook            # Completed tasks
things-query.sh projects           # All projects (with child tasks)
things-query.sh project "Name"     # Tasks in a specific project
things-query.sh search "term"      # Search tasks by name
things-query.sh tags               # All tags
things-query.sh areas              # All areas
```

All commands output JSON arrays. Parse the JSON and present results as clean markdown tables or lists.

### Writing Tasks -- `scripts/things-create.sh`

```bash
# Create a task
things-create.sh task "Buy groceries"
things-create.sh task "Review PR" --notes "Check the auth changes" --due "2026-04-01" --tags "Work" --project "Sprint 12" --list "Today"

# Create a project
things-create.sh project "Q2 Planning" --notes "Quarterly goals" --area "Work"

# Complete a task
things-create.sh complete "Buy groceries"

# Move a task to a scheduling list (Today, Someday, Anytime, Tomorrow)
things-create.sh move "Review PR" --list "Today"

# Delete a task
things-create.sh delete "Old task"
```

All write commands return JSON. **Always capture the return value into a variable and inspect it.** Every call to `things-create.sh` must follow this pattern:

```bash
RESULT=$(things-create.sh move "Task" --list "Today")
if echo "$RESULT" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error: $(echo "$RESULT" | jq -r '.error')"
else
    echo "Success: $(echo "$RESULT" | jq -r '.name')"
fi
```

Return value formats:
- Creation success: `{"name": "...", "id": "...", "status": "open", ...}`
- Complete success: `{"completed": "Task Name"}`
- Error (ambiguous match): `{"error": "Multiple tasks match. Found: Task A, Task B, "}` -- parse and display all matching names to the user

## Workflow Guidelines

1. **Show before modifying**: Always call `things-query.sh` to read the relevant list(s) before any write operations. Display the current state as markdown before making changes.

2. **Capture and check every return value**: Never discard output from `things-create.sh`. Always assign it to a variable and check for the `error` key. When an ambiguity error lists multiple matching task names, display every name to the user.

3. **Verify mutations with a follow-up query**: After writes, always call `things-query.sh` to confirm changes:
   - After creating tasks in a project -> `things-query.sh project "Name"`
   - After completing tasks -> `things-query.sh logbook`
   - After moving tasks -> query the destination list

4. **Build reports from query output, not from creation args**: Any report or markdown file showing task data must be written by piping `things-query.sh` JSON through `jq`. Do not use shell variables from earlier in the script (like `$TASK_NAME` or `$DUE_DATE`) to write the report. The correct pattern is:
   - `TASKS=$(things-query.sh project "Name")`
   - `echo "$TASKS" | jq -r '.[] | "- \(.name) (due: \(.deadline // "none"))"' >> report.md`

   This ensures the report reflects verified state from Things 3, not just what was requested.

## Raw AppleScript

For operations not covered by the helper scripts (bulk operations, checklist items, relative deadline assignment), compose AppleScript directly using `osascript -e`. Follow these rules:

- **Output**: Always use `_private_experimental_ json` -- never manually build JSON from properties
- **Dates**: Always use `(current date) + N * days` -- never `date "YYYY-MM-DD"` (locale-dependent, wrong results)
- **Variables**: Use `output` not `result` (reserved keyword)
- **Empty lists**: Guard with `count` checks before accessing items

See [references/applescript-api.md](references/applescript-api.md) for the full API reference.
