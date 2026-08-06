# 0010 What phase space is, before anything builds a bracket on it

The canonical form and the Poisson bracket are structures on a specific object,
so what that object is has to be settled before either of them is written. It is
not the same object as the state space the variational core works over, even
though in this setting the two look identical.

## The decision

Write `Q` for the configuration space fixed by decision 0003, a finite
dimensional real inner product space, and `inner u v` for its inner product.

Phase space is the product of the configuration space with itself, the first
factor read as position and the second as momentum:

    Phase Q := Q x Q

The state space of the Lagrangian side, position paired with velocity, is a
different object with the same underlying type:

    State Q := Q x Q

The library gives the two distinct abbreviations, and states in the docstring of
each that they are definitionally equal and conceptually not. No lemma is stated
about one and applied to the other without the fibre derivative in between.

### The canonical form and its sign convention

Phase space is a vector space, so a tangent vector at a point is again a pair,
and the canonical form is a bilinear form on pairs. Written out, with `u` and
`v` tangent vectors and `.1` and `.2` the position and momentum components:

    omega u v = inner u.1 v.2 - inner v.1 u.2

In words: the inner product of the position part of the first argument with the
momentum part of the second, minus the same product with the arguments swapped.
This is the convention in which a Hamiltonian vector field comes out as

    X f = (gradient of f in the momentum slot, minus the gradient of f in the position slot)

and in which Hamilton's equations read as position rate equal to the momentum
gradient of the Hamiltonian and momentum rate equal to minus its position
gradient. The other sign convention in wide use flips `omega`, and with it the
sign of every Hamiltonian vector field. Both are defensible. This file fixes the
first one, and the reason for fixing it at all is below.

### The bracket

The Poisson bracket is defined directly from the two partial gradients rather
than through the canonical form and a pair of Hamiltonian vector fields. For
real-valued `f` and `g` on phase space, writing `grad_q` and `grad_p` for the
gradients in the position and momentum slots:

    bracket f g x = inner (grad_q f x) (grad_p g x) - inner (grad_p f x) (grad_q g x)

The agreement theorem is `poissonBracket_eq_omega_hamiltonianVectorField`, and
it says that for suitably differentiable `f` and `g`,

    bracket f g x = omega (X f x) (X g x)

with `X` the Hamiltonian vector field determined by the canonical form. It is a
result in the Poisson bracket milestone, not a definitional unfolding.

The rule about which definition a new statement uses. A new statement uses the
direct definition, both before and after the agreement theorem lands. The
geometric form appears only in a statement whose subject is the canonical form
or a Hamiltonian vector field, and the agreement theorem is what a proof cites
to move between them.

## Why

Distinguishing the two spaces is the point of the file. Everything in this
setting is a pair of vectors, so nothing stops a proof from applying a
momentum-side lemma to a velocity-side object, and the resulting statement would
be wrong in a way that compiles.

Nothing enforces the distinction. The two abbreviations unfold to the same type,
the elaborator accepts either where the other is expected, and no check
proposed anywhere in this plan can tell them apart, because there is nothing in
the tree for such a check to read. What the separate names buy is that the
intended reading is written in every statement, so a reader has something to
compare against. What the review is expected to look at is the specific
question: does this statement say phase space where it means momentum, and is
there a fibre derivative between it and the velocity-side result it is being
applied to. That question is the whole of the control, and it is a person
asking it.

Defining the bracket directly keeps the milestone usable before its geometry is
finished. The conservation criterion, which is the result anybody wants, needs
only the direct definition, so it can land while the canonical form and the
vector field correspondence are still being built. The agreement theorem is then
a real result rather than a restatement, and it is the thing that says the
direct definition was the right one.

The sign convention is fixed in this file rather than in the source because it
is the single most common source of a theorem that is correct and
unrecognisable. Two conventions are in wide use and both are defensible. What is
not defensible is having the choice recorded nowhere, because then the first
person to compare a statement against a textbook cannot tell a convention from
an error.

The two conventions written here are consistent with each other by the following
calculation, which is what the agreement theorem discharges formally. Solving
`omega (X f x) v = df x v` for `X f x` against an arbitrary `v` gives the
position component as the momentum gradient and the momentum component as minus
the position gradient. Substituting that into `omega` and expanding gives the
direct definition of the bracket back. The point of writing this down is that
the signs above were chosen together rather than one at a time, so a later
change to either one is a change to both.

## Rejected

- One space for both sides. Shorter, and it removes the only visible barrier
  against confusing a velocity with a momentum.
- The cotangent bundle of the configuration space, with momenta in the dual.
  Structurally right, and it makes the canonical form a real construction rather
  than a definition. Rejected for the reason 0003 gives: momenta in the dual
  would appear in every statement, in exchange for generality this setting does
  not use.
- Defining the bracket through the canonical form from the start. It is the
  definition somebody would defend in a seminar, and it makes the whole
  milestone a single indivisible piece of work.
- Leaving the sign convention to whichever proof is written first. It will be
  consistent and it will be undocumented.
- Distinguishing the two spaces with a wrapper structure that the elaborator
  would actually refuse to confuse. It would make the distinction real. It also
  puts an unwrapping step in every statement on both sides, and the fibre
  derivative would become a coercion nobody reads.

## What it costs

Two names for one type is a formality that a reader may find pedantic, and it
stops nobody, since the elaborator will accept either where the other is
expected. It is a review aid and this file says so rather than presenting it as
a guarantee.

Two definitions of the bracket mean two things to maintain until the agreement
theorem lands, and after it lands there is still a rule about which one a new
statement uses. The rule is above, and nothing refuses a statement that ignores
it.

Fixing a sign convention means that a reader holding the other one has to
translate every statement in the milestone. The alternative is that they cannot
tell whether they need to.
