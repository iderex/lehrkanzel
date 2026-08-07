# 0014 Where a statement lives before it has a proof

Decision 0012 forbids a half-finished proof from reaching the default branch.
That leaves a real question with no answer yet: where does a statement live
between the moment somebody decides it is needed and the moment it is proved.
Without an answer, the answer becomes a branch nobody merges, and the work that
has been done is invisible to everybody including the person who did it.

## The decision

A written blueprint accompanies the library. It holds every statement the plan
intends to prove, in ordinary mathematical prose, with the dependencies between
them.

Each statement carries exactly one of three statuses:

- stated, meaning the claim is written in prose and nothing else exists
- proved on paper, meaning an argument exists that a person has read and
  believes, and no formal counterpart exists
- proved in the tree, meaning a declaration exists in this repository and the
  statement is linked to it by name

A statement enters the blueprint when it is planned, which is before any file
mentions it. It is linked to its formal counterpart when that counterpart lands.
The dependency graph is generated from the blueprint rather than drawn by hand.

The blueprint is the only place where a statement without a proof exists. The
tree holds proved statements and nothing else. The other home for an unproved
statement, a placeholder declaration admitted without proof, is what 0012
forbids, and this file is the answer to the question that decision leaves open.

## Why

This is the direct answer to the risk the project recorded about itself before
starting: slow feedback, no intermediate results, and a quiet stop. A blueprint
converts a milestone from a binary into a count. Somebody can see that eleven of
nineteen statements in the variational core are proved, which is a fact about
progress that a tree containing only finished work cannot express.

It is also what makes the work divisible. A statement in the blueprint with its
dependencies drawn is a piece somebody can pick up without reading the rest, and
without it every piece of work needs the whole plan in somebody's head first.

The third reason is the one that matters for correctness. Writing the statement
in prose before writing it formally forces the two to be compared, which is
where the misformalised statement is caught. When the formal version lands, the
difference between what the blueprint said and what was proved is visible, and
it has to be explained or the blueprint has to be corrected.

Generating the graph rather than drawing it means it cannot claim a dependency
the text does not have.

## Rejected

- No blueprint, with the issue tracker as the plan. The tracker holds work and
  not statements, it has no dependency structure between mathematical claims, and
  it cannot say which of two statements has to be proved first.
- A checklist in the readme. It drifts within weeks and nothing compares it
  against the tree.
- Long-lived branches holding unfinished proofs. It is the usual answer and it
  moves the problem: the work is somewhere, nobody can see it, and it rots
  against the mathlib pin.
- An exception register in the tree permitting a placeholder where an issue is
  open. It is the same as allowing placeholders, with paperwork.

## What it costs

Every statement is written twice, once in prose and once formally. That is real
duplicated effort and it is the price of the comparison that catches the
misformalised statement, so it is spent deliberately rather than reluctantly.

Building the blueprint is a piece of tooling with its own dependencies and its
own build, which is a second thing to maintain alongside the library.

The blueprint can drift from the tree in a direction the tree cannot drift back:
a statement marked proved whose formal counterpart was later renamed, weakened
or removed. The tree has no way to notice, because nothing in it points at the
blueprint.

## The check, and what it cannot decide

Issue #45 is the check that compares the two, and it is open. What it is asked
to refuse is a blueprint statement marked proved in the tree with no declaration
of that name in the library, which covers the drift named above in the direction
a rename produces.

What it cannot decide is the thing the blueprint exists for. Given a prose
statement and a declaration that carries its name, no check reads the prose and
the formal statement and judges whether they say the same thing. A declaration
with the right name and a hypothesis the prose never mentioned passes it. A
declaration whose conclusion is weaker than the prose claims passes it. The
comparison the blueprint is built to force is a comparison a person makes, and
the review is where a wrong one is caught.

So the check makes the link real and never makes it true, and issue #45 should
not be read as closing that gap.
