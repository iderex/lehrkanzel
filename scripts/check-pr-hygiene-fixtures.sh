#!/bin/sh
# The proof that every leg of check-pr-hygiene.sh bites, for the reason it names.
#
# Each case is a pair. One fixture trips exactly one leg, and a neighbour that
# differs from it in one place does not. A near-miss that could not have failed
# proves nothing, so the neighbours here are the one-character and one-line
# mistakes somebody actually makes: the closing keyword left off, a path one
# directory over, a heading left standing with the template's own comment under
# it, the word `none` where a sentence belongs, the exception line missing.
#
# The vocabularies here are FIXTURE vocabularies. Nothing in this file reads
# this repository's own template, issues or history, so a green run says the
# guard works and says nothing about the state of the tree on the day it ran.
#
# Run it with no arguments. It exits non-zero on the first case that does not
# behave as its name says.

set -eu

here=$(dirname "$0")
check="$here/check-pr-hygiene.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cases=0
bad=0

# A template with three headings, one of which is the statements section.
cat > "$work/template.md" <<'EOF'
<!-- guidance the author is meant to delete -->

## What changed

## The statements, in words

<!-- Where no public declaration changed, write "none". -->

## Closes
EOF

# A body that satisfies every leg. Each case copies this and breaks one thing.
cat > "$work/good-body.md" <<'EOF'
## What changed

One document.

## The statements, in words

none

## Closes

Closes #60
EOF

printf 'docs/parity.md\n' > "$work/good-files.txt"
printf '10\t0\tdocs/parity.md\n' > "$work/good-numstat.txt"
printf 'Write the parity table\n\nIssue #60.\n' > "$work/good-messages.txt"
printf '60\tdocs/\n' > "$work/good-scopes.txt"

run() {
  # run <files> <numstat> <messages> <body> <scopes>
  sh "$check" --files "$1" --numstat "$2" --messages "$3" --body "$4" \
    --scopes "$5" --template "$work/template.md" --cap 400 2>&1
}

expect() {
  # expect <trips|passes> <leg> <label> <files> <numstat> <messages> <body> <scopes>
  want=$1; leg=$2; label=$3; shift 3
  cases=$((cases + 1))
  set +e
  out=$(run "$@")
  code=$?
  set -e
  case "$want" in
    trips)
      if [ "$code" -eq 0 ]; then
        echo "BAD   $label: expected a refusal and the check passed"
        bad=$((bad + 1))
        return
      fi
      if ! printf '%s' "$out" | grep -q "FAIL  $leg"; then
        echo "BAD   $label: refused, but not by $leg"
        printf '%s\n' "$out" | sed 's/^/        /'
        bad=$((bad + 1))
        return
      fi
      echo "ok    $label"
      printf '%s\n' "$out" | grep "FAIL  $leg" | sed 's/^/        /'
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
        bad=$((bad + 1))
        return
      fi
      if ! printf '%s' "$out" | grep -q "$leg"; then
        echo "BAD   $label: passed without printing $leg"
        bad=$((bad + 1))
        return
      fi
      echo "ok    $label"
      printf '%s\n' "$out" | grep -A3 "NOT MADE" | sed 's/^/        /'
      ;;
  esac
}

echo "check-pr-hygiene fixtures: one pair per leg"
echo

# ------------------------------------------------------------- names-an-issue
sed 's/^Closes #60$/Closes the parity work/' "$work/good-body.md" > "$work/no-issue-body.md"
printf 'Write the parity table\n' > "$work/no-issue-messages.txt"

expect trips names-an-issue "names-an-issue trips when no message and no body names one" \
  "$work/good-files.txt" "$work/good-numstat.txt" "$work/no-issue-messages.txt" \
  "$work/no-issue-body.md" "$work/good-scopes.txt"

expect passes names-an-issue "names-an-issue passes on the neighbour that puts the number back" \
  "$work/good-files.txt" "$work/good-numstat.txt" "$work/no-issue-messages.txt" \
  "$work/good-body.md" "$work/good-scopes.txt"

echo

# --------------------------------------------------------- paths-inside-scope
printf 'docs/parity.md\nREADME.md\n' > "$work/outside-files.txt"
printf '10\t0\tdocs/parity.md\n2\t1\tREADME.md\n' > "$work/outside-numstat.txt"

expect trips paths-inside-scope "paths-inside-scope trips on a file outside the declared scope" \
  "$work/outside-files.txt" "$work/outside-numstat.txt" "$work/good-messages.txt" \
  "$work/good-body.md" "$work/good-scopes.txt"

printf '60\tdocs/ README.md\n' > "$work/wider-scopes.txt"
expect passes paths-inside-scope "paths-inside-scope passes on the neighbour whose issue declares that file" \
  "$work/outside-files.txt" "$work/outside-numstat.txt" "$work/good-messages.txt" \
  "$work/good-body.md" "$work/wider-scopes.txt"

: > "$work/empty-scopes.txt"
expect prints "NOT MADE" "paths-inside-scope prints NOT MADE and passes when no named issue declares one" \
  "$work/outside-files.txt" "$work/outside-numstat.txt" "$work/good-messages.txt" \
  "$work/good-body.md" "$work/empty-scopes.txt"

echo

# ----------------------------------------------------- body-carries-its-parts
grep -v '^## Closes$' "$work/good-body.md" | grep -v '^Closes #60$' > "$work/no-heading-body.md"
printf '\nIssue #60.\n' >> "$work/no-heading-body.md"

expect trips body-carries-its-parts "body-carries-its-parts trips when a heading the template asks for is gone" \
  "$work/good-files.txt" "$work/good-numstat.txt" "$work/good-messages.txt" \
  "$work/no-heading-body.md" "$work/good-scopes.txt"

expect passes body-carries-its-parts "body-carries-its-parts passes on the neighbour that keeps the heading" \
  "$work/good-files.txt" "$work/good-numstat.txt" "$work/good-messages.txt" \
  "$work/good-body.md" "$work/good-scopes.txt"

cat > "$work/comment-body.md" <<'EOF'
## What changed

One document.

## The statements, in words

<!-- Where no public declaration changed, write "none". -->

## Closes

Closes #60
EOF

expect trips body-carries-its-parts "body-carries-its-parts trips on a heading holding only the template's own comment" \
  "$work/good-files.txt" "$work/good-numstat.txt" "$work/good-messages.txt" \
  "$work/comment-body.md" "$work/good-scopes.txt"

echo

# ------------------------------------------- the statements section, pressed
printf 'Lehrkanzel/Symmetry/Noether.lean\n' > "$work/source-files.txt"
printf '40\t0\tLehrkanzel/Symmetry/Noether.lean\n' > "$work/source-numstat.txt"
printf '60\tdocs/ Lehrkanzel/\n' > "$work/source-scopes.txt"

expect trips body-carries-its-parts "the statements section trips when a source file changed and it says only none" \
  "$work/source-files.txt" "$work/source-numstat.txt" "$work/good-messages.txt" \
  "$work/good-body.md" "$work/source-scopes.txt"

sed 's/^none$/The conserved quantity of a translation symmetry is the momentum./' \
  "$work/good-body.md" > "$work/stated-body.md"

expect passes body-carries-its-parts "the statements section passes on the neighbour that says what the statement claims" \
  "$work/source-files.txt" "$work/source-numstat.txt" "$work/good-messages.txt" \
  "$work/stated-body.md" "$work/source-scopes.txt"

echo

# ------------------------------------------------------------------------ size
printf '900\t0\tdocs/parity.md\n' > "$work/large-numstat.txt"

expect trips size "size trips over the cap with no exception declared" \
  "$work/good-files.txt" "$work/large-numstat.txt" "$work/good-messages.txt" \
  "$work/good-body.md" "$work/good-scopes.txt"

cp "$work/good-body.md" "$work/exception-body.md"
printf '\nSize exception: every line is one row of one table and the reader checks the same property on each.\n' \
  >> "$work/exception-body.md"

expect passes size "size passes on the neighbour that declares the exception at column zero" \
  "$work/good-files.txt" "$work/large-numstat.txt" "$work/good-messages.txt" \
  "$work/exception-body.md" "$work/good-scopes.txt"

echo
echo "$cases case(s), $bad unexpected"
if [ "$bad" -ne 0 ]; then
  echo "check-pr-hygiene fixtures: refused."
  exit 1
fi
echo "check-pr-hygiene fixtures: every case behaved as its name says."
