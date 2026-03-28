#!/bin/bash
# things-query.sh — Read operations for Things 3 via AppleScript
# Usage: things-query.sh <command> [args]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Helper: run AppleScript and return result
run_applescript() {
    osascript -e "$1" 2>/dev/null
}

# Helper: get JSON for all to-dos in a list
list_todos() {
    local list_name="$1"
    run_applescript "
tell application \"Things3\"
    set todoList to every to do of list \"${list_name}\"
    set output to \"[\"
    set isFirst to true
    repeat with t in todoList
        if not isFirst then set output to output & \",\"
        set output to output & (_private_experimental_ json of t)
        set isFirst to false
    end repeat
    set output to output & \"]\"
    return output
end tell"
}

# Helper: get JSON for all to-dos in a project by name
project_todos() {
    local project_name="$1"
    run_applescript "
tell application \"Things3\"
    set proj to first project whose name is \"${project_name}\"
    set todoList to every to do of proj
    set output to \"[\"
    set isFirst to true
    repeat with t in todoList
        if not isFirst then set output to output & \",\"
        set output to output & (_private_experimental_ json of t)
        set isFirst to false
    end repeat
    set output to output & \"]\"
    return output
end tell"
}

case "${1:-help}" in
    today)
        list_todos "Today"
        ;;
    inbox)
        list_todos "Inbox"
        ;;
    upcoming)
        list_todos "Upcoming"
        ;;
    anytime)
        list_todos "Anytime"
        ;;
    someday)
        list_todos "Someday"
        ;;
    tomorrow)
        list_todos "Tomorrow"
        ;;
    logbook)
        list_todos "Logbook"
        ;;
    projects)
        run_applescript '
tell application "Things3"
    set projList to every project
    set output to "["
    set isFirst to true
    repeat with p in projList
        if not isFirst then set output to output & ","
        set output to output & (_private_experimental_ json of p)
        set isFirst to false
    end repeat
    set output to output & "]"
    return output
end tell'
        ;;
    project)
        if [ -z "${2:-}" ]; then
            echo "Usage: things-query.sh project \"Project Name\"" >&2
            exit 1
        fi
        project_todos "$2"
        ;;
    search)
        if [ -z "${2:-}" ]; then
            echo "Usage: things-query.sh search \"search term\"" >&2
            exit 1
        fi
        search_term="$2"
        run_applescript "
tell application \"Things3\"
    set todoList to every to do whose name contains \"${search_term}\"
    set output to \"[\"
    set isFirst to true
    repeat with t in todoList
        if not isFirst then set output to output & \",\"
        set output to output & (_private_experimental_ json of t)
        set isFirst to false
    end repeat
    set output to output & \"]\"
    return output
end tell"
        ;;
    tags)
        run_applescript '
tell application "Things3"
    set tagList to every tag
    set output to "["
    set isFirst to true
    repeat with t in tagList
        if not isFirst then set output to output & ","
        set output to output & "{\"name\":\"" & (name of t) & "\"}"
        set isFirst to false
    end repeat
    set output to output & "]"
    return output
end tell'
        ;;
    areas)
        run_applescript '
tell application "Things3"
    set areaList to every area
    set output to "["
    set isFirst to true
    repeat with a in areaList
        if not isFirst then set output to output & ","
        set output to output & "{\"name\":\"" & (name of a) & "\"}"
        set isFirst to false
    end repeat
    set output to output & "]"
    return output
end tell'
        ;;
    help|*)
        echo "Usage: things-query.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  today              Show today's tasks"
        echo "  inbox              Show inbox tasks"
        echo "  upcoming           Show upcoming tasks"
        echo "  anytime            Show anytime tasks"
        echo "  someday            Show someday tasks"
        echo "  tomorrow           Show tomorrow's tasks"
        echo "  logbook            Show completed tasks"
        echo "  projects           List all projects"
        echo "  project \"Name\"     Show tasks in a project"
        echo "  search \"term\"      Search tasks by name"
        echo "  tags               List all tags"
        echo "  areas              List all areas"
        ;;
esac
