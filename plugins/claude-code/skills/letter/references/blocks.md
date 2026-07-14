# The letter block vocabulary

Every field and limit below is taken from the letter schema; the CLI's
`letter validate` enforces exactly this. String limits are character counts;
the whole letter is capped at 1 MiB of JSON.

## The envelope

| Field | Type | Notes |
| --- | --- | --- |
| `version` | literal `1` | required |
| `title` | string 1–200 | required — write it as the claim |
| `standfirst` | string ≤300 | optional — one line under the title; drives the unfurl description |
| `recipient` | string ≤120 | optional greeting line, e.g. "For the Acme platform team" |
| `sender` | object | required — `{ "name": string 1–120, "org"?: string ≤120 }` |
| `stationery` | `"letter" \| "terminal" \| "brief" \| "ledger"` | optional, defaults to `"letter"` |
| `brandRef` | string ≤40 | optional account brand theme id (from `letter brand`) — the body never carries hex or fonts |
| `sourceRunId` | string ≤80 | optional private back-reference to the run this letter came from; never rendered as a link |
| `cta` | object | optional footer call to action — `{ "label": string 1–60, "url": http(s) URL ≤2048 }` |
| `blocks` | array 1–60 | required |
| `expiresAt` | ISO datetime string | optional — the letter 404s after this moment |

**Block grammar** (validated, not advisory): a `lead` must be the first block; two
consecutive `callout` blocks or two consecutive `line_chart` blocks are illegal — merge
them or separate them with prose; at most one `stat_tiles` block per letter.

**Code languages** (`code`, and `before_after` panels): `ts`, `js`, `tsx`, `jsx`,
`python`, `bash`, `json`, `yaml`, `diff`, `go`, `rust`, `sql`, `html`, `css`, `java`,
`c`, `cpp`, `ruby`, `php`, `kotlin`, `swift`, `text`. `text` is the honest fallback and
always renders — never guess a language not on this list.

**URLs** (`cta.url`, evidence `url`): http or https only, ≤2048 characters.

## The fifteen blocks

### lead

The executive summary a recipient reads when they read nothing else. Must be the first
block. `text`: 1–600.

```json
{ "kind": "lead", "text": "The double-charge in checkout is fixed, deployed and verified. One race between the payment webhook and the order writer caused it; the fix serialises them." }
```

### heading

Section title — write it as the claim, not a label. `text`: 1–200.

```json
{ "kind": "heading", "text": "The webhook and the order writer raced" }
```

### prose

Body copy in a strict markdown subset (never raw HTML). `markdown`: 1–8000.

```json
{ "kind": "prose", "markdown": "Under load, the payment webhook and the order writer both inserted a charge row. Neither held the idempotency key, so **both writes succeeded**." }
```

### callout

An aside with a tone. `tone`: `info` | `warning` | `success` | `note`; `title`: optional,
≤120; `body`: 1–1000. No two callouts in a row.

```json
{ "kind": "callout", "tone": "warning", "title": "Action needed on your side", "body": "Rotate the webhook secret before Friday — the old one was logged in plain text." }
```

### stat_tiles

The headline numbers — at most one per letter. `title`: optional, ≤120; `tiles`: 1–6,
each `{ label ≤60, value ≤30, delta?: ≤60, tone?: "good" | "flat" | "bad" }`.

```json
{ "kind": "stat_tiles", "tiles": [
  { "label": "duplicate charges", "value": "0", "delta": "was 41/day", "tone": "good" },
  { "label": "p95 checkout", "value": "312 ms", "tone": "flat" }
] }
```

### line_chart

A single series over ordered points. `title`: required, ≤120; `subtitle?`: ≤120;
`unit?`: ≤12 (y-axis suffix); `points`: 2–120 of `{ label?: ≤30, value: finite number }`;
`annotations?`: up to 4 of `{ index: int ≥0, text ≤60 }`; `endLabel?`: ≤30. No two in a row.

```json
{ "kind": "line_chart", "title": "Duplicate charges per day", "unit": "/day",
  "points": [ { "label": "Mon", "value": 38 }, { "label": "Tue", "value": 41 }, { "label": "Wed", "value": 0 } ],
  "annotations": [ { "index": 2, "text": "fix deployed" } ], "endLabel": "0/day" }
```

### table

`title?`: ≤120; `columns`: 1–8 strings ≤60; `rows`: 1–50 arrays of strings ≤200 — every
row must have exactly as many cells as there are columns.

```json
{ "kind": "table", "title": "Affected orders", "columns": ["Order", "Charged", "Refunded"],
  "rows": [ ["#48211", "twice", "yes"], ["#48217", "twice", "yes"] ] }
```

### code

`language`: one of the enum above; `filename?`: ≤300; `code`: 1–8000; `caption?`: ≤200;
`highlightLines?`: up to 40 positive 1-indexed integers.

```json
{ "kind": "code", "language": "ts", "filename": "src/payments/webhook.ts",
  "code": "const key = idempotencyKey(event);\nawait withLock(key, () => writeOrder(event));",
  "caption": "The write now runs under the idempotency lock.", "highlightLines": [2] }
```

### diff

Unified-diff hunks for one file. `filePath`: ≤300; `hunks`: 1–20, each
`{ oldStart, oldLines, newStart, newLines: int ≥0, lines: 1–80 strings ≤200 }` — every
line prefixed `" "`, `"+"` or `"-"`.

```json
{ "kind": "diff", "filePath": "src/payments/webhook.ts", "hunks": [
  { "oldStart": 12, "oldLines": 2, "newStart": 12, "newLines": 3,
    "lines": [ " const key = idempotencyKey(event);", "-await writeOrder(event);", "+await withLock(key, () =>", "+  writeOrder(event));" ] }
] }
```

### timeline

Ordered moments. `items`: 2–20 of `{ at: ≤40, title: 1–200, body?: ≤500 }` — `at` is a
free-form label ("09:41", "Day 2"), not a strict datetime.

```json
{ "kind": "timeline", "items": [
  { "at": "09:41", "title": "First duplicate charge reported", "body": "Support flagged order #48211 charged twice." },
  { "at": "11:05", "title": "Race identified in the webhook handler" }
] }
```

### before_after

Two labelled panels; each panel carries **exactly one** of `markdown` (≤2000) or `code`
(≤4000, with optional `language`), plus `label`: 1–60.

```json
{ "kind": "before_after",
  "before": { "label": "Before", "code": "await writeOrder(event);", "language": "ts" },
  "after":  { "label": "After",  "code": "await withLock(key, () => writeOrder(event));", "language": "ts" } }
```

### quote

`text`: 1–500; `attribution?`: ≤120.

```json
{ "kind": "quote", "text": "A retried webhook must be indistinguishable from the first delivery.", "attribution": "Payment provider integration guide" }
```

### checklist

Action items. `items`: 1–12 of `{ text: 1–200, owner?: ≤80, due?: ≤40 }`.

```json
{ "kind": "checklist", "items": [
  { "text": "Rotate the webhook secret", "owner": "your platform team", "due": "Fri" },
  { "text": "Enable idempotency alerts in the dashboard" }
] }
```

### evidence

The letter's credibility layer — what the research consulted, as a designed panel.
`title?`: ≤120; `items`: 1–30 of `{ kind: "web" | "pdf" | "doc" | "repo" | "dataset",
name: 1–120, url?: http(s) ≤2048, snippet?: ≤500, note?: ≤200 }`. The `snippet` is the
exact passage relied on, so the recipient can verify the source says it.

```json
{ "kind": "evidence", "title": "What we consulted", "items": [
  { "kind": "web", "name": "Stripe webhook best practices", "url": "https://docs.stripe.com/webhooks", "snippet": "Webhook endpoints might occasionally receive the same event more than once." },
  { "kind": "repo", "name": "payments-service", "note": "handler history reviewed back to the introduction of the race" }
] }
```

### divider

A hairline break between sections. No fields.

```json
{ "kind": "divider" }
```
