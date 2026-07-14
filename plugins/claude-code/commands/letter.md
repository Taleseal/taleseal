---
description: Write a customer-facing branded letter from this session's work — compose blocks, validate, draft, human review in the browser, publish
argument-hint: '[what the letter is about, and who it is for]'
disable-model-invocation: true
allowed-tools:
  - Bash(npx -y taleseal@latest letter*)
  - Bash(npx -y taleseal@latest login*)
---

Compose and publish a letter — the customer-facing document kind — from this session's
work. Only through the gate: a draft URL the human opens in a browser, explicit
confirmation, then publish. Never run `letter publish` unless the user has seen the draft
and approved it in this conversation.

Follow the `letter` skill: it carries the block vocabulary, the composition rules and the
full lifecycle. In short:

1. Compose `/tmp/taleseal-letter.json` per the skill's rules — `lead` block first as the
   executive summary, action titles throughout, one story per letter, stationery chosen
   for the recipient, and every source consulted in the `evidence` block. Layout, type
   and colour belong to the renderer: choose blocks, never pixels or hex values.
2. `npx -y taleseal@latest letter validate /tmp/taleseal-letter.json` — local, no key
   needed. Fix what it names by its JSON path and re-validate until it passes.
3. `npx -y taleseal@latest letter draft /tmp/taleseal-letter.json --yes` — creates the
   letter at its final URL behind a DRAFT banner. Give the user the URL and ask them to
   read the real page; the draft is what a browser shows, and no summary substitutes for
   it.
4. Ask with AskUserQuestion: publish as drafted, revise first, or cancel. Only on explicit
   confirmation: `npx -y taleseal@latest letter publish <letter-id> --yes`. Report the
   URL, noting anyone holding it can read the letter.

To change a published letter, `letter revise <letter-id> /tmp/taleseal-letter.json --yes`
stores a new draft the customer cannot see, then `letter publish <letter-id> --yes` after
confirmation — the link never changes. `letter retract <letter-id>` destroys every
revision and the URL 410s.

$ARGUMENTS describes what the letter is about and who it is for. If a brand theme is
wanted, `letter brand --name "Acme" --seed '#0E4F9E'` (or `--from-domain acme.com`) mints
one and prints its id for the letter's brand reference.

If a command fails with "no API key…": ask the user to run `npx -y taleseal@latest login`
in their own terminal (the browser signs them up and stores the key automatically; never
paste a key into this conversation), then retry.
