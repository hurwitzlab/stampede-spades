#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -t 02:00:0
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J spades
#SBATCH -p development
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user kyclark@email.arizona.edu

set -u

./run-spades.pl -d $SCRATCH/data/assembly/generic/test_reads.fa -o $SCRATCH/spades-out --debug
