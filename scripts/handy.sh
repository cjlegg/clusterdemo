#!/bin/bash
echo 'This script is not intended to be run - it is a repository of handy commands for this project / system.'
exit 1

#******************************************************************************

# UCL clusters use the SGE scheduler
# comparison with other schedulers: 
# https://oit.ua.edu/wp-content/uploads/2020/12/scheduler_commands_cheatsheet-2020-ally.pdf

# job submission
qsub <script.sh>
qsub -N <newname> <script.sh>

# particular jobs

# status
qstat -f -j <job_id>
qstat -f -u ucapcjg

qhost
qhost -q

lquota

# job deletion
qdel <job-id>

# interactictive session
qrsh -pe mpi 80 -l mem=512M,h_rt=0:30:00 -now yes


# gerun
cat $(which gerun)

# pi calculation 
qsub ~/clusterdemo/run-scripts-myriad-cluster/batch-pi-calc-gerun-simple.sh 10000000000



