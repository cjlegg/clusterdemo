#!/bin/bash

# this file is just a placeholder for a script that compiles the application program to be run in the job script
# you will not need this of the application is already available in a module 
# the example of this repo has a python application, which of course does not need compiling.


# load dependencies, usually with module commands, which are of two types:

# (1) load build tools and their dependencies, which will include the compiler (e.g. gcc), the build tools (e.g. autotool, or cmake), 
# and their dependencies, e.g. runtime libraries for the compiler, or scripting interpresters for the build tools, e.g. pyhton, perl, m4
# on many systems loading the main items will be arranged to load their dependencies as well

# (2) load the dependencies of application, e.g. math and matrix libraries, messaging libraries (e.g. mpi)
# so that the compiler can link to them.


# set the parameters for the build, e.g. a path for where the compiler will put the build, e.g. for this repo $PROJECT_ROOT/build-code 


# a script to execute the steps of the compile e.g. configure and make for autotools - see the instructions that come with the application 


# some more script to run tests of the compiled code.


# preferably the build script should be run on a compute node where it is intended to run it. 
# building it on the login node may: 
# (i) especially on busy systems be a violation of the login node use poilicy, especially if the compile is lengthy
# (ii) if the login node has a different processor generation it will optimise the code incorrectly for the compute node
#      which then may not run on the compute node or run, but run more slowly 

# a build script may well be specific to the local system

