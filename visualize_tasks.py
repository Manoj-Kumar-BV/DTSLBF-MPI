#!/usr/bin/env python3
"""
Real-Time Task Distribution Visualizer
Shows master distributing tasks to workers in real-time
"""

import sys
import time
import os
from collections import defaultdict

def clear_screen():
    os.system('clear' if os.name != 'nt' else 'cls')

def draw_box(text, width=70):
    print("┌" + "─" * width + "┐")
    print("│" + text.center(width) + "│")
    print("└" + "─" * width + "┘")

def visualize_execution(log_file):
    """Parse execution trace and visualize task distribution"""
    
    if not os.path.exists(log_file):
        print(f"Error: Log file '{log_file}' not found")
        return
    
    # Parse the log file
    tasks_by_rank = defaultdict(list)
    with open(log_file, 'r') as f:
        for line in f:
            if line.startswith("EXECUTION TRACE:"):
                parts = line.strip().split()
                rank = int(parts[2])
                task_info = parts[4]
                tasks_by_rank[rank].append(task_info)
    
    if not tasks_by_rank:
        print("No execution trace found. Run with DEBUG=1 to generate trace.")
        return
    
    num_workers = len(tasks_by_rank) - 1  # Exclude rank 0
    
    clear_screen()
    draw_box("🚀 TASK DISTRIBUTION VISUALIZATION 🚀")
    print()
    
    # Animate task distribution
    max_tasks = max(len(tasks) for tasks in tasks_by_rank.values())
    
    for step in range(max_tasks):
        clear_screen()
        draw_box(f"Task Distribution - Step {step + 1}/{max_tasks}")
        print()
        
        # Master (Rank 0)
        print("┌─────────────────────────────────────────────────┐")
        print("│           MASTER (Rank 0)                       │")
        print("│         Task Queue Manager                      │")
        print("└─────────────────────────────────────────────────┘")
        print("               │")
        print("               │ Distributes Tasks")
        print("               │")
        print("       ┌───────┼───────┐")
        print("       │       │       │")
        print("       ▼       ▼       ▼")
        print()
        
        # Workers
        for rank in sorted(tasks_by_rank.keys()):
            if rank == 0:
                continue  # Skip master
            
            tasks = tasks_by_rank[rank]
            current_task = tasks[step] if step < len(tasks) else "IDLE"
            
            status = "🟢 BUSY" if current_task != "IDLE" else "⚪ IDLE"
            bar_length = min(step + 1, 20)
            progress = "█" * bar_length
            
            print(f"┌────────────────────────────────────────────────┐")
            print(f"│  WORKER {rank}  {status:20}            │")
            print(f"│  Current: {current_task:35} │")
            print(f"│  [{progress:20}] {step+1:3} tasks      │")
            print(f"└────────────────────────────────────────────────┘")
            print()
        
        time.sleep(0.3)  # Animation delay
    
    # Final summary
    clear_screen()
    draw_box("✅ EXECUTION COMPLETE ✅")
    print()
    print("Task Distribution Summary:")
    print("─" * 70)
    
    for rank in sorted(tasks_by_rank.keys()):
        if rank == 0:
            continue
        tasks = tasks_by_rank[rank]
        print(f"Worker {rank}: Executed {len(tasks)} tasks")
        
        # Count by task type
        task_types = defaultdict(int)
        for task in tasks:
            if '.' in task:
                parts = task.split('.')
                if len(parts) >= 2:
                    task_type = parts[1].split('#')[0]
                    task_types[task_type] += 1
        
        type_str = ", ".join(f"{t}:{c}" for t, c in task_types.items())
        print(f"           Types: {type_str}")
        print()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 visualize_tasks.py <log_file>")
        print("Example: python3 visualize_tasks.py logs/execution.log")
        sys.exit(1)
    
    visualize_execution(sys.argv[1])
