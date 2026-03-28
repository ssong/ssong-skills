# New Project Onboarding Script

## Problem/Feature Description

A development team at a mid-size software company is starting a new backend initiative called "API Redesign". The engineering manager wants a repeatable onboarding script they can run at the start of any project that automatically sets up their task management system with the project and its initial set of tasks.

The team tracks everything in Things 3. They want the script to create the project itself, then populate it with the first batch of tasks for the project — things like drafting the technical spec, scheduling kickoff meetings, reviewing existing API endpoints, and setting up CI/CD. Each task should have a realistic deadline (spread over the coming weeks), relevant tags for categorization (e.g., "Engineering", "Planning"), and short notes describing what needs to happen.

## Output Specification

Write a shell script called `setup_project.sh` that, when executed on a macOS machine with Things 3 installed, will:
1. Create a new project called "API Redesign" in Things 3
2. Create at least 5 tasks within that project, each with a deadline, tags, and notes
3. After setup, print a summary of what was created

Also produce a `setup_report.md` file that documents:
- The project and tasks that would be created (with their properties)
- The shell commands used to accomplish this
