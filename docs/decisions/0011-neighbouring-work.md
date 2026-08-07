# 0011 The relationship to the neighbouring physics library and to mathlib

This board was announced against a gap, and part of that gap has since been
filled by somebody else. Recording that here is not a formality. A plan built on
a premise that stopped being true produces work that duplicates what exists, and
the duplication is discovered by a reader rather than by the people doing it.

## What is actually there

Read on 2026-08-07:

    git clone --depth 1 https://github.com/HEPLean/PhysLean physlean
    cd physlean && git rev-parse HEAD
    fa696f859970a19b53ea2b9513231fe243463c73

    ls Physlib/ClassicalMechanics/
    Basic.lean
    DampedHarmonicOscillator
    EulerLagrange.lean
    FreeParticle
    HamiltonsEquations.lean
    HarmonicOscillator
    Lagrangian
    Mass
    OrbitalMechanics
    Pendulum
    RigidBody
    Scattering
    Vibrations
    WaveEquation

    ls Physlib/Mathematics/VariationalCalculus/
    Basic.lean
    HasVarAdjDeriv.lean
    HasVarAdjoint.lean
    HasVarGradient.lean
    IsLocalizedfunctionTransform.lean
    IsTestFunction.lean

    grep -rn 'theorem .*[Nn]oether\|def .*[Nn]oether\|lemma .*[Nn]oether' -- Physlib | wc -l
    0

    grep -rln 'noether' -- Physlib
    Physlib/ClassicalMechanics/HarmonicOscillator/Basic.lean

That library carries a variational calculus layer, a Euler-Lagrange operator for
trajectories in an inner-product space, Hamilton's equations, and worked systems
including a harmonic oscillator, a free particle, pendulums and a rigid body.
There is no declaration in it whose name contains Noether. The single occurrence
of the word is inside a note about work not done.

## The narrowed gap

So the honest statement of the gap is narrower than the one this board was
announced with, and it is also sharper.

What is missing is not Euler-Lagrange. What is missing is the theorem connecting
a symmetry to a conserved quantity, and the Legendre correspondence and Poisson
structure that let that theorem be stated on both sides and shown to agree.

## The decision

This library is built as its own package with its own gate, and it does not
depend on that library at build time. It depends on mathlib only.

Where a result this board needs already exists there, the plan states that it
exists, states why this tree carries its own version, and the reason has to be a
real one: a different setting, a different hypothesis, or a statement this
library needs to be able to change. Reimplementing something identical because
it is easier than reading somebody else's file is not a reason, and the review
is where that is caught.

Whether any of this is offered upstream, and to which body of work, is a
maintainer decision. It is entry 2 of issue #2, it is unanswered, and this file
settles none of it.

## Why

A build-time dependency on a large moving library would put this board's gate at
the mercy of that library's release cadence, on top of the mathlib pin it
already carries. Two moving pins is more than twice the work of one, because
they can disagree about a third.

Depending only on mathlib also keeps every file in this tree potentially
offerable in either direction, which keeps the maintainer decision open rather
than closing it by accident through an import.

The narrower gap is a better project than the announced one. The announcement
said mechanics has nothing, and the true statement is that mechanics has the
equations and not the theorems about them. Building on that reading means the
first milestone that produces new mathematics produces something genuinely
absent, rather than a second copy of an operator.

## Rejected

- Depend on the neighbouring library and build only the missing theorems. The
  smallest amount of work and the least control over the gate. It also makes this
  board's release depend on a release somebody else schedules.
- Ignore that the library exists. It is what the announcement implies and it
  would produce a duplicate Euler-Lagrange operator with no stated relationship
  to the other one, which is worse for a reader than either alternative.
- Contribute everything upstream and keep this repository as a plan only. A
  legitimate choice and not one to make by default, since it disposes of the
  board. It is entry 2 of the maintainer decisions.

## What it costs

Some work is done twice in the ecosystem, and this file is where that is
admitted rather than where it is justified away. The Euler-Lagrange operator in
M5 is the clearest case, and the issue that builds it names what is different
about it.

Not depending on that library means not benefiting from its worked systems, so
the examples here are built from nothing.

A reader who finds both libraries has to be told how they relate. The readme
carries one paragraph doing that, written from this file, and it says what is
missing rather than what is better.
