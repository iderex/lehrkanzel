# 0001 How a decision is recorded

This directory holds the decisions the library rests on. A decision that lives
in a commit message, a review thread or somebody's memory cannot be argued with
a year later, and in a formalisation the first sign that it was never really
made is a proof that quietly assumes the opposite. A setting chosen badly is not
discovered by a failing build. It is discovered when a theorem turns out to be
provable and to say something nobody wanted.

This file is itself decision 0001, and the form it describes applies to it.

## The decision

One file per decision, named `docs/decisions/NNNN-short-name.md`, where `NNNN`
is a four-digit number allocated in order and never reused. A number belongs to
a decision for as long as the directory exists, including after the decision has
been superseded.

Four sections, and nothing else is required:

- what was decided
- why
- which alternatives were rejected and for what reason
- what the decision costs

The cost section is not optional politeness. A decision with no stated cost is
one where the alternatives were never really examined, and it is the section a
later reader has the most use for, because it tells them which pain was chosen
deliberately and which is a defect.

A decision that turns out wrong is not edited. A new file supersedes it by
number, names the file it replaces in its own first paragraph, and the old file
stays in the tree carrying a line at the top saying which file superseded it and
on what date. The reason a decision was wrong is worth as much later as the
reason its replacement is right, so the record of the mistake is kept rather
than overwritten.

A decision file may be corrected for a typographical error, a broken reference,
or a fact that was measured wrongly, and such a correction says in its commit
message what was wrong and how it was found. Changing what was decided is not a
correction.

## Why

The mathematical setting is the whole architecture here. Whether the
configuration space is a vector space or a manifold decides which upstream API
is reachable, how long a proof is, and whether the headline theorem is the one a
physicist would recognise. Changing it later is not a refactor, it is a rewrite
of every statement in the tree. So the setting is argued in a file first, and
the first source file under the library root comes after it.

Numbered files rather than a single document means two decisions can be argued
in parallel without touching the same bytes, and it means a decision can be
cited by number from a docstring, an issue or a review without a link that rots
when a heading is renamed.

Superseding rather than editing keeps the history readable in the tree rather
than only in the log. Somebody who arrives at a decision that looks strange can
read the file that replaced it and the file it replaced, in the order they were
written, without reconstructing anything.

## Rejected

- One long document with a section per decision. Easier to read end to end, and
  every parallel change to it collides. It also makes a decision hard to cite,
  because a section heading is not a stable name.
- Recording decisions in the issue that argued them. The argument is already
  there and it is the right place for it, but an issue is a conversation with a
  beginning and no defined end state, and a reader cannot tell which part of it
  is the decision and which part is a position somebody later abandoned.
- Editing a decision in place when it changes. Shorter directory, and it
  destroys the thing that makes a wrong decision useful later.
- Free-form files with no required sections. Faster to write, and the section
  that goes missing is always the cost one.

## What it costs

Four sections per file is a fixed overhead on a small decision, and some
decisions here are small. The overhead is accepted because the alternative is a
rule that applies only to decisions somebody judged large enough, which is a
rule that is not applied.

The directory grows monotonically and superseded files stay in it, so a reader
who arrives late has to check whether a file is current before trusting it. The
supersede line at the top of a replaced file is what makes that cheap, and it is
the one thing in this form that a reader has to be able to rely on.

Nothing refuses a decision file that is missing a section today, and nothing
refuses one that names a superseded file which does not exist. Both are the
check asked for in issue #1, and until it exists this form is carried by the
people writing the files and by review, not by a machine.
