#!python3

# tested with module pyton/3.9.6

import socket
import sys

if __name__ == '__main__':
    hostname = socket.gethostname()
    print('*' * 80)
    print('This is the hostname program, which has retrieved the following values:')
    print(f'{hostname = }')
    print('command line arguments passed to this python script:')
    for command_line_arg in sys.argv[1:]:
        print(f'{command_line_arg = }')
    print('*' * 80)
