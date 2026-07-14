# Security

Report vulnerabilities to **hello@taleseal.com**. Please do not open a public issue for
anything sensitive.

Canonical disclosure details: https://taleseal.com/.well-known/security.txt — the taleseal
trust page is at https://taleseal.com/security.

Notes on this repository's posture:

- The plugins track `taleseal@latest` deliberately: the API enforces a minimum client
  version (an outdated CLI is refused with an upgrade instruction), so a pinned plugin
  would stop sealing. Every invocation is `npx -y taleseal@latest`, and repository CI
  fails on any pinned version.
- Nothing is published without a human confirming a local preview that includes the
  redaction report. Hooks that auto-publish are not bundled; the one example ships
  disabled, with a warning.
