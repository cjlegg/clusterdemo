#!/bin/bash -l
# adapted from https://www.rc.ucl.ac.uk/docs/Example_Jobscripts/

# Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=0:10:0

# Request 1 gigabyte of RAM (must be an integer followed by M, G, or T)
#$ -l mem=1G

# Request 15 gigabyte of TMPDIR space (default is 10 GB - remove if cluster is diskless)
##$ -l tmpfs=15G  # commented out - see below

# Set the name of the job.
#$ -N calc-pi

# Set the working directory to somewhere in your scratch space.  
#  This is a necessary step as compute nodes cannot write to $HOME.
# Replace "<your_UCL_id>" with your UCL user ID.
##$ -wd /home/<your_UCL_id>/Scratch/workspace
#$ -wd /home/ucapcjg/Scratch/workspace 

# Your work should be done in $TMPDIR 
# cd $TMPDIR  # commented out because on Kathleen there are no local disks, so there is no $TMPDIR

# Extra over https://www.rc.ucl.ac.uk/docs/Example_Jobscripts/ follows:

#$ -pe mpi 36

#$ -m be
#$ -M j.legg.17@ucl.ac.uk


# this file is expected to be called with [qsub] batch-hostname-gerun.sh <number of terms of series> on Myriad 


# retrieve some values and build a name for a results directory:
# name of this file
# see https://stackoverflow.com/questions/192319/how-do-i-know-the-script-file-name-in-a-bash-script
export RUN_SCRIPT=$(readlink --canonicalize --no-newline $0)

# directory name includes date for sorting by such in directory listings, and inlcudes name of this script for ID 
# --universal would give a UTC+0 time
# $(basename $RUN_SCRIPT) gave here the job number because grid engine scheduler renamed its working
# copy of this script with job number
export RUN_AT="$(date +%Y%m%d-%H%M%S)-calc-pi"

# this does not work at runtime for batch job
# beacuse the script has been copied by SGE
# to somewhere under /var/opt/sge/localhost
# export PROJECT_ROOT=$(dirname $(dirname $RUN_SCRIPT))
export PROJECT_ROOT=/home/ucapcjg/clusterdemo
export RESULTS_DIR=$PROJECT_ROOT/results/run-at-$RUN_AT

# provenance subdir will where the current environment values and run argument 
# values will be stored.
mkdir -p $RESULTS_DIR

module purge   # for clarity
# add modules for the software needed by this project
module load gerun
module load gcc-libs/4.9.2
module load compilers/gnu/4.9.2
module load mpi/openmpi/3.1.4/gnu-4.9.2
module load python3/3.7
module load mpi4py/3.0.2/gnu-4.9.2

#******************************************************************************
# set variables for arguments and executables
#******************************************************************************

# set, retrieve and/or calculate arguments forthe application

# interpret arguments supplied to this script
# in this case the transformed argument will be passed through to the application program, 
# but another possibility would be to select the applicaiton program  
export NUMBER_OF_TERMS=$1


# select the executable file of the application to be run
# here is a simple assignment
export PY_EXECUTABLE=$PROJECT_ROOT/src/mpi_calc_pi.py
export PY_EXECUTABLE_ARGUMENTS="--number-terms $NUMBER_OF_TERMS"

# set any arguments for mpi - e.g. for mapping hosts/cores to mpi ranks/slots, communications tweaking 
# here the gerun script takes care of all that for you.
# format of such parameters will depend on implementation of mpi, e.g. OpenMPI, Intel, etc.
MPI_ARGS=


#******************************************************************************
# finally launch in all mpi processes with gerun, the local wrapper for mpi
#******************************************************************************
echo "Now calling: gerun $MPI_ARGS $PY_EXECUTABLE $PY_EXECUTABLE_ARGUMENTS ..."
echo "Begin at: " $(date)
{
gerun $MPI_ARGS $PY_EXECUTABLE $PY_EXECUTABLE_ARGUMENTS
} > $RESULTS_DIR/$(basename $PY_EXECUTABLE).stdout.log 2> $RESULTS_DIR/$(basename $PY_EXECUTABLE).stderr.log
echo "End at  : " $(date)



