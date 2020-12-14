#!/usr/bin/env python3

"""For finding hp-marker positions.
   Use for example like
   $ ./solve.py --measurements 12.3 23.5 28.8 23.65 14.2 13.8 26.0 27.6 24.3 17.6 26.25 30.6 14.4 26.95 15.4
"""
from __future__ import division  # Always want 3/2 = 1.5
import numpy as np
import scipy.optimize
import argparse
import timeit
import sys

def posvec2matrix(posvec):
    return np.array([[0.0, 0.0],
                     [posvec[0], 0.0],
                     [posvec[1], posvec[2]],
                     [posvec[3], posvec[4]],
                     [posvec[5], posvec[6]],
                     [posvec[7], posvec[8]]])

def cost(positions, measurements):
    """The cost function.

    Parameters
    ----------
    positions : A 6x2 matrix of marker positions.
                Markers are in the usual ccw order:
                red0, red1, green0, green1, blue0, blue1
    measurements : The 15 distance measurements between pairs of markers.
                   Pairs are in the usual ccw order:
                   red0-red1, red0-green0, red0-green1, red0-blue0, red0-blue1,
                   red1-green0, red1-green1, red1-blue0, red1-blue1,
                   green0-green1, green0-blue0, green0-blue1,
                   green1-blue0, green1-blue1,
                   blue0-blue1.
    """
    return (
        pow(np.linalg.norm(positions[0] - positions[1],2) - measurements[0], 2)
        + pow(np.linalg.norm(positions[0] - positions[2], 2) - measurements[1], 2)
        + pow(np.linalg.norm(positions[0] - positions[3], 2) - measurements[2], 2)
        + pow(np.linalg.norm(positions[0] - positions[4], 2) - measurements[3], 2)
        + pow(np.linalg.norm(positions[0] - positions[5], 2) - measurements[4], 2)
        + pow(np.linalg.norm(positions[1] - positions[2], 2) - measurements[5], 2)
        + pow(np.linalg.norm(positions[1] - positions[3], 2) - measurements[6], 2)
        + pow(np.linalg.norm(positions[1] - positions[4], 2) - measurements[7], 2)
        + pow(np.linalg.norm(positions[1] - positions[5], 2) - measurements[8], 2)
        + pow(np.linalg.norm(positions[2] - positions[3], 2) - measurements[9], 2)
        + pow(np.linalg.norm(positions[2] - positions[4], 2) - measurements[10], 2)
        + pow(np.linalg.norm(positions[2] - positions[5], 2) - measurements[11], 2)
        + pow(np.linalg.norm(positions[3] - positions[4], 2) - measurements[12], 2)
        + pow(np.linalg.norm(positions[3] - positions[5], 2) - measurements[13], 2)
        + pow(np.linalg.norm(positions[4] - positions[5], 2) - measurements[14], 2)
    )


def solve(measurements, method):
    """Find reasonable marker positions based on a set of measurements."""
    print(method)

    # Red0 has known position (0, 0)
    # Red1 has unknown x-position
    # Green and blue markers have unknown x- and y-positions.
    num_params = 4 * 2 + 1

    lower_bound = [-400.0] * num_params
    upper_bound = [400.0] * num_params

    def costx(posvec):
        """Identical to cost, except the shape of inputs and capture of samp, xyz_of_samp, ux, and u

        Parameters
        ----------
        posvec : [r1x, g0x, g0y, g1x, g1y, b0x, b0y, b1x, b1y]
        """
        positions = posvec2matrix(posvec)
        return cost(positions, measurements)

    guess_0 = [0.0] * num_params

    if method == "SLSQP":
        sol = scipy.optimize.minimize(
            lambda x: costx(x),
            guess_0,
            method="SLSQP",
            bounds=list(zip(lower_bound, upper_bound)),
            tol=1e-20,
            options={"disp": True, "ftol": 1e-40, "eps" : 1e-10, "maxiter": 500},
        )
        print("Best cost: ", sol.fun)
        print("Best positions: \n%s" % posvec2matrix(sol.x))
    elif method == "L-BFGS-B":
        print("L-BFGS-B is not implemented yet")
    else:
        print("Method %s is not supported!" % method)
        sys.exit(1)


class Store_as_array(argparse._StoreAction):
    def __call__(self, parser, namespace, values, option_string=None):
        values = np.array(values)
        return super(Store_as_array, self).__call__(
            parser, namespace, values, option_string
        )

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Figure out where hp-markers are by looking at the distances between them."
    )
    parser.add_argument(
        "-m",
        "--method",
        help="Available methods are SLSQP (0) ,L-BFGS-B (1).",
        default="SLSQP",
    )
    parser.add_argument(
        "-e",
        "--measurements",
        help="Specify the 15 measurements of distances between pairs of markers. Separate numbers by spaces.",
        action=Store_as_array,
        type=float,
        nargs="+",
        default=np.array([]),
    )
    args = vars(parser.parse_args())
    if args["method"] == "0":
        args["method"] = "SLSQP"
    if args["method"] == "1":
        args["method"] = "L-BFGS-B"

    measurements = args["measurements"]
    if np.size(measurements) != 0:
        if np.size(measurements) != 15:
            print(
                "Error: You specified %d numbers after your -e/--measurements option, which is not 15 numbers. It must be 15 numbers."
            )
            sys.exit(1)
    else:
        measurements = np.array(
            # You might want to manually input positions where you made samples here like
            [12.3, 23.5, 28.8, 23.65, 14.2, 13.8, 26.0, 27.6, 24.3, 17.6, 26.25, 30.6, 14.4, 26.95, 15.4]
        )
    solve(measurements, args["method"])
