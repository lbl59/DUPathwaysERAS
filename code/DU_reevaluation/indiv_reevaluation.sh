DATA_DIR="/scratch/04528/tg838274/JLWTP_2021/paper3/DU_reeval/WaterPaths/"
N_REALIZATIONS=1000
SOLS_FILE_NAME="final_pset_DVs.csv"
RDM_PER_JOB=2
N_NODES=50
N_TASKS=200
RDM=1600
#for RDM in $(seq 0 $RDM_PER_JOB 4)
#do
SLURM="#!/bin/bash\n\
#SBATCH -N $N_NODES\n\
#SBATCH -n $N_TASKS\n\
#SBATCH --time=3:00:00\n\
#SBATCH --job-name=python_reeval_${RDM}_to_$(($RDM+$N_TASKS*$RDM_PER_JOB))\n\
#SBATCH --output=output/python_reeval_${RDM}_to_$(($RDM+$N_TASKS*$RDM_PER_JOB)).out\n\
#SBATCH --error=output/python_reeval_${RDM}_to_$(($RDM+$N_TASKS*$RDM_PER_JOB)).err\n\
#SBATCH --partition=skx-normal\n\
#SBATCH --mail-type=all\n\
#SBATCH --mail-user=dgoldri25@gmail.com\n\
export OMP_NUM_THREADS=96\n\
module load ooops\n\
module load gcc/9.1.0\n\
module load python3/3.8.2\n\

time ibrun python3 reeval_specific_set.py 24 $N_REALIZATIONS $DATA_DIR $SOLS_FILE_NAME"
echo -e $SLURM | sbatch
sleep 0.5
#donemod
