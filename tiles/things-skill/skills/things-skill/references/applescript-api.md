# Things 3 AppleScript API Reference

## Available Lists

These are the built-in list names used with `list "Name"`:

| List | Description |
|------|-------------|
| Inbox | Uncategorized tasks |
| Today | Tasks scheduled for today |
| Tomorrow | Tasks scheduled for tomorrow |
| Anytime | Tasks with no specific schedule |
| Upcoming | Tasks with future start dates |
| Someday | Tasks deferred to someday |
| Logbook | Completed tasks |
| Trash | Deleted tasks |

Note: "Later Projects" also appears as a list but is internal to Things.

## Task Properties

Properties available on `to do` objects:

| Property | Type | Writable | Description |
|----------|------|----------|-------------|
| `name` | text | yes | Task title |
| `notes` | text | yes | Task notes (plain text or markdown) |
| `status` | enum | yes | `open`, `completed`, `cancelled` |
| `due date` | date | yes | Deadline |
| `activation date` | date | yes | When the task appears (scheduled date) |
| `tag names` | text | yes | Comma-separated tag names |
| `id` | text | no | Unique identifier |
| `creation date` | date | no | When created |
| `modification date` | date | no | Last modified |
| `completion date` | date | no | When completed |
| `class` | type | no | `to do` or `project` |

## JSON Output

The `_private_experimental_ json` property returns structured JSON for any task or project:

```json
{
  "status": "open",
  "id": "ABC123",
  "creationDate": "2026-03-28T16:04:48Z",
  "modificationDate": "2026-03-28T16:04:48Z",
  "notes": "",
  "tagNames": "Errand, Important",
  "name": "Task title",
  "deadline": "2026-04-01",
  "when": "today",
  "project": "Project Name"
}
```

For projects, the JSON also includes a `childTasks` array.

## Common Operations

### Query tasks in a list

```applescript
tell application "Things3"
    set todoList to every to do of list "Today"
    set output to "["
    set isFirst to true
    repeat with t in todoList
        if not isFirst then set output to output & ","
        set output to output & (_private_experimental_ json of t)
        set isFirst to false
    end repeat
    set output to output & "]"
    return output
end tell
```

### Search tasks by name

```applescript
tell application "Things3"
    set results to every to do whose name contains "search term"
end tell
```

For exact match: `whose name is "exact name"`

### Create a task with properties

```applescript
tell application "Things3"
    set newTodo to make new to do with properties {name:"Task", notes:"Details", tag names:"Tag1, Tag2"}
end tell
```

### Set due date

**Always use relative date arithmetic.** Never use `date "YYYY-MM-DD"` -- it is locale-dependent and produces wrong dates on most systems.

```applescript
-- Correct: relative dates (locale-independent)
set due date of newTodo to (current date) + 5 * days
set due date of newTodo to (current date) + 10 * days
set due date of newTodo to (current date) + 14 * days

-- WRONG: do not use absolute date literals
-- set due date of newTodo to date "2026-04-01"  -- BREAKS on non-US locales
```

### Move task to a list

```applescript
tell application "Things3"
    set t to first to do whose name is "Task Name"
    move t to list "Today"
end tell
```

Valid list targets: Today, Someday, Anytime, Tomorrow.

### Create a task inside a project

Tasks must be assigned to a project at creation time. Use `make new to do of proj`:

```applescript
tell application "Things3"
    set proj to first project whose name is "Project Name"
    set newTodo to make new to do of proj with properties {name:"Task Name", notes:"Details"}
end tell
```

Note: `move to do to project` does NOT work in Things 3. Always create tasks inside the project directly.

### Complete a task

```applescript
tell application "Things3"
    set t to first to do whose name is "Task Name"
    set status of t to completed
end tell
```

### Delete a task

```applescript
tell application "Things3"
    set t to first to do whose name is "Task Name"
    delete t
end tell
```

### Create a project

```applescript
tell application "Things3"
    set newProj to make new project with properties {name:"Project Name", notes:"Description"}
end tell
```

### List all projects

```applescript
tell application "Things3"
    set projList to every project
    repeat with p in projList
        log (_private_experimental_ json of p)
    end repeat
end tell
```

### List all tags

```applescript
tell application "Things3"
    return name of every tag
end tell
```

### List all areas

```applescript
tell application "Things3"
    return name of every area
end tell
```

## Common Pitfalls

1. **Never use absolute date literals**: `date "2026-04-01"` is locale-dependent and produces wrong dates. Always use `(current date) + N * days` for due dates.

2. **Empty list errors**: Querying `first to do of list "Today"` when Today is empty throws an error. Always guard with a count check:
   ```applescript
   set todoList to every to do of list "Today"
   if (count of todoList) > 0 then
       -- safe to access items
   end if
   ```

3. **Name ambiguity**: `first to do whose name is "X"` fails if no match exists. Always use `every to do whose name contains "X"` and check the count before accessing items:
   ```applescript
   set matches to every to do whose name contains "X"
   if (count of matches) is 0 then
       -- handle no match
   else if (count of matches) > 1 then
       -- handle ambiguity
   else
       set target to item 1 of matches
   end if
   ```

4. **Things 3 launches automatically**: AppleScript will start Things 3 if it's not running. This is normal behavior.

5. **Variable naming**: AppleScript reserves `result` as a keyword. Use `output` or other names for string accumulation.
