#!/bin/bash
mkdir -p ~/.claude/skills
cp "$(dirname "$0")/SKILL.md" ~/.claude/skills/n8n-cost-estimator.md
echo "✓ Skill installed. Open Claude Code and type: /n8n-cost"
