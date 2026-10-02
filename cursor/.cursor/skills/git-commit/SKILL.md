---
name: git-commit
description: Add and commit changes to a git repository.
---

# Git Commit

Used to add and commit unchecked changes to a git repository.

# Process

- Add changes to the git staging area.
- Commit the changes.
- DO NOT PUSH UNLESS EXPLICITLY REQUESTED.

# Conventional commits

Always use convetional commit prefixes to describe the changes, unless the existing commits in the 
repo do not follow the convention, in this case ask the user whether to use conventional commits or not.

Split up into mutiple smaller commits if it makes sense to do so.

# Message

The commit message should describe the changes as related to the question/prompt
asked by the user as opped to technical details.

For example, instead of "add tailwind hover: modififer to search-button element",
the message should be "add search button hover style".

If technical details would be useful, describe them in the message body.

Include a line at the end of the message body saying which models were used to generate the changes
in the commit, and another for which model actually committed the changes if it is different.

eg.

```
Work done by: GPT 5.6 Luna
Committed by: GPT 5.6 Luna
```

```
Work done by:
- GPT 6 Astra
- Claude Sonnet 5.5
```
