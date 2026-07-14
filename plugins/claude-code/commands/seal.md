---
description: Seal this session as a shareable tale — you narrate it, receipts stay mechanical; preview, confirm, publish, report the URL
argument-hint: '[--transcript <path>] (or: quick --title "…" --outcome "…" --status succeeded|partial|failed)'
disable-model-invocation: true
allowed-tools:
  - Bash(npx -y taleseal@latest seal*)
  - Bash(npx -y taleseal@latest login*)
---

Publish the current session as a tale — but only through the gate: preview first, explicit
confirmation, then publish. Never run `seal --yes` unless the user has seen the preview in
this conversation and approved it.

Follow the `sealing` skill: it carries the full flow and the authoring rules. In short:

1. `npx -y taleseal@latest seal --skeleton /tmp/taleseal-skeleton.json $ARGUMENTS` — the
   mechanical skeleton (grouped steps + redacted receipts + digest). Read it.
2. Author `/tmp/taleseal-story.json` against the skeleton per the skill's authoring rules:
   5–12 plain-language chapters, every group id used exactly once in order, honest
   `status`, the verdict in `outcome`, decisions recorded, no invented numbers, personal
   context starred out.
3. `npx -y taleseal@latest seal --story /tmp/taleseal-story.json --skeleton /tmp/taleseal-skeleton.json --preview`
   — show the user the full output **verbatim**, redaction and exposure report included.
4. Ask with AskUserQuestion: publish as previewed, adjust the story, or cancel. Only on
   explicit confirmation, re-run step 3's command with `--yes` instead of `--preview`.
   Report the returned URL, noting anyone holding it can read the tale.

If the user asked for a quick seal (flags like `--title`/`--outcome`/`--status` in
`$ARGUMENTS`), use the one-step flow instead: `seal --preview $ARGUMENTS`, confirm, then
`seal --yes $ARGUMENTS`.

If publishing fails with "no API key…": ask the user to run `npx -y taleseal@latest login`
in their own terminal (the browser signs them up and stores the key automatically; never
paste a key into this conversation), then retry the confirmed publish.
