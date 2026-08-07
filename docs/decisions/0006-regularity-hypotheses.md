# 0006 The standing smoothness hypotheses and how they are carried

Every theorem here needs the Lagrangian and the trajectory to be differentiable
enough, and there are three ways to carry that and no way to avoid it. Chosen
once, it is invisible. Chosen per file, it produces a library where two theorems
about the same object cannot be composed, because one of them assumes slightly
more than the other.

## The decision

Smoothness is stated as an explicit hypothesis on each declaration, at the
weakest order that declaration's proof actually uses, expressed as continuous
differentiability of a stated finite order. In this ecosystem that is
`ContDiff` at a natural-number order.

The hypothesis is about the uncurried form of the Lagrangian, a single function
of time, position and velocity taken together, so that joint smoothness is what
is assumed rather than smoothness in each argument separately.

Infinite order is used in one place only: the variations. It is free there,
because the bump functions that produce them are smooth of infinite order
anyway, and assuming less would complicate the fundamental lemma for no gain.

There is no structure bundling a Lagrangian with its hypotheses, and there is no
typeclass making smoothness inferrable.

The rule for changing an order once a declaration is public:

- Lowering an order is allowed and needs nothing beyond the proof that supports
  it, because it weakens a hypothesis and every existing use still applies.
- Raising an order is a change to a public signature that breaks uses, and needs
  a line in the pull request body naming the step in the proof that forced it.
- An order is never raised to make a proof shorter. If a stronger hypothesis
  makes the proof easier, the pull request body says so and says what the weaker
  proof would have cost.

## Why

Weakest sufficient order is the rule that makes the hypothesis auditable. A
reader can ask whether a theorem needs three derivatives, and the answer is in
the statement rather than in the proof. It is also what makes the
hypothesis-necessity programme meaningful. If every declaration assumed infinite
smoothness, no hypothesis could ever be shown to be needed, because none of them
would be.

Joint smoothness rather than slotwise is not a matter of taste. The derivation
of the Euler-Lagrange equation differentiates the action under the integral sign
and then differentiates a composition along a curve, and both steps need
continuity of the derivative jointly in the arguments. Slotwise assumptions do
not give that. A library that assumed them would have theorems that are true,
that look complete, and that cannot be applied to the chain rule step they exist
for. That failure is invisible until somebody tries the composition, which is
late.

A bundled structure is the tempting alternative, because it shortens every
statement. It is refused because it makes the hypothesis invisible at the point
of use, and because the first time somebody has a Lagrangian that satisfies four
of its five fields they discover that the structure was a decision about which
theorems exist.

## Rejected

- Assume infinite differentiability everywhere. Every statement gets shorter,
  every proof gets easier, and the entire hypothesis-necessity programme becomes
  impossible to run. It also excludes the piecewise cases the physics produces.
- A structure carrying a Lagrangian together with its smoothness proofs. Shorter
  statements, hidden hypotheses, and a fixed decision about which combinations
  of assumptions may exist.
- A typeclass for smoothness, so that instance search supplies it. It is the
  mechanism that makes the automation tactics in this ecosystem work well, and
  it is the wrong tool for a hypothesis that a reader is supposed to notice.
- Stating regularity only where a proof breaks without it, discovered as the
  proofs are written. That is the same as no decision, and it produces the
  incompatible-neighbour problem within a few files.
- Slotwise smoothness in time, position and velocity separately. It reads more
  naturally and it is strictly weaker than what the chain rule step needs.

## What it costs

Statements are longer, and a chain of three lemmas can carry the same hypothesis
three times. That is the visible cost and it is paid on purpose.

Weakest sufficient order means the order recorded in a statement can change when
its proof is improved, and lowering it is still a change to a public signature
even though it breaks nothing. Readers who copied a statement will find it does
not match the tree.

The automation in this ecosystem that discharges differentiability side
conditions works best when the hypotheses are in the shapes it expects. Where a
weakest-order hypothesis defeats it, the proof carries the discharge by hand,
and that is a real time cost rather than a hypothetical one.

Nothing refuses a declaration that assumes more than its proof uses. The order a
declaration states is a judgement, and the pull request body is where it is
argued and the review is where a wrong one is caught.
