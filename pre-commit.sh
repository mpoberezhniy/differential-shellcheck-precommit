#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

INPUT_SEVERITY="style"

for opt
do
  case "$opt" in
    -S=*|--severity=*)
        INPUT_SEVERITY="${opt#*=}"
        shift
        ;;
    -S|--severity)
        # shellcheck disable=SC2034
        INPUT_SEVERITY="$2"
        # shellcheck disable=SC2016
        shift 2 || { echo 'option `--severity` requires an argument SEVERITY' >&2; exit 1; }
        ;;
    -x|--external-sources)
        # shellcheck disable=SC2034
        INPUT_EXTERNAL_SOURCES=y
        shift
        ;;
  esac
done

export SHELLCHECK_OPTS=("$@")

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")/"
exort SCRIPT_DIR
. "${SCRIPT_DIR-}functions.sh"

WORK_DIR="$(mktemp -d)/"
export WORK_DIR

# get changed files
git diff --name-only -z --diff-filter=db --cached > "${WORK_DIR}changed-files.txt"

only_changed_scripts=()
get_scripts_for_scanning "${WORK_DIR}changed-files.txt" "only_changed_scripts"

echo -e "${VERSIONS_HEADING}"
show_versions

echo -e "${MAIN_HEADING}"

echo -e "::group::📜 ${WHITE}List of shell scripts for scanning${NOCOLOR}"
  echo "${only_changed_scripts[@]}"
echo "::endgroup::"
echo

# ------------ #
#  SHELLCHECK  #
# ------------ #

exit_status=0

execute_shellcheck "${SHELLCHECK_OPTS[@]}" "${only_changed_scripts[@]}" > "${WORK_DIR}head-shellcheck.err"

git stash >/dev/null

execute_shellcheck "${SHELLCHECK_OPTS[@]}" "${only_changed_scripts[@]}" > "${WORK_DIR}base-shellcheck.err"

git stash apply --index >/dev/null

get_fixes "${WORK_DIR}base-shellcheck.err" "${WORK_DIR}head-shellcheck.err"
evaluate_and_print_fixes

get_defects "${WORK_DIR}head-shellcheck.err" "${WORK_DIR}base-shellcheck.err"

echo

evaluate_and_print_defects
exit_status=$?

summary

exit ${exit_status}
