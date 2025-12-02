#!/bin/bash
## Common code executed by the Slurm file for each configuration

# Change to project root
cd "$(dirname "$0")/.."

# Stop the script if any part fails
set -e

# Uncomment these two lines if we ask you for debugging information
# echo "DEBUG: All Slurm environment variables for this job"
# printenv | grep SLURM

# Debug info for where the job is running
# We use srun to run this on all nodes allocated to us
srun bash -c 'echo "Job is running on $(hostname), started at $(date)"'

# Set debug level to 0 if we didn't pass any environment variables 
DEBUG=${DEBUG:-0}
# Set the "use sequential" condition to 0 if we didn't pass any env vars
SEQ=${SEQ:-0}
# Set the variant (mpi, openmp, simd)
VARIANT=${VARIANT:-mpi}

# Compile the code at the appropriate debug level
echo "Running make to compile your code..."
make

# Choose the right executable to run
if [ "$SEQ" -eq 1 ]; then
    # Use the sequential executable
    EXECUTABLE="distr-sched-seq"
else
    # Choose the right executable based on the DEBUG level and VARIANT
    if [ "$DEBUG" -eq 0 ]; then
        case "$VARIANT" in
            mpi)
                EXECUTABLE="distr-sched"
                echo "Running MPI-only version"
                ;;
            openmp)
                EXECUTABLE="distr-sched-openmp"
                echo "Running MPI+OpenMP version"
                ;;
            simd)
                EXECUTABLE="distr-sched-simd"
                echo "Running MPI+OpenMP+SIMD version"
                ;;
            *)
                echo "Invalid VARIANT: $VARIANT (must be mpi, openmp, or simd)"
                exit 1
                ;;
        esac
    else
        # Debug versions always use MPI-only
        case "$DEBUG" in
            1)
                EXECUTABLE="distr-sched-debug1"
                ;;
            2)
                EXECUTABLE="distr-sched-debug2"
                ;;
            *)
                echo "Invalid value for DEBUG: $DEBUG"
                exit 1
                ;;
        esac
    fi
fi

# Creating temp job file
TMP_JOB_FILE="/tmp/$SLURM_JOB_ID.txt"
touch $TMP_JOB_FILE
chmod 700 $TMP_JOB_FILE
echo "Created temporary file on $(hostname) for job output evaluation after this run at $TMP_JOB_FILE"

# Run your executable and pass all arguments to it
echo "Running..."
set -x
perf stat -- mpirun --map-by core --bind-to core ./$EXECUTABLE $@ | tee $TMP_JOB_FILE
set +x

# Evaluate the results, default is to evaluate
EVALUATE=${EVALUATE:-1}
if [ "$EVALUATE" -eq 1 ]; then
    echo "Evaluating your results...";
    python3 src/check.py $@ < $TMP_JOB_FILE;
fi

# Remove the tmp file if it exists
rm -f $TMP_JOB_FILE