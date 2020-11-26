#!/usr/bin/env bash

set -o errexit
set -o pipefail

readonly BINPATH="$(dirname "$0")"
readonly HPMPATH="${BINPATH}/../hpm"
readonly TMPDIR="${BINPATH}/tmp"

# Rebuild hpm binary
pushd "${HPMPATH}"
b
popd

# Run hpm
readonly POSITIONS=$("${HPMPATH}/hpm/hpm" "${HPMPATH}/hpm/example-cam-params/openscadHandCodedCamParamsSixtupled.xml" 32 "${HPMPATH}/hpm/test-images/grid-red-2000.png")

# Build OpenScad source file, including the hpm results
mkdir -p "${TMPDIR}/"
readonly TMPFILE=$(mktemp -p "${TMPDIR}/" XXXXXXXXXX.scad)
cp "${HPMPATH}/hpm/test-images/geodesic_sphere.scad" "${TMPDIR}/"
cp "${HPMPATH}/hpm/test-images/sphere-grid.scad" "${TMPFILE}"
cat << EOF >> "${TMPFILE}"
for (position = [${POSITIONS}])
  translate([position[0], -position[1], 2000-position[2]])
    geodesic_sphere(d=32);
EOF

# Inspect results in OpenScad
openscad "${TMPFILE}"
