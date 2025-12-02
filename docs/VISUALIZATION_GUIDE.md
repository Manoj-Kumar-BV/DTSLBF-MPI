# 📊 Visualization Guide

## New Visualization Tools Created

### 1. **Interactive Demo with Visualization** ⭐ BEST FOR PRESENTATIONS
```bash
./demo_visualization.sh
```

**What it does:**
- Runs tests with execution tracing
- Animates task distribution across workers
- Shows performance comparison charts
- Perfect for live demonstrations!

**Output:**
- Real-time animation of workers receiving tasks
- ASCII bar charts comparing runtimes
- Speedup calculations
- Beautiful colored terminal output

---

### 2. **Task Distribution Visualizer**
```bash
# First run with debug trace
DEBUG=1 mpirun -np 4 ./distr-sched-debug1 5 2 2 0.00 tests/lala.in > trace.log

# Then visualize
python3 visualize_tasks.py trace.log
```

**Shows:**
- Master distributing tasks to workers
- Which worker executed which tasks
- Task execution sequence (animated!)
- Final distribution summary

**Example Output:**
```
┌─────────────────────────────────────────────────┐
│           MASTER (Rank 0)                       │
│         Task Queue Manager                      │
└─────────────────────────────────────────────────┘
               │
               │ Distributes Tasks
               │
       ┌───────┼───────┐
       │       │       │
       ▼       ▼       ▼

┌────────────────────────────────────────────────┐
│  WORKER 1  🟢 BUSY                            │
│  Current: g0.3#42                             │
│  [████████████████████] 21 tasks              │
└────────────────────────────────────────────────┘
```

---

### 3. **Performance Comparison Charts**
```bash
# After running benchmarks
./run_benchmark_local.sh

# Visualize results
python3 visualize_performance.py
```

**Shows:**
- Runtime comparison (bar charts)
- Speedup analysis
- CPU utilization comparison
- All tests in one view

**Example Output:**
```
======================================================================
                    Runtime (lower is better)
======================================================================

MPI-only                  ████████████████████████████████ 27972ms
MPI + OpenMP              ████████████████████ 17549ms
MPI + OpenMP + SIMD       ███████████████ 13892ms

======================================================================
                    SPEEDUP ANALYSIS (vs MPI-only)
======================================================================

MPI + OpenMP              ████████████████ 1.59x
MPI + OpenMP + SIMD       ████████████████████ 2.01x
```

---

## 🎬 For Your Presentation

### **Option A: Full Interactive Demo (RECOMMENDED)**
```bash
./demo_visualization.sh
```
- Takes ~2-3 minutes
- Shows everything automatically
- Most impressive for jury
- No manual steps needed

### **Option B: Manual Walkthrough**
```bash
# 1. Show task distribution
DEBUG=1 mpirun -np 4 ./distr-sched-debug1 5 2 2 0.00 tests/lala.in > trace.log
python3 visualize_tasks.py trace.log

# 2. Run benchmarks
./run_benchmark_local.sh

# 3. Show performance comparison
python3 visualize_performance.py
```

---

## 📊 What Each Visualization Shows

### **Task Distribution (visualize_tasks.py)**
- **Purpose**: Show how master balances load across workers
- **Key Insight**: Fast workers get more tasks automatically
- **Demo Point**: "Notice how Worker 2 completes more tasks because it's faster"

### **Performance Charts (visualize_performance.py)**
- **Purpose**: Quantify speedup from each optimization level
- **Key Insight**: Each level adds performance gain
- **Demo Point**: "OpenMP gives 1.5x, SIMD adds another 0.5x for 2x total"

### **Interactive Demo (demo_visualization.sh)**
- **Purpose**: Complete end-to-end demonstration
- **Key Insight**: All optimizations working together
- **Demo Point**: "Watch how the system efficiently uses all resources"

---

## 🎯 Visualization Features

### ✅ ASCII Art Animations
- No GUI needed - runs in terminal
- Works over SSH/remote connections
- Professional looking output
- Easy to record for documentation

### ✅ Real-Time Updates
- Shows progress as it happens
- Animated task distribution
- Live worker status updates

### ✅ Color Coding
- 🟢 Green = Busy worker
- ⚪ White = Idle worker
- Different colors for metrics

### ✅ Summary Statistics
- Task counts per worker
- Task types distribution
- Speedup calculations
- Utilization percentages

---

## 💡 Tips for Presentation

1. **Start with Interactive Demo**
   ```bash
   ./demo_visualization.sh
   ```
   Let it run automatically while you explain concepts

2. **Explain While It Runs**
   - "Master is distributing tasks..."
   - "Notice Worker 1 finished first..."
   - "SIMD gives us the best performance..."

3. **Show the Code** (optional)
   Open `runner.cpp` to show master-worker logic
   Open `tasks.cpp` to show `#pragma omp simd`

4. **End with Performance Summary**
   The final chart shows clear speedup numbers

---

## 🔧 Customization

### Change Number of Processes
Edit the scripts and change:
```bash
NUM_PROCS=4  # Change to 6, 8, etc.
```

### Change Test Case
```bash
TEST_NAME="thesun"  # Or tinkywinky, dipsy, po
PARAMS="12 0 10 0.16 tests/thesun.in"
```

### Change Animation Speed
In `visualize_tasks.py`, line with:
```python
time.sleep(0.3)  # Increase for slower, decrease for faster
```

---

## 📸 Creating Screenshots/Recordings

### For Documentation:
```bash
# Record terminal session
script -c "./demo_visualization.sh" demo_output.txt

# Or use asciinema for web-friendly recordings
asciinema rec demo.cast
./demo_visualization.sh
# Press Ctrl+D to stop
```

### For Screenshots:
Just run the demo and take screenshots at key moments:
1. Task distribution animation
2. Performance comparison charts
3. Final speedup summary

---

## 🎓 What to Say During Demo

### Opening:
"Let me demonstrate our three-level parallel system in action. This visualization will show how tasks are distributed and the performance gains we achieve."

### During Task Distribution:
"The master process coordinates all work. Notice how it dynamically assigns tasks to available workers. Faster workers automatically get more tasks."

### During Performance Comparison:
"Here you can see the progressive improvements. MPI alone gives us parallelism across processes. Adding OpenMP utilizes multiple cores within each process. SIMD vectorization provides the final boost."

### Closing:
"As you can see, we achieved a 2x speedup by combining all three levels of parallelism, efficiently utilizing all available hardware resources."

---

## ✅ Quick Reference

| Tool | Command | Use Case |
|------|---------|----------|
| **Interactive Demo** | `./demo_visualization.sh` | Best for presentations |
| **Task Distribution** | `python3 visualize_tasks.py trace.log` | Show load balancing |
| **Performance Charts** | `python3 visualize_performance.py` | Show speedup numbers |
| **Full Benchmark** | `./run_benchmark_local.sh` | Generate all data |

---

## 🎉 You're Ready!

The visualization tools make your project much more impressive and easier to explain. Just run `./demo_visualization.sh` and let it guide you through the demonstration!
