#!/usr/bin/env python3
"""
Performance Visualization Tool
Creates bar charts comparing MPI-only vs MPI+OpenMP vs MPI+OpenMP+SIMD
"""

import sys
import os
from pathlib import Path

def create_ascii_bar_chart(data, title, max_width=60):
    """Create ASCII bar chart"""
    print("\n" + "=" * 70)
    print(title.center(70))
    print("=" * 70 + "\n")
    
    if not data:
        print("No data available")
        return
    
    # Find max value for scaling
    max_val = max(val for _, val in data)
    
    # Print bars
    for label, value in data:
        bar_width = int((value / max_val) * max_width)
        bar = "█" * bar_width
        print(f"{label:25} {bar} {value:.0f}ms")
    
    print()

def create_speedup_chart(baseline, variants, max_width=60):
    """Create speedup comparison chart"""
    print("\n" + "=" * 70)
    print("SPEEDUP ANALYSIS (vs MPI-only)".center(70))
    print("=" * 70 + "\n")
    
    if baseline == 0:
        print("No baseline data available")
        return
    
    for label, value in variants:
        if value > 0:
            speedup = baseline / value
            bar_width = int(speedup * 10)
            bar = "█" * min(bar_width, max_width)
            print(f"{label:25} {bar} {speedup:.2f}x")
        else:
            print(f"{label:25} No data")
    
    print()

def parse_runtime(log_file):
    """Extract FINAL RUNTIME from log file"""
    try:
        with open(log_file, 'r') as f:
            for line in f:
                if 'FINAL RUNTIME:' in line:
                    return int(line.split(':')[1].strip().replace('ms', ''))
    except:
        pass
    return None

def parse_utilization(log_file):
    """Extract CPU utilization from log file"""
    try:
        with open(log_file, 'r') as f:
            for line in f:
                if 'Overall:' in line:
                    parts = line.split('(')[1].split(')')[0]
                    return float(parts) * 100
    except:
        pass
    return None

def visualize_performance(log_dir):
    """Parse logs and create visualizations"""
    
    log_path = Path(log_dir)
    if not log_path.exists():
        print(f"Error: Directory '{log_dir}' not found")
        return
    
    # Find test files
    test_results = {}
    
    for log_file in log_path.glob('*.log'):
        filename = log_file.name
        
        # Parse: local_variant_testname.log
        parts = filename.replace('.log', '').split('_')
        if len(parts) >= 3 and parts[0] == 'local':
            variant = parts[1]
            test = parts[2]
            
            if test not in test_results:
                test_results[test] = {}
            
            runtime = parse_runtime(log_file)
            util = parse_utilization(log_file)
            
            test_results[test][variant] = {
                'runtime': runtime,
                'utilization': util
            }
    
    if not test_results:
        print("No benchmark results found.")
        print("Run: ./run_benchmark_local.sh")
        return
    
    # Display results
    print("\n" + "╔" + "═" * 68 + "╗")
    print("║" + "PERFORMANCE VISUALIZATION".center(68) + "║")
    print("╚" + "═" * 68 + "╝")
    
    for test_name in sorted(test_results.keys()):
        results = test_results[test_name]
        
        print(f"\n\n{'▶ TEST: ' + test_name.upper():^70}")
        print("─" * 70)
        
        # Runtime comparison
        runtime_data = []
        if 'mpi' in results and results['mpi']['runtime']:
            runtime_data.append(("MPI-only", results['mpi']['runtime']))
        if 'openmp' in results and results['openmp']['runtime']:
            runtime_data.append(("MPI + OpenMP", results['openmp']['runtime']))
        if 'simd' in results and results['simd']['runtime']:
            runtime_data.append(("MPI + OpenMP + SIMD", results['simd']['runtime']))
        
        if runtime_data:
            create_ascii_bar_chart(runtime_data, "Runtime (lower is better)")
            
            # Speedup analysis
            baseline = results.get('mpi', {}).get('runtime', 0)
            if baseline:
                speedup_data = []
                if 'openmp' in results and results['openmp']['runtime']:
                    speedup_data.append(("MPI + OpenMP", results['openmp']['runtime']))
                if 'simd' in results and results['simd']['runtime']:
                    speedup_data.append(("MPI + OpenMP + SIMD", results['simd']['runtime']))
                
                if speedup_data:
                    create_speedup_chart(baseline, speedup_data)
        
        # Utilization
        print("CPU Utilization:")
        print("─" * 70)
        for variant in ['mpi', 'openmp', 'simd']:
            if variant in results and results[variant]['utilization']:
                util = results[variant]['utilization']
                bar = "█" * int(util / 2)
                label = {'mpi': 'MPI-only', 'openmp': 'MPI+OpenMP', 'simd': 'MPI+OpenMP+SIMD'}[variant]
                print(f"{label:25} {bar} {util:.1f}%")
        print()

def visualize_summary():
    """Create overall summary visualization"""
    log_dir = "logs/benchmark"
    visualize_performance(log_dir)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        visualize_performance(sys.argv[1])
    else:
        visualize_summary()
