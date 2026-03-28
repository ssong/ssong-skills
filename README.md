# ssong-skills

A collection of [Tessl](https://tessl.io) skills for AI coding agents.

## Skills

| Skill | Description |
|-------|-------------|
| [things-skill](tiles/things-skill/) | [![tessl](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.tessl.io%2Fv1%2Fbadges%2Fssong-skills%2Fthings-skill)](https://tessl.io/registry/ssong-skills/things-skill) Manage Things 3 tasks on macOS via AppleScript |

## Installation

Install any skill with the [Tessl CLI](https://docs.tessl.io):

```bash
tessl install ssong-skills/<skill-name>
```

## Local Development

```bash
# Install a tile locally for testing
tessl install file:./tiles/<skill-name>

# Lint a tile
cd tiles/<skill-name> && tessl tile lint

# Review a skill
cd tiles/<skill-name> && tessl skill review skills/<skill-name>/SKILL.md

# Run evaluations
cd tiles/<skill-name> && tessl eval run .
```
