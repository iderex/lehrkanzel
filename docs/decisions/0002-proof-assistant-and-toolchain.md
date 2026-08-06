# 0002 The proof assistant, the toolchain, and how both are pinned

The means is chosen for this artefact rather than carried over from the last
one. The project name already contains an answer, so the point of this file is
not to reach a surprising conclusion. It is to record why the obvious one is
right and what it costs, so that the first time somebody waits two minutes for a
file to elaborate they are arguing with a written position instead of with
nothing.

Nothing is scaffolded until this file exists, because a package layout is
already an answer to it.

## The decision

Lean 4 with mathlib, built by lake, with the toolchain resolved by elan from a
`lean-toolchain` file pinned to an exact release, and mathlib pinned to an exact
commit in `lake-manifest.json`. Both pins move only in a commit that does
nothing else and that says which upstream change forced it.

The library declares one root module. The prebuilt object cache for mathlib is
fetched rather than rebuilt in the ordinary path, and the path that rebuilds
from source is a separate harness with its own issue, because it is the one
thing here that needs a machine rather than a CPU.

The pins the library starts from are the current stable Lean release and the
mathlib commit tagged for that release. A release candidate is not taken as a
starting pin, so the first thing a contributor installs is a version that is
finished.

    leanprover/lean4:v4.32.2
    mathlib4 at 905b95818eb32af7874a58b427f50c1711a5e96c

Both were read on 2026-08-07 from upstream rather than from this tree, because
the tree does not yet carry the files that hold them. The commands were:

    gh api 'repos/leanprover/lean4/releases?per_page=20' \
      --jq '.[] | select(.prerelease == false) | .tag_name' | head -1
    v4.32.2

    gh api repos/leanprover-community/mathlib4/tags?per_page=100 \
      --jq '.[] | select(.name == "v4.32.2") | .commit.sha'
    905b95818eb32af7874a58b427f50c1711a5e96c

    gh api 'repos/leanprover-community/mathlib4/contents/lean-toolchain?ref=905b95818eb32af7874a58b427f50c1711a5e96c' \
      --jq .content | base64 -d
    leanprover/lean4:v4.32.2

The third command is the one that matters, because it shows that the mathlib
commit named here is built against the toolchain named here rather than against
a neighbouring one.

Once the package is scaffolded the same two facts are read out of the tree
instead, and those are the commands a claim about the pins cites from then on:

    cat lean-toolchain
    jq -r '.packages[] | select(.name == "mathlib") | .rev' lake-manifest.json

Neither of those can be run today. `lean-toolchain` and `lake-manifest.json` are
produced by the scaffolding issue, and until that lands the pins recorded above
are the intended starting values and nothing in this repository holds them.

## Why

The artefact is a set of statements whose value is that a kernel checked them.
That inverts the usual relationship between a build and a test suite. Here the
build is the test suite, and there is no separate question of whether the
theorems pass. What the surrounding apparatus has to do is narrow and unusual.
It has to guarantee that the check actually ran over everything, that no
statement was admitted without a proof, and that no proof leaned on something
outside the kernel.

Lean 4 is the only system in which the mathematics this needs already exists.
The work rests on derivatives of maps between normed spaces, differentiation
under an integral sign, bump functions with prescribed support, and the standard
results about smooth functions on the line. mathlib carries all of them today
under names a contributor can find. Writing this on a foundation without that
library is not a different toolchain choice, it is several years of prerequisite
work.

The three rules this repository is built on carry over here, and the mapping is
direct rather than strained. A property can be refused, because a file that does
not compile is a build that fails. A guard can be shown to bite, because a
hypothesis can be deleted and the proof then has to fail. A claim can carry the
command that produced it, because the command that checks a theorem and prints
what it depends on is one line that any reader can run.

Pinning is not housekeeping here. mathlib is a moving target that renames
declarations regularly, and an unpinned dependency means the library's build
result depends on the day it was built. A pinned commit makes the check
reproducible, which is the whole claim the library makes about itself.

## Rejected

- Rocq, formerly Coq. The stronger tradition in mechanised analysis and a mature
  ecosystem. It loses on the library. The analysis this needs is spread across
  several developments with different conventions, and the effort of assembling
  them is larger than the effort of the mathematics.
- Isabelle/HOL. The best automation of the three and a real analysis library.
  Its type system has no dependent types, and the natural statement of a fibre
  derivative and of a symmetry group acting on a configuration space keeps
  wanting them, so the encodings would be carried in every statement a reader
  has to check.
- A computer algebra system with a proof mode. Fast to write, and it produces
  something that looks like the same result. There is nowhere in it to put a
  kernel-checked statement, so the central claim of this project could not be
  made at all.
- An unpinned dependency on mathlib's default branch, tracking upstream
  continuously. It sounds like less maintenance and is more. Every upstream
  rename lands as an unrelated red gate on whatever change happens to be open,
  and the person who has to fix it is the person who was doing something else.
- Starting from the release candidate mathlib's default branch currently pins.
  It is closer to upstream and it saves one bump later. It also means the first
  bump this repository ever performs is forced by a version being finished
  rather than by a change anybody wanted, and a contributor installing a
  prerelease toolchain has no stable point to fall back to.

## What it costs

The feedback loop is slow and the machine has to be a real one. A cold build of
the dependency graph is hours of work and gigabytes of memory, and even the
cached path costs minutes before a contributor sees their first error. This is
the concrete form of the slow feedback the project recorded about itself before
starting, and it is why the milestones after this one are small.

The pin has a maintenance cost with a name. Every mathlib bump is a piece of
work that produces no new theorem and can still break twenty proofs, and it
cannot be skipped indefinitely because the distance only grows. The register of
what a bump broke goes in the pull request that does the bump.

There is no calculus of variations upstream to build on. Read on 2026-08-07 at
the commit pinned above:

    gh api 'repos/leanprover-community/mathlib4/git/trees/905b95818eb32af7874a58b427f50c1711a5e96c?recursive=1' \
      --jq '.tree[].path' | grep -icE 'calculus/variation|EulerLagrange'
    0

So the fundamental lemma and everything above it is work this repository does
rather than imports. That is the largest single cost in the plan, and the reason
the variational core is a milestone rather than an afternoon.

Pinning to the stable release rather than to the release candidate costs a
bump. The toolchain named here is one minor version behind the one mathlib's
default branch builds against, so the first bump is already foreseeable and is
not a surprise when it arrives.
