#!/usr/bin/env bash

find . -regex ".*\.\(h\+\+\|c\+\+\)" -not -path "./build/*" -not -path "./hpm/extern/*" -not -path "./hpm-gcc/*" -not -path "./hpm-clang/*" -exec clang-format-10 -i {} +

shfmt -w ./*.sh
