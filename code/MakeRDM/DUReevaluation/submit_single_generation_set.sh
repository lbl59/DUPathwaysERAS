#!/bin/bash
#SBATCH --job-name="SynGen"
#SBATCH --output="./output/SynGen.out"
#SBATCH --error="./error/SynGen.err"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --export=ALL
#SBATCH -t 24:00:00
module load octave/6.3.0
time octave-cli ./generate_streamflows.m 0 ./synthetic_inflows/ ./historical/
