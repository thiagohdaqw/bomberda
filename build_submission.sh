#!/bin/bash


SOLVER="downward\/fast-downward.py --alias lama-first"
PROBLEM_PATH="\/tmp\/mapa.pddl"
DOMAIN_PATH="\/tmp\/domain.pddl"

cat bomberda.py | sed -e "s/SOLVER = \"\"/SOLVER = \"$SOLVER\"/g" \
                      -e "s/PROBLEM_PATH = \"\"/PROBLEM_PATH = \"$PROBLEM_PATH\"/g" \
                      -e "s/DOMAIN_PATH = \"\"/DOMAIN_PATH = \"$DOMAIN_PATH\"/g" \
                | sed '/<include_domain>/r domain.pddl' > main.py3