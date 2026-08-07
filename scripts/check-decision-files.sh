#!/bin/sh
# Refuses a decision file that is missing one of the four sections decision 0001
# requires, and a reference to a decision file that is not in the tree.
#
# Decision 0001 says the four sections are what a decision file is, and that a
# superseded decision is replaced by a new file which names the one it replaces.
# Until this ran, both were carried by whoever happened to read the file. The
# section that goes missing is the cost one, which is the section a later reader
# has the most use for; and a supersede line pointing at a file that is not
# there turns the one thing 0001 asks a reader to rely on into a dead end.
#
# It runs on any machine with git and a shell, before there is anything here to
# build, which is the point: these files are written before the library exists.
#
# What it does not do. It counts sections, it does not read them, so a section
# holding one empty sentence passes. Whether a decision was argued is a
# judgement, no reading of the tree makes it, and the review is where a bad one
# is caught.

set -eu

decisions_dir="docs/decisions"

fail=0

files=$(git ls-files -- "$decisions_dir/*.md")
if [ -z "$files" ]; then
  echo "check-decision-files: no tracked file under $decisions_dir - failing closed rather than reporting a clean run over nothing."
  exit 1
fi

count=$(printf '%s\n' "$files" | wc -l | tr -d ' ')
echo "check-decision-files: two rules over $count tracked file(s) under $decisions_dir"
echo "  sections    every decision file carries the four sections decision 0001 requires"
echo "  references  every reference to a decision file names one that is in the tree"
echo

# A heading is matched by its opening words rather than in full, because a file
# may say what it is a why for: "## Why the hypothesis is carried rather than
# derived" is the why section, and a full-string match would refuse it.
for f in $files; do
  file_ok=1
  for heading in 'The decision' 'Why' 'Rejected' 'What it costs'; do
    if ! grep -qE "^## $heading" "$f"; then
      echo "FAIL  $f is missing the section: ## $heading"
      file_ok=0
    fi
  done
  if [ "$file_ok" -eq 1 ]; then
    echo "ok    $f  four sections"
  else
    fail=1
  fi
done

echo

# A reference is a decision file name: four digits, a hyphen, a name, and .md,
# written either bare or with the directory in front of it. The four digits are
# what keeps this off the form written in 0001, which describes the shape of a
# name rather than naming a file.
refs=$(mktemp)
grep -HnoE '(docs/decisions/)?[0-9][0-9][0-9][0-9]-[A-Za-z0-9._-]+\.md' $files > "$refs" || true

if [ ! -s "$refs" ]; then
  echo "no reference to a decision file in any decision file"
else
  while IFS= read -r hit; do
    where=${hit%%:*}
    rest=${hit#*:}
    line=${rest%%:*}
    ref=${rest#*:}
    base=${ref##*/}
    if [ -f "$decisions_dir/$base" ]; then
      echo "ok    $where:$line  $ref"
    else
      echo "FAIL  $where:$line names $ref, which is not a file under $decisions_dir"
      fail=1
    fi
  done < "$refs"
fi

rm -f "$refs"

echo
if [ "$fail" -ne 0 ]; then
  echo "check-decision-files: refused. See the FAIL lines above."
  exit 1
fi
echo "check-decision-files: both rules pass."
