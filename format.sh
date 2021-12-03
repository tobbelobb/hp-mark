#!/usr/bin/env bash

readonly SCRIPT_DIR="$(dirname "$0")"

CLANG_FORMAT_COMMAND="clang-format-10"
if ! clang_format_loc="$(type -p "${CLANG_FORMAT_COMMAND}")" || [[ -z $clang_format_loc ]]; then
	echo "Did not find clang-format-10. Trying clang-format-11 instead."
	CLANG_FORMAT_COMMAND="clang-format-11"
fi
CLANG_FORMAT_COMMAND+=" -i"

readonly PYTHON_FORMAT_COMMAND="black --line-length 120"
readonly BASH_FORMAT_COMMAND="shfmt -w"

find ${SCRIPT_DIR} -regex ".*\.\(h\+\+\|c\+\+\)" -not -path "${SCRIPT_DIR}/build/*" -not -path "${SCRIPT_DIR}/hpm/extern/*" -not -path "${SCRIPT_DIR}/hpm-gcc/*" -exec ${CLANG_FORMAT_COMMAND} {} +
find ${SCRIPT_DIR} -regex ".*\.sh" -not -path "${SCRIPT_DIR}/build/*" -not -path "${SCRIPT_DIR}/hpm/extern/*" -not -path "${SCRIPT_DIR}/hpm-gcc/*" -exec ${BASH_FORMAT_COMMAND} {} +
find ${SCRIPT_DIR} -regex ".*\.py" -not -path "${SCRIPT_DIR}/build/*" -not -path "${SCRIPT_DIR}/hpm/extern/*" -not -path "${SCRIPT_DIR}/hpm-gcc/*" -exec ${PYTHON_FORMAT_COMMAND} {} +
