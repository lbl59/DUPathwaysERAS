DATA_DIR=/ocean/projects/ees200007p/dfg42/paper3/OWASADefection/
N_REALIZATIONS=1000


#for SEED in 200 201 202 203 204
#do
SLURM="#!/bin/bash\n\
#SBATCH -n 200 -N 50\n\
#SBATCH --job-name=owasa_prod\n\
#SBATCH --output=output/owasa_prod.out\n\
#SBATCH --error=output/owasa_prod.err\n\
#SBATCH -p RM\n\
#SBATCH -t 3:00:00\n\
#SBATCH --mail-user=dgoldri25@gmail.com\n\
#SBATCH --mail-type=all\n\
export OMP_NUM_THREADS=32\n\
cd \$SLURM_SUBMIT_DIR\n\
module load openmpi/3.1.6-gcc10.2.0\n\
time mpirun -n 200 ./triangleSimulation -T \${OMP_NUM_THREADS} -t 2344 -r ${N_REALIZATIONS} -d ${DATA_DIR} -F 1 -D pwl -E pwl -C -1 -O ../WaterPaths/rof_tables/ -e 2 -U TestFiles/rdm_factors/WJLWTP_rdm_utilities_paper3_opt.csv -W TestFiles/rdm_factors/WJLWTP_rdm_watersources_paper3_opt.csv -P TestFiles/rdm_factors/WJLWTP_rdm_policies_paper3_opt.csv -b true -o 2500 -n 5000 -i 2 "

echo -e $SLURM | sbatch
#sleep 0.5
#done
