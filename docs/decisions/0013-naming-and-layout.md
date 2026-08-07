# 0013 Naming, layout and documentation conventions

Naming in this ecosystem is a convention that makes a library searchable, and a
library that invents its own is one where nobody can guess the name of the lemma
they need. Layout matters for a second reason specific to this work: import
structure decides how long a change takes to check, and a badly placed import
costs minutes on every run for the life of the tree.

## The decision

The naming convention is mathlib's, taken whole rather than adapted. Names
describe the statement in the established vocabulary, capitalisation follows the
kind of the declaration, and a name is built from the shape of the conclusion.

The style rules for line length, indentation and the placement of binders are
mathlib's as well, and the tooling that checks them is taken from there rather
than written here. In practice that is the linter set `lake lint` runs together
with the style checks distributed with mathlib, adopted as they stand.

Every public declaration carries a docstring. For a definition the docstring
says what the object is, in words a reader of the subject would use. For a
theorem it says what the theorem says, and where the statement corresponds to a
named result in the literature it names it.

Every file carries a module docstring with a heading, a statement of what the
file contains, the main results by name, and, where the file makes a choice a
reader could be surprised by, a note saying which decision file argued it.

The module hierarchy follows the mathematical structure rather than the
milestones. Files import only what they use, and a file that would import the
whole library to reach one lemma moves the lemma instead.

## Why

Adopting a convention wholesale is what makes the library legible to somebody
arriving from the surrounding ecosystem, and it is the precondition for any file
ever being offered upstream. A local convention that is defensible in isolation
still costs every reader the effort of learning it.

Docstrings on everything is a stronger rule than it looks, and it is here
because of what this library is. A theorem's name and its formal statement are
both compressed, and the gap between what a reader believes a name means and
what the statement says is the one error this project can make that a machine
will not catch. The kernel checks the proof, not the name. The docstring is
where that gap is closed, so it is required rather than encouraged.

Import discipline is a performance decision. Checking is the slow step on this
board and an import pulls in everything transitively, so a careless import in a
file near the root is paid by every contributor on every run.

## Rejected

- A local naming convention chosen for readability in this domain. Physics
  vocabulary and mathlib vocabulary disagree in places and it is tempting to
  prefer the former. Rejected because the search tools and the reflexes of every
  reader are built around the latter.
- Docstrings on the main results only. It is the ordinary standard and it leaves
  the definitions undocumented, which is where the misreading actually happens: a
  theorem about a wrongly understood definition is the failure this rule is
  against.
- One file per milestone. Easy to plan against, and it produces imports that
  follow the order the work was done in rather than the order the mathematics
  needs.
- Writing the style checker here. Rejected under the same reasoning as the naming
  convention, and because it is maintenance with no result attached.

## What it costs

Adopted style tooling is somebody else's tooling, so its rules change when they
change it, and a bump can red the gate for a reason unrelated to any change in
this tree. The bump is a commit of its own and the pull request body says which
rule moved.

Docstrings on everything is a real fraction of the writing time, and the
pressure to write a thin one that repeats the name is constant.

## What no check reads

The mechanical half of this rule belongs to M3 and is issue #43, which is open.
Nothing in this repository checks any of the above today.

What a check of that kind can decide is narrow, and the boundary is worth
stating before the check exists rather than after somebody trusts it:

- That a docstring is present on a declaration is checkable. That it says
  anything beyond a restatement of the name is not, and the review is the only
  thing standing behind it.
- That a module docstring exists and has a heading is checkable. That its list of
  main results matches the declarations in the file is checkable only if the list
  is derived rather than typed, which is not what this decision asks for.
- That a name follows the capitalisation and the vocabulary rules is checkable by
  the adopted tooling. That the name describes the statement is a judgement about
  meaning, and it is the failure this whole file exists to reduce.
- That a file imports only what it uses is checkable. Whether an import belongs at
  that point in the hierarchy at all is not.

So the parts of this decision that no machine reads are the three that matter
most: whether a docstring is informative, whether a name means what the statement
proves, and whether the module hierarchy is the mathematical one. Those are
carried by review.
