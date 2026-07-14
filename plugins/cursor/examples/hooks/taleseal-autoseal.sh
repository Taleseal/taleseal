#!/bin/bash
# Auto-seal the finished Cursor session as a tale. Publishes UNSEEN (--yes):
# only install this if you accept the redaction report without previewing it.
# Undo is `npx -y taleseal@0.3.0 retract --run <session id>`.
# Requires jq.
#
# Wired to sessionEnd because that is the event cursor-agent (the CLI) actually
# fires (verified 2026-07); the IDE fires it on session close. For per-completion
# sealing in the IDE only, switch the event to "stop" — but never register both,
# or a session publishes twice.
input=$(cat)
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
[ -z "$transcript" ] && transcript="${CURSOR_TRANSCRIPT_PATH:-}"
# Transcripts disabled, or an unexpected payload: do nothing, never block the agent.
if [ -z "$transcript" ] || [ ! -f "$transcript" ]; then
  echo '{}'
  exit 0
fi

# An honest status: don't let the default "succeeded" dress up an aborted run.
# sessionEnd carries final_status; stop carries status. Unknown vocabulary maps to
# partial — the claim that needs the least trust.
case "$(echo "$input" | jq -r '.final_status // .status // empty')" in
  completed | success) status="succeeded" ;;
  error* | fail*) status="failed" ;;
  *) status="partial" ;;
esac

npx -y taleseal@0.3.0 seal --transcript "$transcript" --yes \
  --status "$status" --publisher cursor-session-end-hook >/dev/null 2>&1

# A taleseal failure must never wedge the agent.
echo '{}'
exit 0
