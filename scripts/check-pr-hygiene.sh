#!/bin/sh
# Deterministic checks over a change rather than over the tree.
#
# Every leg is a function of five files and nothing else: the changed paths, the
# per-file line counts, the commit messages, the pull request body, and the
# scopes the named issues declare. Nothing here reads the network, the clock or
# a working tree, so the same inputs give the same verdict on any machine, and a
# fixture is five small files rather than a repository.
#
# The legs, and what each one prevents:
#
#   names-an-issue        A change whose done-condition was never written down.
#   paths-inside-scope    A second topic riding along inside a change about
#                         something else. Where no named issue declares a scope
#                         the comparison is NOT MADE and the leg passes, and it
#                         says so in a form nobody reads as a pass.
#   body-carries-its-parts
#                         A body missing a heading the template asks for, or one
#                         with the heading and nothing under it. The required
#                         set is read out of the template rather than written
#                         here, so the two cannot drift apart.
#   size                  A change too large to read, against a stated cap, with
#                         one escape that has to be claimed in the body by name.
#
# What no leg does. None of them reads meaning. The scope leg compares paths and
# cannot tell work that belongs to an issue from work that merely touches the
# same paths. The body leg counts sections and cannot tell whether what is
# written under one answers it. The size leg reads a declared exception and
# cannot tell whether the property it names is real. Each of those is a
# judgement, and the review is where it is caught.
#
# One weakness of the scope leg is worth naming rather than leaving to be found.
# The scope it compares against is the UNION over every issue named anywhere in
# the messages or the body, so a number mentioned in passing widens the
# comparison by however much that issue's own Scope line covers. A body citing a
# neighbouring issue for context therefore buys the paths that issue declares,
# which is not what anybody intends by citing it. Narrowing the union to the
# issues a change says it closes would fix that and would also make a change
# closing nothing compare against nothing, which is a worse default, so the wide
# union is kept and disclosed instead of quietly tightened.
#
# The sign-off leg runs as its own check in this repository and is not repeated
# here.

set -eu

files=""
numstat=""
messages=""
body=""
scopes=""
template=".github/pull_request_template.md"
cap=400
print_named=0

usage() {
  cat <<'EOF'
usage: check-pr-hygiene.sh --files F --numstat F --messages F --body F
                           [--scopes F] [--template F] [--cap N]

  --files     one changed path per line, as `git diff --name-only BASE...HEAD`
  --numstat   added, deleted and path per line, as `git diff --numstat BASE...HEAD`
  --messages  every commit message in the range, as `git log --format=%B BASE..HEAD`
  --body      the pull request body
  --scopes    one line per issue: the number, a tab, then its scope entries
              separated by spaces. An issue with no `Scope:` line is absent.
  --template  the pull request template the required headings are read from
  --cap       the line cap the size leg measures against
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --files) files="$2"; shift 2 ;;
    --numstat) numstat="$2"; shift 2 ;;
    --messages) messages="$2"; shift 2 ;;
    --body) body="$2"; shift 2 ;;
    --scopes) scopes="$2"; shift 2 ;;
    --template) template="$2"; shift 2 ;;
    --cap) cap="$2"; shift 2 ;;
    --print-named) print_named=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "check-pr-hygiene: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

for required in files numstat messages body; do
  eval "value=\$$required"
  if [ -z "$value" ]; then
    echo "check-pr-hygiene: --$required is required" >&2
    exit 2
  fi
  if [ ! -f "$value" ]; then
    echo "check-pr-hygiene: --$required names $value, which is not a file" >&2
    exit 2
  fi
done

if [ ! -f "$template" ]; then
  echo "check-pr-hygiene: --template names $template, which is not a file" >&2
  exit 2
fi

fail=0

if [ "$print_named" -eq 0 ]; then
  echo "check-pr-hygiene: four legs over one change"
  echo
fi

# ---------------------------------------------------------------- names-an-issue
#
# An issue reference is a hash and digits, in a commit message or in the body.
# Both are read, because a body may close an issue no commit message mentions
# and a commit message may name one the body forgot.

named=$(cat "$messages" "$body" | grep -oE '#[0-9]+' | tr -d '#' | sort -un || true)

# The caller that builds the scopes file has to name the same issues this leg
# names, so it asks rather than repeating the expression. Nothing else is
# printed in this mode and no leg runs.
if [ "$print_named" -eq 1 ]; then
  [ -z "$named" ] || printf '%s\n' "$named"
  exit 0
fi

if [ -z "$named" ]; then
  echo "FAIL  names-an-issue     no issue is named in any commit message or in the body"
  fail=1
else
  echo "ok    names-an-issue     $(echo "$named" | tr '\n' ' ')"
fi
echo

# ------------------------------------------------------------ paths-inside-scope
#
# The union of the scopes the named issues declare. A path is inside the scope
# if it equals an entry, or if it sits under an entry read as a directory. An
# entry is read as a directory whether or not it carries a trailing slash,
# because an issue writes `docs/decisions/` and `Lehrkanzel/` both ways.

declared=""
if [ -n "$scopes" ] && [ -f "$scopes" ]; then
  for n in $named; do
    line=$(grep "^$n	" "$scopes" || true)
    if [ -n "$line" ]; then
      entries=$(printf '%s' "$line" | cut -f2-)
      declared="$declared $entries"
    fi
  done
fi

# Trim.
declared=$(printf '%s' "$declared" | tr -s ' ' | sed 's/^ //; s/ $//')

if [ -z "$declared" ]; then
  echo "NOT MADE  paths-inside-scope"
  echo "          No named issue declares a Scope, so the changed paths were compared"
  echo "          against nothing. This leg passed WITHOUT LOOKING. Read it as a gap,"
  echo "          not as a clean comparison."
else
  echo "ok    paths-inside-scope declared scope: $declared"
  outside=""
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    inside=0
    for entry in $declared; do
      entry=${entry%/}
      if [ "$path" = "$entry" ] || [ "${path#"$entry"/}" != "$path" ]; then
        inside=1
        break
      fi
    done
    if [ "$inside" -eq 0 ]; then
      outside="$outside $path"
    fi
  done < "$files"
  if [ -n "$outside" ]; then
    for path in $outside; do
      echo "FAIL  paths-inside-scope $path is outside every declared scope"
    done
    fail=1
  fi
fi
echo

# -------------------------------------------------------- body-carries-its-parts
#
# The required headings are the `## ` headings of the template. A heading is
# satisfied when at least one line under it is neither blank nor an HTML comment,
# which is what distinguishes a section from a heading somebody left standing.

headings=$(grep '^## ' "$template" | sed 's/^## //')

section_body() {
  # $1 heading text. Prints the lines under it with blank lines and HTML comment
  # blocks removed, so that a body which still carries the template's own
  # guidance comments counts as empty under that heading rather than as filled.
  # A line that opens a comment is dropped whole, including any text before the
  # opener, which errs towards asking for a clean line rather than towards
  # passing one.
  awk -v want="## $1" '
    $0 == want { inside = 1; next }
    /^## / { inside = 0 }
    !inside { next }
    incomment { if ($0 ~ /-->/) { incomment = 0 } ; next }
    /<!--/ { if ($0 !~ /-->/) { incomment = 1 } ; next }
    { line = $0; gsub(/^[ \t]+|[ \t]+$/, "", line); if (line != "") print line }
  ' "$body"
}

missing=0
IFS='
'
for heading in $headings; do
  if ! grep -Fxq "## $heading" "$body"; then
    echo "FAIL  body-carries-its-parts  the body has no heading: ## $heading"
    missing=1
    continue
  fi
  content=$(section_body "$heading")
  if [ -z "$content" ]; then
    echo "FAIL  body-carries-its-parts  nothing is written under: ## $heading"
    missing=1
  fi
done
unset IFS

# The statements leg. A change touching a source file has to say what the
# statements claim, and `none` alone is the one answer it may not give. A change
# touching no source file is not asked, because there is nothing to describe.
touches_source=$(grep -c '\.lean$' "$files" || true)
if [ "$touches_source" -gt 0 ]; then
  statements=$(section_body "The statements, in words" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:].')
  if [ "$statements" = "none" ]; then
    echo "FAIL  body-carries-its-parts  $touches_source source file(s) changed and the statements section says only: none"
    missing=1
  fi
fi

if [ "$missing" -eq 0 ]; then
  if [ "$touches_source" -gt 0 ]; then
    echo "ok    body-carries-its-parts  every heading the template asks for, and the statements section is not bare"
  else
    echo "ok    body-carries-its-parts  every heading the template asks for; no source file changed, so the statements section was not pressed"
  fi
else
  fail=1
fi
echo

# ------------------------------------------------------------------------- size
#
# Added plus deleted, over every file in the change. A binary file reports `-`
# in both columns and contributes nothing, which is stated rather than silent.

lines=$(awk '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ { total += $1 + $2 } END { print total + 0 }' "$numstat")
binary=$(awk '$1 == "-" { n += 1 } END { print n + 0 }' "$numstat")

if [ "$lines" -le "$cap" ]; then
  echo "ok    size               $lines line(s) against a cap of $cap"
else
  claim=$(grep -c '^Size exception: ' "$body" || true)
  if [ "$claim" -gt 0 ]; then
    echo "ok    size               $lines line(s) against a cap of $cap, with a declared exception"
    grep '^Size exception: ' "$body" | sed 's/^/                         /'
    echo "                         Whether the property named is real is a judgement this leg does not make."
  else
    echo "FAIL  size               $lines line(s) against a cap of $cap, and the body declares no exception"
    echo "                         An exception is a line at column zero beginning: Size exception: "
    fail=1
  fi
fi
if [ "$binary" -gt 0 ]; then
  echo "                         $binary binary file(s) counted for zero lines."
fi
echo

if [ "$fail" -ne 0 ]; then
  echo "check-pr-hygiene: refused. See the FAIL lines above."
  exit 1
fi
echo "check-pr-hygiene: every leg passed."
