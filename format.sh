#!/usr/bin/env bash

CLANG_FORMAT_COMMAND="clang-format-10"
if ! clang_format_loc="$(type -p "${CLANG_FORMAT_COMMAND}")" || [[ -z $clang_format_loc ]]; then
	echo "Did not find clang-format-10. Trying clang-format-11 instead."
	CLANG_FORMAT_COMMAND="clang-format-11"
fi
CLANG_FORMAT_COMMAND+=" -i"

readonly PYTHON_FORMAT_COMMAND="black --line-length 120"
readonly BASH_FORMAT_COMMAND="shfmt -w"

find . -regex ".*\.\(h\+\+\|c\+\+\)" -not -path "./build/*" -not -path "./hpm/extern/*" -not -path "./hpm-gcc/*" -exec ${CLANG_FORMAT_COMMAND} {} +
find . -regex ".*\.sh" -not -path "./build/*" -not -path "./hpm/extern/*" -not -path "./hpm-gcc/*" -exec ${BASH_FORMAT_COMMAND} {} +
find . -regex ".*\.py" -not -path "./build/*" -not -path "./hpm/extern/*" -not -path "./hpm-gcc/*" -exec ${PYTHON_FORMAT_COMMAND} {} +
