# AGENTS.md (global)

Conflicting rules from project specific AGENTS.md always overrides these rules.

SIMPLICITY (non-negotiable)
- Ship the dumbest thing that works with existing patterns.
- No new files, helpers, types, abstractions, or config unless the current code already does that.
- Before writing code: state the simplest option in one sentence, print that sentence, then write only that.
- If you added layers I didn't ask for, you failed.

# Testing

If the hostname is `wp.gsdev.uk`, you are on a remote dev server, and therefore cannot
use browser testing tools such as Playwrite and Chrome Dev Tools MCP.

For NodeJS etc projects, always assume there is already a `npm watch` etc
running, don't try and check yourself, and don't attempt to build yourself.
