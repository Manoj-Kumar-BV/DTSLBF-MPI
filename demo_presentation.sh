#!/bin/bash
##############################################################################
# PRESENTATION DEMO SCRIPT
# Quick demonstration of all three parallel variants
##############################################################################

set -e

# Colors
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
║     HYBRID PARALLEL TASK SCHEDULER DEMONSTRATION                  ║
║     MPI + OpenMP + SIMD                                          ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

echo -e "${CYAN}This demonstration will showcase three levels of parallelism:${NC}"
echo -e "  ${GREEN}1.${NC} MPI-only (Distributed Memory Parallelism)"
echo -e "  ${GREEN}2.${NC} MPI + OpenMP (Hybrid: Distributed + Shared Memory)"
echo -e "  ${GREEN}3.${NC} MPI + OpenMP + SIMD (Full Three-Level Parallelism)"
echo ""
echo -e "${YELLOW}Test Configuration:${NC}"
echo "  • Test Case: 'lala' (balanced workload)"
echo "  • MPI Processes: 4"
echo "  • OpenMP Threads per Process: 2"
echo "  • Parameters: H=5, Nmin=2, Nmax=2, P=0.00"
echo ""
read -p "Press Enter to start the demonstration..."

# Ensure built
if [ ! -f "./distr-sched" ]; then
    echo -e "\n${YELLOW}Building executables...${NC}\n"
    make clean
    make all
fi

mkdir -p logs

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Run 1: MPI-only
echo -e "${BOLD}${GREEN}▶ VARIANT 1: MPI-only (Baseline)${NC}"
echo -e "${CYAN}Command:${NC} mpirun -np 4 ./distr-sched 5 2 2 0.00 tests/lala.in"
echo ""
sleep 1
mpirun -np 4 ./distr-sched 5 2 2 0.00 tests/lala.in | tee /tmp/demo_mpi.txt
MPI_RUNTIME=$(grep "FINAL RUNTIME:" /tmp/demo_mpi.txt | awk '{print $3}' | sed 's/ms//')
echo ""
echo -e "${GREEN}✓ MPI-only Runtime: ${MPI_RUNTIME}ms${NC}"
echo ""
read -p "Press Enter to continue to the next variant..."
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Run 2: MPI+OpenMP
echo -e "${BOLD}${GREEN}▶ VARIANT 2: MPI + OpenMP${NC}"
echo -e "${CYAN}Command:${NC} OMP_NUM_THREADS=2 mpirun -np 4 ./distr-sched-openmp 5 2 2 0.00 tests/lala.in"
echo ""
sleep 1
OMP_NUM_THREADS=2 mpirun -np 4 ./distr-sched-openmp 5 2 2 0.00 tests/lala.in | tee /tmp/demo_openmp.txt
OPENMP_RUNTIME=$(grep "FINAL RUNTIME:" /tmp/demo_openmp.txt | awk '{print $3}' | sed 's/ms//')
echo ""
echo -e "${GREEN}✓ MPI+OpenMP Runtime: ${OPENMP_RUNTIME}ms${NC}"
if [ -n "$MPI_RUNTIME" ] && [ -n "$OPENMP_RUNTIME" ]; then
    SPEEDUP=$(echo "scale=2; $MPI_RUNTIME / $OPENMP_RUNTIME" | bc)
    echo -e "${YELLOW}  Speedup over MPI-only: ${SPEEDUP}x${NC}"
fi
echo ""
read -p "Press Enter to continue to the final variant..."
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Run 3: MPI+OpenMP+SIMD
echo -e "${BOLD}${GREEN}▶ VARIANT 3: MPI + OpenMP + SIMD${NC}"
echo -e "${CYAN}Command:${NC} OMP_NUM_THREADS=2 mpirun -np 4 ./distr-sched-simd 5 2 2 0.00 tests/lala.in"
echo ""
sleep 1
OMP_NUM_THREADS=2 mpirun -np 4 ./distr-sched-simd 5 2 2 0.00 tests/lala.in | tee /tmp/demo_simd.txt
SIMD_RUNTIME=$(grep "FINAL RUNTIME:" /tmp/demo_simd.txt | awk '{print $3}' | sed 's/ms//')
echo ""
echo -e "${GREEN}✓ MPI+OpenMP+SIMD Runtime: ${SIMD_RUNTIME}ms${NC}"
if [ -n "$MPI_RUNTIME" ] && [ -n "$SIMD_RUNTIME" ]; then
    SPEEDUP=$(echo "scale=2; $MPI_RUNTIME / $SIMD_RUNTIME" | bc)
    echo -e "${YELLOW}  Speedup over MPI-only: ${SPEEDUP}x${NC}"
fi
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Summary
echo -e "${BOLD}${BLUE}PERFORMANCE SUMMARY${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""
printf "${CYAN}%-25s${NC} ${GREEN}%15s${NC}\n" "Variant" "Runtime"
echo "───────────────────────────────────────────"
printf "%-25s %15s\n" "MPI-only (Baseline)" "${MPI_RUNTIME}ms"
printf "%-25s %15s" "MPI + OpenMP" "${OPENMP_RUNTIME}ms"
if [ -n "$MPI_RUNTIME" ] && [ -n "$OPENMP_RUNTIME" ]; then
    SPEEDUP=$(echo "scale=2; $MPI_RUNTIME / $OPENMP_RUNTIME" | bc)
    printf " ${YELLOW}(%.2fx speedup)${NC}" "$SPEEDUP"
fi
echo ""
printf "%-25s %15s" "MPI + OpenMP + SIMD" "${SIMD_RUNTIME}ms"
if [ -n "$MPI_RUNTIME" ] && [ -n "$SIMD_RUNTIME" ]; then
    SPEEDUP=$(echo "scale=2; $MPI_RUNTIME / $SIMD_RUNTIME" | bc)
    printf " ${YELLOW}(%.2fx speedup)${NC}" "$SPEEDUP"
fi
echo ""
echo ""
echo -e "${BOLD}${GREEN}✓ Demonstration Complete!${NC}"
echo ""
echo -e "${CYAN}Key Takeaways:${NC}"
echo "  • Three-level parallelism: MPI → OpenMP → SIMD"
echo "  • Master-worker architecture with dynamic load balancing"
echo "  • Progressive performance improvements at each level"
echo "  • Non-blocking MPI communication for efficiency"
echo ""
