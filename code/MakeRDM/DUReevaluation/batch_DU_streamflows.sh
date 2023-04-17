#!/bin/bash
#SBATCH --nodes=1                   # Use one node
#SBATCH --ntasks=1                  # Run a single task
#SBATCH --output=./output/SynGen.out
#SBATCH --error=./output/SynGen.err
#SBATCH --time 1:00:00
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --array=1-5                # Array range

module load octave/6.3.0
#Set the number of runs that each SLURM task should do
PER_TASK=10

# Calculate the starting and ending values for this task based
# on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))


# Run the loop of runs for this task.
for (( run=$START_NUM; run<=END_NUM; run++ )); do
  echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run
    srun  octave-cli ./generate_streamflows.m $run ./RDM_inflows_demands/RDM_$run/synthetic_inflows/ ../historical/
    echo 
done

