#!/bin/bash
# install.sh: copies the chapter 5 setup into your project (ch05:383-387, "copy the
# template and customize"). never overwrites a file, writes nothing outside the folder
# you name (a hooks folder elsewhere gets a printed line instead), no network.
#
#   ./install.sh ~/path/to/your-project
#
# What lands where:
#   chapters/05-claude-md-power-system/CLAUDE.md.template  -> CLAUDE.md
#   chapters/05-claude-md-power-system/skills/*.md         -> .claude/commands/
#   chapters/05-claude-md-power-system/hooks/*.sh          -> .claude/hooks/
#   chapters/05-claude-md-power-system/hooks/pre-commit    -> .git/hooks/pre-commit
# Only secret-scanner.sh is switched on. The other three hooks need a Node project:
# switch one on with chmod +x, the way chapter 5 does (ch05:165).

set -u
SRC="$(cd "$(dirname "$0")" && pwd)/chapters/05-claude-md-power-system"

if [ $# -ne 1 ]; then
  echo "usage: ./install.sh <your-project-folder>"
  echo "example: ./install.sh ~/my-first-claude-project"
  exit 2
fi
if [ ! -d "$1" ]; then
  echo "no such folder: $1"
  echo "make one first (ch03:74):"
  echo "  mkdir ~/my-first-claude-project && cd ~/my-first-claude-project"
  exit 2
fi
PROJECT="$(cd "$1" && pwd)"

COPIED=0
KEPT=0
# put SRC DEST: copy only when DEST does not exist yet
put() {
  if [ -e "$2" ]; then
    echo "  kept:   ${2#"$PROJECT"/} (already there, not changed)"
    KEPT=$((KEPT + 1))
    return 1
  fi
  mkdir -p "$(dirname "$2")"
  cp "$1" "$2"
  echo "  copied: ${2#"$PROJECT"/}"
  COPIED=$((COPIED + 1))
}

echo "Installing the chapter 5 setup into $PROJECT"
put "$SRC/CLAUDE.md.template" "$PROJECT/CLAUDE.md"
for f in "$SRC"/skills/*.md; do
  put "$f" "$PROJECT/.claude/commands/$(basename "$f")"
done
for f in "$SRC"/hooks/*.sh; do
  dest="$PROJECT/.claude/hooks/$(basename "$f")"
  if put "$f" "$dest"; then
    case "$(basename "$f")" in
      secret-scanner.sh) chmod +x "$dest" ;;
      *) chmod -x "$dest" ;;
    esac
  fi
done
put "$SRC/hooks/allowed-large-deps.txt" "$PROJECT/.claude/hooks/allowed-large-deps.txt"

if [ -e "$PROJECT/.git" ]; then
  HOOKS="$(git -C "$PROJECT" rev-parse --git-path hooks)"
  case "$HOOKS" in /*) ;; *) HOOKS="$PROJECT/$HOOKS" ;; esac
  # core.hooksPath, a worktree or a submodule can put the hooks folder outside the
  # project. don't write there: print the line to add instead
  if [ -d "$HOOKS" ]; then HOOKS="$(cd "$HOOKS" && pwd)"; fi
  case "$HOOKS/" in
    "$PROJECT"/*) INSIDE=1 ;;
    *) INSIDE=0 ;;
  esac
  if [ "$INSIDE" -eq 0 ]; then
    echo "  skipped: pre-commit hook. git keeps this project's hooks in $HOOKS, outside $PROJECT."
    echo "  To run the .claude/hooks scripts, add this line to the pre-commit hook there:"
    # shellcheck disable=SC2016  # printed for the reader to paste, not run here
    echo '  for h in .claude/hooks/*.sh; do [ -x "$h" ] || continue; "$h" || exit $?; done'
  elif put "$SRC/hooks/pre-commit" "$HOOKS/pre-commit"; then
    chmod +x "$HOOKS/pre-commit"
  else
    echo "  Your pre-commit hook is yours. To run the .claude/hooks scripts too, add this line to it:"
    # shellcheck disable=SC2016  # printed for the reader to paste, not run here
    echo '  for h in .claude/hooks/*.sh; do [ -x "$h" ] || continue; "$h" || exit $?; done'
  fi
else
  echo "  no git repo: run git init in $PROJECT, then run install.sh again to add the pre-commit hook"
fi

echo
echo "$COPIED copied, $KEPT kept."
ON=""; OFF=""
for h in "$PROJECT"/.claude/hooks/*.sh; do
  if [ -x "$h" ]; then ON="$ON $(basename "$h")"; else OFF="$OFF $(basename "$h")"; fi
done
echo "Runs on every commit:${ON:- none}"
echo "Off until you chmod +x .claude/hooks/<name>.sh:${OFF:- none}"
echo "Next: cd $PROJECT && claude"
echo "Then fill in every [bracket] in CLAUDE.md (ch05:399)."
