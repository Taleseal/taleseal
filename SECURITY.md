# Security

Report vulnerabilities to **hello@taleseal.com**. Please do not open a public issue for
anything sensitive.

Canonical disclosure details: https://taleseal.com/.well-known/security.txt — the taleseal
trust page is at https://taleseal.com/security.

Notes on this repository's posture:

- The plugins track `taleseal@latest` deliberately: the API enforces a minimum client
  version (an outdated CLI is refused with an upgrade instruction), so a pinned plugin
  would stop publishing. Every invocation is `npx -y taleseal@latest`, and repository CI
  fails on any pinned version. CI also fails if any plugin invokes a CLI verb outside the
  current allow-list, so a renamed or removed verb cannot ship broken.
- Nothing is published without a human reviewing the private draft in the browser, which
  includes the redaction and exposure report. There is no auto-publish hook and no capture
  path: a tale exists only because a person reviewed it and confirmed.
