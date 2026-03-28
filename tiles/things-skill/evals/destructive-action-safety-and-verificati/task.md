# Sprint Closure Task Completion Script

## Problem/Feature Description

A scrum master at a software team runs two-week sprints. At the end of each sprint, she needs to mark all completed work as done in Things 3. The tasks follow a naming convention that includes the sprint number (e.g., tasks with "Sprint 24" in their name), but there are often multiple tasks with similar names — like "Sprint 24: Review PR #8" and "Sprint 24: Review PR #12" — which makes bulk completion tricky.

She needs a careful, safe workflow: see what tasks exist before doing anything, mark them done one by one, and then verify they're actually gone from the active lists and appear in the logbook. If a task name is ambiguous and matches multiple items, she wants to see all the matches clearly rather than having the script guess which one to complete.

## Output Specification

Write a shell script called `close_sprint.sh` that accepts a sprint keyword as a parameter (e.g., `./close_sprint.sh "Sprint 24"`) and:
1. Searches for tasks matching the keyword and displays them
2. Attempts to complete each matched task
3. For any ambiguous completion results (multiple matches for a task name), displays all the matches for review
4. Queries the logbook at the end to confirm completed tasks appear there

Also produce a `sprint_closure_report.md` that documents:
- The tasks found matching the sprint keyword (before completion)
- The outcome of each completion attempt (including any ambiguity errors)
- The logbook contents after the sprint closure
- All output formatted as markdown tables or lists
