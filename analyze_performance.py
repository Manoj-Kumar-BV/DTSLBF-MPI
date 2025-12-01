#!/usr/bin/env python3
"""
Performance Analysis Tool for Hybrid MPI+OpenMP+SIMD Comparison
Parses benchmark logs and generates performance reports
"""

import os
import re
import sys
from collections import defaultdict
from pathlib import Path

def extract_runtime(log_file):
    """Extract FINAL RUNTIME from a log file"""
    try:
        with open(log_file, 'r') as f:
            for line in f:
                if 'FINAL RUNTIME:' in line:
                    match = re.search(r'FINAL RUNTIME:\s*(\d+)ms', line)
                    if match:
                        return int(match.group(1))
    except Exception as e:
        print(f"Error reading {log_file}: {e}")
    return None

def extract_utilization(log_file):
    """Extract CPU utilization from Overall: line"""
    try:
        with open(log_file, 'r') as f:
            for line in f:
                if line.startswith('Overall:'):
                    match = re.search(r'\((\d+\.\d+)\)', line)
                    if match:
                        return float(match.group(1))
    except Exception as e:
        print(f"Error reading {log_file}: {e}")
    return None

def parse_benchmark_logs(log_dir):
    """Parse all benchmark logs and organize results"""
    results = defaultdict(lambda: defaultdict(dict))
    
    log_path = Path(log_dir)
    if not log_path.exists():
        print(f"Error: Directory {log_dir} not found")
        return results
    
    for log_file in log_path.glob('*.log'):
        filename = log_file.name
        
        # Parse filename: ConfigName_TestName_Variant_JobID.log
        parts = filename.replace('.log', '').split('_')
        if len(parts) < 3:
            continue
        
        config = parts[0]
        test = parts[1]
        variant = parts[2]
        
        runtime = extract_runtime(log_file)
        utilization = extract_utilization(log_file)
        
        if runtime is not None:
            results[config][test][variant] = {
                'runtime': runtime,
                'utilization': utilization,
                'file': filename
            }
    
    return results

def calculate_speedup(baseline, optimized):
    """Calculate speedup factor"""
    if baseline and optimized and optimized > 0:
        return baseline / optimized
    return None

def print_comparison_table(results):
    """Print formatted comparison table"""
    print("\n" + "="*100)
    print("PERFORMANCE COMPARISON: MPI-only vs MPI+OpenMP vs MPI+OpenMP+SIMD")
    print("="*100)
    
    for config in sorted(results.keys()):
        print(f"\n{'='*100}")
        print(f"Configuration: {config}")
        print(f"{'='*100}")
        print(f"{'Test':<15} {'MPI Runtime':<15} {'OpenMP Runtime':<17} {'SIMD Runtime':<15} {'OpenMP Speedup':<17} {'SIMD Speedup':<15}")
        print(f"{'-'*15} {'-'*15} {'-'*17} {'-'*15} {'-'*17} {'-'*15}")
        
        for test in sorted(results[config].keys()):
            test_data = results[config][test]
            
            mpi_time = test_data.get('mpi', {}).get('runtime')
            openmp_time = test_data.get('openmp', {}).get('runtime')
            simd_time = test_data.get('simd', {}).get('runtime')
            
            openmp_speedup = calculate_speedup(mpi_time, openmp_time)
            simd_speedup = calculate_speedup(mpi_time, simd_time)
            
            mpi_str = f"{mpi_time}ms" if mpi_time else "N/A"
            openmp_str = f"{openmp_time}ms" if openmp_time else "N/A"
            simd_str = f"{simd_time}ms" if simd_time else "N/A"
            openmp_sp_str = f"{openmp_speedup:.2f}x" if openmp_speedup else "N/A"
            simd_sp_str = f"{simd_speedup:.2f}x" if simd_speedup else "N/A"
            
            print(f"{test:<15} {mpi_str:<15} {openmp_str:<17} {simd_str:<15} {openmp_sp_str:<17} {simd_sp_str:<15}")
        
        # Calculate averages for this config
        all_openmp_speedups = []
        all_simd_speedups = []
        
        for test in results[config].values():
            mpi_time = test.get('mpi', {}).get('runtime')
            openmp_time = test.get('openmp', {}).get('runtime')
            simd_time = test.get('simd', {}).get('runtime')
            
            openmp_speedup = calculate_speedup(mpi_time, openmp_time)
            simd_speedup = calculate_speedup(mpi_time, simd_time)
            
            if openmp_speedup:
                all_openmp_speedups.append(openmp_speedup)
            if simd_speedup:
                all_simd_speedups.append(simd_speedup)
        
        if all_openmp_speedups and all_simd_speedups:
            avg_openmp = sum(all_openmp_speedups) / len(all_openmp_speedups)
            avg_simd = sum(all_simd_speedups) / len(all_simd_speedups)
            
            print(f"{'-'*15} {'-'*15} {'-'*17} {'-'*15} {'-'*17} {'-'*15}")
            print(f"{'AVERAGE':<15} {'':<15} {'':<17} {'':<15} {avg_openmp:.2f}x{'':<11} {avg_simd:.2f}x{'':<9}")

def print_detailed_analysis(results):
    """Print detailed analysis with utilization metrics"""
    print("\n" + "="*100)
    print("DETAILED PERFORMANCE ANALYSIS")
    print("="*100)
    
    for config in sorted(results.keys()):
        print(f"\n{config}:")
        for test in sorted(results[config].keys()):
            test_data = results[config][test]
            print(f"\n  {test}:")
            
            for variant in ['mpi', 'openmp', 'simd']:
                if variant in test_data:
                    data = test_data[variant]
                    runtime = data.get('runtime', 'N/A')
                    util = data.get('utilization', 'N/A')
                    util_str = f"{util:.4f}" if isinstance(util, float) else util
                    print(f"    {variant.upper():<10} Runtime: {runtime}ms, Utilization: {util_str}")

def main():
    if len(sys.argv) < 2:
        log_dir = "logs/benchmark"
    else:
        log_dir = sys.argv[1]
    
    print(f"Analyzing benchmark results from: {log_dir}")
    
    results = parse_benchmark_logs(log_dir)
    
    if not results:
        print("No benchmark results found!")
        print(f"Expected log files in format: ConfigName_TestName_Variant_JobID.log")
        return
    
    print_comparison_table(results)
    print_detailed_analysis(results)
    
    print("\n" + "="*100)
    print("Analysis complete!")
    print("="*100)

if __name__ == "__main__":
    main()
