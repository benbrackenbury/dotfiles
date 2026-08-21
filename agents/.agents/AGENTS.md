# AGENTS.md (global)

Conflicting rules from project specific AGENTS.md always overrides these rules.
But obviously, always use these global rules as a base.

## Coding Style

Prefer simplest solutions possible that remain congruent with the project's existing coding style.
Prefer a YAGNI approach to solutions.
Always think about if a solution can be more simple. I always end up asking agents if
a solution can be acheived a simpler way - you should do this yourself instead of me 
asking you to do it.

Explain generated code concisely and clearly.

# Testing

If the hostname is `wp.gsdev.uk`, you are on a remote dev server, and therefore cannot
use browser testing tools such as Playwrite and Chrome Dev Tools MCP.

For NodeJS etc projects, always assume there is already a `npm watch` etc
running, don't try and check yourself, and don't attempt to build yourself.
