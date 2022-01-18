#!/usr/bin/env python3
import sys
import math
import argparse

def arguments_from_command_line():
    parser = argparse.ArgumentParser(description='An short program to calculate pi using the Lebnitz series.', prog='mpi_calc_pi.py')
    parser.add_argument('--number-terms', nargs='?', required=True, help='number of terms of the Leibnitz series to include (required)')
    return vars(parser.parse_args())

def pi_partial_sum(term_idx_start, term_idx_stop):
    partial_sum = 0
    for idx in range(term_idx_start, term_idx_stop):
        # idx starts at 0 
        partial_sum += 1 / (2 * idx + 1) * (1 if idx % 2 == 0  else -1)
    return 4.0 * partial_sum

if __name__ == '__main__':
    from mpi4py import MPI
    communicator = MPI.COMM_WORLD
    rank = communicator.Get_rank()
    ranks = communicator.Get_size()
    if rank == 0:
        print('This is rank 0. There are {} ranks in total.'.format(ranks), file=sys.stderr)

    # set up for approx the number of terms in the series specified (all ranks will calculate and equal number) 
    arguments = arguments_from_command_line()
    print('This is rank {}. Arguments for this run are: {}.'.format(rank, arguments), file=(sys.stdout if rank == 0 else sys.stderr))
    step = int(arguments['number_terms']) // ranks 
    start_idx = step * rank
    stop_idx = start_idx + step
    print('This is rank {}. Calculating for range [{}, {})'.format(rank, start_idx, stop_idx), file=sys.stderr)
    # calculate them
    rank_partial_sum = pi_partial_sum(start_idx, stop_idx)
    # reduce in rank 0, and report
    all_partial_sums = communicator.gather(rank_partial_sum, root=0)
    if rank == 0:
        pi_approx = sum(all_partial_sums)
        print('This is rank 0. Gathered partial sums are:', file=sys.stderr)
        print(all_partial_sums, file=sys.stderr)
        print('This is rank 0:') 
        print('Result: sum of {} terms of Leibnitz series for pi is {}.'.format(ranks * step, pi_approx))
        print('Python math module value is {}'. format(math.pi))
        print('Difference of result with Python math module value is {}.'.format(pi_approx - math.pi))
