# Running the Project Locally (Without SLURM)

## ✅ Fixed Issues
- **Buffer overflow in SHA256**: Fixed by increasing result buffer from 64 to 65 chars
- **Sign comparison warnings**: Fixed by using `size_t` for vector iterations
- All executables now compile and run cleanly on WSL/Ubuntu

## 🚀 Quick Start (For Presentations)

### Option 1: Interactive Demo (RECOMMENDED for presentations)
```bash
./demo_presentation.sh
```
This provides a beautiful, step-by-step demonstration of all three variants with automatic performance comparison.

### Option 2: Run Single Test
```bash
./run_local.sh lala 4
```
Runs all three variants on the "lala" test case with 4 MPI processes.

Available tests: `tinkywinky`, `dipsy`, `lala`, `po`, `thesun`

### Option 3: Full Benchmark Suite
```bash
./run_benchmark_local.sh
```
Runs all 5 tests × 3 variants = 15 benchmark runs and generates performance analysis.

## 📊 Manual Execution

### Basic Commands

```bash
# MPI-only (baseline)
mpirun -np 4 ./distr-sched 5 2 2 0.00 tests/lala.in

# MPI + OpenMP
OMP_NUM_THREADS=2 mpirun -np 4 ./distr-sched-openmp 5 2 2 0.00 tests/lala.in

# MPI + OpenMP + SIMD (full optimization)
OMP_NUM_THREADS=2 mpirun -np 4 ./distr-sched-simd 5 2 2 0.00 tests/lala.in
```

### Parameters Explained
- `-np 4`: Use 4 MPI processes (1 master + 3 workers)
- `OMP_NUM_THREADS=2`: Use 2 OpenMP threads per MPI process
- `5 2 2 0.00`: H=5, Nmin=2, Nmax=2, P=0.00
- `tests/lala.in`: Input test file

## 📝 Test Cases Available

| Test | H | Nmin | Nmax | P | Characteristics |
|------|---|------|------|-----|-----------------|
| tinkywinky | 16 | 1 | 2 | 0.10 | Deep task hierarchy |
| dipsy | 5 | 3 | 5 | 0.50 | High generation rate |
| lala | 5 | 2 | 2 | 0.00 | No task generation (best for demos) |
| po | 5 | 2 | 4 | 0.50 | Balanced workload |
| thesun | 12 | 0 | 10 | 0.16 | Many initial tasks |

## 🎯 For Jury Presentation

### Best Approach:
1. **Clean Terminal**: `clear`
2. **Run Demo**: `./demo_presentation.sh`
3. **Highlight Features**:
   - Three-level parallelism hierarchy
   - Progressive performance improvements
   - Master-worker architecture
   - Dynamic load balancing

### Key Talking Points:
- **MPI (Level 1)**: Distributed memory parallelism across nodes
- **OpenMP (Level 2)**: Shared memory parallelism within nodes
- **SIMD (Level 3)**: Instruction-level parallelism for vectorization

### Expected Speedup:
- MPI+OpenMP: 1.2-1.5x over MPI-only
- MPI+OpenMP+SIMD: 1.5-2.0x over MPI-only

## 🔧 Adjusting Performance

### More MPI Processes:
```bash
mpirun -np 8 ./distr-sched-simd 5 2 2 0.00 tests/lala.in
```

### More OpenMP Threads:
```bash
OMP_NUM_THREADS=4 mpirun -np 4 ./distr-sched-openmp 5 2 2 0.00 tests/lala.in
```

### Different Test Cases:
```bash
./run_local.sh thesun 6  # More complex workload
./run_local.sh dipsy 4   # High task generation
```

## 📈 Performance Analysis

After running benchmarks:
```bash
python3 analyze_performance.py
```

This generates detailed performance comparison tables and speedup calculations.

## 🐛 Troubleshooting

### If MPI is not installed:
```bash
sudo apt update
sudo apt install mpich libmpich-dev
```

### If build fails:
```bash
make clean
make all
```

### If executables don't exist:
The demo and test scripts automatically build if needed, but you can manually run:
```bash
make clean && make all
```

## 📁 Output Files

- `logs/local_*_output.txt` - Individual test outputs
- `logs/benchmark/local_*.log` - Benchmark results
- `/tmp/demo_*.txt` - Demo run outputs

## 🎓 Architecture Highlights

### Master Node (Rank 0):
- Maintains task queue
- Tracks worker availability
- Non-blocking communication (MPI_Isend, MPI_Irecv, MPI_Waitsome)

### Worker Nodes (Rank 1+):
- Execute tasks using compute kernels
- OpenMP threads for intra-node parallelism
- SIMD vectorization for compute-intensive operations

### Compute Kernels:
- **PRIME**: Prime number checking
- **MATMULT**: Matrix multiplication (SIMD-optimized)
- **LCS**: Longest common subsequence
- **SHA**: SHA-256 hashing
- **BITONIC**: Bitonic sort (SIMD-optimized)

## 🌟 Ready for Presentation!

The project is now fully functional on WSL/Ubuntu without SLURM. Use `./demo_presentation.sh` for the best presentation experience!
