#!/usr/bin/env bash

# Find only test files (absolute paths)
TESTS="hpm/hpm/.*test\.c.*"

# Find all .c++ files except test files (absolute paths)
APPLICATION_CODE="hpm/hpm/([a-z]|-|_|[A-Z]|[0-9])+\.c"

# If there's an argument, use it and assume it is application code
if [ $1 ]; then
	# Convert a relative path to an absolute path
	APPLICATION_CODE=$(find hpm/ -name "*$1*")
	# Cut away trailing ++ because run-clang-tidy will interpret them as a regex
	APPLICATION_CODE=${APPLICATION_CODE%++}
	echo $APPLICATION_CODE
fi

CHECKS="-*,cppcoreguidelines-*,modernize-*,bugprone-*,clang-analyzer-*,misc-*,performance-*,readability-*"

./make-compilation-database.sh

echo "Tidy application code"
CLANG_TIDY_COMMAND="run-clang-tidy-10"
if ! clang_tidy_loc="$(type -p "$CLANG_TIDY_COMMAND")" || [[ -z $clang_tidy_loc ]]; then
	echo "Did not find run-clang-tidy-10. Trying run-clang-tidy-11 instead."
	CLANG_TIDY_COMMAND="run-clang-tidy-11"
fi
$CLANG_TIDY_COMMAND -p=. -checks=$CHECKS -quiet $APPLICATION_CODE 2>/dev/null

if [ -z "$1" ]; then
	# Allow magic numbers in test code
	CHECKS="$CHECKS,-readability-magic-numbers,-cppcoreguidelines-avoid-magic-numbers"
	echo ""
	echo "Tidy test code"
	$CLANG_TIDY_COMMAND -p=. -checks=$CHECKS -quiet $TESTS 2>/dev/null
fi
