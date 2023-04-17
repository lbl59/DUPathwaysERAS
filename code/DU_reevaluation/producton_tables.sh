DATA_DIR="/scratch/04528/tg838274/JLWTP_2021/paper3/DU_reeval/WaterPaths/"
N_REALIZATIONS=1000
SOLS_FILE_NAME="Reference_DVs.csv"
RDM_PER_JOB=1
N_NODES=50
RDM=950
#for RDM in $(seq 0 $RDM_PER_JOB 4)
#do
SLURM="#!/bin/bash\n\
#SBATCH -N $N_NODES\n\
#SBATCH -n $N_NODES\n\
#SBATCH --time=3:00:00\n\
#SBATCH --job-name=tables\n\
#SBATCH --output=output/tables_${RDM}_to_$(($RDM+50-1)).out\n\
#SBATCH --error=output/tables_${RDM}_to_$(($RDM+50-1)).err\n\
#SBATCH --partition=skx-normal\n\
#SBATCH --mail-type=all\n\
#SBATCH --mail-user=dgoldri25@gmail.com\n\
export OMP_NUM_THREADS=96\n\
module load ooops\n\
module load gcc/9.1.0\n\
module load python3/3.8.2\n\

time ibrun python3 reeval_tables.py \$OMP_NUM_THREADS $N_REALIZATIONS $DATA_DIR $RDM $SOLS_FILE_NAME $N_NODES $RDM_PER_JOB"
echo -e $SLURM | sbatch
sleep 0.5
#done
