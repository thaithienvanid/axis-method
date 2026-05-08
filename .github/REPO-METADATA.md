# GitHub repository metadata

This file is the canonical source for the GitHub *About* sidebar (description, homepage, topics). It exists because GitHub's repo metadata cannot live in-tree — only the owner can set it via the Settings UI or the API.

When you update the description, homepage, or topics, update this file in the same PR so the in-repo source of truth stays aligned with what GitHub displays.

## Description

```
AXIS-26 v0.0.1: risk-gated spec-driven development for AI coding agents. Includes the AXIS specification, Claude Code/Codex plugin, portable commands, lifecycle gates, EARS requirements, CWE checks, evals, and adapters for Cursor, Gemini CLI, and Aider.
```

GitHub allows up to 350 characters; the line above is ~260.

## Homepage

```
https://github.com/thaithienvanid/axis-method/blob/main/AXIS-26.md
```

(Replace with a dedicated landing page if/when one exists.)

## Topics

GitHub: lowercase, hyphens, ≤50 chars each, max 20 per repo. Aligned with `keywords` in `axis-core/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.

```
axis-26
spec-driven-development
agentic-development
ai-agents
ai-coding
claude-code
claude-code-plugin
codex
cursor
gemini-cli
aider
agents-md
skill-md
ears
cwe
evals
conformance
risk-management
software-delivery
developer-tools
```

## Apply via the GitHub UI

1. Go to https://github.com/thaithienvanid/axis-method
2. Click the gear icon next to **About** in the right sidebar.
3. Paste the description and homepage. Add the topics one-by-one or paste them space-separated.
4. Save.

## Apply via the `gh` CLI

```bash
gh repo edit thaithienvanid/axis-method \
  --description "AXIS-26 v0.0.1: risk-gated spec-driven development for AI coding agents. Includes the AXIS specification, Claude Code/Codex plugin, portable commands, lifecycle gates, EARS requirements, CWE checks, evals, and adapters for Cursor, Gemini CLI, and Aider." \
  --homepage "https://github.com/thaithienvanid/axis-method/blob/main/AXIS-26.md" \
  --add-topic axis-26 \
  --add-topic spec-driven-development \
  --add-topic agentic-development \
  --add-topic ai-agents \
  --add-topic ai-coding \
  --add-topic claude-code \
  --add-topic claude-code-plugin \
  --add-topic codex \
  --add-topic cursor \
  --add-topic gemini-cli \
  --add-topic aider \
  --add-topic agents-md \
  --add-topic skill-md \
  --add-topic ears \
  --add-topic cwe \
  --add-topic evals \
  --add-topic conformance \
  --add-topic risk-management \
  --add-topic software-delivery \
  --add-topic developer-tools
```

## Apply via the GitHub REST API

```bash
TOKEN="$GITHUB_TOKEN"  # needs `repo` scope

# Description + homepage
curl -fsS -X PATCH \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{
    "description":"AXIS-26 v0.0.1: risk-gated spec-driven development for AI coding agents. Includes the AXIS specification, Claude Code/Codex plugin, portable commands, lifecycle gates, EARS requirements, CWE checks, evals, and adapters for Cursor, Gemini CLI, and Aider.",
    "homepage":"https://github.com/thaithienvanid/axis-method/blob/main/AXIS-26.md"
  }' \
  https://api.github.com/repos/thaithienvanid/axis-method

# Topics (replaces all existing)
curl -fsS -X PUT \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{
    "names":["axis-26","spec-driven-development","agentic-development","ai-agents","ai-coding","claude-code","claude-code-plugin","codex","cursor","gemini-cli","aider","agents-md","skill-md","ears","cwe","evals","conformance","risk-management","software-delivery","developer-tools"]
  }' \
  https://api.github.com/repos/thaithienvanid/axis-method/topics
```

## Boost discoverability further

| Action | Where | Why |
|---|---|---|
| Cut a `v0.0.1` release | Releases → Draft a release, tag `v0.0.1` from `main` | Indexed by GitHub; gives external linkers a stable target |
| Enable Discussions | Settings → Features → Discussions | `CONTRIBUTING.md` already references it as a channel |
| Add a social-preview image | Settings → Social preview (1280×640 PNG) | Used when the repo is shared on Twitter/X, LinkedIn, Slack |
| Pin the repo on your profile | Profile → Customize pinned | Personal-discovery surface |
| Submit to awesome-lists | `awesome-claude-code`, `awesome-ai-agents`, spec-driven lists | External link surface |
