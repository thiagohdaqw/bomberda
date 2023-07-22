#!/bin/bash

# Usage: bash solve.sh <map_path>
#
# Example: bash solve.sh maps/more_simple

MAP_PATH=$1
MAP_PROBLEM_PATH="$1.pddl"
MAP_SOLUTION_PATH="$1.out"
DOMAIN="domain.pddl"

python bomberda.py $MAP_PATH
./downward/fast-downward.py --alias lama-first $DOMAIN $MAP_PROBLEM_PATH | tee $MAP_SOLUTION_PATH;
