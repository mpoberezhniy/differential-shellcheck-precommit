#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

INPUT_SEVERITY="style"

for arg
do
  case "$arg" in
    -S=*|--severity=*)
        INPUT_SEVERITY="${arg#*=}"
        ;;
    -S|--severity)
        # shellcheck disable=SC2034
        INPUT_SEVERITY="$2"
        # shellcheck disable=SC2016
        shift 2 || { echo 'option `--severity` requires an argument SEVERITY' >&2; exit 1; }
        ;;
    *)
      echo "Unknown option: %s" "$arg" >&2
      exit 1
      ;;
  esac
done

export SCRIPT_DIR="/action/"
. "${SCRIPT_DIR-}functions.sh"

WORK_DIR="$(mktemp -d)/"
export WORK_DIR

# pre-commit mounts repos at /src
# source: https://pre-commit.com/#docker
git config --global --add safe.directory "/src"

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

execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}head-shellcheck.err"

git stash >/dev/null

execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}base-shellcheck.err"

git stash apply --index >/dev/null

get_fixes "${WORK_DIR}base-shellcheck.err" "${WORK_DIR}head-shellcheck.err"
evaluate_and_print_fixes

get_defects "${WORK_DIR}head-shellcheck.err" "${WORK_DIR}base-shellcheck.err"

echo

evaluate_and_print_defects
exit_status=$?

summary

exit ${exit_status}