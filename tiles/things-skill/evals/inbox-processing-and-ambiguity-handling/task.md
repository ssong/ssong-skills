# Inbox Processing and Organization Script

## Problem/Feature Description

A busy product lead has let his Things 3 inbox grow over a week of travel. He now has 10+ tasks sitting in his inbox that were captured quickly and need proper organization — some belong to his "Product Roadmap" project, some should be on his Today list for immediate attention, some should go to Anytime, and a few should be deferred to Someday.

He also knows from past experience that some of his quickly-captured tasks have similar names (he sometimes captures the same idea twice with slightly different wording), which can cause problems when trying to move them. He wants the script to be careful: if moving a task fails because the name is ambiguous, it should surface the conflicting names for him to review rather than silently skipping.

## Output Specification

Write a shell script called `process_inbox.sh` that:
1. Reads and displays the current contents of the inbox
2. Moves a set of tasks to their appropriate destinations (a mix of list moves and project moves — at least 3 total moves)
3. Handles the case where a move returns an error indicating multiple tasks matched the name
4. After all moves, re-reads the inbox and relevant destination lists to show the updated state

The script should use realistic example task names. Also produce an `inbox_report.md` that shows:
- The inbox contents before processing (formatted as a markdown list or table)
- The outcome of each move operation (success or error with matches shown)
- The updated state of the inbox and destination lists after processing
