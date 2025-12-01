#!/bin/bash

## Performance comparison script for MPI-only vs MPI+OpenMP vs MPI+OpenMP+SIMD

set -e

echo "=========================================="
echo "Performance Benchmarking Suite"
echo "=========================================="
echo ""

# Make all versions
make clean
make all

# Create benchmark logs directory
mkdir -p logs/benchmark

# Test configurations
CONFIGS=("config1.sh" "config2.sh" "config3.sh")
CONFIG_NAMES=("Config1-Heterogeneous" "Config2-Homogeneous-XS" "Config3-Homogeneous-i7")

# Test cases
TEST_CASES=(
    "16 1 2 0.10 tests/tinkywinky.in"
    "5 3 5 0.50 tests/dipsy.in"
    "5 2 2 0.00 tests/lala.in"
    "5 2 4 0.50 tests/po.in"
    "12 0 10 0.16 tests/thesun.in"
)

TEST_NAMES=("tinkywinky" "dipsy" "lala" "po" "thesun")

echo "Starting benchmark runs..."
echo "This will submit 45 jobs (3 configs × 5 tests × 3 variants)"
echo ""

# Submit all jobs
for i in "${!CONFIGS[@]}"; do
    config="${CONFIGS[$i]}"
    config_name="${CONFIG_NAMES[$i]}"
    
    echo "Configuration: $config_name"
    
    for j in "${!TEST_CASES[@]}"; do
        test_case="${TEST_CASES[$j]}"
        test_name="${TEST_NAMES[$j]}"
        
        # MPI-only version
        echo "  Submitting: $test_name (MPI-only)"
        sbatch --job-name="bench_mpi_${config_name}_${test_name}" \
               --output="logs/benchmark/${config_name}_${test_name}_mpi_%j.log" \
               $config $test_case
        
        # MPI+OpenMP version
        echo "  Submitting: $test_name (MPI+OpenMP)"
        VARIANT="openmp" sbatch --job-name="bench_openmp_${config_name}_${test_name}" \
               --output="logs/benchmark/${config_name}_${test_name}_openmp_%j.log" \
               $config $test_case
        
        # MPI+OpenMP+SIMD version
        echo "  Submitting: $test_name (MPI+OpenMP+SIMD)"
        VARIANT="simd" sbatch --job-name="bench_simd_${config_name}_${test_name}" \
               --output="logs/benchmark/${config_name}_${test_name}_simd_%j.log" \
               $config $test_case
    done
    echo ""
done

echo "=========================================="
echo "All jobs submitted!"
echo "Monitor with: squeue -u \$USER"
echo "Results will be in: logs/benchmark/"
echo "=========================================="
