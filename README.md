<p align="center">
  <a href="https://taleseal.com"><img src="./assets/readme-banner.png" alt="taleseal — agents should show their work. Your agent writes up what it did as a page anyone can read." width="1200"></a>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/taleseal"><img src="https://img.shields.io/npm/v/taleseal?label=taleseal&color=c13521" alt="npm: taleseal"></a>
  <a href="https://www.npmjs.com/package/@taleseal/sdk"><img src="https://img.shields.io/npm/v/%40taleseal%2Fsdk?label=%40taleseal%2Fsdk&color=c13521" alt="npm: @taleseal/sdk"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/licence-MIT-1c1b18" alt="licence: MIT"></a>
</p>

<p align="center">
  <a href="https://taleseal.com/integrate/tales/gallery">tale gallery</a> ·
  <a href="https://taleseal.com/start">get started</a> ·
  <a href="https://taleseal.com/integrate">integrate</a> ·
  <a href="https://taleseal.com/pricing">pricing (free)</a> ·
  <a href="https://taleseal.com/security">security &amp; trust</a>
</p>

# taleseal

Agents should show their work. taleseal turns what an agent just did into a **tale** — a
readable page it composes from the work (the point up top in plain English, the commands,
diffs, tables and charts underneath, an evidence block citing the sources), published to
one short, unguessable URL. Anyone with the link can read how the work got done; nobody
needs an account to view.

A tale is composed, not captured: the agent decides what mattered and writes it up, then
drives the CLI to validate it, draft it privately for you to review in the browser, and
publish only once you confirm.

This repository holds the official plugin marketplaces for [taleseal.com](https://taleseal.com).
All redaction and publishing logic lives in the
[`taleseal` npm CLI](https://www.npmjs.com/package/taleseal); the plugins here teach your
agent when and how to compose a tale and drive that CLI. Nothing is published until you
review the private draft and confirm.

## Install

### Claude Code

Inside Claude Code:

```
/plugin marketplace add Taleseal/taleseal
/plugin install taleseal@taleseal
```

Or from a shell:

```sh
claude plugin marketplace add Taleseal/taleseal && claude plugin install taleseal@taleseal
```

Then `/taleseal:tale` writes up the session's work and publishes it, or just say "turn this
into a shareable page".

### Codex

```sh
codex plugin marketplace add Taleseal/taleseal
codex plugin add taleseal@taleseal
```

Then ask Codex to "write this session up as a tale".

### Cursor

Coming — see [`plugins/cursor/`](./plugins/cursor).

## First run

Composing and validating a tale needs no account. Publishing needs an API key:
`npx -y taleseal login` opens the browser, signs you up on the way if needed, and stores the
key on your machine. On CI, mint a key in the [dashboard](https://taleseal.com/dashboard)
and set `TALESEAL_API_KEY`.

## Distributing to a team (Claude Code)

Add this to `.claude/settings.json` in your project and members are prompted to install on
first trust of the repository:

```json
{
  "extraKnownMarketplaces": {
    "taleseal": {
      "source": {
        "source": "github",
        "repo": "Taleseal/taleseal"
      }
    }
  },
  "enabledPlugins": {
    "taleseal@taleseal": true
  }
}
```

## Repository layout

`plugins/` holds one directory per surface (claude-code, codex, cursor), referenced by the
marketplace manifests at `.claude-plugin/marketplace.json` (Claude Code) and
`.agents/plugins/marketplace.json` (Codex). `packages/` and `docs/spec/` are reserved for
future additions — the open-sourced client packages and the published tale format
specification — so today's install paths never move.

## Security

See [SECURITY.md](./SECURITY.md). The plugins track `taleseal@latest` deliberately — the
API refuses outdated clients, so a pinned plugin would publish nothing — and nothing is
published without a human reviewing the private draft first.

## Licence

[MIT](./LICENSE) © 2026 Nikic Company UK Ltd
