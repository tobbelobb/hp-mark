#!/usr/bin/env bash

CLANG_FORMAT_COMMAND="clang-format-10"
if ! clang_format_loc="$(type -p "$CLANG_FORMAT_COMMAND")" || [[ -z $clang_format_loc ]]; then
	echo "Did not find clang-format-10. Trying clang-format-11 instead."
	CLANG_FORMAT_COMMAND="clang-format-11"
fi

find . -regex ".*\.\(h\+\+\|c\+\+\)" -not -path "./build/*" -not -path "./hpm/extern/*" -not -path "./hpm-gcc/*" -not -path "./hpm-clang/*" -exec $CLANG_FORMAT_COMMAND -i {} +

shfmt -w ./*.sh
