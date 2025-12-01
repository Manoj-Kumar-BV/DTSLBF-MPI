# Hybrid Parallel Task Scheduler: MPI + OpenMP + SIMD

A high-performance distributed task execution system demonstrating **three levels of parallelism**: distributed memory (MPI), shared memory (OpenMP), and instruction-level vectorization (SIMD).

## 🎯 Overview

This project implements a distributed task scheduler with three parallel variants:
1. **MPI-only** (`distr-sched`) - Baseline distributed memory implementation
2. **MPI+OpenMP** (`distr-sched-openmp`) - Hybrid distributed + shared memory parallelism
3. **MPI+OpenMP+SIMD** (`distr-sched-simd`) - Full three-level parallel optimization

### Course Concepts Demonstrated

| Unit | Concept | Implementation |
|------|---------|----------------|
| **Unit I** | ILP, Pipelining | SIMD vectorization with `#pragma omp simd` |
| **Unit II** | Thread-level parallelism | OpenMP threading in worker nodes |
| **Unit III** | Data-level parallelism | Vector operations on matrix and sort kernels |
| **Unit IV** | Message passing | MPI master-worker with non-blocking communication |

The system employs a master-worker architecture with dynamic load balancing across heterogeneous compute nodes.

## 🏗️ Architecture

### Master-Worker Pattern

```text
                  ┌─── Worker 1 ──► Execute Task
                  │
Master Queue ─────┼─── Worker 2 ──► Execute Task
                  │
                  └─── Worker N ──► Execute Task
```

### Key Components

1. **Master Node (Rank 0)**

   - Task queue management
   - Worker availability tracking
   - Non-blocking communication handling

2. **Worker Nodes**
   - Task execution
   - Result reporting
   - Dynamic task handling

## 💻 Technical Implementation

### Master Node Management

```cpp
// Master node data structures
queue<task_t> task_queue = get_initial_tasks(params);
vector<bool> availability(N_WORKERS, true);
vector<MPI_Request> proc_requests(N_WORKERS, MPI_REQUEST_NULL);
vector<task_t*> desc_tasks(num_procs - 1, nullptr);

// Non-blocking receive for descendant tasks
MPI_Irecv(desc_tasks[proc], Nmax, TASK_T_TYPE,
          worker_rank, 0, MPI_COMM_WORLD,
          &proc_requests[proc]);
```

### Key Implementations

**OpenMP Threading** (worker nodes):
```cpp
#ifdef _OPENMP
    omp_set_num_threads(2); // Balance MPI and OpenMP
#endif
```

**SIMD Vectorization** (compute kernels):
```cpp
#pragma omp simd
for (int j = 0; j < p; j++) {
    C[{i, j}] += a_ik * B[{k, j}];
}
```

**Non-blocking MPI Communication**:
```cpp
MPI_Waitsome(unavailable_requests.size(),
             unavailable_requests.data(),
             &outcount, indices.data(),
             MPI_STATUSES_IGNORE);
```

## 🚀 Quick Start

### Build All Variants
```bash
make clean
make all
```
This creates:
- `distr-sched` (MPI-only)
- `distr-sched-openmp` (MPI+OpenMP)
- `distr-sched-simd` (MPI+OpenMP+SIMD)

### Run Single Test
```bash
# MPI-only
sbatch config1.sh 16 1 2 0.10 tests/tinkywinky.in

# MPI+OpenMP
VARIANT=openmp sbatch config1.sh 16 1 2 0.10 tests/tinkywinky.in

# MPI+OpenMP+SIMD
VARIANT=simd sbatch config1.sh 16 1 2 0.10 tests/tinkywinky.in
```

### Run Full Benchmark Suite
```bash
chmod +x benchmark.sh analyze_performance.py
./benchmark.sh              # Submit 45 jobs (3 configs × 5 tests × 3 variants)
# Wait for completion...
./analyze_performance.py    # Generate performance comparison
```

## 📊 Expected Performance

| Variant | Speedup over MPI-only | Best For |
|---------|----------------------|----------|
| MPI+OpenMP | 1.2-1.5x | Multi-core nodes |
| MPI+OpenMP+SIMD | 1.5-2.0x | Compute-intensive tasks |

### Performance Factors
- **SIMD gains**: Most effective on matrix operations and sorting
- **OpenMP benefits**: Better utilization of multi-core nodes
- **Load balancing**: Dynamic task distribution handles heterogeneous workloads

## 🔧 Project Structure

```
DTSLBF-MPI/
├── main.cpp              # Entry point
├── runner.cpp            # MPI+OpenMP coordination logic
├── runner_seq.cpp        # Sequential reference implementation
├── tasks.cpp             # SIMD-optimized compute kernels
├── Makefile              # Multi-variant build system
├── job.sh                # SLURM job execution script
├── benchmark.sh          # Automated performance testing
├── analyze_performance.py # Results analysis tool
├── config*.sh            # Cluster configurations
└── tests/                # Input test cases
```

## 📝 Prerequisites

- MPI compiler (`mpic++`) with C++20 support
- OpenMP support (`-fopenmp`)
- CPU with SIMD extensions (AVX2 or better)
- SLURM workload manager (for cluster deployment)

## 📊 Test Configurations

```bash
# Configuration 1
sbatch config1.sh 16 1 2 0.10 tests/tinkywinky.in
sbatch config1.sh 5 3 5 0.50 tests/dipsy.in
sbatch config1.sh 5 2 2 0.00 tests/lala.in
sbatch config1.sh 5 2 4 0.50 tests/po.in
sbatch config1.sh 12 0 10 0.16 tests/thesun.in
```

## 📚 Test Cases

- `tinkywinky.in` - Large task depth (H=16)
- `dipsy.in` - High generation probability (P=0.50)
- `lala.in` - No task generation (P=0.00)
- `po.in` - Balanced workload
- `thesun.in` - Many initial tasks

## 🏆 Key Features

### Parallel Programming Concepts
- ✅ **Three-level parallelism hierarchy** (MPI → OpenMP → SIMD)
- ✅ **Distributed memory parallelism** - Master-worker pattern with MPI
- ✅ **Shared memory parallelism** - OpenMP threads within nodes
- ✅ **Instruction-level parallelism** - SIMD vectorization of compute kernels

### Implementation Highlights
- ✅ **Dynamic load balancing** across heterogeneous nodes
- ✅ **Non-blocking communication** (MPI_Isend, MPI_Irecv, MPI_Waitsome)
- ✅ **SIMD-optimized kernels** (matrix multiplication, bitonic sort)
- ✅ **Cache-friendly loop ordering** (ikj instead of ijk)
- ✅ **Automated benchmarking suite** with performance analysis
- ✅ **Comprehensive documentation** and testing framework

### Academic Value
- Demonstrates concepts from Units I-IV of parallel programming
- Quantitative performance comparison across paradigms
- Real-world hybrid parallelism implementation
- Suitable for mini project demonstration

## 📄 License

This project was developed as part of a distributed systems and parallel programming coursework.
