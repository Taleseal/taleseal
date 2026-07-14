---
name: sealing
description: Seal an agent session as a shareable published tale via the taleseal CLI. Use when the user says "seal this", "seal this session", "publish a tale", "share what this run did", or wants a shareable link to what happened in a session. Composes locally, shows a redaction preview, and publishes only after explicit confirmation.
allowed-tools:
  - Bash(npx -y taleseal@latest seal*)
  - Bash(npx -y taleseal@latest login*)
---

# Sealing a session as a tale

A tale is the published, shareable narrative of one agent run — title, beats, receipts —
readable by anyone holding its URL. The CLI is `npx -y taleseal@latest`; with no
`--transcript` flag it picks the newest Claude Code transcript for the current directory,
which in a live session is the session itself.

## The flow — preview, confirm, publish

1. Run `npx -y taleseal@latest seal --preview [flags]` — local only, no key needed. Show the
   user the entire output verbatim, including the redaction report. This step is never
   skipped: secrets travel nowhere without a human seeing what the scrubber caught.
2. Ask with AskUserQuestion: publish as previewed, adjust flags first, or cancel. If flags
   change, re-preview.
3. On explicit confirmation only, run `npx -y taleseal@latest seal --yes [same flags]` and
   report the returned URL, noting that anyone holding it can read the tale. Never run
   `--yes` without a confirmed preview of the same composition in this conversation.

## Flags worth offering

- `--title "…"` — long sessions drift from the task they opened with; offer a truer title.
- `--outcome "…"` — the verdict. A transcript has no conclusion of its own; without this
  flag the tale falls back to its closing words, which are rarely the verdict.
- `--status succeeded|partial|failed` — honest, always. The default is `succeeded`, so an
  unflagged failure would lie; suggest `partial` or `failed` when the session did not
  clearly succeed. A failure report is a first-class tale.
- `--transcript <path>` — seal a specific transcript instead of the newest one.

## No API key

Publishing fails with "no API key…". The fix happens in the user's own terminal, not in
this session: ask them to run `npx -y taleseal@latest login` — the browser opens, signs
them up on the way if needed, and stores the key automatically (nothing to copy or paste).
On CI, they mint a key at https://taleseal.com/dashboard and set `TALESEAL_API_KEY`. Never
ask for a key in chat — transcripts are exactly what gets sealed. Previews need no key.
