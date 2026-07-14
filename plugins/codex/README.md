# taleseal — Codex

Seal a Codex session as a published, shareable **tale** — title, beats, receipts —
readable by anyone holding its URL. All logic lives in the
[`taleseal` npm CLI](https://www.npmjs.com/package/taleseal); this plugin is a thin
wrapper that teaches Codex when and how to call it.

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
- **`examples/`** — an opt-in hook that auto-seals every finished session. Not installed
  by default: it publishes with `--yes`, meaning nobody previews the redaction report
  before the tale goes up. Only wire it in if you accept that.

## Auth

First publish needs a key: run `npx -y taleseal@latest login` in your own terminal — the
browser opens, signs you up on the way if needed, and stores the key automatically.
Previews and `letter validate` need no key. Never paste keys into an agent chat.

The plugin invokes `npx -y taleseal@latest` deliberately unpinned: taleseal accepts
publishes from the latest client only, and refuses a stale one with `426 Upgrade
Required`. A pin here would be a pin into a wall.
