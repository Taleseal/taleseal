# taleseal — Claude Code plugin

Seal your Claude Code runs as shareable **tales**. The plugin adds:

- **`/taleseal:seal`** — preview the composed tale (title, beats, receipts, redaction
  report), confirm, publish, get the URL. Optionally pass `--title "…"`, `--outcome "…"` or
  `--status succeeded|partial|failed`.
- **A sealing skill** — say "seal this session" or "share what this run did" in plain words
  and Claude walks the same preview → confirm → publish flow.
- **A letter skill** — say "write the customer a letter" or "turn this into a solution
  page" and Claude composes a branded, customer-facing **letter** at `taleseal.com/l/…`:
  a curated solution page, not a transcript. It validates against the block schema,
  creates a private draft with a DRAFT banner for you to review in the browser, and
  publishes only after you confirm. Letters are versioned — revising keeps the customer's
  link stable — and cite their sources in an evidence block instead of carrying receipts.

All logic lives in the [`taleseal` npm CLI](https://www.npmjs.com/package/taleseal); the
plugin is a thin, gate-respecting wrapper around it. Nothing is ever published without you
seeing the preview and the redaction report first.

## Install

Inside Claude Code (two slash commands):

```
/plugin marketplace add Taleseal/taleseal
/plugin install taleseal@taleseal
```

Or from a shell:

```sh
claude plugin marketplace add Taleseal/taleseal && claude plugin install taleseal@taleseal
```

The plugin invokes `npx -y taleseal@latest` — the [`taleseal` npm
package](https://www.npmjs.com/package/taleseal) — so it always seals with the current CLI.

It is deliberately not pinned: taleseal accepts publishes from the latest client only. An
older CLI composes a thinner tale — it cannot capture what it was never taught to capture —
and a reader cannot tell a thin tale from an honest one, so a stale client is refused with
`426 Upgrade Required`. A pin here would be a pin into a wall.

## First run: the API key

Previews need no account — `/taleseal:seal` shows you the composed tale either way.
Publishing needs an API key, set up once, in your own terminal:

```sh
npx -y taleseal@latest login
```

The browser opens: approve there — signing up on the way if needed — and a key is created
and stored at `~/.config/taleseal/config.json` (mode 0600) automatically. Nothing to copy
or paste. If you skip this, `/taleseal:seal` walks you through it the first time you
confirm a publish. On CI, mint a key in the [dashboard](https://taleseal.com/dashboard) and
set `TALESEAL_API_KEY`. `taleseal logout` removes the stored key.

## Usage

- `/taleseal:seal` — preview the newest transcript for this project, confirm, publish.
- `/taleseal:seal --status failed` — seal an honest failure report (a first-class tale).
- `/taleseal:seal --title "…" --outcome "…"` — override the drifted title and state the
  verdict; a transcript has no conclusion of its own.
- Or just ask: "seal this session", "publish a tale of this run".

## Optional: auto-seal on session end (off by default)

You can add a hook so every session is sealed automatically when it ends. Claude Code hooks
receive JSON on stdin including `transcript_path`. Add this to your `settings.json` yourself
if you want it (`--quick --yes` is required — hooks are not a TTY and have no narrator):

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -r .transcript_path | xargs -I{} npx -y taleseal@latest seal --quick --yes --transcript {}"
          }
        ]
      }
    ]
  }
}
```

This is deliberately **not** bundled with the plugin, and think twice before adding it:
`--yes` skips the redaction gate, which is the whole point. Transcripts can contain secrets —
tokens pasted into prompts, env values echoed by tools. The CLI redacts common patterns, but
client-side redaction is best-effort. Sealing stays a manual, deliberate act by default.
