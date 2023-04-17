DATA_DIR=/scratch/04528/tg838274/JLWTP_2021/paper3/DU_reeval/WaterPaths/

N_REALIZATIONS=1000
RDM=1876

SLURM="#!/bin/bash\n\
#SBATCH --nodes=1\n\
#SBATCH --ntasks-per-node=1\n\
#SBATCH --job-name=paper3_tables\n\
#SBATCH --output=output/tables${RDM}.out\n\
#SBATCH --error=output/tables${RDM}.err\n\
#SBATCH --partition=skx-dev\n\
#SBATCH --time=00:30:00\n\
#SBATCH --mail-user=dgoldri25@gmail.com\n\
#SBATCH --mail-type=all\n\

export OMP_NUM_THREADS=96\n\
cd \$SLURM_SUBMIT_DIR\n\

#module load gcc openmpi\n\
module load ooops\n\

time ./triangleSimulation -T 96 -t 2344 -r ${N_REALIZATIONS} -d ${DATA_DIR} -R ${RDM} -C 1 -D pwl -E pwl -F 1 -O rof_tables/RDM_${RDM}/ -s Reference_DVs.csv -U TestFiles/rdm_factors/WJLWTP_rdm_utilities_paper3_reeval.csv -W TestFiles/rdm_factors/WJLWTP_rdm_watersources_paper3_reeval.csv -P TestFiles/rdm_factors/WJLWTP_rdm_policies_paper3_reeval.csv -m 0"

echo -e $SLURM | sbatch
sleep 0.5


