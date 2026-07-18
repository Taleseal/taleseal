# taleseal — Cursor

Write up a Cursor session's work as a published, shareable **tale** — a readable page the
agent composes from the work, readable by anyone holding its URL. All redaction and
publishing logic lives in the [`taleseal` npm CLI](https://www.npmjs.com/package/taleseal);
this plugin is a thin wrapper that teaches Cursor's agent when and how to call it.

> Status: pre-release. Ships with `taleseal@latest`. Not yet listed on the Cursor
> Marketplace.

## What's in the plugin

- **`skills/tale`** — the tale skill. Say "turn this into a page" or "write this up for the
  platform team" and the agent composes the page as blocks (headings, prose, code, diffs,
  tables, charts, an evidence block citing the sources — never a transcript dump), validates
  it against the schema, creates a private draft with a DRAFT banner for you to review in
  the browser, and publishes only after you confirm. Tales are versioned: revising keeps the
  link stable, and `taleseal retract <id>` is the emergency stop.

The tale renders at `taleseal.com/t/…`. There is no auto-publish hook and no capture path;
a tale exists only because you reviewed the draft and confirmed.

## Install

Until the marketplace listing is live, install locally: clone this repo and add the plugin
directory via Cursor's Customize page, or symlink it under `~/.cursor/plugins/`. CLI runs
can load it with `cursor-agent --plugin-dir <path-to>/plugins/cursor`.

## Auth

Publishing needs a key: run `npx -y taleseal@latest login` in your own terminal — the
browser opens, signs you up on the way if needed, and stores the key automatically.
Composing and `validate` need no key. Never paste keys into an agent chat.

## An AGENTS.md nudge (optional)

Add to your project's `AGENTS.md` so any agent in this repo publishes safely:

```
## Sharing work as a tale (taleseal)
When asked to turn this session into a page, tale or shareable link, use the taleseal tale
skill. Compose the work as a readable page (never a transcript dump), create a private
draft, and get explicit confirmation after the human reviews it in the browser before any
publish. Never paste API keys into chat.
```
