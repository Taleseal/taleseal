# taleseal — Claude Code plugin

Write up your Claude Code session's work as a shareable **tale**. The plugin adds:

- **`/taleseal:tale`** — compose the session's work into a readable page, validate it,
  draft it privately behind a DRAFT banner for you to review in the browser, then publish
  to a short URL once you confirm. Optionally pass what the tale should cover and who it is
  for.
- **A tale skill** — say "turn this into a page", "write this up" or "make a shareable link
  for this" in plain words and Claude composes the page and walks the same
  validate → draft → review → publish flow, with iterative `revise` / `ops` edits.

A tale is composed, not captured: Claude decides what mattered and writes it up as blocks
(headings, prose, code, diffs, tables, charts, timelines, an evidence block citing the
sources), never a transcript dump. It renders at `taleseal.com/t/…` and is versioned —
revising keeps the link stable.

All redaction and publishing logic lives in the
[`taleseal` npm CLI](https://www.npmjs.com/package/taleseal); the plugin is a thin,
gate-respecting wrapper around it. Nothing is ever published without you reviewing the
private draft and the redaction report first.

## Install

Inside Claude Code:

```
/plugin marketplace add Taleseal/taleseal
/plugin install taleseal@taleseal
```

Or from a shell:

```sh
claude plugin marketplace add Taleseal/taleseal && claude plugin install taleseal@taleseal
```

The plugin invokes `npx -y taleseal@latest` — the [`taleseal` npm
package](https://www.npmjs.com/package/taleseal) — so it always runs with the current CLI.

It is deliberately not pinned: taleseal accepts publishes from the latest client only. An
older CLI composes against a stale schema and is refused with `426 Upgrade Required`, and
plugins do not auto-update, so a pin here would be a pin into a wall.

## First run: the API key

Composing and validating a tale needs no account. Publishing needs an API key, set up once,
in your own terminal:

```sh
npx -y taleseal@latest login
```

The browser opens: approve there — signing up on the way if needed — and a key is created
and stored at `~/.config/taleseal/config.json` (mode 0600) automatically. Nothing to copy
or paste. If you skip this, `/taleseal:tale` walks you through it the first time you confirm
a publish. On CI, mint a key in the [dashboard](https://taleseal.com/dashboard) and set
`TALESEAL_API_KEY`. `taleseal logout` removes the stored key.

## Usage

- `/taleseal:tale` — compose the session's work into a tale, review the draft, publish.
- `/taleseal:tale write up the payment fix for the platform team` — steer what it covers and
  who it is for.
- Or just ask: "turn this into a shareable page", "publish a tale of this work".

To change a published tale, ask Claude to revise it: it edits the private draft (block by
block, or a whole-file `revise`) and republishes through the same review gate, so the link
never changes. "Take it down" retracts it — every revision is destroyed and the URL 410s.

## Review is the gate, always

Every publish goes through a private draft you open in the browser. The CLI redacts secret
patterns before anything leaves your machine and shows an exposure report (paths, hosts,
emails) at the draft step; the draft URL is unguessable and noindexed. There is no
auto-publish hook and no capture path — a tale exists only because you reviewed it and
confirmed.
