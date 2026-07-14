---
name: sealing
description: Seal the current Cursor agent session as a shareable published tale via the taleseal CLI. Use when the user says "seal this", "seal this session", "publish a tale", "share what this run did", or wants a shareable link to what happened in a session. Composes locally, shows a redaction preview, and publishes only after explicit confirmation.
---

# Sealing a session as a tale

A tale is the published, shareable narrative of one agent run — title, beats, receipts —
readable by anyone holding its URL. The CLI is `npx -y taleseal@latest` (plain Node, no
install). `seal --cursor` picks the newest Cursor transcript on this machine, which in a
live session is usually the session itself — if several Cursor windows are open, confirm
the pick with the user, or pin an explicit path with `--transcript <path>`.

## The flow — preview, confirm, publish

1. Run `npx -y taleseal@latest seal --cursor --preview [flags]` — local only, no key
   needed. Show the user the entire output verbatim, including the redaction report.
   Never skip or summarise this step: secrets travel nowhere without a human seeing what
   the scrubber caught.
2. Ask the user: publish as previewed, adjust flags first, or cancel. If flags change,
   re-preview.
3. On explicit confirmation only, run `npx -y taleseal@latest seal --cursor --yes [same
   flags]` and report the returned URL, noting that anyone holding it can read the tale.
   `--yes` is required because this shell is not a TTY; it is legitimate only because the
   user has just seen this exact composition's preview and said yes.

## Flags worth offering

- `--title "…"` — Cursor transcripts carry no session title, so without this the tale is
  titled by the opening prompt; offer a truer title, especially for long sessions.
- `--outcome "…"` — the verdict. A transcript has no conclusion of its own; without this
  flag the tale falls back to its closing words, which are rarely the verdict.
- `--status succeeded|partial|failed` — honest, always. The default is `succeeded`, so an
  unflagged failure would lie; suggest `partial` or `failed` when the session did not
  clearly succeed. A failure report is a first-class tale.

## No API key

Publishing fails with "no API key…". The fix happens in the user's own terminal, not in
this session: ask them to run `npx -y taleseal@latest login` — the browser opens, signs
them up on the way if needed, and stores the key automatically (nothing to copy or
paste). On CI, they mint a key at https://taleseal.com/dashboard and set
`TALESEAL_API_KEY`. Never ask for a key in chat — transcripts are exactly what gets
sealed. Previews need no key.
