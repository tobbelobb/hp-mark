#!/usr/bin/env bash

set -o errexit
set -o pipefail

readonly THISPATH="$(dirname "$0")"
readonly HPMPATH="${THISPATH}/../hpm"
readonly TMPDIR="${THISPATH}/tmp"

# Rebuild hpm binary
pushd "${HPMPATH}"
b
popd

# Run hpm
readonly COMMAND="${HPMPATH}/hpm/hpm ${THISPATH}/openscadHandCodedCamParamsSixtupled.xml ${THISPATH}/grid-check-marker-params.xml ${HPMPATH}/hpm/test-images/grid-red-2000.png --no-fit-by-distance"
readonly POSITIONS=$(${COMMAND} | tail -n +2)

# Build OpenScad source file, including the hpm results
mkdir -p "${TMPDIR}/"
readonly TMPFILE=$(mktemp -p "${TMPDIR}/" XXXXXXXXXX.scad)
cp "${HPMPATH}/hpm/test-images/geodesic_sphere.scad" "${TMPDIR}/"
cp "${HPMPATH}/hpm/test-images/sphere-grid.scad" "${TMPFILE}"
cat <<EOF >>"${TMPFILE}"
for (position = [${POSITIONS}])
  translate([position[0], -position[1], 2000-position[2]])
    geodesic_sphere(d=32);
EOF

echo "Produced ${TMPFILE}"
# Inspect results in OpenScad
openscad "${TMPFILE}"
