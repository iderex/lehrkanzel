#!/bin/sh
# Rules over the text of the tree, each one holding a decision in place.
#
# Every rule names the decision file it protects, and the first rule run is the
# one that reads the others: a rule whose decision file is not in the tree is
# refused rather than run, because a rule with no decision behind it is a rule
# nobody maintains and nobody can argue with.
#
# The rules are data, in scripts/invariants.rules, and this file is the code
# that applies them. That split is not tidiness. The headless rule refuses a set
# of invocations inside shell scripts, and a shell script carrying those
# invocations as literals would refuse itself, so the vocabulary lives in a file
# that is not a shell script and the rule reaches every script including this
# one.
#
# What this cannot do, stated here rather than discovered. A grep refuses a word
# and never a dependency: a declaration can rest on a placeholder through six
# lemmas in three files without the word appearing near it, which is exactly
# what decision 0012 says about the cheap half. This is the cheap half. The
# axiom report is the other one and it is issue #41.
#
# A rule whose subject set is empty prints NOT MADE rather than ok, and so do
# the two comparing rules while the tree declares nothing for them to compare
# against. All of them pass. The distinction is the whole point of printing it:
# a run over nothing and a run that found nothing are different results and they
# look identical in an exit code.
#
# Deterministic: the verdict is a function of the file list, the bytes of those
# files, and the rules file. Nothing reads the network, the clock or a working
# tree the caller did not name.

set -eu

root="."
rules="scripts/invariants.rules"
files_from=""

usage() {
  echo "usage: check-invariants.sh [--root DIR] [--rules FILE] [--files-from FILE]" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --root) root=$2; shift 2 ;;
    --rules) rules=$2; shift 2 ;;
    --files-from) files_from=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "check-invariants: unknown argument: $1" >&2; usage; exit 2 ;;
  esac
done

if [ ! -f "$rules" ]; then
  echo "check-invariants: no rules file at $rules - failing closed rather than reporting a clean run over nothing."
  exit 1
fi

list=$(mktemp)
trap 'rm -f "$list"' EXIT INT TERM

if [ -n "$files_from" ]; then
  cat "$files_from" > "$list"
else
  (cd "$root" && git ls-files) > "$list"
fi

if [ ! -s "$list" ]; then
  echo "check-invariants: the file list is empty - failing closed rather than reporting a clean run over nothing."
  exit 1
fi

decisions_dir="docs/decisions"
tab=$(printf '\t')
fail=0

rule_count=$(grep -cvE '^[[:space:]]*(#|$)' "$rules" || true)
echo "check-invariants: $rule_count rule(s) over the text of the tree, and two rules over the rules"
echo

# The two rules over the rules.
#
# The shape leg runs first and exits on its own, because the loop below reads
# the file with `read` and a tab IFS, and a tab is an IFS whitespace character:
# the shell collapses a run of them, so a line that dropped a field arrives with
# every later field shifted one place left rather than with an empty one. That
# is a misparse and not a value, so it is refused by awk, which splits on each
# tab and does not collapse, before anything reads a field.
echo "  every-rule-is-five-fields    $rules"
shape=$(awk -F'\t' '
  /^[[:space:]]*(#|$)/ { next }
  NF != 5 { printf "line %d carries %d field(s), not 5\n", NR, NF; next }
  { for (i = 1; i <= NF; i++) if ($i == "") printf "line %d leaves field %d empty\n", NR, i }
' "$rules")
if [ -n "$shape" ]; then
  printf '%s\n' "$shape" | sed 's/^/FAIL  every-rule-is-five-fields  /'
  echo
  echo "check-invariants: refused. See the FAIL lines above."
  exit 1
fi
echo "ok    every-rule-is-five-fields    every rule line carries five non-empty fields"

# Every rule names a decision file, and that file is in the tree. A rule naming
# a file that is not there is refused here and is not run below, so a rule
# cannot quietly outlive the decision it was written for.
echo "  every-rule-names-a-decision  $decisions_dir"
meta_fail=0
while IFS="$tab" read -r id decision subject pattern detail; do
  case "$id" in ''|\#*) continue ;; esac
  if [ ! -f "$root/$decisions_dir/$decision" ]; then
    echo "FAIL  every-rule-names-a-decision  $id names $decision, which is not a file under $decisions_dir"
    meta_fail=1
    continue
  fi
  echo "ok    every-rule-names-a-decision  $id holds $decision"
done < "$rules"

if [ "$meta_fail" -ne 0 ]; then
  fail=1
  echo
  echo "check-invariants: refused. See the FAIL lines above."
  exit 1
fi

echo

# Subject selection. Each rule reads one of three sets, and the set it read is
# printed with its size, so a rule that applied to nothing cannot be read as a
# rule that applied and found nothing.
subject_files() {
  subject=$1
  while IFS= read -r f; do
    case "$subject" in
      lean)
        case "$f" in *.lean) ;; *) continue ;; esac ;;
      tooling)
        case "$f" in
          scripts/*-fixtures.sh) continue ;;
          scripts/*.sh) ;;
          *) continue ;;
        esac ;;
      toolchain|dependency)
        case "$f" in .github/workflows/*.yml|.github/workflows/*.yaml) ;; *) continue ;; esac ;;
      *) continue ;;
    esac
    [ -f "$root/$f" ] || continue
    printf '%s\n' "$f"
  done < "$list"
}

toolchain_version=""
if grep -qx 'lean-toolchain' "$list" && [ -f "$root/lean-toolchain" ]; then
  toolchain_version=$(tr -d ' \t\r\n' < "$root/lean-toolchain")
fi

# The revisions the manifest declares, as an alternation. Every package in it
# counts and not only the one the decision file names, because a revision pasted
# into a workflow is the same second declaration whichever package it belongs
# to. A revision is hexadecimal, so it carries no character the pattern would
# have to escape, and the extraction says so by refusing anything else.
dependency_revisions=""
if grep -qx 'lake-manifest.json' "$list" && [ -f "$root/lake-manifest.json" ]; then
  dependency_revisions=$(
    grep -oE '"rev"[[:space:]]*:[[:space:]]*"[0-9a-fA-F]{7,40}"' "$root/lake-manifest.json" |
      sed 's/.*"\([0-9a-fA-F]*\)"$/\1/' |
      sort -u |
      tr '\n' '|' |
      sed 's/|$//'
  )
fi

while IFS="$tab" read -r id decision subject pattern detail; do
  case "$id" in ''|\#*) continue ;; esac

  subject_list=$(subject_files "$subject" || true)
  n=0
  [ -n "$subject_list" ] && n=$(printf '%s\n' "$subject_list" | wc -l | tr -d ' ')

  if [ "$n" -eq 0 ]; then
    echo "NOT MADE  $id  $decision"
    echo "          No tracked file is in subject $subject, so this rule was compared"
    echo "          against nothing. It passed WITHOUT LOOKING. Read it as a gap, not"
    echo "          as a clean run."
    echo
    continue
  fi

  if [ "$subject" = toolchain ]; then
    if [ -z "$toolchain_version" ]; then
      echo "NOT MADE  $id  $decision"
      echo "          The tree declares no toolchain version, so no workflow was compared"
      echo "          against one. This rule passed WITHOUT LOOKING. Read it as a gap, not"
      echo "          as a clean comparison. It starts comparing on the day lean-toolchain"
      echo "          lands, which is issue #20."
      echo
      continue
    fi
    pattern=$(printf '%s' "$toolchain_version" | sed 's/[].[^$\\*\/]/\\&/g')
  fi

  if [ "$subject" = dependency ]; then
    if [ -z "$dependency_revisions" ]; then
      echo "NOT MADE  $id  $decision"
      echo "          The tree declares no dependency revision, so no workflow was"
      echo "          compared against one. This rule passed WITHOUT LOOKING. Read it as"
      echo "          a gap, not as a clean comparison. It starts comparing on the day"
      echo "          lake-manifest.json lands, which is issue #22."
      echo
      continue
    fi
    pattern="$dependency_revisions"
  fi

  echo "  $id  $decision  $n file(s) in subject $subject"

  rule_fail=0
  for f in $subject_list; do
    hits=$(grep -nE "$pattern" "$root/$f" || true)
    [ -z "$hits" ] && continue
    while IFS= read -r hit; do
      line=${hit%%:*}
      echo "FAIL  $id  $f:$line  $detail"
      rule_fail=1
    done <<HITS
$hits
HITS
  done

  if [ "$rule_fail" -eq 0 ]; then
    echo "ok    $id  no hit in $n file(s)"
  else
    fail=1
  fi
  echo
done < "$rules"

if [ "$fail" -ne 0 ]; then
  echo "check-invariants: refused. See the FAIL lines above."
  exit 1
fi
echo "check-invariants: every rule passes."
