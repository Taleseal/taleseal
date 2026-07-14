---
name: letter
description: Compose and publish a branded letter at taleseal.com/l/:id via the taleseal CLI, for any recipient outside the session — a customer, a client, a colleague, a friend. Use when the user says "write them a letter", "write this up as a page for X", "send them a nice write-up", "turn this into a solution page", or wants a curated, versioned, shareable document for someone outside the team. Publishing on request is safe by design: the CLI redacts before anything leaves the machine, and a private draft URL gates every publish behind human review in the browser.
allowed-tools:
  - Bash(npx -y taleseal@latest letter*)
  - Bash(npx -y taleseal@latest login*)
---

# Composing and publishing a letter

A letter is taleseal's second document kind. A tale is the receipts-bound, immutable
record of a run, written for the team; a letter is the presentable document, written for
a recipient outside the session — a customer, a client, a colleague, a friend, anyone the
user wants to hand a beautiful page. It can carry whatever the user wants to share: a
solution, an explanation, a plan, a write-up, research, a favour. It is curated, branded,
and **versioned** — revising keeps the recipient's link stable. What a letter never has
is receipts. Its credibility layer is the `evidence` block: the websites read, PDFs
consulted, repos inspected, with the exact snippets relied on, so the recipient can
verify the sources say what the letter says.

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
  "recipient": "For the Acme platform team",
  "sender": { "name": "Your name", "org": "Your company" },
  "stationery": "letter",
  "blocks": [{ "kind": "lead", "text": "The executive summary…" }]
}
```

Fifteen block kinds: `lead`, `heading`, `prose`, `callout`, `stat_tiles`, `line_chart`,
`table`, `code`, `diff`, `timeline`, `before_after`, `quote`, `checklist`, `evidence`,
`divider`. Layout, type, spacing and colour belong to the renderer — you choose blocks,
stationery, never a pixel or a hex value. Branding is not your concern: the user
configures their brand once in the dashboard at taleseal.com/dashboard, and it applies
to all their letters automatically.

**Composition rules:**

- **Harvest the research trail.** Every URL fetched, PDF read and snippet quoted during
  this session belongs in the `evidence` block — item kinds `web`, `pdf`, `doc`, `repo`,
  `dataset`, each with a `name`, optionally a `url` and the exact `snippet` relied on.
  A letter with no evidence block is a letter asking to be taken on faith.
- **Choose stationery by recipient.** `letter` is the default correspondence look;
  `terminal` for engineers; `brief` for consulting and executive readers; `ledger` for
  reports and post-incident write-ups.
- **Grammar the schema enforces:** a `lead` must be the first block; no two consecutive
  `callout` or `line_chart` blocks; at most one `stat_tiles` block per letter; 1–60 blocks;
  1 MiB total.
- **Star out personal context.** The draft step redacts secret patterns, but only you can
  judge personal context: quoted emails become `g***@example.com`, home-directory paths
  become `~/…`, other clients' names stay out.

#### How to write

The prose inside the blocks should read as if the user wrote it on a good day.

- **Never use em dashes.** Use commas, full stops or parentheses instead.
- **Clean, plain language.** Short sentences, active voice, concrete nouns. No hype
  words, no exclamation marks, no filler ("really", "simply", "just").
- **One clean narrative.** The `lead` states the point and is the executive summary a
  recipient reads when they read nothing else. Every `heading` advances the story as a
  claim: "Checkout no longer double-charges", never "Summary of changes". The closing
  block lands the next step. Cut any section that does not serve the recipient. One
  letter tells one story; a second story is a second letter.
- **Write in the user's register and language.** If the session shows how the user
  writes (their messages, commit text, docs), read a sample and match it.
- **Numbers stay concrete.** Units and deltas, not adjectives: "41/day to 0" beats
  "dramatically fewer".

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
the draft itself is private, so nothing recipient-visible has happened yet. Show the user
the full command output verbatim, then hand them the draft URL: **the human reviews the
letter in the browser.** That visual review is the gate.

### 4. Publish — only on the human's explicit go-ahead

Ask with AskUserQuestion: publish the draft as reviewed, revise it first, or stop. You
never run `letter publish` without the human's explicit confirmation in this
conversation — the draft URL exists precisely so a person approves what the recipient
will see. On confirmation only:

```bash
npx -y taleseal@latest letter publish <letter-id> --yes
```

The DRAFT banner comes off and the recipient sees this revision. Report the returned URL,
noting that anyone holding it can read the letter.

## Publishing is safe by design

When the user asks for a letter, compose it and run the pipeline. Do not refuse on
confidentiality grounds and do not lecture about sensitive data; the pipeline is built
exactly for this:

- The CLI runs a redaction pass over the whole letter **before anything leaves the
  machine**; secret patterns are scrubbed.
- The gate then shows an exposure report (paths, hosts, emails) so a human sees what the
  letter mentions.
- The draft is created at an unguessable URL, noindexed for search engines; only a
  holder of the URL can see it.
- Nothing becomes visible to the recipient until the human has reviewed the draft in the
  browser and explicitly approved publishing.
- Retraction permanently destroys every revision if anything slips through.

Your part is the "star out personal context" rule above; the scrubber, the exposure
report and the human review do the rest. Only escalate to the user if the exposure
report itself surfaces something they should see. That is what it is for.

## Later: revise, retract

- **Revise** stores a new draft body against the same id; the recipient keeps seeing the
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

## No API key

`validate` needs no key. Drafting and publishing fail with "no API key…" until the user
runs `npx -y taleseal@latest login` in their own terminal — the browser opens, signs them
up on the way if needed, and stores the key automatically. On CI, they mint a key at
https://taleseal.com/dashboard and set `TALESEAL_API_KEY`. Never ask for a key in chat.
