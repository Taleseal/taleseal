---
name: sealing
description: Seal the current Codex session as a shareable published tale via the taleseal CLI. Use when the user says "seal this", "seal this session", "publish a tale", "share what this run did", or wants a shareable link to what happened in a session. You author the narrative against the CLI's skeleton; receipts stay mechanical; a redaction preview gates every publish.
---

# Sealing a session as a tale

A tale is the published, shareable narrative of one agent run, readable by anyone holding
its URL. It has two layers with different owners:

- **Receipts** (commands, test output, diffs, metrics) are extracted mechanically by the
  CLI from the transcript. You cannot add to them — that is what keeps a tale honest.
- **The narrative** (title, verdict, chapters, decisions) is YOURS to write. You were the
  session; you know what mattered. A machine projection of the transcript reads like a
  log file — your job is to write the story a person who was not there can actually read.

The CLI is `npx -y taleseal@latest` (plain Node, no install). Codex writes each session as
rollout JSONL under `~/.codex/sessions/YYYY/MM/DD/`; `--codex` picks the newest rollout,
which in a live session is usually the session itself. If several Codex windows are open,
pin an explicit path with `--transcript <path>` so the skeleton, preview and publish all
refer to the same run.

## The flow — skeleton, story, preview, confirm, publish

### 1. Get the skeleton

```bash
npx -y taleseal@latest seal --codex --skeleton /tmp/taleseal-skeleton.json
```

Local only, no key needed. The file holds the run's step groups (`s1`, `s2`, …), each with
its receipts already extracted and redacted, plus a `digest`. Read it.

### 2. Author the story

Write a story JSON (e.g. `/tmp/taleseal-story.json`):

```json
{
  "version": 1,
  "skeletonDigest": "<the skeleton's digest field>",
  "title": "What the run achieved, as a statement",
  "status": "succeeded | partial | failed",
  "outcome": "The executive summary — 2 to 4 sentences a layman reads first.",
  "beats": [
    {
      "steps": ["s1", "s2"],
      "title": "A chapter title that states what happened",
      "prose": "Plain-language prose. What was done, what was found, why it mattered.",
      "decisions": [{ "title": "…", "state": "chosen | set_aside", "why": "…" }],
      "widgets": [{ "kind": "stat_tiles", "tiles": [{ "label": "tests", "value": "42" }] }]
    }
  ]
}
```

**Authoring rules — the merge enforces most of these, so getting them right first saves a
round trip:**

- **5–12 chapters** for a typical session (hard cap 40). Every group id from the skeleton
  must appear **exactly once, in order**, across `beats[].steps` — fold quiet stretches
  into a neighbouring chapter rather than dropping them. The CLI refuses a story that
  drops, invents, duplicates or reorders work.
- **Write for a reader who was not there.** No tool names in prose ("checked the failing
  test", never "ran Bash"), no session jargon, no shorthand you invented mid-run. Each
  chapter: what happened and why it mattered, 2–6 sentences.
- **The verdict is the product.** `outcome` is what a reader takes away — write it last,
  write it plainly, and make `status` honest: a failed run publishes as `failed`. Never
  dress a failure up as a success.
- **Record decisions.** Wherever the session weighed options, fill `decisions[]` — the
  paths set aside and why are precisely what a reviewer cannot get from the diff.
- **Widgets only from receipts.** A `stat_tiles` or `table` widget may carry only numbers
  that appear in the skeleton's receipts or metrics. Never invent a figure.
- **Star out personal context.** The scrubber removes secrets, but only you can judge
  personal context: emails you quote become `g***@example.com`, home-directory paths
  become `~/…`, client names stay out unless the user says otherwise.

### 3. Preview

```bash
npx -y taleseal@latest seal --story /tmp/taleseal-story.json --skeleton /tmp/taleseal-skeleton.json --preview
```

Show the user the entire output verbatim, including the redaction and exposure report.
This step is never skipped: secrets travel nowhere without a human seeing what the
scrubber caught. If the CLI refuses the story, fix what it names and re-preview.

### 4. Confirm, then publish

Ask the user: publish as previewed, adjust the story first, or cancel. If the
story changes, re-preview. On explicit confirmation only:

```bash
npx -y taleseal@latest seal --story /tmp/taleseal-story.json --skeleton /tmp/taleseal-skeleton.json --yes
```

Report the returned URL, noting that anyone holding it can read the tale. Never run
`--yes` without a confirmed preview of the same composition in this conversation.

## Quick seal (no narration)

When the user explicitly wants speed over polish, the one-step flow takes `--quick` and
is gated the same way: `seal --quick --preview [--title … --outcome … --status …]`,
confirm, then `seal --quick --yes [same flags]`. Without `--quick` the CLI refuses an
un-narrated seal from an agent session and prints the narrated flow instead — quick is a
deliberate choice, never a fallback. The result is a mechanical projection — legible, but
not a story. Prefer the narrated flow whenever the tale is meant to be read by someone
else.

## No API key

Publishing fails with "no API key…". The fix happens in the user's own terminal, not in
this session: ask them to run `npx -y taleseal@latest login` — the browser opens, signs
them up on the way if needed, and stores the key automatically (nothing to copy or paste).
On CI, they mint a key at https://taleseal.com/dashboard and set `TALESEAL_API_KEY`. Never
ask for a key in chat — transcripts are exactly what gets sealed. Previews need no key.
