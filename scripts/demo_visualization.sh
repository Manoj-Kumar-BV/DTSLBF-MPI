#!/bin/bash
##############################################################################
# Interactive Demo with Live Visualization
# Runs tests and shows real-time visualizations
##############################################################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${BOLD}${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║     INTERACTIVE VISUALIZATION DEMO                                ║
║     Hybrid MPI + OpenMP + SIMD Task Scheduler                    ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

echo -e "${CYAN}This demo will:${NC}"
echo "  1. Run a test with execution tracing"
echo "  2. Visualize task distribution across workers"
echo "  3. Show performance comparison charts"
echo ""
read -p "Press Enter to start..."

# Ensure built
if [ ! -f "./distr-sched" ]; then
    echo -e "\n${YELLOW}Building executables...${NC}\n"
    make clean && make all
fi

mkdir -p logs/visualization

# Test parameters
TEST_NAME="lala"
PARAMS="5 2 2 0.00 tests/lala.in"
NUM_PROCS=4

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Step 1: Running test with execution trace${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Run with debug trace
echo -e "${CYAN}Running MPI-only with trace...${NC}"
DEBUG=1 mpirun -np ${NUM_PROCS} ./distr-sched-debug1 ${PARAMS} > logs/visualization/trace_mpi.log 2>&1
echo -e "${GREEN}✓ Complete${NC}"

echo ""
echo -e "${CYAN}Running MPI+OpenMP...${NC}"
OMP_NUM_THREADS=2 mpirun -np ${NUM_PROCS} ./distr-sched-openmp ${PARAMS} > logs/visualization/perf_openmp.log 2>&1
echo -e "${GREEN}✓ Complete${NC}"

echo ""
echo -e "${CYAN}Running MPI+OpenMP+SIMD...${NC}"
OMP_NUM_THREADS=2 mpirun -np ${NUM_PROCS} ./distr-sched-simd ${PARAMS} > logs/visualization/perf_simd.log 2>&1
echo -e "${GREEN}✓ Complete${NC}"

echo ""
read -p "Press Enter to see task distribution visualization..."

# Visualize task distribution
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Step 2: Task Distribution Visualization${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

python3 visualize_tasks.py logs/visualization/trace_mpi.log

echo ""
read -p "Press Enter to see performance comparison..."

# Create performance comparison
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Step 3: Performance Comparison${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Extract and display metrics
echo "Extracting performance metrics..."
echo ""

MPI_TIME=$(grep "FINAL RUNTIME:" logs/visualization/trace_mpi.log | awk '{print $3}' | sed 's/ms//')
OPENMP_TIME=$(grep "FINAL RUNTIME:" logs/visualization/perf_openmp.log | awk '{print $3}' | sed 's/ms//')
SIMD_TIME=$(grep "FINAL RUNTIME:" logs/visualization/perf_simd.log | awk '{print $3}' | sed 's/ms//')

echo -e "${BOLD}Runtime Comparison:${NC}"
echo "─────────────────────────────────────────────────────"
printf "%-30s %15s\n" "Variant" "Runtime"
echo "─────────────────────────────────────────────────────"
printf "%-30s %15s\n" "MPI-only" "${MPI_TIME}ms"
printf "%-30s %15s\n" "MPI + OpenMP" "${OPENMP_TIME}ms"
printf "%-30s %15s\n" "MPI + OpenMP + SIMD" "${SIMD_TIME}ms"
echo ""

if [ -n "$MPI_TIME" ] && [ -n "$OPENMP_TIME" ] && [ -n "$SIMD_TIME" ]; then
    OPENMP_SPEEDUP=$(echo "scale=2; $MPI_TIME / $OPENMP_TIME" | bc)
    SIMD_SPEEDUP=$(echo "scale=2; $MPI_TIME / $SIMD_TIME" | bc)
    
    echo -e "${BOLD}Speedup Analysis:${NC}"
    echo "─────────────────────────────────────────────────────"
    printf "%-30s %15s\n" "MPI + OpenMP" "${OPENMP_SPEEDUP}x"
    printf "%-30s %15s\n" "MPI + OpenMP + SIMD" "${SIMD_SPEEDUP}x"
    echo ""
    
    # ASCII bar chart
    echo -e "${BOLD}Visual Speedup Comparison:${NC}"
    echo "─────────────────────────────────────────────────────"
    
    OPENMP_BAR=$(printf '█%.0s' $(seq 1 $(echo "$OPENMP_SPEEDUP * 10" | bc | cut -d. -f1)))
    SIMD_BAR=$(printf '█%.0s' $(seq 1 $(echo "$SIMD_SPEEDUP * 10" | bc | cut -d. -f1)))
    
    printf "%-30s %s\n" "MPI + OpenMP" "$OPENMP_BAR ${OPENMP_SPEEDUP}x"
    printf "%-30s %s\n" "MPI + OpenMP + SIMD" "$SIMD_BAR ${SIMD_SPEEDUP}x"
    echo ""
fi

echo -e "${BOLD}${GREEN}✓ Visualization Demo Complete!${NC}"
echo ""
echo -e "${CYAN}Log files saved in: logs/visualization/${NC}"
echo ""
