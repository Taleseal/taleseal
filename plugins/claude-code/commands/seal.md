---
description: Seal this session as a shareable tale — preview, confirm, publish, report the URL
argument-hint: '[--title "…"] [--outcome "…"] [--status succeeded|partial|failed]'
disable-model-invocation: true
allowed-tools:
  - Bash(npx -y taleseal@0.1.0 seal*)
  - Bash(npx -y taleseal@0.1.0 login*)
---

Publish the current session as a tale — but only through the gate: preview first, explicit
confirmation, then publish. Never run `seal --yes` unless the user has seen the preview in
this conversation and approved it.

The CLI is `npx -y taleseal@0.1.0`.

## 1. Preview

Run from the project directory:

    npx -y taleseal@0.1.0 seal --preview $ARGUMENTS

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

    npx -y taleseal@0.1.0 seal --yes <exactly the flags that were previewed>

`--yes` is required because this shell is not a TTY; it is legitimate here only because the
user has just seen this composition's preview and said yes. Report the returned tale URL, and
note that anyone holding the URL can read the tale.

## 4. If there is no API key

Publishing fails with "no API key — TALESEAL_API_KEY is unset…". Walk the user through setup,
then retry:

1. Sign up at https://taleseal.com/signup and mint an API key in the dashboard.
2. Store the key, either way:
   - the user runs `npx -y taleseal@0.1.0 login` in their own terminal and pastes the key at
     the prompt, or
   - the user sends `!npx -y taleseal@0.1.0 login --key tk_…` as a message here — the `!`
     prefix runs it directly. The key is validated against the server and stored at
     `~/.config/taleseal/config.json` (mode 0600).
3. Retry step 3 if the preview was already confirmed; otherwise start again at step 1.
