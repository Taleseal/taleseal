# Security

Report vulnerabilities to **hello@taleseal.com**. Please do not open a public issue for
anything sensitive.

Canonical disclosure details: https://taleseal.com/.well-known/security.txt — the taleseal
trust page is at https://taleseal.com/security.

Notes on this repository's posture:

- The plugins pin an exact `taleseal` npm version; no hook or command uses `@latest`.
- Nothing is published without a human confirming a local preview that includes the
  redaction report. Hooks that auto-publish are not bundled; the one example ships
  disabled, with a warning.
