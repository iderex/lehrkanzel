# lehrkanzel

High-energy physics has HepLean, the foundation exists in mathlib, and the work has been announced since 2023. The visible result is a machine-verified Noether theorem. This board carries the highest barrier to entry and the slowest feedback of its cohort, which is recorded before the work starts rather than discovered in month four, and its milestones are therefore small and each lands something checkable.

Four things this project cannot claim, in the same words as
[docs/limits.md](docs/limits.md). That formalising this helps research, because
the value is expected rather than demonstrated. That it is a foundation for
anything, until something is built on it. Completeness in any direction, because
the plan is bounded and what is outside it is absent rather than pending. That a
formal statement is the right formalisation of an informal one, because that
judgement is made by people and can be wrong.

There is a neighbouring library in this area, and what it already holds is
worth knowing before reading further. PhysLean carries a variational calculus
layer, a Euler-Lagrange operator for trajectories in an inner-product space,
Hamilton's equations, and worked systems including a harmonic oscillator, a free
particle, pendulums and a rigid body. What is missing there is the theorem
connecting a symmetry to a conserved quantity, together with the Legendre
correspondence and the Poisson structure that let that theorem be stated on both
sides and shown to agree. That absence is what this repository is for. It is
built as its own package and depends on mathlib only, not on that library. The
measurement behind this paragraph and the reasons for the arrangement are in
[docs/decisions/0011-neighbouring-work.md](docs/decisions/0011-neighbouring-work.md).

Planning happens on the issue tracker first. Every decision that shapes
the architecture is written down there with its reasons before the code
that depends on it exists.

See [NOTICE.md](NOTICE.md) for the intended-use notice.
