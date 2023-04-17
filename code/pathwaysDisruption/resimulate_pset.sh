DATA_DIR=/ocean/projects/ees200007p/dfg42/paper3/pathwaysDisruption/DU_reeval/
N_REALIZATIONS=1000

SLURM="#!/bin/bash\n\
#SBATCH --nodes=1\n\
#SBATCH --ntasks-per-node=128\n\
#SBATCH --job-name=disruptionSim\n\
#SBATCH --output=output/disruptionSim.out\n\
#SBATCH --error=output/disruptionSim.err\n\
#SBATCH -p RM\n\
#SBATCH --time=2:00:00\n\
##SBATCH --cpus-per-task=128\n\
##SBATCH --account=TG-EAR090013\n\
export OMP_NUM_THREADS=128\n\
cd \$SLURM_SUBMIT_DIR\n\

time ./triangleSimulation -T 128 -t 2344 -r ${N_REALIZATIONS} -d ${DATA_DIR} -C -1 -D pwl -E pwl -F 1 -O ../../WaterPaths/rof_tables/ -U TestFiles/rdm_factors/WJLWTP_rdm_utilities_paper3_opt.csv -W TestFiles/rdm_factors/WJLWTP_rdm_watersources_paper3_opt.csv -P TestFiles/rdm_factors/WJLWTP_rdm_policies_paper3_opt.csv -s compSol_DVs_140_disrupted_permitonly.csv -p false -f 0 -l 21"

echo -e $SLURM | sbatch
sleep 0.5


