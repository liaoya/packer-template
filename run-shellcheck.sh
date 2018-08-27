#!/bin/bash
#
# Run this script to make every shell file is valid

THIS_DIR=$(dirname $(readlink -f ${BASH_SOURCE}))
export SHELLCHECK_OPTS='--exclude=SC1090,SC2046,SC2086,SC2128'

[[ $(command -v shellcheck) ]] || { echo "Cannot find shellcheck"; exit 1; }

#find ${THIS_DIR} -iname "*.sh" -exec sh -c 'shellcheck $1 >/dev/null || echo $1' sh {} \;

SHELLCHECK_RESULT="true"
while IFS= read -r -d '' shellfile
do
    shellcheck "${shellfile}" || { echo ${shellfile}; SHELLCHECK_RESULT="false"; }
done < <(find ${THIS_DIR} -iname "*.sh" -print0)

[[ ${SHELLCHECK_RESULT} == true ]] || exit 1
