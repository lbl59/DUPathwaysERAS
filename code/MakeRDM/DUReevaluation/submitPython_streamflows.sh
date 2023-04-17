
RDM_PER_JOB=40
N_NODES=5
TASKS=10
RDM=0

TOTAL_CORE=$(($N_NODES*$TASKS))

SLURM="#!/bin/bash\n\
#SBATCH -n $TOTAL_CORE -N $N_NODES\n\
#SBATCH --time=7:00:00\n\
#SBATCH --job-name=python_reeval_${RDM}_to_$(($RDM+$RDM_PER_JOB-1))\n\
#SBATCH --output=output/python_reeval_${RDM}_to_$(($RDM+$RDM_PER_JOB-1)).out\n\
#SBATCH --error=output/python_reeval_${RDM}_to_$(($RDM+$RDM_PER_JOB-1)).err\n\
#SBATCH --exclusive\n\
export OMP_NUM_THREADS=16\n\
module load py3-mpi4py\n\
module load py3-numpy\n\
module load octave/6.3.0\n\
time mpirun -np $TOTAL_CORE python3 pythonCreateDUstreamflows.py $RDM $TOTAL_CORE $RDM_PER_JOB"

echo -e $SLURM | sbatch
sleep 0.5
#donemod
