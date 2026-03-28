#!/bin/bash
# things-create.sh — Write operations for Things 3 via AppleScript
# Usage: things-create.sh <command> [args]

set -euo pipefail

run_applescript() {
    osascript -e "$1" 2>/dev/null
}

case "${1:-help}" in
    task)
        shift
        if [ -z "${1:-}" ]; then
            echo "Usage: things-create.sh task \"Task Name\" [--notes \"...\"] [--due \"YYYY-MM-DD\"] [--tags \"t1,t2\"] [--project \"Name\"] [--list \"Today|Someday|...\"]" >&2
            exit 1
        fi
        TASK_NAME="$1"
        shift

        NOTES=""
        DUE_DATE=""
        TAGS=""
        PROJECT=""
        LIST=""

        while [ $# -gt 0 ]; do
            case "$1" in
                --notes) NOTES="$2"; shift 2 ;;
                --due) DUE_DATE="$2"; shift 2 ;;
                --tags) TAGS="$2"; shift 2 ;;
                --project) PROJECT="$2"; shift 2 ;;
                --list) LIST="$2"; shift 2 ;;
                *) echo "Unknown option: $1" >&2; exit 1 ;;
            esac
        done

        # Build properties string
        PROPS="name:\"${TASK_NAME}\""
        [ -n "$NOTES" ] && PROPS="${PROPS}, notes:\"${NOTES}\""
        [ -n "$TAGS" ] && PROPS="${PROPS}, tag names:\"${TAGS}\""

        # Build the AppleScript
        SCRIPT="tell application \"Things3\"
    set newTodo to make new to do with properties {${PROPS}}"

        # Due date requires date coercion
        if [ -n "$DUE_DATE" ]; then
            SCRIPT="${SCRIPT}
    set due date of newTodo to date \"${DUE_DATE}\""
        fi

        # Assign to project
        if [ -n "$PROJECT" ]; then
            SCRIPT="${SCRIPT}
    set proj to first project whose name is \"${PROJECT}\"
    move newTodo to proj"
        fi

        # Move to list (Today, Someday, etc.)
        if [ -n "$LIST" ]; then
            SCRIPT="${SCRIPT}
    move newTodo to list \"${LIST}\""
        fi

        SCRIPT="${SCRIPT}
    return _private_experimental_ json of newTodo
end tell"

        run_applescript "$SCRIPT"
        ;;

    project)
        shift
        if [ -z "${1:-}" ]; then
            echo "Usage: things-create.sh project \"Project Name\" [--notes \"...\"] [--area \"Name\"]" >&2
            exit 1
        fi
        PROJECT_NAME="$1"
        shift

        NOTES=""
        AREA=""

        while [ $# -gt 0 ]; do
            case "$1" in
                --notes) NOTES="$2"; shift 2 ;;
                --area) AREA="$2"; shift 2 ;;
                *) echo "Unknown option: $1" >&2; exit 1 ;;
            esac
        done

        PROPS="name:\"${PROJECT_NAME}\""
        [ -n "$NOTES" ] && PROPS="${PROPS}, notes:\"${NOTES}\""

        SCRIPT="tell application \"Things3\"
    set newProj to make new project with properties {${PROPS}}"

        if [ -n "$AREA" ]; then
            SCRIPT="${SCRIPT}
    set a to first area whose name is \"${AREA}\"
    set area of newProj to a"
        fi

        SCRIPT="${SCRIPT}
    return _private_experimental_ json of newProj
end tell"

        run_applescript "$SCRIPT"
        ;;

    complete)
        shift
        if [ -z "${1:-}" ]; then
            echo "Usage: things-create.sh complete \"Task Name\"" >&2
            exit 1
        fi
        TASK_NAME="$1"
        run_applescript "
tell application \"Things3\"
    set matchingTodos to every to do whose name is \"${TASK_NAME}\"
    if (count of matchingTodos) is 0 then
        set matchingTodos to every to do whose name contains \"${TASK_NAME}\"
    end if
    if (count of matchingTodos) is 0 then
        return \"{\\\"error\\\": \\\"No task found matching '${TASK_NAME}'\\\"}\"
    end if
    if (count of matchingTodos) > 1 then
        set names to \"\"
        repeat with t in matchingTodos
            set names to names & (name of t) & \", \"
        end repeat
        return \"{\\\"error\\\": \\\"Multiple tasks match. Found: \" & names & \"\\\"}\"
    end if
    set targetTodo to item 1 of matchingTodos
    set status of targetTodo to completed
    return \"{\\\"completed\\\": \\\"\" & (name of targetTodo) & \"\\\"}\"
end tell"
        ;;

    move)
        shift
        if [ -z "${1:-}" ] || [ -z "${3:-}" ]; then
            echo "Usage: things-create.sh move \"Task Name\" --list \"Today\"" >&2
            exit 1
        fi
        TASK_NAME="$1"
        shift
        LIST=""
        PROJECT=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --list) LIST="$2"; shift 2 ;;
                --project) PROJECT="$2"; shift 2 ;;
                *) echo "Unknown option: $1" >&2; exit 1 ;;
            esac
        done

        SCRIPT="tell application \"Things3\"
    set matchingTodos to every to do whose name is \"${TASK_NAME}\"
    if (count of matchingTodos) is 0 then
        set matchingTodos to every to do whose name contains \"${TASK_NAME}\"
    end if
    if (count of matchingTodos) is 0 then
        return \"{\\\"error\\\": \\\"No task found matching '${TASK_NAME}'\\\"}\"
    end if
    if (count of matchingTodos) > 1 then
        set names to \"\"
        repeat with t in matchingTodos
            set names to names & (name of t) & \", \"
        end repeat
        return \"{\\\"error\\\": \\\"Multiple tasks match. Found: \" & names & \"\\\"}\"
    end if
    set targetTodo to item 1 of matchingTodos"

        if [ -n "$LIST" ]; then
            SCRIPT="${SCRIPT}
    move targetTodo to list \"${LIST}\""
        fi
        if [ -n "$PROJECT" ]; then
            SCRIPT="${SCRIPT}
    set proj to first project whose name is \"${PROJECT}\"
    move targetTodo to proj"
        fi

        SCRIPT="${SCRIPT}
    return _private_experimental_ json of targetTodo
end tell"

        run_applescript "$SCRIPT"
        ;;

    delete)
        shift
        if [ -z "${1:-}" ]; then
            echo "Usage: things-create.sh delete \"Task Name\"" >&2
            exit 1
        fi
        TASK_NAME="$1"
        run_applescript "
tell application \"Things3\"
    set matchingTodos to every to do whose name is \"${TASK_NAME}\"
    if (count of matchingTodos) is 0 then
        set matchingTodos to every to do whose name contains \"${TASK_NAME}\"
    end if
    if (count of matchingTodos) is 0 then
        return \"{\\\"error\\\": \\\"No task found matching '${TASK_NAME}'\\\"}\"
    end if
    if (count of matchingTodos) > 1 then
        set names to \"\"
        repeat with t in matchingTodos
            set names to names & (name of t) & \", \"
        end repeat
        return \"{\\\"error\\\": \\\"Multiple tasks match. Found: \" & names & \"\\\"}\"
    end if
    set taskName to name of item 1 of matchingTodos
    delete item 1 of matchingTodos
    return \"{\\\"deleted\\\": \\\"\" & taskName & \"\\\"}\"
end tell"
        ;;

    help|*)
        echo "Usage: things-create.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  task \"Name\" [options]     Create a new task"
        echo "    --notes \"...\"           Set task notes"
        echo "    --due \"YYYY-MM-DD\"      Set due date"
        echo "    --tags \"t1,t2\"          Set tags (comma-separated)"
        echo "    --project \"Name\"        Assign to project"
        echo "    --list \"Today|...\"      Move to list"
        echo ""
        echo "  project \"Name\" [options]  Create a new project"
        echo "    --notes \"...\"           Set project notes"
        echo "    --area \"Name\"           Assign to area"
        echo ""
        echo "  complete \"Task Name\"      Complete a task"
        echo "  move \"Name\" --list \"..\"   Move task to a list"
        echo "  move \"Name\" --project \"\" Move task to a project"
        echo "  delete \"Task Name\"        Delete a task"
        ;;
esac
