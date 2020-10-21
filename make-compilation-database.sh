#!/usr/bin/env bash

cd hpm
b -vn clean update |& compiledb
mv compile_commands.json ..
