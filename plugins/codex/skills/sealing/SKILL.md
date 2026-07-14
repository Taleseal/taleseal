---
name: sealing
description: Seal the current Codex session as a shareable tale — preview, confirm, publish, report the URL. Use when the user asks to seal, share, or publish this session, run, or conversation as a tale or a link.
---

# Sealing a tale

Publish the current Codex session as a tale — but only through the gate: preview first,
explicit confirmation from the user, then publish. **Never run `seal --yes` unless the user
has seen the preview in this conversation and approved it.** Transcripts can carry secrets;
the preview's redaction report is the whole point of the gate.

The CLI is `npx -y taleseal@0.3.0` (plain Node, no install).

## 1. Resolve the transcript

Codex writes each session as rollout JSONL under `~/.codex/sessions/YYYY/MM/DD/`. The
current session is the newest rollout. Pin it to a concrete path so the same file is
previewed and published:

```bash
ls -t ~/.codex/sessions/*/*/*/rollout-*.jsonl | head -1
```

If several Codex windows are open, the newest file may belong to another session — confirm
the pick with the user if in doubt, or let them name a specific rollout. (`seal --codex`
does the same newest-rollout discovery in one flag, but pinning an explicit path keeps
preview and publish honest about which run they refer to.)

## 2. Preview

```bash
npx -y taleseal@0.3.0 seal --transcript <path> --preview
```

This composes the tale entirely locally — nothing is published and no key is needed. Show
the user the full output **verbatim**: title, status, beats, receipts, and the redaction
report. Do not summarise or trim it; seeing exactly what would become public is the point.

## 3. Confirm

Ask the user whether to publish, offering:

- **Publish** — exactly as previewed.
- **Adjust first** — set flags, then re-preview:
  - `--title "…"` when the session drifted from the task it opened with;
  - `--outcome "…"` for the verdict — a transcript has no conclusion of its own;
  - `--status succeeded|partial|failed` — honest, always. A failed or abandoned run is a
    first-class tale; if this session did not clearly succeed, suggest `partial` or
    `failed` yourself. Never dress a failure up as a success.
- **Cancel** — nothing leaves the machine.

If flags change, return to step 2 and show the new preview.

## 4. Publish

Only after the user has confirmed the previewed composition:

```bash
npx -y taleseal@0.3.0 seal --transcript <path> --yes <exactly the flags that were previewed>
```

`--yes` is required because this shell is not a TTY; it is legitimate here only because the
user has just seen this composition's preview and said yes. Report the returned tale URL,
and note that anyone holding the URL can read the tale.

## 5. If there is no API key

Publishing fails with "no API key — TALESEAL_API_KEY is unset…". Signing in is one command,
but it needs the user's own terminal (this shell is not a TTY, and the login opens a
browser). Walk the user through it, then retry:

1. Ask the user to run `npx -y taleseal@0.3.0 login` in their own terminal. The browser
   opens; they approve there — signing up on the way if needed — and a key is created and
   stored at `~/.config/taleseal/config.json` (mode 0600) automatically. Nothing to copy
   or paste. Works over SSH too: they open the printed URL on any device and match the code.
2. Only for CI or a machine with no browser anywhere: mint a key by hand at
   https://taleseal.com/dashboard and set `TALESEAL_API_KEY`, or run
   `npx -y taleseal@0.3.0 login --key tk_…`. Never paste a key into this conversation —
   transcripts are exactly what gets sealed.
3. Once the user says they are signed in, retry step 4 if the preview was already
   confirmed; otherwise start again at step 2.
