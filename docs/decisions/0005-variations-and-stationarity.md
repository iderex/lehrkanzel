# 0005 What a variation is, and what stationary means

The word stationary is where a formalisation of this subject either says
something or quietly says nothing. There are several inequivalent definitions in
circulation, they agree on the examples everybody checks, and a library that
picks the weakest one can prove the Euler-Lagrange theorem while asserting
almost nothing.

## The decision

A variation is a smooth function from the reals into the configuration space
whose support is contained in the open interval between the two endpoints.

A trajectory is stationary for a Lagrangian on that interval when, for every
such variation, the real function taking a parameter to the action of the
trajectory displaced by that parameter times the variation has derivative zero
at zero.

Displacement is addition in the configuration space. It is available because the
setting fixed in 0003 is a vector space, and it is one of the reasons the
setting was chosen that way.

Support inside the open interval is the condition, rather than vanishing at the
two endpoints. The two are not the same and the difference is the point of this
file.

## Why the support condition rather than vanishing endpoints

The derivation of the Euler-Lagrange equation integrates by parts once. That
step produces a boundary term, the pairing of the velocity-slot derivative with
the variation, evaluated at each endpoint.

If the variation has support strictly inside the interval, the boundary term is
the pairing evaluated at a point where the variation is identically zero on a
neighbourhood, so it vanishes and there is nothing to argue.

If the variation is only required to be zero at the two endpoints, it may be
nonzero arbitrarily close to them. The boundary term is then zero for a reason
that has to be established by a limit argument at each end rather than read off.
That argument is real work, it is carried in every proof that needs it, and it
buys nothing that the support condition does not give for free.

The support condition is also what makes the fundamental lemma available in the
form the derivation needs. That lemma is stated for compactly supported test
functions, so the class of variations and the class the lemma quantifies over
are the same class, with no bridging step between them.

## Why the derivative is an ordinary one

Taking the derivative of a real function of one parameter, rather than defining
a derivative of a functional, keeps the whole definition inside results that
already exist upstream. There is no calculus of variations to import. Read on
2026-08-07 at the mathlib commit this library pins:

    gh api 'repos/leanprover-community/mathlib4/git/trees/905b95818eb32af7874a58b427f50c1711a5e96c?recursive=1' \
      --jq '.tree[].path' | grep -icE 'calculus/variation|EulerLagrange'
    0

So every abstraction invented here is one this board also has to maintain and
prove things about. The parameter derivative is an ordinary derivative, and
everything already known about ordinary derivatives applies to it immediately.

## What the condition is, and what it is not

The definition is a first-order condition. It says a trajectory is critical. It
does not say the trajectory minimises the action, and it does not say a minimum
exists.

That is what the physics means, and it is worth being explicit, because the
phrase principle of least action invites the other reading and the theorem does
not support it. A free particle on a long enough interval is the standard case
where a solution of the equation is not a minimiser.

## Rejected

- A general variational derivative or functional gradient, defined once and used
  everywhere. It is the right long-term abstraction and the neighbouring library
  has built one. Rejected as the definition this library's statements are phrased
  in, because the theorem then reads as a statement about an apparatus that a
  reader has to learn before they can judge whether the theorem is the one they
  wanted. It stays available as a later reformulation with an equivalence lemma.
- Variations vanishing at the endpoints, without a support condition. Closer to
  the textbook phrasing. Rejected because the boundary term then needs a limit
  argument at each end, which is real work that buys nothing.
- Two-sided families of curves, a smooth map of two variables with the trajectory
  at parameter zero. The general form, and it is what a manifold setting would
  force. Rejected because in a vector space it is strictly more machinery for the
  same content.
- Minimising rather than stationary. It is what the name of the principle
  suggests and it is false for most of the examples. Not adopted, and the
  documentation says why rather than leaving the reader to discover it.

## What it costs

The statements are about criticality and not about minimisation, so a reader who
came for the principle of least action gets a first-order condition. The module
docstring on the file defining stationarity is required to say so in these same
words, so that the qualification reaches somebody reading the declaration rather
than only somebody reading this file.

Restricting to smooth compactly supported variations makes the stationarity
condition weaker than it could be. Quantifying over fewer variations is a weaker
hypothesis to satisfy, so the class of trajectories the definition admits as
stationary is potentially larger than the class a stronger definition would
admit. If it were strictly larger, the definition would be saying less than it
appears to.

## The evidence that nothing was given away

That cost is discharged by proving the equivalence in both directions rather
than by asserting it. Issue #78 proves that stationary implies the
Euler-Lagrange equation, and issue #80 proves the converse. Together they say
that the class of trajectories this definition admits is exactly the class
satisfying the equation, which is what pins the definition down: a weaker
definition that admitted more trajectories could not prove the second direction.

Until #80 lands, the claim that the definition is not too weak is a claim and
not a result.
