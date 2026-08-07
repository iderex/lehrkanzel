# 0003 What a mechanical system is here, and where the velocities live

This is the decision the whole library is shaped by. Every statement after it
mentions the configuration space, so getting it wrong is not a refactor, it is
rewriting the tree. It is also the decision most likely to be made by accident,
because the first file somebody writes already contains an answer.

## The decision

The configuration space is a finite-dimensional real inner-product space,
written `Q`. The assumptions are carried as typeclasses and appear in the source
in this form:

    variable {Q : Type*} [NormedAddCommGroup Q] [InnerProductSpace ℝ Q]
      [FiniteDimensional ℝ Q]

Velocities live in the same space, so the state space is `Q` paired with `Q`
rather than a tangent bundle. A Lagrangian is a function of time, position and
velocity taking a real value, so it has the type `ℝ → Q → Q → ℝ`.

Each assumption is there for a stated reason.

`NormedAddCommGroup Q` gives the addition that a variation is added by and the
norm that every derivative in the tree is taken with respect to. Without the
addition there is no way to displace a trajectory, which is how 0005 defines a
variation.

`InnerProductSpace ℝ Q` is not decoration. The derivative of the Lagrangian in
each slot is a linear functional, and the inner product is what turns it into a
vector of the same kind as the thing it is paired against. That is what lets a
conserved quantity be written as a pairing of the momentum with a generator and
read as the expression a physicist would recognise, rather than as a functional
applied to an argument.

`FiniteDimensional ℝ Q` is required for the same reason the physics is. It makes
the pairing above an isomorphism with no further conditions, and it makes a
concrete example with three coordinates an instance of the general statement
rather than a separate development.

The configuration manifold, the tangent bundle and the cotangent bundle are
named here as out of scope and are not built on. Whether that scope is ever
widened is a maintainer decision, entry 3 of issue #2, and this file settles
none of it.

## What the resulting theorem says, in the words a physicist would use

The library proves Noether's theorem for a system whose positions are vectors in
a fixed finite-dimensional space with a fixed inner product. Cartesian
coordinates, in other words, with the coordinate choice never written down. A
particle in a potential, a system of particles, a harmonic oscillator and a
central-force problem are all systems of this kind.

What it does not say is anything about a system whose positions live on a curved
space. A pendulum on a circle, a rigid body, a bead on a wire and anything with
a holonomic constraint are not instances of it. Neither is a field theory, whose
configuration space is infinite-dimensional. Any sentence in this project that
says Noether without that qualification is overclaiming. Every place this
project describes its own result to a reader is required to carry the
qualification in these same terms.

## Why

The visible result is Noether's theorem in a form somebody can read and check.
Over an inner-product space the whole chain, action to variation to
Euler-Lagrange to conserved quantity, is derivatives of maps between normed
spaces, which is the best-supported corner of the library this depends on. Every
step is a rewrite somebody can follow.

Over a manifold the same chain needs the smooth structure of the tangent bundle,
sections of pulled-back bundles along a curve, and a notion of varying a curve
inside the manifold rather than adding a function to it. Some of that exists
upstream and some does not, and the parts that do exist would be exercised
harder by this work than they have been by anything so far.

For the Hamiltonian half the ground is simply absent. Read on 2026-08-07 at the
mathlib commit this library pins, `905b95818eb32af7874a58b427f50c1711a5e96c`:

    gh api 'repos/leanprover-community/mathlib4/git/trees/905b95818eb32af7874a58b427f50c1711a5e96c?recursive=1' \
      --jq '.tree[].path' | grep -i symplectic
    Mathlib/LinearAlgebra/SymplecticGroup.lean

One file, and it is a group of matrices rather than a symplectic manifold. So
M7 and M8 over a manifold would be built from nothing before the first result
appeared.

The recorded assessment of this board is that it has the slowest feedback of its
cohort, and that a board with slow feedback and no intermediate results is the
one that quietly stops. Choosing the setting where every milestone can land a
checked theorem is the direct response to that. It is a decision about survival
rather than about taste, and 0015 is the rule that follows from it.

## Rejected

- A smooth manifold with its tangent bundle. The statement a geometer wants and
  the one the announcement implies. Rejected for now because the prerequisite
  work is larger than the work it enables, and because the symplectic half would
  have to be built from nothing before the first result appears. Named as out of
  scope rather than deferred quietly, so that nobody reads the library as
  claiming it.
- Coordinates, that is functions into a finite product of reals with an index
  type. Concrete, and every derivative becomes a partial derivative a reader
  recognises. Rejected because every statement then carries an index bookkeeping
  that the mathematics does not need, rotations become matrices before they need
  to be, and moving to a coordinate-free statement later means rewriting
  everything anyway.
- A general normed space with no inner product and momenta in the dual. Closer
  to the honest structure, since momentum really does live in the dual. Rejected
  because every conserved quantity would then be written as an application of a
  functional, the harmonic oscillator would need two spaces where the physics has
  one, and the finite-dimensional inner-product case is where all the intended
  examples live.
- An infinite-dimensional configuration space, so that field theory is included.
  Rejected because the fundamental lemma, the Legendre transform and the
  identification of momenta all acquire conditions that would then appear in
  every statement, in exchange for a generality this board has not promised.

## What it costs

The headline theorem is the vector-space theorem. It is not false and it is not
a toy, but it is not the geometric statement, and documentation that omits the
qualification is making a claim the tree does not support.

A constrained system is not directly an instance. A pendulum on a circle or a
rigid body has to be treated in a chart or through a constraint that the general
statement does not know about. That is why the worked examples in this plan are
the ones that live naturally in a vector space, and why the pendulum is not
among them.

Widening to manifolds later is not an extension of this development, it is a
second one with a compatibility lemma between them. That cost is real and is why
entry 3 of the maintainer decisions asks whether the manifold statement is ever
promised.

## What no check reads

Nothing in this repository refuses a declaration that assumes a weaker or a
stronger structure than the block above. The invariants gate asked for in issue
#52 is where that refusal would live, and it has not landed. Today the tree
holds no Lean declaration at all, so there is nothing yet for it to be wrong
about:

    git ls-tree -r --name-only HEAD | grep -c '\.lean$'
    0

Until #52 exists, this file is carried by the people writing the declarations
and by review, not by a machine.
