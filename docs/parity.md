# Parity with the gate the sso board runs

The target for this repository's gate is the one `iderex/jellyfin-plugin-sso`
already runs. Its protected branch requires thirteen named checks, and that list
is what this table is measured against. Read from that repository rather than
copied from anywhere closer to hand:

    gh api repos/iderex/jellyfin-plugin-sso/rulesets --jq '.[] | select(.name == "Protect main and 5.0") | .id'
    18802863
    gh api repos/iderex/jellyfin-plugin-sso/rulesets/18802863 \
      --jq '.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks[].context'
    build
    ABI floor build
    Package (JPRM) / Build package
    Package (JPRM) / Generate SBOM
    CodeQL
    Analyze (csharp)
    DCO sign-off
    Deterministic PR-hygiene checks
    Enforce greppable invariants
    Reject Trojan Source Unicode
    Audit workflows (zizmor)
    prettier
    dependency-review

Parity means the same coverage, not the same file names. A check copied without
its reason is a check nobody maintains, so every line below either keeps a
control, replaces it with a named counterpart, or drops it, and a replacement or
a drop carries its reasoning.

Every counterpart named here is either a check run this repository has actually
produced, or an open issue in this repository. Nothing in the table stands for
work that has neither.

## What the build being the test suite removes, and what it adds

In this repository the build is the test suite. There is no separate question of
whether the code works, because a theorem that is present has been checked by a
kernel before it could be present at all.

What that removes is any counterpart to a test-execution gate. On the target
board a green build and a green test run answer two different questions. Here
they answer one, and a table that listed them separately would be claiming two
controls where one exists.

What it adds has no counterpart on the target board at all. A library here can
pass every check while asserting nothing, because a proof can be admitted rather
than finished, or a statement can be made to hold by adding an axiom that makes
it hold. Neither shows up as a failure anywhere else. That is the risk this gate
is really built around, and it is why the check that reports what a result rests
on is the central one rather than an extra.

## The thirteen contexts

### Kept unchanged

These four are already producing check runs here under the same names. The names
below are the check-run names, read off the head commit of a pull request:

    gh api "repos/iderex/lehrkanzel/commits/cf2cb909491bddc481494967dc266d63e37c28f8/check-runs" \
      --jq '.check_runs[] | "\(.name)\t\(.conclusion)"' | sort -u

- **`DCO sign-off`**. Kept. The control is that every commit carries a sign-off,
  and nothing about that changes with the language. Check run observed.
- **`Reject Trojan Source Unicode`**. Kept. The control is that the bytes a
  reviewer reads are the bytes the machine reads. It matters more here than on
  the target, because this language uses non-ASCII notation in ordinary source
  and a reader cannot fall back on treating every unusual character as
  suspicious. Check run observed.
- **`Audit workflows (zizmor)`**. Kept. The control is over the workflow
  definitions, which are the same kind of artefact in both repositories. Check
  run observed.
- **`dependency-review`**. Kept, with a limit recorded in #50 rather than
  hidden here. The control is that a new or upgraded dependency is checked
  against the advisory database before it lands. Check run observed. What it
  reaches today is the actions surface; the library dependency is in an
  ecosystem the dependency graph does not parse, so a counterpart that reads the
  committed pin is owed and #50 holds it.

None of the four is required by this repository's protection rule yet. That is
#58.

### Kept with a different implementation

- **`build`**. Keeps its name. It builds the library rather than an assembly,
  and it is simultaneously the whole test suite, which is stated here so that
  one name is not read as thinner coverage than the target's two. #37, open.
- **`ABI floor build`** becomes **pinned toolchain from a cold clone**. There is
  no host application whose interface has to hold, so the name does not carry
  over; the risk does, and it is the same one, a declared minimum that nothing
  ever resolved from scratch. #47, open.
- **`CodeQL`** becomes **`Analyze (actions)`** only. The scanner supports the
  workflow language in this tree and nothing else in it, so the actions leg is
  kept and the source leg has no counterpart to keep. #49, open.
- **`Analyze (csharp)`** is replaced rather than dropped, and its replacement is
  not a scanner. The defect class a source analyser looks for is decided by the
  kernel here, so what stands in its place is the check that reports what a
  result rests on, #41, and the invariants table, #52. Both open.
- **`Enforce greppable invariants`**. Keeps its name and gets a different table.
  The rules on the target hold a login path in place; the rules here hold in
  place the decisions about what a proof may rest on, where a derivative form
  may appear, and what the default run may touch. #52, open.
- **`Deterministic PR-hygiene checks`**. Keeps its name and gains one leg the
  target has no reason for: where a public declaration is added or changed, the
  body has to say what the statement claims in words. A reviewer reading a proof
  diff without that is reviewing the part the machine already decided. #54,
  open.
- **`Package (JPRM) / Build package`** becomes the release work in M10. What
  ships here is a tagged source package another project depends on rather than
  an installable artefact, so the packaging step has no counterpart and the
  publishing step does. #140, open.
- **`Package (JPRM) / Generate SBOM`** becomes the provenance work in M10. The
  control is that somebody downstream can check what they received, and for a
  source package that is a signature and an attestation rather than a component
  list. #145, open.

### Dropped

- **`prettier`**. Dropped. There is no JavaScript, stylesheet or web asset in
  this tree, so the formatter has nothing to keep consistent, and formatting for
  what is here is covered by the style leg of #43.

## Added, because this project carries risks the target does not

- **No unfinished proof and no added axiom**. The central one, for the reason in
  the paragraph above. #41, open.
- **The environment linter**. Two of its rules catch a hypothesis or a lemma
  that looks load-bearing and is not, which is the same class of defect as a
  name promising more than its statement. #42, open.
- **Naming, style and a docstring on every public declaration**. The docstring
  leg exists because the gap between what a name suggests and what a statement
  says is the error this project can actually make. #43, open.
- **The blueprint and the library agree**. The target has no plan document that
  can overstate what has landed. This one will. #45, open.
- **Checking time and memory**. The target's build is fast and this one is not,
  and feedback that degrades unnoticed is how a slow board becomes a stopped
  one. #56, open.
- **Build on three operating systems**. The target ships to one runtime. The
  claim here is that a default run needs nothing but a CPU on any of three, and
  a claim about three platforms that is only ever run on one is not measured.
  #40, open.

## Deferred, each to the milestone that owns it

- The release, the signing and the provenance to M10. #140 and #145, open.
- The published reference documentation to M10. #142, open.

## Not gating, with the reason

- The from-source harness. It needs hours and several gigabytes of memory, and a
  required check an outside contributor cannot run on an ordinary laptop is a
  check that blocks them. It runs on a schedule and on request, and its result is
  reported rather than required. #27, open.

## What this document is not

It is not the authority for what this repository requires. Nothing here is
required yet, and when something is, the protection rule is what says so and it
is read rather than restated:

    gh api repos/iderex/lehrkanzel/rulesets/20521583 \
      --jq '{bypass: .bypass_actors, rules: [.rules[].type]}'

It is also not a claim that any counterpart works. Every line above that names
an issue names one that is open, which is the whole of what it asserts. Reaching
the target means closing them, and this table is what makes it visible how many
are left rather than a record that the gap was thought about once.
