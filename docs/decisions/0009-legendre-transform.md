# 0009 How the Legendre transform is handled, and what regularity it assumes

The passage from the Lagrangian to the Hamiltonian is the one place in this plan
where the mathematics is not a straightforward consequence of what came before.
It needs an invertibility that is false in general, and how that condition is
carried decides whether M7 is a milestone or a research problem.

## The decision

The fibre derivative of a Lagrangian sends a time, a position and a velocity to
the derivative of the Lagrangian in its velocity slot, taken as a vector of the
configuration space through the inner product fixed in 0003. That vector is the
momentum.

The Legendre transform is defined relative to an explicit hypothesis carried as
an argument. The hypothesis is that for each time and each position, the fibre
derivative is a bijection of the configuration space onto itself with a smooth
inverse. It appears in the source as a hypothesis on the declaration rather than
as a side condition discharged inside it.

Under that hypothesis the Hamiltonian at a time, a position and a momentum is
the inner product of the momentum with the velocity that produces it, minus the
Lagrangian evaluated at that velocity.

Strict convexity of the Lagrangian in the velocity is not the definition. It is
a separate sufficient condition, and it is proved to imply the hypothesis in the
case that covers the intended examples, namely a Lagrangian whose velocity
dependence is a positive definite quadratic form. Issue #108 is where that proof
lands.

The general convex-analytic conjugate is not used.

## Why the hypothesis is carried rather than derived

Carrying invertibility as an explicit hypothesis is what lets M7 be built at
all. The alternative is to prove a general theorem giving invertibility from
convexity and growth, which is a substantial piece of analysis, and to have
every result in M7 blocked behind it. With the hypothesis explicit, that general
theorem becomes an optional improvement that adds instances rather than a
prerequisite that gates the milestone.

It is also the honest shape. A Lagrangian that is not regular in this sense has
no Hamiltonian, and that is a fact about mechanics rather than a defect of the
formalisation. A definition that hid the condition would be defining something
else and calling it the Legendre transform.

The quadratic case is proved rather than left as a remark because every example
in this plan is of that form, kinetic energy minus a potential, and because a
sufficient condition nobody can instantiate is a sufficient condition that has
not been checked.

The convex conjugate is refused as the definition for two reasons. It produces a
function that agrees with the Hamiltonian only under conditions that would have
to be proved anyway, so it does not avoid the work. And it takes values in the
extended reals, which would propagate into every statement in M7 and M8, where
each one would then carry a finiteness side condition that the mathematics does
not need.

## The unconditional theorem, named as future work

The theorem that would remove the hypothesis is the one giving invertibility of
the fibre derivative from strict convexity together with a growth condition. It
is not in this plan.

What it would buy is stated so that a later reader can judge whether it is worth
doing: every result in M7 would apply to a Lagrangian on the strength of a
condition on the Lagrangian itself, rather than on the strength of a hypothesis
the caller supplies about a map derived from it. The set of instances would grow
beyond the quadratic case, which today is the only case the library can
discharge. It is a milestone of its own and it sits in front of nothing, because
the explicit hypothesis makes M7 reachable without it.

## Rejected

- Define the Hamiltonian through the convex conjugate. Elegant, general, and it
  drags extended real values through the whole Hamiltonian half of the library.
- Prove invertibility from strict convexity plus superlinear growth first, and
  define the transform unconditionally afterwards. The right theorem, and it is a
  milestone of its own placed in front of the results that need it. It is named
  as future work above instead.
- Assume the Hamiltonian is given and never construct it from a Lagrangian. It
  makes M7 easy and it deletes the only interesting content, which is that the
  two descriptions are the same mechanics.
- Restrict the whole library to Lagrangians of kinetic-minus-potential form.
  Every example is covered, and the theorem stops being about Lagrangian
  mechanics.

## What it costs

Every result in M7 carries a regularity hypothesis and a reader has to supply
it. For the examples the quadratic lemma supplies it and the cost is invisible.
For anything else it is real work by whoever applies the theorem.

The library will not have the Legendre transform of a degenerate Lagrangian, so
constrained systems in the sense that matters to field theory are out. That is
stated where a reader will look for it rather than left as a silence.

The two-slot structure of the transform, invertible in the velocity for each
fixed time and position, means the smoothness of the inverse in the other two
arguments is a separate hypothesis rather than a consequence. It is carried
explicitly for the same reason the first one is, and it is the one a reader is
most likely to forget is there.
