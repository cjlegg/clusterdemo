#!/usr/bin/env python3

# tested with module pyton/3.9.6

import socket
import sys, os

if __name__ == '__main__':
    hostname = socket.gethostname()
    print('*' * 80)
    print('This is the hostname program (a python script), which has retrieved the following values:')
    print(f'{hostname = }')
    print('command line arguments passed to this python script:')
    for command_line_arg in sys.argv[1:]:
        print(f'{command_line_arg = }')
    shape = os.environ['SHAPE'] if 'SHAPE' in os.environ.keys() else None
    if shape is not None:
        print('Ooo you passed this shape info with the original job submission request: {}'.format(shape))
        print("So the arguments after this program's name in gerun were passed to each instance of this program.")
    else:
        print("I would have told you about shapes but you did not pass 'S' or 'C' to the original job submission request!", file=sys.stderr)
    a_pos = sys.argv.index('-A')
    if a_pos > 1:
        args_file = sys.argv[a_pos + 1]
        with open(args_file, 'r') as f:
            lines = f.readlines()
        print('Here are some arguments I picked up from the specified arguments file:')
        for line in lines: print('---> {}'.format(line))
    print('Leaving the hostname program, which has retrieved the following values:')
    print('*' * 80)
