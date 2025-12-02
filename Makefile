## Makefile for Hybrid MPI+OpenMP+SIMD Task Scheduler

# Directories
SRC_DIR := src

# Compiler and flags
CXX := mpic++
CXXFLAGS := -Wall -Wextra -Wpedantic -std=c++20 -O3 -DOMPI_SKIP_MPICXX -I$(SRC_DIR)
CXXFLAGS_OPENMP := $(CXXFLAGS) -fopenmp
CXXFLAGS_SIMD := $(CXXFLAGS_OPENMP) -DUSE_SIMD -march=native -ftree-vectorize
LDLIBS := -lm

# Output executables
OUTPUT := distr-sched
OUTPUT_OPENMP := distr-sched-openmp
OUTPUT_SIMD := distr-sched-simd
OUTPUT_DEBUG1 := distr-sched-debug1
OUTPUT_DEBUG2 := distr-sched-debug2
SEQUENTIAL := distr-sched-seq

# Object files
OBJS := $(SRC_DIR)/main.o $(SRC_DIR)/runner.o
OBJS_OPENMP := $(SRC_DIR)/main.openmp.o $(SRC_DIR)/runner.openmp.o
OBJS_SIMD := $(SRC_DIR)/main.simd.o $(SRC_DIR)/runner.simd.o
SEQ_OBJS := $(SRC_DIR)/main.o $(SRC_DIR)/runner_seq.o

all: $(OUTPUT) $(OUTPUT_OPENMP) $(OUTPUT_SIMD) $(OUTPUT_DEBUG1) $(OUTPUT_DEBUG2) $(SEQUENTIAL)

# Your main executable at DEBUG level 0 (MPI-only)
$(OUTPUT): $(OBJS) $(SRC_DIR)/tasks.0.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# MPI + OpenMP version
$(OUTPUT_OPENMP): $(OBJS_OPENMP) $(SRC_DIR)/tasks.0.openmp.o
	$(CXX) $(CXXFLAGS_OPENMP) $^ -o $@ $(LDLIBS)

# MPI + OpenMP + SIMD version
$(OUTPUT_SIMD): $(OBJS_SIMD) $(SRC_DIR)/tasks.0.simd.o
	$(CXX) $(CXXFLAGS_SIMD) $^ -o $@ $(LDLIBS)

# DEBUG level 1 version: execution "trace"
$(OUTPUT_DEBUG1): $(OBJS) $(SRC_DIR)/tasks.1.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# DEBUG level 2 version: execution "trace" plus more MPI information
$(OUTPUT_DEBUG2): $(OBJS) $(SRC_DIR)/tasks.2.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# Sequential version for checking trace outputs
$(SEQUENTIAL): $(SEQ_OBJS) $(SRC_DIR)/tasks.1.o
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDLIBS)

# Compile tasks with different DEBUG levels
$(SRC_DIR)/tasks.0.o: $(SRC_DIR)/tasks.cpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS) -DDEBUG=0 -c $< -o $@

$(SRC_DIR)/tasks.0.openmp.o: $(SRC_DIR)/tasks.cpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS_OPENMP) -DDEBUG=0 -c $< -o $@

$(SRC_DIR)/tasks.0.simd.o: $(SRC_DIR)/tasks.cpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS_SIMD) -DDEBUG=0 -c $< -o $@

$(SRC_DIR)/tasks.1.o: $(SRC_DIR)/tasks.cpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS) -DDEBUG=1 -c $< -o $@

$(SRC_DIR)/tasks.2.o: $(SRC_DIR)/tasks.cpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS) -DDEBUG=2 -c $< -o $@

# Compile main with different flags
$(SRC_DIR)/main.o: $(SRC_DIR)/main.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(SRC_DIR)/main.openmp.o: $(SRC_DIR)/main.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS_OPENMP) -c $< -o $@

$(SRC_DIR)/main.simd.o: $(SRC_DIR)/main.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS_SIMD) -c $< -o $@

# Compile runner with different flags
$(SRC_DIR)/runner.o: $(SRC_DIR)/runner.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(SRC_DIR)/runner.openmp.o: $(SRC_DIR)/runner.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS_OPENMP) -c $< -o $@

$(SRC_DIR)/runner.simd.o: $(SRC_DIR)/runner.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS_SIMD) -c $< -o $@

$(SRC_DIR)/runner_seq.o: $(SRC_DIR)/runner_seq.cpp $(SRC_DIR)/runner.hpp $(SRC_DIR)/tasks.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean all
clean:
	rm -f $(OUTPUT) $(OUTPUT_OPENMP) $(OUTPUT_SIMD) $(OUTPUT_DEBUG1) $(OUTPUT_DEBUG2) $(SEQUENTIAL)
	rm -f $(SRC_DIR)/*.o
