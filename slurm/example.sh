#!/bin/bash

## Examples of running your code
set -e

# Change to project root
cd "$(dirname "$0")/.."

# Make here to avoid any conflicts between overlapping makes
make all

## These are the 5 tests x 3 configs that you must achieve your speedup on

export DEBUG=0

## Config1
sbatch slurm/config1.sh 16 1 2 0.10 tests/tinkywinky.in
sbatch slurm/config1.sh 5 3 5 0.50 tests/dipsy.in
sbatch slurm/config1.sh 5 2 2 0.00 tests/lala.in
sbatch slurm/config1.sh 5 2 4 0.50 tests/po.in
sbatch slurm/config1.sh 12 0 10 0.16 tests/thesun.in

## Config2
sbatch slurm/config2.sh 16 1 2 0.10 tests/tinkywinky.in
sbatch slurm/config2.sh 5 3 5 0.50 tests/dipsy.in
sbatch slurm/config2.sh 5 2 2 0.00 tests/lala.in
sbatch slurm/config2.sh 5 2 4 0.50 tests/po.in
sbatch slurm/config2.sh 12 0 10 0.16 tests/thesun.in

## Config3
sbatch slurm/config3.sh 16 1 2 0.10 tests/tinkywinky.in
sbatch slurm/config3.sh 5 3 5 0.50 tests/dipsy.in
sbatch slurm/config3.sh 5 2 2 0.00 tests/lala.in
sbatch slurm/config3.sh 5 2 4 0.50 tests/po.in
sbatch slurm/config3.sh 12 0 10 0.16 tests/thesun.in


## We already ran this for you to get sequential outputs and times, no need to re-run
# ./generate_test_output.sh 16 1 2 0.10 tests/tinkywinky.in
# ./generate_test_output.sh 5 3 5 0.50 tests/dipsy.in
# ./generate_test_output.sh 5 2 2 0.00 tests/lala.in
# ./generate_test_output.sh 5 2 4 0.50 tests/po.in
# ./generate_test_output.sh 12 0 10 0.16 tests/thesun.in


