# DUPathwaysERAS
Data and code for Gold et al., in review at WRR

All code can be found in the code directory. Results can be found in the results directory. 

## Optimization
1. Clone repository and extract compressed source files
2. Download the Borg MOEA (must request access) from http://borgmoea.org/. To replicate the full experiment, a parallel version of the algorithm is required
3. Compile Waterpaths using "make gcc"
4. Construct ROF tables using the "Make_tables.sh" script
5. recompile WaterPaths using "make borg"
6. Run the optimization across a desired number of NFE

## DU reevaluation
1. copy the TestFiles folder from the regionalDefection directory
2. compile WaterPaths with "make gcc"
3. use make_RDM_tables.sh to create tables for each DU SOW (note this method of parallelization may not suit all clusters and final tables will take a significant amount of memory, this may require using a python script similar to reeval.py)
4. peform DU reevaluation using the python_reevaluation.sh bash file (will need to be edited for the cluster being used)

## Regional Defection Analysis
1. compile waterpaths using with a gcc compiler by typing "make gcc" into the command line
2. construct ROF tables using the make_tables.sh bash script (this will need to be edited in accordance with the cluster being used, the file path must be edited as well as the number of cores, partitions etc., note that the timing may need to be changed depending on the number of available processors)
3. add the borg moea to the regionalDefection directory in a subdirectory titled "Borg"
4. compile borg using OpenMPI (as long as the cluster has openMPI this only requires "make")
5. copy the libborgms.a file to a directory titled "lib" within the regionalDefection directory
6. Run regional defection 

