---
name: letter
description: Compose and publish a customer-facing branded letter at taleseal.com/l/:id via the taleseal CLI. Use when the user says "write the customer a letter", "turn this into a solution page", "make a branded page of this fix", or wants a curated, versioned, shareable document for someone outside the team. You compose typed blocks against the schema; a private draft URL gates every publish behind human review in the browser.
---

# Composing and publishing a letter

A letter is taleseal's second document kind. A tale is the receipts-bound, immutable
record of a run, written for colleagues; a letter is the presentable solution, written
for a customer: curated, branded, and **versioned** — revising keeps the customer's link
stable. What a letter never has is receipts. Its credibility layer is the `evidence`
block: the websites read, PDFs consulted, repos inspected, with the exact snippets relied
on, so the recipient can verify the sources say what the letter says.

The CLI is `npx -y taleseal@latest letter <subcommand>`. Running it bare prints the full
usage — the refusal is the documentation.

## The flow — compose, validate, draft, human review, publish

### 1. Compose `letter.json`

Write the whole letter as one JSON file (e.g. `/tmp/taleseal-letter.json`). The complete
block vocabulary with every field and limit is in `references/blocks.md`; two worked,
schema-valid examples are `references/example-bugfix-letter.json` and
`references/example-postincident-letter.json`. The envelope:

```json
{
  "version": 1,
  "title": "The claim, as a statement — an action title",
  "standfirst": "One line under the title; also drives the link unfurl.",
  "recipient": "For your customer's platform team",
  "sender": { "name": "Your name", "org": "Your company" },
  "stationery": "letter",
  "blocks": [{ "kind": "lead", "text": "The executive summary…" }]
}
```

Fifteen block kinds: `lead`, `heading`, `prose`, `callout`, `stat_tiles`, `line_chart`,
`table`, `code`, `diff`, `timeline`, `before_after`, `quote`, `checklist`, `evidence`,
`divider`. Layout, type, spacing and colour belong to the renderer — you choose blocks,
stationery and (optionally) a brand reference, never a pixel or a hex value.

**Composition rules:**

- **Harvest the research trail.** Every URL fetched, PDF read and snippet quoted during
  this session belongs in the `evidence` block — item kinds `web`, `pdf`, `doc`, `repo`,
  `dataset`, each with a `name`, optionally a `url` and the exact `snippet` relied on.
  A letter with no evidence block is a letter asking to be taken on faith.
- **Choose stationery by recipient.** `letter` is the default correspondence look;
  `terminal` for engineers; `brief` for consulting and executive readers; `ledger` for
  reports and post-incident write-ups.
- **The heading is the claim.** Action titles throughout: "Checkout no longer double-charges",
  never "Summary of changes". The `lead` block comes first and is the executive summary a
  recipient reads when they read nothing else. One letter tells one story — split a second
  story into a second letter.
- **Grammar the schema enforces:** a `lead` must be the first block; no two consecutive
  `callout` or `line_chart` blocks; at most one `stat_tiles` block per letter; 1–60 blocks;
  1 MiB total.
- **Star out personal context.** The draft step redacts secret patterns, but only you can
  judge personal context: quoted emails become `g***@example.com`, home-directory paths
  become `~/…`, other clients' names stay out.

### 2. Validate — the repair loop

```bash
npx -y taleseal@latest letter validate /tmp/taleseal-letter.json
```

Local only, no key needed. Any problem is printed with its exact JSON path; exit code 1
on any issue. Fix the named paths, re-run, repeat until it reports a valid letter.

### 3. Draft

```bash
npx -y taleseal@latest letter draft /tmp/taleseal-letter.json --yes
```

This redacts, runs the exposure gate, creates the letter as a **draft** and prints its
URL. The page renders with the production view and a DRAFT banner; only the holder of the
unguessable URL can see it. `--yes` is required here because your shell is not a TTY —
the draft itself is private, so nothing customer-visible has happened yet. Show the user
the full command output verbatim, then hand them the draft URL: **the human reviews the
letter in the browser.** That visual review is the gate.

### 4. Publish — only on the human's explicit go-ahead

Ask the user: publish the draft as reviewed, revise it first, or stop. You
never run `letter publish` without the human's explicit confirmation in this
conversation — the draft URL exists precisely so a person approves what a customer will
see. On confirmation only:

```bash
npx -y taleseal@latest letter publish <letter-id> --yes
```

The DRAFT banner comes off and the customer sees this revision. Report the returned URL,
noting that anyone holding it can read the letter.

## Later: revise, retract

- **Revise** stores a new draft body against the same id; the customer keeps seeing the
  published revision until the next publish. Same gate: draft, human review, confirm,
  publish.

  ```bash
  npx -y taleseal@latest letter revise <letter-id> /tmp/taleseal-letter.json --yes
  npx -y taleseal@latest letter publish <letter-id> --yes   # after confirmation
  ```

- **Retract** is the emergency stop — it destroys the letter and every revision, and the
  URL answers 410 Gone forever. No prompt. Use it when the user says take it down.

  ```bash
  npx -y taleseal@latest letter retract <letter-id>
  ```

## Brand — once per account

```bash
npx -y taleseal@latest letter brand --name "Acme" --seed '#0E4F9E'
```

One seed colour; the server derives the full accessible palette and echoes it back with a
theme id. Alternatively `--from-domain acme.com` extracts the seed colour and logo from
the company's site (an explicit `--seed` still wins when both are given). Optional `--pairing letter|terminal|brief|ledger` and `--neutral warm|cool|gray`.
Set it up once, then reference it on letters with `"brandRef": "<theme-id>"` — the letter
body itself never carries hex values or fonts.

## No API key

`validate` needs no key. Drafting and publishing fail with "no API key…" until the user
runs `npx -y taleseal@latest login` in their own terminal — the browser opens, signs them
up on the way if needed, and stores the key automatically. On CI, they mint a key at
https://taleseal.com/dashboard and set `TALESEAL_API_KEY`. Never ask for a key in chat.
