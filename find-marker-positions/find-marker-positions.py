#!/usr/bin/env python3

"""For finding hp-marker positions.
   Use for example like
   $ ./find-marker-positions.py --measurements 211.0 212.0 225.2 239.0 240.0 242.5 120.0 232.0 306.0 287.0 139.0 133.7 286.5 308.0 248.2 216.6 277.7 327.0 97.0 303.5 243.9

    measurements : The 21 distance measurements between pairs of markers.
                   Pairs are in the usual ccw order:
                   nozzle-m0, nozzle-m1, nozzle-m2, nozzle-m3, nozzle-m4, nozzle-m5
                   m0-m1, m0-m2, m0-m3, m0-m4, m0-m5,
                   m1-m2, m1-m3, m1-m4, m1-m5,
                   m2-m3, m2-m4, m2-m5,
                   m3-m4, m3-m5,
                   m4-m5.

"""

from __future__ import division  # Always want 3/2 = 1.5
import numpy as np
import scipy.optimize
import argparse
import timeit
import sys


def posvec2matrix_nozzle(posvec, intermediate_solution):
    return np.append(
        np.array([[0.0, 0.0, 0.0]]), posvec2matrix_no_nozzle(intermediate_solution) - posvec, axis=0  # Nozzle
    )


def posvec2matrix_no_nozzle(posvec):
    return np.array(
        [
            [0.0, 0.0, 0.0],  # m0
            [posvec[0], 0.0, 0.0],
            [posvec[1], posvec[2], 0.0],
            [posvec[3], posvec[4], 0.0],
            [posvec[5], posvec[6], 0.0],
            [posvec[7], posvec[8], 0.0],
        ]
    )


def cost_nozzle(positions, measurements):
    """The cost function.

    Parameters
    ----------
    positions : A 7x2 matrix of marker positions.
                Nozzle is first.
                Markers are in the usual ccw order:
                m0, m1, m2, m3, m4, m5
    measurements : The 21 distance measurements between pairs of markers.
                   Pairs are in the usual ccw order:
                   nozzle-m0, nozzle-m1, nozzle-m2, nozzle-m3, nozzle-m4, nozzle-m5
                   m0-m1, m0-m2, m0-m3, m0-m4, m0-m5,
                   m1-m2, m1-m3, m1-m4, m1-m5,
                   m2-m3, m2-m4, m2-m5,
                   m3-m4, m3-m5,
                   m4-m5.
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


def cost_no_nozzle(positions, measurements):
    """The cost function.

    Parameters
    ----------
    positions : A 6x2 matrix of marker positions.
                Markers are in the usual ccw order.
    measurements : The 15 distance measurements between pairs of markers.
                   Pairs are in the usual ccw order:
                   m0-m1, m0-m2, m0-m3, m0-m4, m0-m5,
                   m1-m2, m1-m3, m1-m4, m1-m5,
                   m2-m3, m2-m4, m2-m5,
                   m3-m4, m3-m5,
                   m4-m5.
    """
    return (
        +pow(np.linalg.norm(positions[0] - positions[1], 2) - measurements[0], 2)
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

    marker_measurements = measurements
    if np.size(measurements) == 21:
        marker_measurements = measurements[(21 - 15) :]
    # m0 has known positions (0, 0, 0)
    # m1 has unknown x-position
    # All others have unknown xy-positions
    num_params = 0 + 1 + 2 + 2 + 2 + 2

    bound = 400.0
    lower_bound = [
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        -bound,
        0.0,
        -bound,
        0.0,
    ]
    upper_bound = [
        bound,
        bound,
        bound,
        bound,
        bound,
        bound,
        bound,
        bound,
        bound,
    ]

    def costx_no_nozzle(posvec):
        """Identical to cost_no_nozzle, except the shape of inputs"""
        positions = posvec2matrix_no_nozzle(posvec)
        return cost_no_nozzle(positions, marker_measurements)

    guess_0 = [0.0] * num_params

    intermediate_cost = 0.0
    intermediate_solution = []
    if method == "SLSQP":
        sol = scipy.optimize.minimize(
            costx_no_nozzle,
            guess_0,
            method="SLSQP",
            bounds=list(zip(lower_bound, upper_bound)),
            tol=1e-20,
            options={"disp": True, "ftol": 1e-40, "eps": 1e-10, "maxiter": 500},
        )
        intermediate_cost = sol.fun
        intermediate_solution = sol.x
    elif method == "L-BFGS-B":
        sol = scipy.optimize.minimize(
            costx_no_nozzle,
            guess_0,
            method="L-BFGS-B",
            bounds=list(zip(lower_bound, upper_bound)),
            options={"disp": True, "ftol": 1e-12, "gtol": 1e-12, "maxiter": 50000, "maxfun": 1000000},
        )
        intermediate_cost = sol.fun
        intermediate_solution = sol.x
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
        solver.Solve(costx_no_nozzle)
        intermediate_cost = solver.bestEnergy
        intermediate_solution = solver.bestSolution
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
            costx_no_nozzle,
            termination=stop,
            strategy=Best1Bin,
        )
        intermediate_cost = solver.bestEnergy
        intermediate_solution = solver.bestSolution
    else:
        print("Method %s is not supported!" % method)
        sys.exit(1)
    print("Best intermediate cost: ", intermediate_cost)
    print("Best intermediate positions: \n%s" % posvec2matrix_no_nozzle(intermediate_solution))
    if np.size(measurements) == 15:
        print("Got only 15 samples, so will not try to find nozzle position\n")
        return
    nozzle_measurements = measurements[: (21 - 15)]
    # Look for nozzle's xyz-offset relative to marker 0
    num_params = 3
    lower_bound = [
        0.0,
        0.0,
        -bound,
    ]
    upper_bound = [bound, bound, 0.0]

    def costx_nozzle(posvec):
        """Identical to cost_nozzle, except the shape of inputs"""
        positions = posvec2matrix_nozzle(posvec, intermediate_solution)
        return cost_nozzle(positions, measurements)

    guess_0 = [0.0, 0.0, 0.0]
    final_cost = 0.0
    final_solution = []
    if method == "SLSQP":
        sol = scipy.optimize.minimize(
            costx_nozzle,
            guess_0,
            method="SLSQP",
            bounds=list(zip(lower_bound, upper_bound)),
            tol=1e-20,
            options={"disp": True, "ftol": 1e-40, "eps": 1e-10, "maxiter": 500},
        )
        final_cost = sol.fun
        final_solution = sol.x
    elif method == "L-BFGS-B":
        sol = scipy.optimize.minimize(
            costx_nozzle,
            guess_0,
            method="L-BFGS-B",
            bounds=list(zip(lower_bound, upper_bound)),
            options={"disp": True, "ftol": 1e-12, "gtol": 1e-12, "maxiter": 50000, "maxfun": 1000000},
        )
        final_cost = sol.fun
        final_solution = sol.x
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
        solver.Solve(costx_nozzle)
        final_cost = solver.bestEnergy
        final_solution = solver.bestSolution
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
            costx_nozzle,
            termination=stop,
            strategy=Best1Bin,
        )
        final_cost = solver.bestEnergy
        final_solution = solver.bestSolution

    print("Best final cost: ", final_cost)
    print("Best final positions:")
    final = posvec2matrix_nozzle(final_solution, intermediate_solution)[1:]
    for num in range(0, 6):
        print(
            "{0: 8.3f} {1: 8.3f} {2: 8.3f} <!-- Marker {3} -->".format(final[num][0], final[num][1], final[num][2], num)
        )


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
        help="Specify the 6 measurements of distances between nozzle and marker centers, followed by the 15 measurements of distances between pairs of markers. The latter 15 measurements are the most important ones. Separate numbers by spaces.",
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
    if np.size(measurements) == 0:
        measurements = np.array(
            # You might want to manually input positions where you made samples here like
            [
                211.0,  # 210.0, # 212.0,
                212.0,  # 213.0, # 210.0,
                225.2,  # 223.0, # 226.0,
                239.0,  # 238.0, # 235.0,
                240.0,  # 239.0, # 241.0,
                242.5,  # 239.0, # 241.0,
                120.0,  # 120.5, # 120.5, # 121.0, # 120.0,
                232.0,  # 233.0, # 233.0,  #
                306.0,  # 306.0, # 306.0,  # 305.0, # 307.0,
                287.0,  # 288.1, # 288.1,  #
                139.0,  # 139.0, # 139.0,  # 139.0, # 140.0,
                133.7,  # 137.0, # 137.0,  # 135.0, # 137.0,
                286.5,  # 287.2, # 287.2,  #
                308.0,  # 310.0, # 310.0,  # 309.0, # 311.0,
                248.2,  # 247.5, # 247.5,  # 246.0, # 247.5,
                216.6,  # 208.5, # 208.5,  # 211.0, # 208.0,
                277.7,  # 271.1, # 271.1,  #
                327.0,  # 323.0, # 323.0,  # 322.0, # 324.0,
                97.0,  # 98.0, #  98.0,  # 99.0,  # 97.5,
                303.5,  # 302.0, # 302.0,  # 301.0, # 303.0,
                243.9,  # 241.75,# 241.75,  # 241.0, # 242.5,
            ]
        )
    if np.size(measurements) != 15 and np.size(measurements) != 21:
        print(
            "Error: You specified %d numbers after your -e/--measurements option, which is not 15 or 21 numbers. It must be 15 or 21 numbers."
        )
        sys.exit(1)
    solve(measurements, args["method"])
