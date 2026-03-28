# Weekly Review Automation Script

## Problem/Feature Description

A product manager uses Things 3 to manage her workload. Every Monday morning she does a "weekly review" where she looks at her current Today list and her Inbox, then moves items around to reflect the week's priorities — some Inbox tasks get scheduled for specific days, some Today tasks get pushed to Someday, and a few Someday tasks are pulled in.

She wants an automation script for this routine that she can run once and have it handle the reorganization. The challenge is she doesn't want any surprises — she wants to see exactly what's in each relevant list before anything is changed, and then confirm the updated state after the moves are done.

## Output Specification

Write a shell script called `weekly_review.sh` that performs the following workflow:
1. Captures the current state of the Today, Inbox, and Someday lists
2. Performs a set of moves: move at least 2 tasks from the Inbox to Today or Anytime, and move at least 1 task from Today to Someday
3. Captures the updated state of those lists after the moves

Also produce a `review_report.md` that contains:
- A "Before" section showing the tasks in each list prior to any changes
- An "After" section showing the updated lists after the moves
- Format task data as readable tables or bullet lists (not raw JSON)

For the purposes of this script, you may use example/placeholder task names since Things 3 content is not available here.
