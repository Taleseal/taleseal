# taleseal — Cursor

Seal a Cursor agent session as a published, shareable **tale** — title, beats, receipts —
readable by anyone holding its URL. All logic lives in the
[`taleseal` npm CLI](https://www.npmjs.com/package/taleseal); this plugin is a thin
wrapper that teaches Cursor's agent when and how to call it.

> Status: pre-release. Ships with `taleseal@latest` (the first CLI release with the
> Cursor transcript reader). Not yet listed on the Cursor Marketplace.

## What's in the plugin

- **`skills/sealing`** — the sealing skill. Say "seal this session" and the agent authors
  the story against the CLI's skeleton, shows you the full preview including the redaction
  report, and publishes only after you confirm.
- **`skills/letter`** — the letter skill. Say "write the customer a letter" and the agent
  composes a branded, customer-facing **letter** at `taleseal.com/l/…` — a curated
  solution page with an evidence block instead of receipts. It validates against the block
  schema, creates a private draft with a DRAFT banner for you to review in the browser,
  and publishes only after you confirm. Letters are versioned: revising keeps the
  customer's link stable, and `taleseal letter retract <id>` is the emergency stop.
- **`agents/tale-polisher`** — optional subagent that drafts a truthful `--title`,
  `--outcome` and `--status` from what actually happened, then previews. It never
  publishes; the main conversation confirms.
- **`examples/`** — an opt-in `stop` hook that auto-seals every finished session.
  **Not installed by default**: it publishes with `--yes`, meaning nobody previews the
  redaction report before the tale goes up. Only wire it in if you accept that. Undo a
  publish with `taleseal retract --run <conversation_id>`; retraction destroys the tale
  and the URL answers 410 forever. The hook script requires `jq`.

## Install

Until the marketplace listing is live, install locally: clone this repo and add the
plugin directory via Cursor's Customize page, or symlink it under `~/.cursor/plugins/`.
CLI runs can load it with `cursor-agent --plugin-dir <path-to>/plugins/cursor`.

## Auth

First publish needs a key: run `npx -y taleseal@latest login` in your own terminal — the
browser opens, signs you up on the way if needed, and stores the key automatically.
Previews need no key. Never paste keys into an agent chat.

## An AGENTS.md nudge (optional)

Add to your project's `AGENTS.md` so any agent in this repo seals safely:

```
## Sealing sessions (taleseal)
When asked to seal, share or publish this session as a tale or link, use the taleseal
sealing skill. Always show the full `seal --preview` output (redaction report included)
and get explicit confirmation before any `seal --yes`. Never paste API keys into chat.
```
