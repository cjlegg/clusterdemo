#!/bin/bash -l
# adapted from https://www.rc.ucl.ac.uk/docs/Example_Jobscripts/

# Request ten minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=0:10:0

# Request 1 gigabyte of RAM (must be an integer followed by M, G, or T)
#$ -l mem=3G

# Request 15 gigabyte of TMPDIR space (default is 10 GB - remove if cluster is diskless)
##$ -l tmpfs=15G  # commented out - see below

#$ -pe smp 1

# Set the name of the job.
#$ -N alltheargs

# Set the working directory to somewhere in your scratch space.  
#  This is a necessary step as compute nodes cannot write to $HOME.
# Replace "<your_UCL_id>" with your UCL user ID.
##$ -wd /home/<your_UCL_id>/Scratch/workspace
#$ -wd /home/ucapcjg/Scratch/workspace 

# Your work should be done in $TMPDIR 
# cd $TMPDIR  # commented out because on Kathleen there are no local disks, so there is no $TMPDIR

# Extra over https://www.rc.ucl.ac.uk/docs/Example_Jobscripts/ follows:
#$ -m be
#$ -M j.legg.17@ucl.ac.uk

# this file is expected to be called with [qsub] run-scripts/batch-allthearguments.sh [--args-file <path to arguments file>]



# retrieve some values and build a name for a results directory:
# name of this file
# see https://stackoverflow.com/questions/192319/how-do-i-know-the-script-file-name-in-a-bash-script
export RUN_SCRIPT=$(readlink --canonicalize --no-newline $0)

# directory name includes date for sorting by such in directory listings, and inlcudes name of this script for ID 
# --universal would give a UTC+0 time
# $(basename $RUN_SCRIPT) gave here the job number because grid engine scheduler renamed its working
# copy of this script with job number
export RUN_AT="$(date +%Y%m%d-%H%M%S)-alltheargs"

# this does not work at runtime for batch job
# beacuse the script has been copied by SGE
# to somewhere under /var/opt/sge/localhost
# export PROJECT_ROOT=$(dirname $(dirname $RUN_SCRIPT))
export PROJECT_ROOT=/home/ucapcjg/clusterdemo/
export RESULTS_DIR=$PROJECT_ROOT/results/run-at-$RUN_AT

# provenance subdir will where the current environment values and run argument 
# values will be stored.
mkdir -p $RESULTS_DIR/provenance

# set the runtime environment 
module purge   # for clarity
# not quite so clear beause the definiton of this module set could change
# also do not do this if modules it loads are undesirable for the project
module load default-modules/2018  
# add modules for the software needed by this project
module load python/3.9.6

#******************************************************************************
# set variables for arguments and executables
#******************************************************************************

# set, retrieve and/or calculate arguments for the application
export ARGUMENTS_FILE=$PROJECT_ROOT/arguments/allthearguments_set_A.args

# interpret arguments supplied to this script
# in this case the transformed argument will be passed through to the application program, 
# but another possibility would be to select the applicaiton program  
if [[ $1 == '--args-file' ]]; then
    export ARGUMENTS_FILE=$2  # in this case the argument will be passed through to the application program
fi

# set environment variables needed by the application
export ALLTHEARGUMENTS_DELIMITER='='  # this has been manually set here to be right for allthearguments_set_A.args


# select the executable file of the modapplication to be run
# here is a simple assignment
export PY_EXECUTABLE=$PROJECT_ROOT/src/allthearguments.py
export PY_EXECUTABLE_ARGUMENTS="--arg-file $ARGUMENTS_FILE" 



#******************************************************************************
# note some items of provenance
#******************************************************************************
# environment:
module list 2> $RESULTS_DIR/provenance/modules.log
env > $RESULTS_DIR/provenance/env.log
# SGE environment variables 
{ for item in ARC  SGE_ROOT  SGE_BINARY_PATH SGE_CELL  SGE_JOB_SPOOL_DIR SGE_O_HOME  SGE_O_HOST  \
              SGE_O_LOGNAME  SGE_O_MAIL  SGE_O_PATH  SGE_O_SHELL  SGE_O_TZ  SGE_O_WORKDIR  \
              SGE_CKPT_ENV  SGE_CKPT_DIR  SGE_STDERR_PATH  SGE_STDOUT_PATH  SGE_TASK_ID  \
              ENVIRONMENT  HOME  HOSTNAME  JOB_ID   JOB_NAME  LOGNAME  \
              NHOSTS  NQUEUES  NSLOTS  PATH  PE  PE_HOSTFILE  QUEUE \
              REQUEST  RESTARTED  TMPDIR  TMP  TZ  USER  OMP_NUM_THREADS
do
    echo $item=${!item}
done 
} > $RESULTS_DIR/provenance/scheduler_vars.log
if [[ ! -z "$PE_HOSTFILE" ]]; then
    cp $PE_HOSTFILE $RESULTS_DIR/provenance/hostfile
fi

# application software:
cd $PROJECT_ROOT
git show > $RESULTS_DIR/provenance/git_show.log
cd -

# if executable file is a compliled code then could do this to record dynamic libraries in use
# ldd <executable> > $RESULTS_DIR/provenance/ldd.log

# other software:

# save arguments of this script
cp $ARGUMENTS_FILE $RESULTS_DIR/provenance/
{ for item in RESULTS_DIR ARGUMENTS_FILE PY_EXECUTABLE PY_EXECUTABLE_ARGUMENTS
do
    echo $item=${!item}
done 
} > $RESULTS_DIR/provenance/arguments.log

# record hardware
cpuinfo > $RESULTS_DIR/provenance/cpuinfo.log
ibstat > $RESULTS_DIR/provenance/ibstat.log
ifconfig > $RESULTS_DIR/provenance/ifconfig.log

# and set those all to read only
chmod 0444 $RESULTS_DIR/provenance/*

#******************************************************************************
# finally launch the calculation
#******************************************************************************
echo "Now calling: $PY_EXECUTABLE $PY_EXECUTABLE_ARGUMENTS ..."
{
$PY_EXECUTABLE $PY_EXECUTABLE_ARGUMENTS
} > $RESULTS_DIR/$(basename $PY_EXECUTABLE).stdout.log 2> $RESULTS_DIR/$(basename $PY_EXECUTABLE).stderr.log

# run post processing - this example just uses the head node, so no mpirun


# move files to longer term storage
# need to supply a script to run after job is finished - these files no complete yet!
cat <<EOF > $RESULTS_DIR/gather_batch_job_stdout.sh
echo Check that all relevant files have been moved from /home/ucapcjg/Scratch/workspace/
mv /home/ucapcjg/Scratch/workspace/${JOB_NAME}.o${JOB_ID} $RESULTS_DIR/
mv /home/ucapcjg/Scratch/workspace/${JOB_NAME}.e${JOB_ID} $RESULTS_DIR/
mv /home/ucapcjg/Scratch/workspace/${JOB_NAME}.po${JOB_ID} $RESULTS_DIR/
mv /home/ucapcjg/Scratch/workspace/${JOB_NAME}.pe${JOB_ID} $RESULTS_DIR/
find $RESULTS_DIR -type f -exec chmod 0444 {} \;
chmod +x $RESULTS_DIR/gather_batch_job_stdout.sh
EOF
chmod +x $RESULTS_DIR/gather_batch_job_stdout.sh

# drop any handy scripts in among the results files - e.g. a python notebook


# tidy up unwanted files.

# preserve the results - mark read only
find $RESULTS_DIR -type f -exec chmod 0444 {} \;
chmod +x $RESULTS_DIR/gather_batch_job_stdout.sh

