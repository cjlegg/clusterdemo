#!python3

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
    shape = os.environ['SHAPE'] if name in os.environ.keys() else None
    if shape is not None:
        print('Ooo you passed this shape info with the original job submission request: {}'.format(shape))
        print("So the arguments after this program's name in gerun were passed to each instance of this program.")
    else:
        print("I would have told you about shapes but you did not pass 'S' or 'C' to the original job submission request!", file=sys.stderr)
    print('Leaving the hostname program, which has retrieved the following values:')
    print('*' * 80)
