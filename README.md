# DUPathwaysERAS
Data and code for Gold et al., in review at WRR

All code can be found in the code directory. Results can be found in the results directory. 

## Optimization


## Regional Defection Analysis
1. clone this repository and extract the following compressed data
2. compile waterpaths using with a gcc compiler by typing "make gcc" into the command line
3. construct ROF tables using the make_tables.sh bash script (this will need to be edited in accordance with the cluster being used, the file path must be edited as well as the number of cores, partitions etc., note that the timing may need to be changed depending on the number of available processors)
4. add the borg moea to the regionalDefection directory in a subdirectory titled "Borg"
5. compile borg using OpenMPI (as long as the cluster has openMPI this only requires "make")
6. copy the libborgms.a file to a directory titled "lib" within the regionalDefection directory
7. Run regional defection 

## DU reevaluation
1. Extract the compressed source files from
2. copy the TestFiles folder from the regionalDefection directory
3. upload the Pareto Approximate fronts from each regional defection optimization
4. compile WaterPaths with "make gcc"
5. use make_RDM_tables.sh to create tables for each DU SOW (note this method of parallelization may not suit all clusters and final tables will take a significant amount of memory, this may require using a python script similar to reeval.py)
6. peform DU reevaluation using the python_reevaluation.sh bash file (will need to be edited for the cluster being used)
