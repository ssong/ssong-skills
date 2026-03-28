# Deadline Assignment and Checklist Automation

## Problem/Feature Description

A freelance consultant manages her client deliverables in Things 3. She has a recurring need to assign relative deadlines to a batch of planning tasks (e.g., "Initial Draft" is due in 5 days, "Client Review" in 10 days, "Final Submission" in 14 days) and to add a checklist to her main "Project Kickoff" task so she can track sub-steps within it.

She looked into the available task management scripts but found they don't support adding checklist items to tasks or setting deadlines in bulk. She needs a more powerful solution that works directly with the Things 3 application.

## Output Specification

Write a bash script called `setup_deadlines.sh` that uses AppleScript (via the shell) to:
1. Find or create the tasks "Initial Draft", "Client Review", and "Final Submission"
2. Set their due dates to 5, 10, and 14 days from today respectively (using locale-safe date arithmetic)
3. Add checklist items to a task called "Project Kickoff" (items like "Book meeting room", "Prepare agenda", "Send invites")
4. Output a JSON summary of the modified tasks

Also produce a `deadline_report.md` that shows the tasks and their assigned deadlines in a readable format.

