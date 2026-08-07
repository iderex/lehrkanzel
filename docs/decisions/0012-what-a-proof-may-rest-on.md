# 0012 What a proof may rest on

This is the integrity decision of the whole repository. Everything else here is
a matter of taste compared with it, because a library of theorems whose proofs
rest on something unproved is not a weaker library. It is a different object
that looks identical from the outside.

The failure is quiet by construction. A placeholder standing in for a missing
proof produces a file that builds, a declaration that exists, a name that can be
cited, and a warning that scrolls past. A library can reach a hundred theorems
in that state and every one of them is worthless, and nothing in the ordinary
build output distinguishes it from the real thing.

## The decision

No declaration in the library may be admitted without a proof, and no proof may
rest on anything beyond the three foundational axioms the underlying logic is
built with. Nothing may be closed by an evaluator that runs outside the kernel,
and nothing in the mathematical part of the tree may be marked as unsafe,
partial, or implemented by external code.

Four things are refused anywhere under the library root:

- a placeholder standing in for a missing proof, and the axiom the elaborator
  introduces on its behalf
- a declaration introducing a new axiom
- a proof step that appeals to compiled evaluation rather than to kernel
  reduction
- any escape from the termination and safety checks

The three axioms a proof may rest on are propositional extensionality, the
axiom of choice in its classical form, and the soundness of quotients. They are
the ones the ambient library is built with, and the expected report for every
public result in this tree names those three and nothing else.

The report is per declaration and positive rather than negative. For every
public result the library states which axioms it depends on, produced by the
command the ecosystem already provides for the purpose, and the expected answer
is the same three every time. A report saying a declaration depends on the
placeholder axiom is the failure this decision exists to catch, and it is
reported as a named declaration with the chain that reached it rather than as a
count.

A grep for a forbidden word is the cheap half and it is not the check. A
declaration can depend on a placeholder through six intermediate lemmas in three
files without the word appearing anywhere near it, and that is the case that
actually occurs, because it is what a half-finished piece of work looks like
after somebody has moved on to the next file.

This document does not quote the placeholder token itself. A greppable
invariant refusing the token in tracked text would otherwise refuse this file,
and the rule would be carrying an exception on the day it landed. The command
that lists occurrences in the tree stands in place of the literal, and it is the
one the check runs.

## Where a half-finished proof lives instead

In the blueprint, decided in 0014. A statement can be planned, given its
dependencies and drawn in the graph long before it is proved, and that is where
a partial result lives. It does not live in the tree behind a placeholder, and
it does not live in a branch that is merged with a note.

This is what makes the rule affordable rather than merely strict. Refusing an
unfinished proof in the tree without giving it somewhere else to be is a rule
that gets suspended the first time it is inconvenient.

## Why

The claim this repository makes is that a machine checked these statements. That
claim is exactly as strong as the weakest thing any proof leans on, and it is
not observable from the source. The only way to state it truthfully is to derive
it from the environment after checking, which is what the axiom report does.

Doing this at the start rather than before the first release is not caution. It
is the difference between a rule and a cleanup. A tree with fifty declarations
can be brought into this state in an afternoon. A tree with five hundred cannot,
and the pressure at that point is to add an exception register, which is how the
rule turns into a list of things that are allowed to be false.

Refusing the compiled evaluator is a narrower point and worth stating
separately. Closing a goal by running compiled code puts the compiler and the
runtime into what has to be trusted, and there is nothing here that needs it. No
result in this plan is a computation over a large finite object.

The report is positive rather than negative because a negative report can only
refuse the failures somebody thought of. Listing what each declaration actually
depends on refuses everything that is not the expected three, including the ones
nobody has thought of yet.

## Rejected

- Allow placeholders during development and clear them before a release.
  Universal practice, and it is what produces the libraries this rule exists to
  avoid. The half-proved state is fine. What is refused is that state reaching
  the default branch.
- Grep for the forbidden words and call it done. Cheap, and blind to a
  dependency reached through an import chain.
- Allow a placeholder if it carries a comment and an issue number. It makes the
  debt visible to a person reading that file and invisible to everybody who
  cites the theorem.
- Allow the compiled evaluator with a note in the docstring. There is no result
  here that needs it, so the exception would exist only to be used by accident.
- Report a count of clean declarations rather than a per-declaration list. It
  reads well and it cannot be checked against the tree.

## What it costs

A branch cannot be merged with a proof half done. Work has to be cut into pieces
that each end at a completed proof, which makes the pieces smaller than they
would otherwise be and makes some of them awkward to place. That is the largest
single constraint this decision puts on how the work is divided, and it is why
the blueprint exists.

The report costs a step in every run, and it has to hold the expected axiom set
somewhere, which is a file that can drift from the tree. It is generated rather
than written, and the check compares a fresh run against what is committed.

The report is only as complete as the list of declarations it runs over. A
declaration that the report never reaches is not refused by it, so the list is
derived from the tree rather than maintained by hand.

## What is not enforced yet

Nothing in this repository refuses any of the four today. There is no library
root, no report and no check, so this file is a position and not a mechanism.
The check is issue #13 and the gate that runs it is issue #41, and until both
land the only thing standing behind this decision is that nobody has written a
proof yet.
