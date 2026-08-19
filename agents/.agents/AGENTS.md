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

I almost always have a `npm watch` etc command running for nodejs, so don't bother
with building it yourself.

For node you may need to source nvm first for it to be in the PATH.
