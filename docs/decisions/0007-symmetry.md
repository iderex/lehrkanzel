# 0007 How a symmetry is represented, and what invariance is allowed to mean

Noether's theorem says a symmetry gives a conserved quantity. Everything that is
hard about stating it is in the word symmetry, and a formalisation that gets
this definition slightly wrong produces a theorem that is true, that compiles,
and that no physicist would accept as the theorem.

## The decision

A symmetry is a one-parameter family of transformations of the configuration
space: a smooth map from a real parameter and a point to a point, which is the
identity at parameter zero.

Its generator is the derivative of that map in the parameter at zero. It is a
vector field on the configuration space, and it is the object the conserved
quantity is paired against.

The theorem is stated for the infinitesimal condition. The family is required to
leave the Lagrangian invariant in the sense that the derivative at parameter
zero of the transformed Lagrangian vanishes, with the velocity transported by
the derivative of the transformation. The stronger requirement, that the
Lagrangian is exactly equal for every value of the parameter, implies it and is
available as a lemma.

## The two invariance conditions

Two forms exist in the library, and the main theorem assumes the weaker one.

Strict invariance is the vanishing described above: the parameter derivative of
the transformed Lagrangian at zero is zero.

Invariance up to a total time derivative is the condition where that parameter
derivative equals the time derivative of some function of time and position,
rather than zero. It is weaker, it is what the interesting examples satisfy, and
it is the hypothesis the main theorem in M6 is stated under. Strict invariance
is the special case where the function is constant.

The weaker condition is present from the beginning rather than added later
because of one example. A Galilean boost satisfies only that form, and issue
#101 is where that is shown. A version of Noether that cannot see boosts is a
version a reader will notice is missing the case they came for. Adding the
condition afterwards is not an addition: it changes the definition of the
conserved quantity, and so it changes every statement that mentions one.

## The boundary this definition draws

Transformations that move time are not covered. The family acts on the
configuration space alone, at fixed time.

Conservation of energy from time-translation invariance is therefore not an
instance of the theorem in this library. It is proved separately by direct
computation, in issue #102, and does not go through this machinery. That is a
deliberate boundary and it is stated here rather than left to be discovered by
somebody who went looking for the corollary and did not find it.

## Why

The infinitesimal condition is the hypothesis that makes the theorem usable.
Checking that a Lagrangian is exactly invariant under a rotation by an arbitrary
angle is a real computation. Checking that its derivative at the identity
vanishes is one differentiation, and it is what somebody applying the theorem
actually has in hand. Stating the theorem under the weaker hypothesis makes the
stronger case a corollary rather than the other way round.

Restricting to transformations of the configuration space alone is what keeps
the generator a vector field and the conserved quantity a single pairing. The
time-dependent case is a genuinely bigger theorem: the generator acquires a time
component, the conserved quantity acquires a second term, and every statement in
M6 becomes harder to read. The energy result people want out of that generality
is provable directly in a short computation, so the general machinery would be
built to reach something the tree already has another way.

## Rejected

- Symmetry as a group action, with a Lie group acting on the configuration space
  and the generator coming from its algebra. The structurally correct statement,
  and it is where this ends up if the manifold setting is ever adopted. Rejected
  here because it would put the Lie group prerequisites in front of the first
  result, and because the one-parameter family is what every application
  instantiates anyway.
- Requiring the family to be a flow, so that composing two parameters adds them.
  It is true of every example and it is not needed by the proof. Assuming it
  would be a hypothesis that cannot be shown to bite.
- Requiring each transformation to be a diffeomorphism. Also true of the
  examples, also unused: the proof differentiates at zero and never inverts
  anything.
- Symmetries of the action rather than of the Lagrangian. More general, and it
  swallows the total-derivative case automatically. Rejected because the
  invariance condition then quantifies over intervals, and the hypothesis becomes
  something nobody can check for a given example.
- Covering time-dependent transformations from the start. The full theorem.
  Rejected for the reason given above, in exchange for a case this library
  reaches another way.

## What it costs

Two invariance conditions in the tree means two versions of the main theorem and
a lemma connecting them. That is three declarations where a more general
treatment would have one, and it is the price of the statement being readable.

The library will not say that energy conservation is an instance of Noether's
theorem, because in this setting it is not one. That is a real limitation
against the way the subject is usually taught. The documentation states it in
these same words rather than letting a reader infer that the connection was
overlooked, and issue #104 is where the full list of what the result does not
say is written down.
