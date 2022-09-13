DATA_DIR=/ocean/projects/ees200007p/dfg42/paper3/WaterPaths/

N_REALIZATIONS=1000


SLURM="#!/bin/bash\n\
#SBATCH -N 1\n\
#SBATCH -n 1\n\
#SBATCH --job-name=paper3_tables\n\
#SBATCH --output=output/tables.out\n\
#SBATCH --error=output/tables.err\n\
#SBATCH -p RM\n\
#SBATCH --time=02:00:00\n\
#SBATCH --mail-user=dgoldri25@gmail.com\n\
#SBATCH --mail-type=all\n\
export OMP_NUM_THREADS=128\n\
cd \$SLURM_SUBMIT_DIR\n\

time ./triangleSimulation -T 128 -t 2344 -r ${N_REALIZATIONS} -d ${DATA_DIR} -C 1 -D pwl -E pwl -F 1 -O rof_tables/ -s Reference_DVs.csv -U TestFiles/rdm_factors/WJLWTP_rdm_utilities_paper3_opt.csv -W TestFiles/rdm_factors/WJLWTP_rdm_watersources_paper3_opt.csv -P TestFiles/rdm_factors/WJLWTP_rdm_policies_paper3_opt.csv -m 0"

echo -e $SLURM | sbatch
sleep 0.5


