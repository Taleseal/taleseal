# taleseal — Claude Code plugin

Seal your Claude Code runs as shareable **tales**. The plugin adds:

- **`/taleseal:seal`** — preview the composed tale (title, beats, receipts, redaction
  report), confirm, publish, get the URL. Optionally pass `--title "…"`, `--outcome "…"` or
  `--status succeeded|partial|failed`.
- **A sealing skill** — say "seal this session" or "share what this run did" in plain words
  and Claude walks the same preview → confirm → publish flow.

All logic lives in the [`taleseal` npm CLI](https://www.npmjs.com/package/taleseal); the
plugin is a thin, gate-respecting wrapper around it. Nothing is ever published without you
seeing the preview and the redaction report first.

## Install

Inside Claude Code (two slash commands):

```
/plugin marketplace add vepler/taleseal
/plugin install taleseal@taleseal
```

Or from a shell:

```sh
claude plugin marketplace add vepler/taleseal && claude plugin install taleseal@taleseal
```

The plugin invokes `npx -y taleseal@0.1.0` — the pinned [`taleseal` npm
package](https://www.npmjs.com/package/taleseal). The version is pinned deliberately; new
plugin releases bump it.

## First run: the API key

Previews need no account — `/taleseal:seal` shows you the composed tale either way.
Publishing needs an API key, set up once:

1. Sign up at https://taleseal.com/signup.
2. Mint an API key in the dashboard.
3. Run `npx -y taleseal@0.1.0 login` and paste the key when prompted.

The key is validated against the server and stored at `~/.config/taleseal/config.json`
(mode 0600). If you skip this, `/taleseal:seal` walks you through it the first time you
confirm a publish. `taleseal logout` removes the key.

## Usage

- `/taleseal:seal` — preview the newest transcript for this project, confirm, publish.
- `/taleseal:seal --status failed` — seal an honest failure report (a first-class tale).
- `/taleseal:seal --title "…" --outcome "…"` — override the drifted title and state the
  verdict; a transcript has no conclusion of its own.
- Or just ask: "seal this session", "publish a tale of this run".

## Optional: auto-seal on session end (off by default)

You can add a hook so every session is sealed automatically when it ends. Claude Code hooks
receive JSON on stdin including `transcript_path`. Add this to your `settings.json` yourself
if you want it (`--yes` is required — hooks are not a TTY):

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -r .transcript_path | xargs -I{} npx -y taleseal@0.1.0 seal --yes --transcript {}"
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
