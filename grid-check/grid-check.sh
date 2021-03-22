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
COMMAND="${HPMPATH}/hpm/hpm ${THISPATH}/openscadHandCodedCamParamsSixtupled.xml ${THISPATH}/grid-check-marker-params.xml ${THISPATH}/grid-red-2000.png --no-fit-by-distance"
SCADSRC="${THISPATH}/sphere-grid.scad"
SCADOBJ="geodesic_sphere(d=32)"
if [[ "$1" == "--disk" ]]; then
	COMMAND="${HPMPATH}/hpm/hpm ${THISPATH}/openscadHandCodedCamParamsSixtupled.xml ${THISPATH}/grid-check-disk-params.xml ${THISPATH}/disk-grid-2000.png --no-fit-by-distance"
	SCADSRC="${THISPATH}/disk-grid.scad"
	SCADOBJ="cylinder(d=70, h=0.01)"
else
	cp "${HPMPATH}/hpm/test-images/geodesic_sphere.scad" "${TMPDIR}/"
fi
readonly POSITIONS=$(${COMMAND} | tail -n +2)

# Build OpenScad source file, including the hpm results
mkdir -p "${TMPDIR}/"
readonly TMPFILE=$(mktemp -p "${TMPDIR}/" XXXXXXXXXX.scad)
cp "${SCADSRC}" "${TMPFILE}"
cat <<EOF >>"${TMPFILE}"
for (position = [${POSITIONS}])
  translate([position[0], -position[1], 2000-position[2]])
    ${SCADOBJ};
EOF

echo "Produced ${TMPFILE}"
# Inspect results in OpenScad
openscad "${TMPFILE}"
