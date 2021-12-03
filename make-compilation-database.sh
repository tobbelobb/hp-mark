#!/usr/bin/env bash

readonly SCRIPT_DIR="$(dirname "$0")"

cd ${SCRIPT_DIR}/hpm
b -vn clean update |& compiledb
mv compile_commands.json ..
cd -
