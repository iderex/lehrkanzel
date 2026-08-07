# 0015 Every milestone lands a worked example, and what counts as one

The project recorded before it started that it has the slowest feedback of its
cohort, and that a board with slow feedback and no intermediate results is the
one that quietly stops. This file turns that observation into a rule with a
shape, so that the response to it is something the plan can be checked against
rather than an intention.

## The decision

No milestone from M5 onward is complete until it has landed at least one worked
example: a concrete Lagrangian, or a concrete symmetry, or a concrete system,
for which the milestone's general result is instantiated and the resulting
statement is one somebody who knows the subject would recognise on sight.

## What counts

An example is a theorem in the tree, subject to every rule the other theorems
are subject to. Its statement contains no abstract variable ranging over
Lagrangians, and its conclusion is a specific equation or a specific conserved
quantity.

The instantiation has to be carried far enough that something has been computed.
An explicit equation of motion, an explicit conserved quantity, an explicit
Hamiltonian. That a trajectory of a free particle is affine is an example. That
a free particle satisfies the Euler-Lagrange equation is not, because nothing
was solved.

## What does not count

- A test. A test checks that the library behaves; an example is a statement the
  library makes.
- A docstring, or a worked case written only in the documentation. It drifts, and
  nothing refuses a documented example whose theorem was renamed out from under
  it.
- A restatement of the general theorem with the letters changed. If the proof is
  the general theorem applied and nothing else, no obligation was discharged and
  nothing was computed.
- An evaluated computation producing a number. A number printed by a computation
  is not checked by the kernel in the sense this library claims, and 0012 forbids
  the mechanism that would make it look as though it were.

## Why

An instantiated example is the only artefact this board produces that a person
outside it can evaluate. A general theorem about an abstract Lagrangian is
checkable by the kernel and readable by perhaps a few dozen people. A statement
that the trajectory of a free particle is affine, or that the angular momentum
of a central-force system is constant, is checkable by anybody who took the
course.

It is also the strongest available guard against the failure mode this subject
has, which is a theorem that is true and does not say what its name says. A
general statement with a subtly wrong hypothesis often still proves. The same
statement instantiated at a concrete system usually will not, because the
concrete case is where a wrong hypothesis becomes an obligation somebody has to
discharge and cannot.

And it is the mechanism that keeps the milestones small. A milestone that has to
end at a recognisable statement cannot be twelve weeks of infrastructure,
because infrastructure does not instantiate.

## Rejected

- Examples collected in one milestone at the end. It is the natural way to
  organise them and it defers every checkable result to after the point where the
  risk was going to bite.
- Examples as evaluated computations rather than theorems. Covered above.
- Examples in the documentation only. They drift, and nothing refuses a
  documented example whose theorem was renamed out from under it.
- No rule, and trust that examples get written. They do get written, last, and
  this file exists because of what the project already knows about itself.

## What it costs

Instantiating a general theorem at a concrete system is real work, and it is
often harder than the general theorem, because the concrete case is where the
hypotheses have to actually be discharged rather than assumed. Some of the
examples in this plan will cost more than the result they illustrate.

The rule constrains how milestones may be cut, which is a constraint on planning
rather than on code. A piece of work that genuinely cannot end at an example is
a piece of work that has been cut wrong, and the response is to re-cut it rather
than to grant an exception.

## What no check reads

Nothing refuses a milestone that closes without an example, and nothing could
today, because the rule is about a plan rather than about a tree.

The count this rule is meant to make derivable is derivable only once the
blueprint of 0014 exists and marks which statements are examples. Until then,
whether a given milestone satisfies this rule is established by reading its
issues, which is an assertion by whoever read them and not a measurement.
Issue #31 is where the blueprint lands.
