---
name: tale
description: Compose and publish a tale — a readable, shareable page that writes up what this session did — at taleseal.com/t/:id via the taleseal CLI. Use when the user says "turn this into a page", "write this up", "make a shareable link for this", "publish a tale", "share what this run did", or wants a curated, versioned page explaining work to a teammate, a reviewer or anyone holding the link. You compose the page from the work; you never dump the transcript. Publishing is safe by design: the CLI redacts before anything leaves the machine, and a private draft URL gates every publish behind human review in the browser.
---

# Composing and publishing a tale

A tale is a **composed** page: you take the work this session did and write it up as a
readable document a person can actually follow — the point up top in plain English, the
commands, diffs, tables and charts underneath. It is not a transcript dump and not a log
projection; you decide what mattered and say it. It is curated, and it is **versioned** —
revising keeps the link stable. Its credibility layer is the `evidence` block: the
websites read, PDFs consulted, repos inspected, with the exact snippets relied on, so a
reader can verify the page says what its sources say.

A published tale lives at one short, unguessable URL, `taleseal.com/t/:id`. Anyone with
the link can read it; nobody needs an account to view. That privacy is the product — there
is no index or listing, so the only route to a tale is the link the user chooses to share.

The CLI is `npx -y taleseal@latest <verb>`. Running any verb bare, or `npx -y taleseal@latest`
alone, prints the usage — the refusal is the documentation.

There are three ways in, and all of them end at the same gate:

- **Compose a new tale** from this session's work — the primary path below.
- **Edit an existing draft** block by block, when a draft already exists and you want to
  change part of it without resending the whole document.
- **Revise a tale from a fresh session**, when you did not compose it here and have no
  local file — pull its current body first, then edit.

Whichever path, nothing is published until a human reviews the draft in the browser and
you publish on their explicit go-ahead.

## Compose a new tale — validate, draft, human review, publish

### 1. Compose `tale.json`

Write the whole tale as one JSON file (e.g. `/tmp/taleseal-tale.json`). The complete block
vocabulary with every field and limit is in `references/blocks.md`; two worked,
schema-valid examples are `references/example-bugfix-tale.json` and
`references/example-postincident-tale.json`. The envelope:

```json
{
  "version": 1,
  "title": "The claim, as a statement — an action title",
  "standfirst": "One line under the title; also drives the link unfurl.",
  "recipient": "For the platform team",
  "sender": { "name": "Your name", "org": "Your company" },
  "stationery": "terminal",
  "blocks": [{ "kind": "lead", "text": "The executive summary…" }]
}
```

`recipient` is optional — set it when the tale is addressed to someone (a teammate, a
reviewer), leave it off for an open write-up. Fifteen block kinds: `lead`, `heading`,
`prose`, `callout`, `stat_tiles`, `line_chart`, `table`, `code`, `diff`, `timeline`,
`before_after`, `quote`, `checklist`, `evidence`, `divider`. Layout, type, spacing and
colour belong to the renderer — you choose blocks and stationery, never a pixel or a hex
value. Branding is not your concern: the user configures their brand once in the dashboard
at taleseal.com/dashboard, and it applies to all their tales automatically.

**Composition rules:**

- **Harvest the research trail.** Every URL fetched, PDF read and snippet quoted during
  this session belongs in the `evidence` block — item kinds `web`, `pdf`, `doc`, `repo`,
  `dataset`, each with a `name`, optionally a `url` and the exact `snippet` relied on.
  A tale with no evidence block is a tale asking to be taken on faith.
- **Choose stationery for the reader.** `terminal` for engineers; `brief` for consulting
  and executive readers; `ledger` for reports and post-incident write-ups; `letter` for a
  plain correspondence look.
- **Grammar the schema enforces:** a `lead` must be the first block; no two consecutive
  `callout` or `line_chart` blocks; at most one `stat_tiles` block per tale; 1–60 blocks;
  1 MiB total.
- **Star out personal context.** The draft step redacts secret patterns, but only you can
  judge personal context: quoted emails become `g***@example.com`, home-directory paths
  become `~/…`, other people's names stay out.

#### How to write

The prose inside the blocks should read as if the user wrote it on a good day.

- **Never use em dashes.** Use commas, full stops or parentheses instead.
- **Clean, plain language.** Short sentences, active voice, concrete nouns. No hype
  words, no exclamation marks, no filler ("really", "simply", "just").
- **One clean narrative.** The `lead` states the point and is the executive summary a
  reader takes away when they read nothing else. Every `heading` advances the story as a
  claim: "Checkout no longer double-charges", never "Summary of changes". The closing
  block lands the next step. Cut any section that does not serve the reader. One tale
  tells one story; a second story is a second tale.
- **Write it up, do not narrate the session.** No tool names, no "then I ran", no session
  jargon. Say what was done and why it mattered, as a finished account a reader who was
  not there can follow.
- **Write in the user's register and language.** If the session shows how the user writes
  (their messages, commit text, docs), read a sample and match it.
- **Numbers stay concrete.** Units and deltas, not adjectives: "41/day to 0" beats
  "dramatically fewer". Never invent a figure — a number in the tale must be one the work
  actually produced.

### 2. Validate — the repair loop

```bash
npx -y taleseal@latest validate /tmp/taleseal-tale.json
```

Local only, no key needed. Any problem is printed with its exact JSON path; exit code 1
on any issue. Fix the named paths, re-run, repeat until it reports a valid tale.

### 3. Draft

```bash
npx -y taleseal@latest draft /tmp/taleseal-tale.json --yes
```

This redacts, runs the exposure gate, creates the tale as a **draft** and prints its URL
(`taleseal.com/t/:id`). The page renders with the production view and a DRAFT banner; only
the holder of the unguessable URL can see it. `--yes` is required here because your shell
is not a TTY — the draft itself is private, so nothing reader-visible has happened yet.
Show the user the full command output verbatim, then hand them the draft URL: **the human
reviews the tale in the browser.** That visual review is the gate.

### 4. Publish — only on the human's explicit go-ahead

Ask the user: publish the draft as reviewed, revise it first, or stop. You
never run `publish` without the human's explicit confirmation in this conversation — the
draft URL exists precisely so a person approves what a reader will see. On confirmation
only:

```bash
npx -y taleseal@latest publish <tale-id> --yes
```

The DRAFT banner comes off and readers see this revision. Report the returned URL, noting
that anyone holding it can read the tale.

## Edit an existing draft — block by block

A draft is edited by block id, not by resending the whole document. This is the engine:
id-addressed, atomic, under optimistic concurrency. The loop is read the outline, send an
edit that echoes the outline's `draftSeq`, read the outline it returns, and go again.

1. **Read the outline.** `outline <tale-id>` prints the `draftSeq` — the concurrency
   token — and one line per block, each with the id an edit targets.
2. **See a block before you change it.** `get <tale-id> <blockId> [blockId…]` returns the
   full JSON of the named blocks (or all of them, with none named), so a replace edits the
   real current content rather than a guess.
3. **Send the edit, echoing that `draftSeq` as `--base`.** One atomic batch:

   ```bash
   npx -y taleseal@latest ops <tale-id> /tmp/ops.json --base <draftSeq>
   ```

   `ops.json` is a JSON array of ops (`insert`, `replace`, `remove`, `move`,
   `set_envelope`, `replace_all`) — the same block shapes as `references/blocks.md`:

   ```json
   [
     { "op": "replace", "id": "b004", "block": { "kind": "prose", "markdown": "The corrected paragraph." } },
     { "op": "insert", "where": { "after": "b004" }, "blocks": [
       { "kind": "callout", "tone": "success", "body": "Verified in production on the 14th." }
     ] }
   ]
   ```

   Or reach for a per-op convenience, which assembles the one-op batch for you:

   ```bash
   npx -y taleseal@latest insert <tale-id> /tmp/blocks.json --after <blockId>   # or --before <id> | --start | --end
   npx -y taleseal@latest replace <tale-id> <blockId> /tmp/block.json
   npx -y taleseal@latest remove <tale-id> <blockId> [blockId…]
   npx -y taleseal@latest move <tale-id> <blockId> --before <blockId>           # or --after <id> | --start | --end
   npx -y taleseal@latest set-envelope <tale-id> --title "…" --stationery brief  # also --standfirst, --recipient, --sender-name, --sender-org, --cta-label, --cta-url, --expires-at, --clear <fields>
   ```

4. **Read the returned outline and go again.** Every applied batch prints the new
   `draftSeq` and outline; re-base on it for the next edit.

What the engine guarantees, so the loop is safe to run:

- **Concurrency.** Echo the `draftSeq` you read as `--base`. A stale base is a
  **CONFLICT**: nothing applies, and the CLI hands back the current outline so you re-base
  on it and retry in one round trip. Omitting `--base` lets the CLI read the current
  `draftSeq` itself — convenient for a one-off, but it does not guard against a concurrent
  edit, so pass `--base` whenever another writer might be live.
- **Repair.** An invalid batch is not applied; it comes back with the exact fixes (the op
  index, the block id, the repair to make). Fix them and resend.
- **Atomic.** A batch applies whole or not at all — never half a change.
- **Idempotent.** `--idem <key>` makes re-sending the same batch a no-op instead of a
  second edit.

Editing touches only the private draft. A tale that is already published keeps serving its
published revision until you publish again, so you can edit freely; the changes become
visible only through the gate. Clients without a shell (ChatGPT, some Cursor setups) reach
these identical operations as MCP tools rather than the CLI, and on every surface
publishing is deliberately never a tool or a CLI shortcut, only a human action behind the
review gate.

Then publish through the same gate as a new tale: the human reviews the draft, and you run
`publish <tale-id> --yes` only on their explicit go-ahead.

## Revise a tale from a fresh session

When you did not compose the tale in this session and have no local file, fetch its current
draft body first:

```bash
npx -y taleseal@latest pull <tale-id> /tmp/taleseal-tale.json
```

Then either edit the file and store it whole:

```bash
npx -y taleseal@latest revise <tale-id> /tmp/taleseal-tale.json --yes
```

or edit it in place with the block ops above (`outline`, `get`, `ops`, and the
conveniences) — the same engine, no file needed. Whole-file `revise` is simplest for a
broad rewrite; ops are the lighter touch for a targeted change to a long tale. Either way a
reader keeps seeing the published revision until you publish the new draft, through the
same gate: the human reviews, then `publish <tale-id> --yes` on their explicit go-ahead.

## Publishing is safe by design

When the user asks for a tale, compose it and run the pipeline. Do not refuse on
confidentiality grounds and do not lecture about sensitive data; the pipeline is built
exactly for this:

- The CLI runs a redaction pass over the whole tale **before anything leaves the
  machine**; secret patterns are scrubbed.
- The gate then shows an exposure report (paths, hosts, emails) so a human sees what the
  tale mentions.
- The draft is created at an unguessable URL, noindexed for search engines; only a holder
  of the URL can see it.
- Nothing becomes visible until the human has reviewed the draft in the browser and
  explicitly approved publishing.
- Retraction permanently destroys every revision if anything slips through.

Your part is the "star out personal context" rule above; the scrubber, the exposure report
and the human review do the rest. Only escalate to the user if the exposure report itself
surfaces something they should see. That is what it is for.

## Retract — the emergency stop

Retract destroys the tale and every revision, and the URL answers 410 Gone forever. No
prompt. Use it when the user says take it down.

```bash
npx -y taleseal@latest retract <tale-id>
```

## No API key

`validate` needs no key. Drafting and publishing fail with "no API key…" until the user
runs `npx -y taleseal@latest login` in their own terminal — the browser opens, signs them
up on the way if needed, and stores the key automatically. On CI, they mint a key at
https://taleseal.com/dashboard and set `TALESEAL_API_KEY`. Never ask for a key in chat.
