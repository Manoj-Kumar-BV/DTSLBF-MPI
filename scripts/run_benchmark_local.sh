#!/bin/bash
##############################################################################
# Comprehensive Benchmark Script for Local Execution (No SLURM)
# Runs all test cases and generates performance comparison
##############################################################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Performance Benchmarking Suite (Local)"
echo -e "==========================================${NC}\n"

# Build
echo -e "${YELLOW}Building all variants...${NC}"
make clean
make all
echo ""

# Create directories
mkdir -p logs/benchmark

# Configuration
NUM_PROCS=4
OMP_THREADS=2

# Test cases
declare -A TESTS
TESTS[tinkywinky]="16 1 2 0.10 tests/tinkywinky.in"
TESTS[dipsy]="5 3 5 0.50 tests/dipsy.in"
TESTS[lala]="5 2 2 0.00 tests/lala.in"
TESTS[po]="5 2 4 0.50 tests/po.in"
TESTS[thesun]="12 0 10 0.16 tests/thesun.in"

echo -e "${BLUE}Running benchmarks with ${NUM_PROCS} MPI processes...${NC}"
echo ""

TOTAL_TESTS=$((${#TESTS[@]} * 3))
CURRENT=0

for test_name in "${!TESTS[@]}"; do
    params=${TESTS[$test_name]}
    
    # MPI-only
    CURRENT=$((CURRENT + 1))
    echo -e "${GREEN}[$CURRENT/$TOTAL_TESTS] Running: ${test_name} (MPI-only)${NC}"
    mpirun -np ${NUM_PROCS} ./distr-sched ${params} > logs/benchmark/local_mpi_${test_name}.log 2>&1
    
    # MPI+OpenMP
    CURRENT=$((CURRENT + 1))
    echo -e "${GREEN}[$CURRENT/$TOTAL_TESTS] Running: ${test_name} (MPI+OpenMP)${NC}"
    OMP_NUM_THREADS=${OMP_THREADS} mpirun -np ${NUM_PROCS} ./distr-sched-openmp ${params} > logs/benchmark/local_openmp_${test_name}.log 2>&1
    
    # MPI+OpenMP+SIMD
    CURRENT=$((CURRENT + 1))
    echo -e "${GREEN}[$CURRENT/$TOTAL_TESTS] Running: ${test_name} (MPI+OpenMP+SIMD)${NC}"
    OMP_NUM_THREADS=${OMP_THREADS} mpirun -np ${NUM_PROCS} ./distr-sched-simd ${params} > logs/benchmark/local_simd_${test_name}.log 2>&1
done

echo ""
echo -e "${GREEN}=========================================="
echo "All benchmarks completed!"
echo -e "==========================================${NC}"
echo ""
echo "Results saved in: logs/benchmark/"
echo ""
echo -e "${YELLOW}Generating performance analysis...${NC}"
echo ""

# Generate analysis
python3 analyze_performance.py

echo ""
echo -e "${GREEN}Done!${NC}"
