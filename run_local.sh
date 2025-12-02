#!/bin/bash
##############################################################################
# Local Testing Script (No SLURM Required)
# Usage: ./run_local.sh [test_name] [num_processes]
# Example: ./run_local.sh lala 4
##############################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
NUM_PROCS=${2:-4}
OMP_THREADS=2

# Test configurations
declare -A TEST_PARAMS
TEST_PARAMS[tinkywinky]="16 1 2 0.10 tests/tinkywinky.in"
TEST_PARAMS[dipsy]="5 3 5 0.50 tests/dipsy.in"
TEST_PARAMS[lala]="5 2 2 0.00 tests/lala.in"
TEST_PARAMS[po]="5 2 4 0.50 tests/po.in"
TEST_PARAMS[thesun]="12 0 10 0.16 tests/thesun.in"

echo -e "${BLUE}=========================================="
echo "Hybrid MPI+OpenMP+SIMD Task Scheduler"
echo -e "==========================================${NC}\n"

# Build if needed
if [ ! -f "./distr-sched" ]; then
    echo -e "${YELLOW}Building executables...${NC}"
    make clean
    make all
    echo ""
fi

# Create logs directory
mkdir -p logs

# Function to run a test variant
run_variant() {
    local variant=$1
    local executable=$2
    local params=$3
    local label=$4
    
    echo -e "${GREEN}▶ Running: ${label}${NC}"
    echo "  Command: mpirun -np ${NUM_PROCS} ./${executable} ${params}"
    echo ""
    
    if [ "$variant" == "mpi" ]; then
        mpirun -np ${NUM_PROCS} ./${executable} ${params} | tee logs/local_${variant}_output.txt
    else
        OMP_NUM_THREADS=${OMP_THREADS} mpirun -np ${NUM_PROCS} ./${executable} ${params} | tee logs/local_${variant}_output.txt
    fi
    
    echo ""
    echo -e "${GREEN}✓ Completed${NC}"
    echo "-------------------------------------------"
    echo ""
}

# Main execution
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <test_name> [num_processes]${NC}"
    echo ""
    echo "Available tests:"
    for test in "${!TEST_PARAMS[@]}"; do
        echo "  - $test"
    done
    echo ""
    echo "Example: $0 lala 4"
    exit 1
fi

TEST_NAME=$1
PARAMS=${TEST_PARAMS[$TEST_NAME]}

if [ -z "$PARAMS" ]; then
    echo -e "${RED}Error: Unknown test '${TEST_NAME}'${NC}"
    echo "Available tests: ${!TEST_PARAMS[@]}"
    exit 1
fi

echo -e "${BLUE}Test:${NC} ${TEST_NAME}"
echo -e "${BLUE}Parameters:${NC} ${PARAMS}"
echo -e "${BLUE}MPI Processes:${NC} ${NUM_PROCS}"
echo -e "${BLUE}OpenMP Threads:${NC} ${OMP_THREADS}"
echo ""
echo "=========================================="
echo ""

# Run all three variants
run_variant "mpi" "distr-sched" "${PARAMS}" "MPI-only (Baseline)"
run_variant "openmp" "distr-sched-openmp" "${PARAMS}" "MPI + OpenMP"
run_variant "simd" "distr-sched-simd" "${PARAMS}" "MPI + OpenMP + SIMD"

echo -e "${GREEN}=========================================="
echo "All variants completed successfully!"
echo -e "==========================================${NC}"
echo ""
echo "Output logs saved in: logs/local_*_output.txt"
