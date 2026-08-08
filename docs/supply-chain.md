# Supply chain

A supply-chain self-audit runs against this repository and publishes what it
finds. A published score that nobody reads is decoration, so every finding it
produces is placed here in one of two states: fixed, or accepted with the reason
and with what would change the decision. There is no third state and no
untriaged backlog. If a finding is not in this file, the file is wrong.

This document also states what is trusted about the prebuilt object cache the
ordinary build is going to consume, because that is a supply chain no scanner in
this repository examines.

## Where the findings come from

The audit is `.github/workflows/scorecard.yml`, which runs the OpenSSF Scorecard
checks and uploads the result to code scanning. A second audit,
`.github/workflows/zizmor.yml`, analyses the workflow definitions themselves and
fails the run on any finding at low severity or above. A third,
`.github/workflows/codeql.yml`, reads the same definitions as a data-flow graph
and fails on a finding the query pack reports at critical or high; it uploads
into the same tab, so a finding it produces would appear in the list below
beside the Scorecard ones. It produces none today.

The list below was read at `e2ca55c` with

    gh api repos/iderex/lehrkanzel/code-scanning/alerts \
      --jq '.[] | [.number, .rule.id, .state] | @tsv'
    9	CIIBestPracticesID	open
    8	CodeReviewID	open
    7	MaintainedID	open
    6	LicenseID	open
    5	FuzzingID	open
    4	SecurityPolicyID	open
    3	DependencyUpdateToolID	open
    2	SASTID	fixed
    1	BranchProtectionID	open

Nine findings, and all nine are triaged below. The heading of each entry is the
Scorecard check the alert reports, with the alert number that command prints.
Every one of the nine comes from Scorecard, which is a fact about the tab rather
than an assumption about it:

    gh api repos/iderex/lehrkanzel/code-scanning/alerts \
      --jq '[.[].tool.name] | unique | @tsv'
    Scorecard

## The findings

### 1, Branch-Protection

Accepted for now.

Scorecard scores this 3 and reports that `main` requires no approving review, no
code-owner review, no last-push approval, no stale-review dismissal, and no
status check. The first four are true and are a consequence of how this
repository is worked at present. The fifth is the one that matters, because a
required status check is what stops a change merging while a gate is red or
while a gate never ran at all.

What would change it: the issue that requires the named checks on the protected
branch. The score cannot move before the checks it would require exist, and most
of them do not exist yet.

### 2, SAST

Fixed, and reported as fixed by the audit itself, which is why the command above
prints `fixed` beside it rather than `open`.

Two static analysers now run over the most privileged code in this repository,
and both gate rather than report. `.github/workflows/zizmor.yml` judges the
shape of a workflow document. `.github/workflows/codeql.yml` builds a data-flow
graph over the expressions and follows an untrusted value into a place that
executes it. They disagree in both directions on a fixture that was run through
them, which is why both are kept: the record is in the pull request that landed
the second one.

What the second one refuses is bounded, and the bound belongs here rather than
only in that file. The default query suite carries the critical and high
variants of each query and not the medium ones, so the same injection in a
workflow that declares no token scope is reported at a severity this gate never
sees.

This does not mean a source analyser covers the mathematical part of the tree.
It does not, no such analyser is planned, and the reason is written into the
issue that decides what a code scanner covers here.

### 3, Dependency-Update-Tool

Accepted for now.

No automated dependency update configuration exists. The repository declares no
package dependency yet, so an update tool would have nothing to update. When the
toolchain pin and the mathlib pin land, they are the dependencies, and decision
0002 already fixes how they move: only in a commit that does nothing else and
that says which upstream change forced it. An update tool that opens a pull
request per upstream commit is at odds with that, so adopting one is a decision
rather than a default, and it belongs with the issue that gates known vulnerable
dependencies.

What would change it: a dependency landing in the tree together with a decision
about who is allowed to move its pin.

### 4, Security-Policy

Accepted for now.

There is no `SECURITY.md`. The issue that writes the contributor, conduct,
security and governance documents is where it is written, and that issue asks
for a security document that describes what a vulnerability means for a library
of this kind rather than a template. Writing one now, ahead of the gate it is
supposed to describe, is how a security document ends up describing something
that is not true.

What would change it: that issue landing.

### 5, Fuzzing

Accepted, and the acceptance is a considered one rather than a deferral.

There is no parser here and no untrusted input, so a fuzzer would have nothing
to drive. The risk underneath fuzzing does transfer, which is that a hand-chosen
set of cases agrees with a wrong implementation because the same person chose
both, and the issue that checks the worked examples against independently
derived values is what answers it. That issue also records this substitution
where the parity between this repository and its reference gate is written down.

What would change it: something in this repository acquiring an untrusted input
surface. Nothing in the plan has one.

### 6, License

Accepted for now, and this one is not a matter of engineering judgement.

There is no license file. Which license this repository carries is an open
maintainer decision, it is the first item on the issue that holds the maintainer
decisions, and nothing here settles it. Choosing one to clear a finding would be
choosing it for the wrong reason, and it is the single decision in this
repository that is hardest to reverse once code exists under it.

What would change it: the maintainer deciding, after which the issue that
applies the license decision and ships the notices closes this finding.

### 7, Maintained

Accepted.

The check reports that the repository was created within the last ninety days.
That is true, it is not a defect, and nothing can be done about it except to
continue. The check is a warning to a reader evaluating an unfamiliar
repository, and it is correct to warn them.

What would change it: the passage of time and continued activity. Neither is a
task.

### 8, Code-Review

Accepted, with the disclosure the finding is really asking for.

Scorecard found zero of three recent changesets approved. That is accurate.
Changes here have merged without a second person reading them, and the branch
ruleset requires zero approving reviews, so nothing refuses that. This is the
weakest point in the repository's process and it is not softened here.

What would change it: a second reader, and a required approving review count
above zero in the ruleset. The second is easy and worthless without the first.

### 9, CII-Best-Practices

Accepted.

No OpenSSF best practices badge has been applied for. The badge is a
self-assessment questionnaire, and most of what it asks about is either not yet
true here or is answered better by the issues that make each property refusable.
Applying for it before those exist would produce a badge that is accurate on the
day it is filled in and stale afterwards.

What would change it: the gate milestone landing, after which the questionnaire
can be answered from things that exist rather than from intentions.

## The workflow hygiene rules

Four rules are kept true about every workflow in this repository. They are not
asserted here, they are decided by the audits named above, and each rule below
names what refuses a violation. The counts move whenever a workflow is added, so
they are read again rather than carried forward; these were read at `e2ca55c`,
where the directory holds eight files.

Every action is pinned to an exact revision with the version in a comment:

    git grep -h -E '^\s+(- )?uses:' -- .github/workflows \
      | grep -cvE '@[0-9a-f]{40} # '
    0

Scorecard's Pinned-Dependencies check, zizmor's `unpinned-uses` rule and
CodeQL's `actions/unpinned-tag` all refuse a violation, and none reports one.

Checkout never persists the token, because no step in this repository pushes
with git:

    git grep -c 'actions/checkout@' -- .github/workflows \
      | awk -F: '{s+=$2} END {print s}'
    8
    git grep -c 'persist-credentials: false' -- .github/workflows \
      | awk -F: '{s+=$2} END {print s}'
    8

zizmor's `artipacked` rule refuses a checkout that leaves the token in
`.git/config`.

Permissions are declared at the narrowest scope that works. Every workflow
declares a token scope at the top, six of them `contents: read` and two an empty
set, and a write scope appears only inside the three jobs that write:

    git grep -n -A1 '^permissions' -- .github/workflows
    git grep -n -E '^      [a-z-]+: write' -- .github/workflows
    .github/workflows/codeql.yml:61:      security-events: write # upload the SARIF into the code-scanning tab
    .github/workflows/scorecard.yml:63:      security-events: write
    .github/workflows/scorecard.yml:65:      id-token: write
    .github/workflows/zizmor.yml:45:      security-events: write # upload the SARIF into the code-scanning tab

Scorecard's Token-Permissions check, zizmor's `excessive-permissions` rule and
CodeQL's `actions/missing-workflow-permissions` all refuse a violation, and none
reports one. The last of those is not an assumption: it is one of the two
findings the fixture in the pull request that landed the scanner was refused
with.

No job holds a write scope it does not use. The three that do are the Scorecard
analysis job, which needs `security-events: write` to upload its result and
`id-token: write` to publish the score, and the two scanning jobs, each of which
needs `security-events: write` for the same reason. All are declared on the job
rather than on the workflow, which is what the second command above shows by
matching only at that indentation.

No deliberate exception to any of these four rules exists in this repository
today, so no workflow file carries one. When one is taken, the reason goes in
the workflow file it applies to rather than here, because the reader who needs
it is reading that file.

The three audits were last observed green on `e2ca55c`:

    gh run list --repo iderex/lehrkanzel --branch main --limit 10 \
      --json databaseId,workflowName,conclusion,headSha \
      --jq '.[] | select(.headSha|startswith("e2ca55c"))
             | [.databaseId, .workflowName, .conclusion] | @tsv'
    31254098571	unicode-guard	success
    31254098583	decision-files	success
    31254098574	codeql	success
    31254098593	Workflow Security Analysis	success
    31254098567	Scorecard supply-chain security	success

## The object cache

Decision 0002 fixes that the ordinary build fetches mathlib's prebuilt object
cache rather than rebuilding the dependency graph from source. That is the one
place where this repository's central claim, that a kernel checked these
statements, leans on machines nobody here controls, and no scanner in this
repository looks at it.

What is trusted. The cache holds compiled artefacts for the mathlib commit named
in decision 0002. It is fetched over HTTPS from blob storage whose address and
trust order are decided by mathlib's own cache module rather than by anything
here, which can be read at the pinned commit with

    gh api 'repos/leanprover-community/mathlib4/contents/Cache/Requests.lean?ref=905b95818eb32af7874a58b427f50c1711a5e96c' \
      --jq .content | base64 -d | grep -n 'defaultContainersForRepo'

Who produces it. The mathlib project's own automation, from the same commit this
repository pins. Nobody here has any part in producing it, and nothing here
verifies that the artefacts correspond to the source at that commit. Fetching
the cache therefore trusts the mathlib project, its automation, and the storage
in front of it. Stating that is the whole of what this section can do; it is a
trust rather than a check.

What tests the trust. The from-source harness, which builds the dependency and
the library with the cache disabled and is the issue that names what it needs in
memory, disk and time. That harness is what turns the trust above into something
checked, and it does not gate, because a required check that an outside
contributor cannot run on an ordinary laptop is a check that blocks them.

Neither the cache nor the harness exists in this repository today. Nothing is
scaffolded, so nothing fetches a cache and there is nothing yet for the harness
to build. This section is written now because the decision that creates the
trust is already made, and a trust recorded after it is being relied on is a
trust nobody chose.
