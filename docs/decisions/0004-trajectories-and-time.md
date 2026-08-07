# 0004 Trajectories, the time domain, and which derivative a statement uses

A trajectory and its derivative appear in every statement in the library, so how
they are written is not a local choice. Two things are decided here: what the
time domain is, and which of the several available notions of derivative the
statements use.

## The decision

Time is the real line, and a trajectory is a function from the reals into the
configuration space fixed by decision 0003. The action is taken over a closed
interval whose endpoints are explicit parameters, and the interval is not baked
into the type of a trajectory.

The derivative in a statement is the one-dimensional derivative of a function
into a normed space, the notion whose value is a vector rather than a linear
map. In this ecosystem that is `deriv`, and the linear-map form is `fderiv`.

Where a proof needs the stronger fact that a derivative exists, the hypothesis
is the predicate form, `HasDerivAt`, rather than an assertion about the value of
`deriv`. The value form is then available as a consequence and never as an
assumption in disguise. This matters because the value form is total: it is
defined for a function that is not differentiable, where it returns zero, so a
hypothesis written about the value can be satisfied by a function that has no
derivative at all.

Second derivatives appear only where the Euler-Lagrange equation is put into its
second-order form, and there they are the iterated first derivative rather than
a separate notion.

The rule about which form appears where, which is the part of this file a
contributor has to remember:

- The statement of a public declaration uses `deriv` and `HasDerivAt`, and no
  public statement outside the translation module mentions `fderiv` or
  `HasFDerivAt`.
- Inside a proof either form may appear, and the multivariable steps will use
  the linear-map form because the results they cite are stated in it.
- The lemmas that move between the two forms live in one module and nowhere
  else, so the cost of carrying two notions is paid once and is greppable.

That module does not exist at the time this file lands. It is the module the
setting issue creates under the library root, and until it exists the rule above
constrains nothing, because there are no statements yet for it to constrain.

## Why

A trajectory defined on the whole line and integrated over an interval keeps
composition cheap. A curve restricted to a subtype has to be extended,
restricted and re-extended at every step, and each of those is a rewrite that
adds nothing to the mathematics. Nothing in the intended results needs the
trajectory to be undefined outside the interval, because the variations are the
things that vanish there and they carry that condition themselves.

Explicit endpoints rather than a fixed interval means the same theorem covers
the whole line, a bounded window and a single period without three statements.
It also keeps the endpoint conditions visible in the statement, which is where a
reader looks for them.

Choosing the vector-valued derivative rather than the linear-map form is a
readability decision with a real cost attached, and it is worth being explicit
about it. The vector form makes the Euler-Lagrange equation look like the
equation in a textbook, so a physicist reading the statement can check it
against what they already know. The linear-map form composes better with the
multivariable results the differentiation-under-the-integral step needs. This
library takes the vector form in the statements a reader reads and translates at
the boundary of the proofs that need the other.

The predicate form as the hypothesis is the same argument in a smaller place. A
reader checking a statement should be able to see that differentiability is
assumed rather than deduce it from the shape of an equation about a total
function.

## Rejected

- Trajectories as functions from a closed interval. Faithful to the problem, and
  the source of a restriction obligation in every single lemma. Rejected on the
  count of rewrites rather than on principle.
- Time as an abstract one-dimensional space with a unit attached. It is the
  honest treatment of a physical time, and a neighbouring library takes it.
  Rejected because it puts an extra layer between every statement and the
  analysis results underneath, and this library has no units anywhere else for
  it to be consistent with.
- Requiring smoothness of infinite order in the definition of a trajectory. It
  would delete a great many hypotheses. Rejected because the theorems are then
  unavailable for a trajectory that is merely twice differentiable, which is the
  class the physics actually produces, and because a hypothesis that is not
  needed is a hypothesis nobody can tell is unnecessary.
- Carrying the derivative as a second function with a hypothesis relating it to
  the first. It reads well in a statement, and it silently permits two different
  derivatives of the same curve to appear in one theorem.
- Using the linear-map form everywhere and never translating. One notion, no
  translation module, and every headline statement then carries a linear map
  applied to one, which is the form nobody checks against a textbook.

## What it costs

Two notions of derivative in the tree means a translation layer and a rule about
which one appears where. The rule is in this file, and without something reading
the tree for it, it decays as soon as a proof is easier to write the other way.

Endpoints as parameters means every statement carries two more of them and the
hypothesis that one is below the other. That is visible clutter in exchange for
one theorem instead of three.

The total value form of the derivative stays reachable from any statement, so a
proof can still be written that uses it as an assumption. Nothing here prevents
that. The rule above says the hypothesis is the predicate form, and the review
is what catches a statement that used the other.

Nothing refuses a public statement mentioning the linear-map form outside the
translation module. That refusal is the invariants check asked for in issue #5
and in the invariants gate issue, and until it exists this file is a position
rather than a mechanism.
