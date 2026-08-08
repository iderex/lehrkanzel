#!/bin/sh
# The proof that every rule in scripts/invariants.rules bites, for the reason it
# names, and that a one-change neighbour of each fixture does not.
#
# The rules read here are the SHIPPED rules. A fixture vocabulary would prove
# that the engine applies a pattern and would say nothing about the patterns
# this repository actually enforces, and the patterns are the part of #52 that
# has to be right. What is a fixture is the TREE: every file below is written
# into a temporary directory, nothing reads this repository's own tracked files,
# and a green run therefore says the rules work and says nothing about the state
# of the tree on the day it ran.
#
# Each case is a pair. One fixture trips exactly one rule and nothing else, and
# a neighbour that differs from it in one place trips nothing. The neighbours
# are the mistakes somebody actually makes: an identifier that starts with a
# forbidden word, a declaration commented out, one tactic swapped for another,
# the linear-map form moved from the statement into the proof.
#
# The meta rule is the exception to using the shipped rules, and it has to be:
# proving that a rule naming an absent decision file is refused requires a rule
# naming an absent decision file, which is the one thing the shipped set may
# never contain.
#
# Run it with no arguments. It exits non-zero on the first case that does not
# behave as its name says.

set -eu

here=$(dirname "$0")
check="$here/check-invariants.sh"
shipped="$here/invariants.rules"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

tree="$work/tree"
mkdir -p "$tree/docs/decisions" "$tree/Lehrkanzel" "$tree/scripts" "$tree/.github/workflows"

# The decision files the shipped rules name, as empty stand-ins. The meta rule
# asks whether the file is there and reads nothing out of it, so an empty file
# is the whole of what it needs, and copying the real ones would make this
# harness depend on their contents for no gain.
for d in 0002-proof-assistant-and-toolchain.md 0004-trajectories-and-time.md \
         0012-what-a-proof-may-rest-on.md 0016-headless-and-unelevated.md; do
  : > "$tree/docs/decisions/$d"
done

cases=0
bad=0

run() {
  # run <rules> <files-list>
  sh "$check" --root "$tree" --rules "$1" --files-from "$2" 2>&1
}

expect() {
  # expect <trips|passes|prints> <rule> <label> <rules> <files-list>
  want=$1; rule=$2; label=$3; rules=$4; list=$5
  cases=$((cases + 1))
  set +e
  out=$(run "$rules" "$list")
  code=$?
  set -e
  case "$want" in
    trips)
      if [ "$code" -eq 0 ]; then
        echo "BAD   $label: expected a refusal and the check passed"
        printf '%s\n' "$out" | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      if ! printf '%s\n' "$out" | grep -q "^FAIL  $rule  "; then
        echo "BAD   $label: refused, but not by $rule"
        printf '%s\n' "$out" | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      # Exactly that rule and no other. A fixture that trips two rules proves
      # neither of them, because either one would have produced the refusal.
      others=$(printf '%s\n' "$out" | grep '^FAIL  ' | grep -cv "^FAIL  $rule  " || true)
      if [ "$others" -ne 0 ]; then
        echo "BAD   $label: refused by $rule and by $others other line(s)"
        printf '%s\n' "$out" | grep '^FAIL  ' | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      echo "ok    $label"
      printf '%s\n' "$out" | grep "^FAIL  $rule  " | sed 's/^/        /'
      ;;
    passes)
      if [ "$code" -ne 0 ]; then
        echo "BAD   $label: expected a pass and the check refused"
        printf '%s\n' "$out" | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      echo "ok    $label"
      ;;
    prints)
      if [ "$code" -ne 0 ]; then
        echo "BAD   $label: expected a pass and the check refused"
        printf '%s\n' "$out" | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      if ! printf '%s\n' "$out" | grep -q "^NOT MADE  $rule  "; then
        echo "BAD   $label: passed without printing NOT MADE for $rule"
        printf '%s\n' "$out" | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      echo "ok    $label"
      printf '%s\n' "$out" | grep -A3 "^NOT MADE  $rule  " | sed 's/^/        /'
      ;;
  esac
}

lean_list() {
  # lean_list <path> ... - a file list holding only the named lean files
  : > "$work/list.txt"
  for p in "$@"; do printf '%s\n' "$p" >> "$work/list.txt"; done
  printf '%s' "$work/list.txt"
}

echo "check-invariants fixtures: one pair per rule, over a fixture tree"
echo

# ------------------------------------------------------------- no-placeholder
#
# The token is written here rather than named, because a fixture that does not
# contain the bytes the rule refuses proves nothing about the rule. Decision
# 0012 declines to quote it in prose for a reason that does not reach this file:
# the rule's subject is `lean`, and this is a shell script.
cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
theorem free_particle_is_affine : True := by
  sorry
EOF
expect trips no-placeholder "no-placeholder trips on a proof left standing open" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"

cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
theorem sorryFree : True := by
  trivial
EOF
expect passes no-placeholder "no-placeholder passes on an identifier that begins with the word" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"
echo

# ------------------------------------------------------------- no-added-axiom
cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
axiom energy_is_conserved : True
EOF
expect trips no-added-axiom "no-added-axiom trips on a declaration that introduces one" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"

cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
-- axiom energy_is_conserved : True
theorem energy_is_conserved : True := trivial
EOF
expect passes no-added-axiom "no-added-axiom passes on the neighbour that commented it out" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"
echo

# ------------------------------------------------------ no-compiled-evaluation
cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
theorem two_is_even : True := by
  native_decide
EOF
expect trips no-compiled-evaluation "no-compiled-evaluation trips on a goal closed outside the kernel" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"

cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
theorem two_is_even : True := by
  decide
EOF
expect passes no-compiled-evaluation "no-compiled-evaluation passes on the neighbour that reduces in the kernel" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"
echo

# ------------------------------------------------------------ no-escape-hatch
cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
partial def iterate (n : Nat) : Nat := iterate n
EOF
expect trips no-escape-hatch "no-escape-hatch trips on a declaration that escapes termination checking" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"

cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
def partialSum (n : Nat) : Nat := n
EOF
expect passes no-escape-hatch "no-escape-hatch passes on a name that begins with the modifier" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"
echo

# -------------------------------------------------- deriv-form-in-statements
cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
theorem stationary_of_euler (f : Real -> Real) : HasFDerivAt f g x := h
EOF
expect trips deriv-form-in-statements "deriv-form-in-statements trips when the statement carries the linear-map form" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"

cat > "$tree/Lehrkanzel/Case.lean" <<'EOF'
theorem stationary_of_euler (f : Real -> Real) : deriv f x = 0 := by
  have step : fderiv Real f x = 0 := h
  simpa using step
EOF
expect passes deriv-form-in-statements "deriv-form-in-statements passes on the neighbour that keeps the linear-map form inside the proof" \
  "$shipped" "$(lean_list Lehrkanzel/Case.lean)"
echo

# ------------------------------------------------------------ headless-tooling
cat > "$tree/scripts/fetch.sh" <<'EOF'
#!/bin/sh
curl https://example.invalid/toolchain
EOF
expect trips headless-tooling "headless-tooling trips when the default run's tooling reaches the network" \
  "$shipped" "$(lean_list scripts/fetch.sh)"

cat > "$tree/scripts/fetch.sh" <<'EOF'
#!/bin/sh
printf 'curled\n'
EOF
expect passes headless-tooling "headless-tooling passes on a word the forbidden one is a prefix of" \
  "$shipped" "$(lean_list scripts/fetch.sh)"

# The exclusion the subject declares: a fixtures script may carry the vocabulary,
# because it has to in order to prove the rule bites, and this file is the case.
cat > "$tree/scripts/thing-fixtures.sh" <<'EOF'
#!/bin/sh
curl https://example.invalid/toolchain
EOF
expect prints headless-tooling "headless-tooling does not read a fixtures script, and the empty subject prints NOT MADE" \
  "$shipped" "$(lean_list scripts/thing-fixtures.sh)"
echo

# ------------------------------------------------------ toolchain-declared-once
printf 'leanprover/lean4:v4.24.0\n' > "$tree/lean-toolchain"

cat > "$tree/.github/workflows/build.yml" <<'EOF'
jobs:
  build:
    steps:
      - run: elan toolchain install leanprover/lean4:v4.24.0
EOF
expect trips toolchain-declared-once "toolchain-declared-once trips on a workflow repeating the pinned version" \
  "$shipped" "$(lean_list lean-toolchain .github/workflows/build.yml)"

cat > "$tree/.github/workflows/build.yml" <<'EOF'
jobs:
  build:
    steps:
      - run: elan toolchain install "$(cat lean-toolchain)"
EOF
expect passes toolchain-declared-once "toolchain-declared-once passes on the neighbour that reads the file instead" \
  "$shipped" "$(lean_list lean-toolchain .github/workflows/build.yml)"

cat > "$tree/.github/workflows/build.yml" <<'EOF'
jobs:
  build:
    steps:
      - run: elan toolchain install leanprover/lean4:v4.24.0
EOF
expect prints toolchain-declared-once "toolchain-declared-once prints NOT MADE when the tree declares no version" \
  "$shipped" "$(lean_list .github/workflows/build.yml)"
echo

# ----------------------------------------------------- dependency-declared-once
#
# The manifest here holds two packages, because the rule compares against every
# revision it declares rather than only the one the decision file names, and a
# fixture with one package could not tell the two apart. The revision pasted
# into the workflow is the second package's, so a rule that read only the first
# would pass this fixture.
#
# The file list for these cases carries the manifest and the workflow and not
# lean-toolchain, so the toolchain rule prints NOT MADE beside these runs. That
# is deliberate: NOT MADE is not a FAIL, so the exactness assertion still says
# this fixture trips this rule and no other.
cat > "$tree/lake-manifest.json" <<'EOF'
{"version": "1.1.0",
 "packages":
 [{"url": "https://github.com/leanprover-community/batteries",
   "name": "batteries",
   "rev": "4a3f2d8b4e1c9d0a7b6e5f4c3d2a1b0e9f8d7c6b"},
  {"url": "https://github.com/leanprover-community/mathlib4",
   "name": "mathlib",
   "rev": "905b95818eb32af7874a58b427f50c1711a5e96c"}]}
EOF

cat > "$tree/.github/workflows/pin.yml" <<'EOF'
jobs:
  build:
    steps:
      - run: lake update mathlib --rev 905b95818eb32af7874a58b427f50c1711a5e96c
EOF
expect trips dependency-declared-once "dependency-declared-once trips on a workflow repeating a revision the manifest declares" \
  "$shipped" "$(lean_list lake-manifest.json .github/workflows/pin.yml)"

cat > "$tree/.github/workflows/pin.yml" <<'EOF'
jobs:
  build:
    steps:
      - run: lake update mathlib --rev "$(jq -r '.packages[] | select(.name == "mathlib") | .rev' lake-manifest.json)"
EOF
expect passes dependency-declared-once "dependency-declared-once passes on the neighbour that reads the manifest instead" \
  "$shipped" "$(lean_list lake-manifest.json .github/workflows/pin.yml)"

cat > "$tree/.github/workflows/pin.yml" <<'EOF'
jobs:
  build:
    steps:
      - run: lake update mathlib --rev 905b95818eb32af7874a58b427f50c1711a5e96c
EOF
expect prints dependency-declared-once "dependency-declared-once prints NOT MADE when the tree declares no revision" \
  "$shipped" "$(lean_list .github/workflows/pin.yml)"
echo

# -------------------------------------------------- every-rule-names-a-decision
#
# The one case that may not use the shipped rules: it needs a rule whose
# decision file is absent, and the shipped set may never hold one.
tab=$(printf '\t')
printf 'invented%s9999-not-a-decision.md%slean%sxyzzy%sa rule nobody can argue with\n' \
  "$tab" "$tab" "$tab" "$tab" > "$work/dangling.rules"
expect trips every-rule-names-a-decision "every-rule-names-a-decision trips on a rule naming a decision file that is not there" \
  "$work/dangling.rules" "$(lean_list Lehrkanzel/Case.lean)"

printf 'invented%s0012-what-a-proof-may-rest-on.md%slean%sxyzzy%sa rule with a decision behind it\n' \
  "$tab" "$tab" "$tab" "$tab" > "$work/held.rules"
expect passes every-rule-names-a-decision "every-rule-names-a-decision passes on the neighbour whose decision file is in the tree" \
  "$work/held.rules" "$(lean_list Lehrkanzel/Case.lean)"
echo

# -------------------------------------------------- every-rule-is-five-fields
#
# The mistake this leg exists for is a field typed with spaces instead of a tab,
# or one left out. Neither arrives as an empty value: the shell collapses a run
# of tabs, so the fields after the gap shift left and the rule runs with a
# pattern in the subject slot. Both shapes are refused before a field is read.
printf 'invented%s0012-what-a-proof-may-rest-on.md%slean%sxyzzy\n' \
  "$tab" "$tab" "$tab" > "$work/short.rules"
expect trips every-rule-is-five-fields "every-rule-is-five-fields trips on a rule line with a field left out" \
  "$work/short.rules" "$(lean_list Lehrkanzel/Case.lean)"

printf 'invented%s%slean%sxyzzy%sa rule nobody can argue with\n' \
  "$tab" "$tab" "$tab" "$tab" > "$work/nameless.rules"
expect trips every-rule-is-five-fields "every-rule-is-five-fields trips on a rule line that names no decision file" \
  "$work/nameless.rules" "$(lean_list Lehrkanzel/Case.lean)"

expect passes every-rule-is-five-fields "every-rule-is-five-fields passes on the neighbour that carries all five" \
  "$work/held.rules" "$(lean_list Lehrkanzel/Case.lean)"
echo

# ------------------------------------------------------------------ fail closed
#
# Two ways to report a clean run over nothing, and neither is allowed to look
# like a pass.
cases=$((cases + 1))
: > "$work/empty-list.txt"
set +e
out=$(run "$shipped" "$work/empty-list.txt"); code=$?
set -e
if [ "$code" -eq 0 ]; then
  echo "BAD   an empty file list is reported as a clean run"
  bad=$((bad + 1))
else
  echo "ok    an empty file list fails closed"
  printf '%s\n' "$out" | sed 's/^/        /'
fi

cases=$((cases + 1))
set +e
out=$(run "$work/no-such.rules" "$(lean_list Lehrkanzel/Case.lean)"); code=$?
set -e
if [ "$code" -eq 0 ]; then
  echo "BAD   a missing rules file is reported as a clean run"
  bad=$((bad + 1))
else
  echo "ok    a missing rules file fails closed"
  printf '%s\n' "$out" | sed 's/^/        /'
fi

echo
echo "$cases case(s), $bad unexpected"
if [ "$bad" -ne 0 ]; then
  echo "check-invariants fixtures: refused."
  exit 1
fi
echo "check-invariants fixtures: every case behaved as its name says."
