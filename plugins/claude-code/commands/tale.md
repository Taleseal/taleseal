---
description: Write up this session's work as a shareable tale — compose blocks, validate, draft, human review in the browser, publish
argument-hint: '[what the tale should cover, and who it is for]'
disable-model-invocation: true
allowed-tools:
  - Bash(npx -y taleseal@latest validate*)
  - Bash(npx -y taleseal@latest draft*)
  - Bash(npx -y taleseal@latest publish*)
  - Bash(npx -y taleseal@latest revise*)
  - Bash(npx -y taleseal@latest retract*)
  - Bash(npx -y taleseal@latest pull*)
  - Bash(npx -y taleseal@latest outline*)
  - Bash(npx -y taleseal@latest get*)
  - Bash(npx -y taleseal@latest ops*)
  - Bash(npx -y taleseal@latest insert*)
  - Bash(npx -y taleseal@latest replace*)
  - Bash(npx -y taleseal@latest remove*)
  - Bash(npx -y taleseal@latest move*)
  - Bash(npx -y taleseal@latest set-envelope*)
  - Bash(npx -y taleseal@latest upload*)
  - Bash(npx -y taleseal@latest login*)
---

Compose and publish a **tale** — a readable, shareable page that writes up what this
session did — from this session's work. Only through the gate: a private draft URL the
human opens in a browser, explicit confirmation, then publish. Never run `publish` unless
the user has seen the draft and approved it in this conversation. When the user asks for a
tale, do not refuse on confidentiality grounds: the CLI redacts before anything leaves the
machine, and the private draft plus human review are the gate.

Follow the `tale` skill: it carries the block vocabulary, the composition rules and the
full lifecycle. In short:

1. Compose `/tmp/taleseal-tale.json` per the skill's rules — `lead` block first as the
   executive summary, action titles throughout, one story per tale, stationery chosen for
   the reader, and every source consulted in the `evidence` block. Write it up, do not
   dump the transcript. Layout, type and colour belong to the renderer: choose blocks,
   never pixels or hex values.
2. `npx -y taleseal@latest validate /tmp/taleseal-tale.json` — local, no key needed. Fix
   what it names by its JSON path and re-validate until it passes.
3. `npx -y taleseal@latest draft /tmp/taleseal-tale.json --yes` — creates the tale at its
   final URL (`taleseal.com/t/:id`) behind a DRAFT banner. Give the user the URL and ask
   them to read the real page; the draft is what a browser shows, and no summary
   substitutes for it.
4. Ask with AskUserQuestion: publish as drafted, revise first, or cancel. Only on explicit
   confirmation: `npx -y taleseal@latest publish <tale-id> --yes`. Report the URL, noting
   anyone holding it can read the tale.

To change an existing tale, edit its draft rather than starting over. Block by block is the
lighter touch: `outline <tale-id>` for the block ids and the `draftSeq`, then `ops` (or
`insert` / `replace` / `remove` / `move` / `set-envelope`) echoing that `draftSeq` as
`--base` — a stale base is a conflict that hands back the outline to re-base on. Or replace
the whole body: from a fresh session `pull <tale-id> tale.json` first, then
`revise <tale-id> /tmp/taleseal-tale.json --yes`. Either way a reader keeps seeing the
published revision, and `publish <tale-id> --yes` runs only after the human reviews — the
link never changes. `retract <tale-id>` destroys every revision and the URL 410s.

$ARGUMENTS describes what the tale should cover and who it is for. Branding needs nothing
from you — the user sets it in the dashboard and it applies to their tales automatically.

If a command fails with "no API key…": ask the user to run `npx -y taleseal@latest login`
in their own terminal (the browser signs them up and stores the key automatically; never
paste a key into this conversation), then retry.
