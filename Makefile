## How to use this Makefile
## You should not have to modify anything except the OBJS variable
## 	by adding .o file names if you have more .cpp/.hpp files.

CXX := mpic++
CXXFLAGS := -Wall -Wextra -Wpedantic -std=c++20 -O3 -DOMPI_SKIP_MPICXX
CXXFLAGS_OPENMP := $(CXXFLAGS) -fopenmp
CXXFLAGS_SIMD := $(CXXFLAGS_OPENMP) -DUSE_SIMD -march=native -ftree-vectorize
LDLIBS := -lm

# Generate output files
# Main executable, 2 debug level versions of your code, and a reference sequential executable
OUTPUT := distr-sched
OUTPUT_OPENMP := distr-sched-openmp
OUTPUT_SIMD := distr-sched-simd
OUTPUT_DEBUG1 := distr-sched-debug1
OUTPUT_DEBUG2 := distr-sched-debug2
SEQUENTIAL := distr-sched-seq

# STUDENT TODO: Append to this list if you have more files to compile
# E.g., if you create the files `custom.cpp` and `custom.hpp`, add 'custom.o' to the list below. 
# You should also add them to the `main.o` dependancy list (after `tasks.hpp`)
OBJS := main.o runner.o
OBJS_OPENMP := main.openmp.o runner.openmp.o
OBJS_SIMD := main.simd.o runner.simd.o
SEQ_OBJS := main.o runner_seq.o

all: $(OUTPUT) $(OUTPUT_OPENMP) $(OUTPUT_SIMD) $(OUTPUT_DEBUG1) $(OUTPUT_DEBUG2) $(SEQUENTIAL)

# Your main executable at DEBUG level 0 (MPI-only)
$(OUTPUT): $(OBJS) tasks.0.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# MPI + OpenMP version
$(OUTPUT_OPENMP): $(OBJS_OPENMP) tasks.0.openmp.o
	$(CXX) $(CXXFLAGS_OPENMP) $^ -o $@ $(LDLIBS)

# MPI + OpenMP + SIMD version
$(OUTPUT_SIMD): $(OBJS_SIMD) tasks.0.simd.o
	$(CXX) $(CXXFLAGS_SIMD) $^ -o $@ $(LDLIBS)

# DEBUG level 1 version: execution "trace"
$(OUTPUT_DEBUG1): $(OBJS) tasks.1.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# DEBUG level 2 version: execution "trace" plus more MPI information
$(OUTPUT_DEBUG2): $(OBJS) tasks.2.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# Sequential version for checking trace outputs
$(SEQUENTIAL): $(SEQ_OBJS) tasks.1.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

tasks.0.o: tasks.cpp tasks.hpp 
	$(CXX) $(CXXFLAGS) -DDEBUG=0 -c $< -o $@

tasks.0.openmp.o: tasks.cpp tasks.hpp 
	$(CXX) $(CXXFLAGS_OPENMP) -DDEBUG=0 -c $< -o $@

tasks.0.simd.o: tasks.cpp tasks.hpp 
	$(CXX) $(CXXFLAGS_SIMD) -DDEBUG=0 -c $< -o $@

tasks.1.o: tasks.cpp tasks.hpp 
	$(CXX) $(CXXFLAGS) -DDEBUG=1 -c $< -o $@

tasks.2.o: tasks.cpp tasks.hpp 
	$(CXX) $(CXXFLAGS) -DDEBUG=2 -c $< -o $@

main.o: main.cpp runner.hpp tasks.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

main.openmp.o: main.cpp runner.hpp tasks.hpp
	$(CXX) $(CXXFLAGS_OPENMP) -c $< -o $@

main.simd.o: main.cpp runner.hpp tasks.hpp
	$(CXX) $(CXXFLAGS_SIMD) -c $< -o $@

runner.openmp.o: runner.cpp runner.hpp tasks.hpp
	$(CXX) $(CXXFLAGS_OPENMP) -c $< -o $@

runner.simd.o: runner.cpp runner.hpp tasks.hpp
	$(CXX) $(CXXFLAGS_SIMD) -c $< -o $@

%.o: %.cpp %.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(OUTPUT) $(OUTPUT_OPENMP) $(OUTPUT_SIMD) $(OUTPUT_DEBUG1) $(OUTPUT_DEBUG2) $(SEQUENTIAL) $(OBJS) $(OBJS_OPENMP) $(OBJS_SIMD) $(SEQ_OBJS) *.o
