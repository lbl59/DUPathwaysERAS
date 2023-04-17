
N_NODES=1
TASKS_PER_NODE=1
#START_RDM=0

TOTAL_TASKS=$(($N_NODES*$TASKS_PER_NODE))

SLURM="#!/bin/bash\n\
#SBATCH -n $TOTAL_TASKS -N $N_NODES\n\
#SBATCH --time=1:00:00\n\
#SBATCH --job-name=copy_flows\n\
#SBATCH --output=output/copy_flows\n\
#SBATCH --error=output/copy_flows.err\n\
#SBATCH --exclusive\n\

time ./copy_final_synthetic.sh"

echo -e $SLURM | sbatch
sleep 0.5
#donemod
