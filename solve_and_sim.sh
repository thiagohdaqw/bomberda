#!/bin/bash

MAP=$1
./solve.sh maps/$MAP && python simulate.py maps/$MAP

