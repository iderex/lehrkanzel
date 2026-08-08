# Limits

There are two kinds of limit here and they are worth keeping apart.

The first is what a particular theorem does not support. That is recorded per
statement, next to the statement, and it is the more useful of the two for
somebody who wants to apply a result. None of it is written yet, because no
theorem has landed; issue #104 is where the Noether result's version of it goes.
Nothing below stands in for it.

The second is what this project cannot claim about itself, whatever it proves.
That is what this document holds today. It is written before there is anything
to overstate, because a project that states its own limits before anybody else
does is read differently from one that has them pointed out, and because the
temptation to overstate arrives with the first result rather than before it.

## It cannot claim that formalising this helps research

Nobody has shown that a machine-checked mechanics theorem changes what a
physicist does. This board is not an experiment that could show it: it produces
one library, it has no control, and the people most likely to read it are the
people already persuaded.

The honest position is that the value is expected rather than demonstrated. The
expectation is a real one and it is why the work is being done, but an
expectation stated as a finding is a false claim about evidence, and it is the
easiest one to make by accident when writing an abstract.

## It cannot claim to be a foundation for anything until something is built on it

A library with no dependants is a library that has not been used. Until another
package depends on this one, nothing here has met a requirement it did not
choose for itself, and the parts that are awkward to build on have had no
opportunity to show it.

The count of dependants is a fact anybody can check rather than a thing to
assert. Today it is zero, and it cannot be otherwise, because nothing is
published and no package manifest exists in the tree. Read at `a545cb4`:

    git ls-files 'lakefile*' 'lean-toolchain' 'lake-manifest.json' | wc -l
    0

## It cannot claim completeness in any direction

The chapters this library has are the ones in the plan, and the plan is bounded.
It covers a variational core, a symmetry chapter with one theorem at its centre,
a Hamiltonian side and a Poisson structure, in one setting, chosen and argued in
the decision files.

Everything outside that is absent rather than pending. A reader looking for
constrained systems, for fields, for a manifold setting, or for anything
quantum, will not find them, and the absence is not a gap somebody forgot to
fill.

## It cannot claim that a formal statement is the right formalisation of an informal one

This is the limit that survives every check in this repository, and it is the
one worth understanding before the others.

A kernel decides whether a proof establishes a statement. Nothing decides
whether the statement is the one its name promises. A theorem called Noether's
theorem can be true, checked, and about something narrower or stranger than the
result a physicist has in mind, and every automatic guard in this tree would
stay green.

That judgement is made by people. It is recorded per statement, in the decision
files for the setting and in the docstring for the statement, so that a reader
can disagree with it in a specific place rather than in general. It can be
wrong, and if it is wrong the repair is a new statement rather than a correction
to a proof.

## What no check in this document refuses

Every sentence above is prose. The check that would refuse a document naming a
result the register of unproved statements does not support is issue #69, which
is open and which needs the blueprint before it can be written. Until it exists,
nothing refuses a document in this repository that overstates what has landed,
including this one.
