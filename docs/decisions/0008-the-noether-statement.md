# 0008 The exact statement of Noether this repository is aiming at

The one result this repository is announced to produce is written down here, in
full, before anything is built toward it. A target that is only described in a
readme drifts into whatever turned out to be provable, and the drift is
invisible, because the thing that lands still compiles and still carries the
name.

## The decision

The headline statement is fixed as follows, in words.

Let the configuration space be as decided in 0003. Let the Lagrangian be
continuously differentiable to the order 0006 fixes, jointly in its three
arguments. Let a one-parameter family of transformations of the configuration
space be given, smooth, equal to the identity at parameter zero, with generator
the derivative in the parameter at zero. Suppose the family leaves the
Lagrangian invariant in the infinitesimal sense of 0007. Let a trajectory
satisfy the Euler-Lagrange equation of that Lagrangian on an interval. Then the
real function sending a time to the inner product of the velocity-derivative of
the Lagrangian along the trajectory with the generator evaluated at the position
is constant on that interval.

The second form replaces strict invariance with invariance up to a total time
derivative, and subtracts that function from the conserved quantity. Both forms
are stated, and the first is derived from the second rather than the two being
proved separately.

Constant is stated as the derivative being zero throughout the open interval and
the values at two times being equal, with the second following from the first.

This is the vector-space statement, and it carries the qualification 0003
records every time it is stated, in the docstring and in the documentation.
Whether a statement over a general configuration manifold is ever promised is an
open maintainer decision, entry 3 of issue #2, and it is not settled here.

## Why

Fixing the statement now is what makes the milestones after it decidable. Every
issue in the variational core exists because this statement needs it, and each
one can be checked against this file rather than against a general sense of
progress.

The quantity is written as a pairing of the momentum with the generator rather
than as a coordinate sum, because that is the form that survives if the setting
is ever widened, and because it is the form in which the three corollaries are
one substitution each.

Stating the conclusion as constancy on an interval rather than as a global
conservation law keeps the theorem honest about what the hypothesis gives. The
Euler-Lagrange equation is assumed on an interval and nothing outside it is
known.

The theorem takes a solution of the Euler-Lagrange equation as its hypothesis
rather than a stationary trajectory. The two are equivalent by the variational
core, and the equation is the form somebody applying the theorem has in hand.

Deriving the strict form from the weaker one, rather than proving both, means
there is one proof to maintain and one place where a sign convention can be
wrong.

## Rejected

- Concluding that the quantity is constant on the whole real line. Stronger, and
  not supported by the hypothesis.
- Taking stationarity as the hypothesis instead of the equation. Equivalent, and
  it makes every application go through the equivalence lemma first.
- Proving only the strict-invariance form and adding the total-derivative form
  later. The conserved quantity differs between them, so later means changing a
  published statement.
- Stating the conclusion as an existence claim, that some conserved quantity
  exists. It is what the informal theorem says and it is useless, because the
  content is the formula.
- Leaving the statement to be settled by whichever proof turns out to work. It
  is the ordinary way a formalisation drifts, and there is no point at which
  anybody notices.

## What it costs

Fixing the statement in advance means that if the proof turns out to need an
extra hypothesis, the difference is visible and has to be argued rather than
absorbed. That is the intent, and it will at some point be uncomfortable.

Both forms stated means both are public, so a later change to either is a change
somebody may have depended on.

## Differences between what was planned and what was proved

Nothing is recorded here yet. The theorem has not landed, so there is no formal
statement to compare against the prose above, and this section is empty because
the work has not happened rather than because no difference was found.

When the theorem lands, the formal statement is copied into this file from the
source with the command that prints it, and any difference from the prose above
is recorded with its reason. A difference of none is written here as none rather
than left blank.
