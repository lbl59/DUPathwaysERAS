DATA_DIR="/expanse/lustre/scratch/dfg42/temp_project/WaterPaths/"
N_REALIZATIONS=1000
SOLS_FILE_NAME="ref_set_filtered_dvs_noheaders_ids.csv"
RDM_PER_JOB=2
N_NODES=2
RDM=0
#for RDM in $(seq 0 $RDM_PER_JOB 4)
#do
SLURM="#!/bin/bash\n\
#SBATCH --nodes=$N_NODES\n\
#SBATCH --ntasks-per-node=4\n\
#SBATCH --time=03:00:00\n\
#SBATCH --job-name=python_reeval_${RDM}_to_$(($RDM+$RDM_PER_JOB*$N_NODES*4))\n\
#SBATCH --output=output/python_reeval_${RDM}_to_$(($RDM+$RDM_PER_JOB*$N_NODES*4)).out\n\
#SBATCH --error=output/python_reeval_${RDM}_to_$(($RDM+$RDM_PER_JOB*$N_NODES*4)).err\n\
#SBATCH --partition=skx-dev\n\
export OMP_NUM_THREADS=96\n\
module load  python/3.8.5\n\
module load py-mpi4py\n\

time ibrun triangleSimulation python3 reeval.py \$OMP_NUM_THREADS $N_REALIZATIONS $DATA_DIR $RDM $SOLS_FILE_NAME $N_NODES $RDM_PER_JOB"
echo -e $SLURM | sbatch
sleep 0.5
#donemod
