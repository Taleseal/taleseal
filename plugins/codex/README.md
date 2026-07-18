# taleseal — Codex

Write up a Codex session's work as a published, shareable **tale** — a readable page the
agent composes from the work, readable by anyone holding its URL. All redaction and
publishing logic lives in the [`taleseal` npm CLI](https://www.npmjs.com/package/taleseal);
this plugin is a thin wrapper that teaches Codex when and how to call it.

## What's in the plugin

- **`skills/tale`** — the tale skill. Say "write this session up as a tale" or "turn this
  into a page for the platform team" and the agent composes the page as blocks (headings,
  prose, code, diffs, tables, charts, an evidence block citing the sources — never a
  transcript dump), validates it against the schema, creates a private draft with a DRAFT
  banner for you to review in the browser, and publishes only after you confirm. Tales are
  versioned: revising keeps the link stable, and `taleseal retract <id>` is the emergency
  stop.

The tale renders at `taleseal.com/t/…`. There is no auto-publish hook and no capture path;
a tale exists only because you reviewed the draft and confirmed.

## Auth

Publishing needs a key: run `npx -y taleseal@latest login` in your own terminal — the
browser opens, signs you up on the way if needed, and stores the key automatically.
Composing and `validate` need no key. Never paste keys into an agent chat.

The plugin invokes `npx -y taleseal@latest` deliberately unpinned: taleseal accepts
publishes from the latest client only, and refuses a stale one with `426 Upgrade Required`.
A pin here would be a pin into a wall.
