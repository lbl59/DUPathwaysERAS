from mpi4py import MPI
import numpy as np
import subprocess, sys, time
import os
import time

comm = MPI.COMM_WORLD
rank = comm.Get_rank()

start_realization = int(sys.argv[1])
N_CORE = int(sys.argv[2])
Num_RDM = int(sys.argv[3])


for i in range(Num_RDM):
	RDM = start_realization + rank + N_CORE * i

	command_gen_demands = "Rscript JLWTPModel_conditionAndBuildDemandRealizations.R {}".format(RDM)
	print(RDM)
	os.system(command_gen_demands)
	#time.sleep(660)

comm.Barrier()