#!/usr/bin/env python3
import os, sys
import argparse

# demonstrates gathering of arguments for this script, from various sources:
# environment command line, environment variables, parameter files
# a computation would often be a C code, but this demonstration is in 
# Python for easy reading
# a script to run this code will need to set all the non-constant arguments
# in the various sources 

#******************************************************************************
# The payload computational function
#******************************************************************************
def ultimate_answer(argument_dict):
    print('*' * 80)
    print('Entering the workings of the ultimate answer function ...')
    print('The arguments supplied for this momentus calculation were:')
    print(argument_dict)
    print('I would engage in some pointless calculation based on those parameters')
    print('but I think you can guess the that the answer is 42')
    print('... leaving the ultimate answer function')
    return 42

#******************************************************************************
# Some functions to retrieve arguments from variuous places
#******************************************************************************
def arguments_from_environment(environment_variable_names):
    return {name: os.environ[name] for name in environment_variable_names if name in os.environ.keys()}

# these arguments come from after the name of this script in the command line
# and that command line can of course be in a script.
def arguments_from_command_line():
    parser = argparse.ArgumentParser(description='An amusingly short program to calculate the ultimate answer.', prog='allthearguments.py')
    parser.add_argument('--arg-file', nargs='?', required=True, help='path to file or arguments (required)')
    return vars(parser.parse_args())
# expect dict of filename:delimiter
# in reality parameter file formats are various
# will need a relevant parser for each, library or DIY 
def arguments_from_parameter_files(filenames):
    arguments = {}
    for filename in filenames.keys():
        with open(filename, 'r') as argument_file:
            lines = argument_file.readlines()
        # filenames[filename] is the delimiter string
        if filenames[filename] in [':', '=']:
            delimiter = filenames[filename]
        else:
            delimiter = ':'
        arguments_in_file = {}
        for line in lines:
            parts = line.split(delimiter)
            if len(parts) == 2:
                arguments[parts[0]] =parts[1]
    return arguments

# some constants
def arguments_from_authorities():
    arguments = {}
    # https://www.bipm.org/documents/20126/41483022/SI-Brochure-9-EN.pdf/2d2b50bf-f2b4-9661-f402-5f9d66e4b507?version=1.10&download=true
    # retrieved on 7 November 2021
    arguments['speed_of_light'] = 299792458  # m/s
    return arguments



#******************************************************************************
# Main script: obtain arguments and run the calculation based on those
#******************************************************************************
if __name__ == '__main__':
    # note that results are printed to stdout, so record that in a file if posterity is to be informed 

    # gather arguments
    # do this one before printing 'Entering ...' to allow exit if --help specified
    command_line_arguments = arguments_from_command_line()

    print('Entering ultimate answer calculation program...')
    print('Gathering arguments...')
    arguments = arguments_from_environment(['ALLTHEARGUMENTS_DELIMITER'])
    delimiter = arguments['ALLTHEARGUMENTS_DELIMITER'] if 'ALLTHEARGUMENTS_DELIMITER' in os.environ.keys() else None
    if delimiter is None: print('Environment variable ALLTHEARGUMENTS_DELIMITER not found, so code will use ':'., file=sys.stdout)
    arguments['decided_delimiter'] = delimiter
    arguments.update(command_line_arguments)
    arguments.update(arguments_from_authorities())
    # this arrgument is used to find more arguments
    argument_file_filename = arguments['arg_file']
    arguments.update(arguments_from_parameter_files({argument_file_filename:delimiter}))

    # run the computation using the arguments
    print('Arguments gathered, now calling the computation...')
    result = ultimate_answer(arguments)
    print('The calculation returned the value of {}'.format(result))
    print('Exiting ultimate answer calculation program - BYE!!')
