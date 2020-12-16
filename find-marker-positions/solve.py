#!/usr/bin/env python3

"""For finding hp-marker positions.
   Use for example like
   $ ./solve.py --measurements 209.0 206.5 216.0 218.0 212.5 225.5 123.0 235.0 288.0 236.5 142.0 138.0 260.0 276.0 243.0 176.0 262.5 306.0 144.0 269.5 154.0

    measurements : The 21 distance measurements between pairs of markers.
                   Pairs are in the usual ccw order:
                   nozzle-red0, nozzle-red1, nozzle-green0, nozzle-green1, nozzle-blue0, nozzle-blue1
                   red0-red1, red0-green0, red0-green1, red0-blue0, red0-blue1,
                   red1-green0, red1-green1, red1-blue0, red1-blue1,
                   green0-green1, green0-blue0, green0-blue1,
                   green1-blue0, green1-blue1,
                   blue0-blue1.

"""
from __future__ import division  # Always want 3/2 = 1.5
import numpy as np
import scipy.optimize
import argparse
import timeit
import sys


def posvec2matrix(posvec):
    return np.array(
        [
            [0.0, 0.0, 0.0],  # Nozzle
            [posvec[0], posvec[1], posvec[2]],  # Red0
            [posvec[3], posvec[1], posvec[2]],  # Red1 same y coord as Red0
            [posvec[4], posvec[5], posvec[2]],  # Green0
            [posvec[6], posvec[7], posvec[2]],  # Green1
            [posvec[8], posvec[9], posvec[2]],  # Blue0
            [posvec[10], posvec[11], posvec[2]],
        ]
    )  # Blue1


def cost(positions, measurements):
    """The cost function.

    Parameters
    ----------
    positions : A 6x2 matrix of marker positions.
                Nozzle is first.
                Markers are in the usual ccw order:
                red0, red1, green0, green1, blue0, blue1
    measurements : The 21 distance measurements between pairs of markers.
                   Pairs are in the usual ccw order:
                   nozzle-red0, nozzle-red1, nozzle-green0, nozzle-green1, nozzle-blue0, nozzle-blue1
                   red0-red1, red0-green0, red0-green1, red0-blue0, red0-blue1,
                   red1-green0, red1-green1, red1-blue0, red1-blue1,
                   green0-green1, green0-blue0, green0-blue1,
                   green1-blue0, green1-blue1,
                   blue0-blue1.
    """
    return (
        +pow(np.linalg.norm(positions[0] - positions[1], 2) - measurements[0], 2)
        + pow(np.linalg.norm(positions[0] - positions[2], 2) - measurements[1], 2)
        + pow(np.linalg.norm(positions[0] - positions[3], 2) - measurements[2], 2)
        + pow(np.linalg.norm(positions[0] - positions[4], 2) - measurements[3], 2)
        + pow(np.linalg.norm(positions[0] - positions[5], 2) - measurements[4], 2)
        + pow(np.linalg.norm(positions[0] - positions[6], 2) - measurements[5], 2)
        + pow(np.linalg.norm(positions[1] - positions[2], 2) - measurements[6], 2)
        + pow(np.linalg.norm(positions[1] - positions[3], 2) - measurements[7], 2)
        + pow(np.linalg.norm(positions[1] - positions[4], 2) - measurements[8], 2)
        + pow(np.linalg.norm(positions[1] - positions[5], 2) - measurements[9], 2)
        + pow(np.linalg.norm(positions[1] - positions[6], 2) - measurements[10], 2)
        + pow(np.linalg.norm(positions[2] - positions[3], 2) - measurements[11], 2)
        + pow(np.linalg.norm(positions[2] - positions[4], 2) - measurements[12], 2)
        + pow(np.linalg.norm(positions[2] - positions[5], 2) - measurements[13], 2)
        + pow(np.linalg.norm(positions[2] - positions[6], 2) - measurements[14], 2)
        + pow(np.linalg.norm(positions[3] - positions[4], 2) - measurements[15], 2)
        + pow(np.linalg.norm(positions[3] - positions[5], 2) - measurements[16], 2)
        + pow(np.linalg.norm(positions[3] - positions[6], 2) - measurements[17], 2)
        + pow(np.linalg.norm(positions[4] - positions[5], 2) - measurements[18], 2)
        + pow(np.linalg.norm(positions[4] - positions[6], 2) - measurements[19], 2)
        + pow(np.linalg.norm(positions[5] - positions[6], 2) - measurements[20], 2)
    )


def solve(measurements, method):
    """Find reasonable marker positions based on a set of measurements."""
    print(method)

    # Nozzle has known position (0, 0, 0)
    # Red0 has unknown position (r0x, r0y, r0z)
    # Red1 has the same unknown y-position and z-position as Red0 (r1x, r0y, r0z)
    # Green and blue markers have unknown x-positions and y-positions, and same z-positions as Red0.
    num_params = 3 + 1 + 4 * 2

    bound = 400.0
    # lower_bound = [-bound]*num_params
    # upper_bound = [bound]*num_params
    lower_bound = [
        -bound,  # Red0 X
        -bound,  # Red0 and Red1 Y
        0.0,  # All Z
        0.0,  # Red1 X
        0.0,  # Green0 X
        -bound,  # Green0 Y
        0.0,  # Green1 X
        0.0,  # Green1 Y
        -bound,  # Blue0 X
        0.0,  # Blue0 Y
        -bound,  # Blue1 X
        -bound,  # Blue1 Y
    ]
    upper_bound = [
        0.0,  # Red0 X
        0.0,  # Red0 and Red1 Y
        bound,  # All Z,
        bound,  # Red1 X
        bound,  # Green0 X
        bound,  # Green0 Y
        bound,  # Green1 X
        bound,  # Green1 Y
        0.0,  # Blue0 X
        bound,  # Blue0 Y
        0.0,  # Blue1 X
        bound,  # Blue1 Y
    ]

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
            costx,
            guess_0,
            method="SLSQP",
            bounds=list(zip(lower_bound, upper_bound)),
            tol=1e-20,
            options={"disp": True, "ftol": 1e-40, "eps": 1e-10, "maxiter": 500},
        )
        print("Best cost: ", sol.fun)
        print("Best positions: \n%s" % posvec2matrix(sol.x))
    elif method == "L-BFGS-B":
        sol = scipy.optimize.minimize(
            costx,
            guess_0,
            method="L-BFGS-B",
            bounds=list(zip(lower_bound, upper_bound)),
            options={"disp": True, "ftol": 1e-12, "gtol": 1e-12, "maxiter": 50000, "maxfun": 1000000},
        )
        print("Best cost: ", sol.fun)
        print("Best positions: \n%s" % posvec2matrix(sol.x))
    elif method == "PowellDirectionalSolver":
        from mystic.solvers import PowellDirectionalSolver
        from mystic.termination import Or, CollapseAt, CollapseAs
        from mystic.termination import ChangeOverGeneration as COG
        from mystic.monitors import VerboseMonitor
        from mystic.termination import VTR, And, Or

        solver = PowellDirectionalSolver(num_params)
        solver.SetRandomInitialPoints(lower_bound, upper_bound)
        solver.SetEvaluationLimits(evaluations=3200000, generations=100000)
        solver.SetTermination(Or(VTR(1e-25), COG(1e-10, 20)))
        solver.SetStrictRanges(lower_bound, upper_bound)
        solver.SetGenerationMonitor(VerboseMonitor(5))
        solver.Solve(costx)
        print("Best cost: ", solver.bestEnergy)
        print("Best positions: \n%s" % posvec2matrix(solver.bestSolution))
    elif method == "differentialEvolutionSolver":
        from mystic.solvers import DifferentialEvolutionSolver2
        from mystic.monitors import VerboseMonitor
        from mystic.termination import VTR, ChangeOverGeneration, And, Or
        from mystic.strategy import Best1Exp, Best1Bin

        stop = Or(VTR(1e-18), ChangeOverGeneration(1e-9, 500))
        npop = 3
        stepmon = VerboseMonitor(100)
        solver = DifferentialEvolutionSolver2(num_params, npop)
        solver.SetEvaluationLimits(evaluations=3200000, generations=100000)
        solver.SetRandomInitialPoints(lower_bound, upper_bound)
        solver.SetStrictRanges(lower_bound, upper_bound)
        solver.SetGenerationMonitor(stepmon)
        solver.Solve(
            costx,
            termination=stop,
            strategy=Best1Bin,
        )
        print("Best cost: ", solver.bestEnergy)
        print("Best positions: \n%s" % posvec2matrix(solver.bestSolution))
    else:
        print("Method %s is not supported!" % method)
        sys.exit(1)


class Store_as_array(argparse._StoreAction):
    def __call__(self, parser, namespace, values, option_string=None):
        values = np.array(values)
        return super(Store_as_array, self).__call__(parser, namespace, values, option_string)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Figure out where hp-markers are compared to the nozzle by looking at the distances between marker to nozzle, and marker to marker."
    )
    parser.add_argument(
        "-m",
        "--method",
        help="Available methods are SLSQP (0, default), L-BFGS-B (1), PowellDirectionalSolver (2), and differentialEvolutionSolver (3). SLSQP and L-BFGS-B require scipy to be installed. The others require mystic to be installed.",
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
    if args["method"] == "0" or args["method"] == "default":
        args["method"] = "SLSQP"
    if args["method"] == "1":
        args["method"] = "L-BFGS-B"
    if args["method"] == "2":
        args["method"] = "PowellDirectionalSolver"
    if args["method"] == "3":
        args["method"] = "differentialEvolutionSolver"

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
            [
                209.0,
                206.5,
                216.0,
                218.0,
                212.5,
                225.5,
                123.0,
                235.0,
                288.0,
                236.5,
                142.0,
                138.0,
                260.0,
                276.0,
                243.0,
                176.0,
                262.5,
                306.0,
                144.0,
                269.5,
                154.0,
            ]
        )
    solve(measurements, args["method"])
