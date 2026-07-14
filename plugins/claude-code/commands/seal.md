---
description: Seal this session as a shareable tale — preview, confirm, publish, report the URL
argument-hint: '[--title "…"] [--outcome "…"] [--status succeeded|partial|failed]'
disable-model-invocation: true
allowed-tools:
  - Bash(npx -y taleseal@latest seal*)
  - Bash(npx -y taleseal@latest login*)
---

Publish the current session as a tale — but only through the gate: preview first, explicit
confirmation, then publish. Never run `seal --yes` unless the user has seen the preview in
this conversation and approved it.

The CLI is `npx -y taleseal@latest`.

## 1. Preview

Run from the project directory:

    npx -y taleseal@latest seal --preview $ARGUMENTS

This composes the tale from the newest transcript for this directory, entirely locally —
nothing is published and no key is needed. Show the user the full output **verbatim**: title,
status, beats, receipts, and the redaction report. Do not summarise or trim it; seeing exactly
what would become public is the point.

## 2. Confirm

Ask the user with AskUserQuestion whether to publish, offering:

- **Publish** — exactly as previewed.
- **Adjust first** — set flags, then re-preview:
  - `--title "…"` when the session drifted from the task it opened with;
  - `--outcome "…"` for the verdict — a transcript has no conclusion of its own;
  - `--status succeeded|partial|failed` — honest, always. A failed or abandoned run is a
    first-class tale; if this session did not clearly succeed, suggest `partial` or `failed`
    yourself. Never dress a failure up as a success.
- **Cancel** — nothing leaves the machine.

If flags change, return to step 1 and show the new preview.

## 3. Publish

Only after the user has confirmed the previewed composition:

    npx -y taleseal@latest seal --yes <exactly the flags that were previewed>

`--yes` is required because this shell is not a TTY; it is legitimate here only because the
user has just seen this composition's preview and said yes. Report the returned tale URL, and
note that anyone holding the URL can read the tale.

## 4. If there is no API key

Publishing fails with "no API key — TALESEAL_API_KEY is unset…". Signing in is one command,
but it needs the user's own terminal (this shell is not a TTY, and the login opens a
browser). Walk the user through it, then retry:

1. Ask the user to run `npx -y taleseal@latest login` in their own terminal. The browser
   opens; they approve there — signing up on the way if needed — and a key is created and
   stored at `~/.config/taleseal/config.json` (mode 0600) automatically. Nothing to copy or
   paste. Works over SSH too: they open the printed URL on any device and match the code.
2. Only for CI or a machine with no browser anywhere: mint a key by hand at
   https://taleseal.com/dashboard and set `TALESEAL_API_KEY`, or run
   `npx -y taleseal@latest login --key tk_…`. Never paste a key into this conversation —
   transcripts are exactly what gets sealed.
3. Once the user says they are signed in, retry step 3 if the preview was already
   confirmed; otherwise start again at step 1.
