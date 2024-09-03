# DUPathwaysERAS
Data and code for Gold et al., in review at WRR

All code can be found in the code directory. Results can be found in the results directory. 

## Experimental workflow

1. Generate SOWs for DU optimization (see DU optimization RDM section below)
	a. Generate DU factor LHS based on ranges found in [Generating SOWs](https://www.notion.so/Generating-SOWs-6da9f9f3c62c4186893bde427d5cac60) 
	b. Generate sinusoidal inflows [Generating streamflows](https://www.notion.so/Generating-streamflows-a072aa110c154988aa346677b69eed73) 
2. Run optimization detailed in [Optimization](https://www.notion.so/Optimization-bac9a4737be947b98b1694ec6cd601e2) 
    a. Transfer inflow and demand data to Bridges2 with Globus
    b. Transfer results back to Hopper with Globus
3. Find reference set across all seeds (see Post processing)
4. Perform runtime diagnostics (see Post processing) 
5. Generate SOWs for DU reevaluation (see DU reevaluation RDMs) 
6. Perform DU reevaluation on Stampede2, (see details in DU Re-evaluation) 
7. Analyze results using procedures in (Data analysis) 
8. Perform regional defection analysis (see regional defeciton analysis section)
9. Perform infrastructure disruption analysis (see infrastructure disruption analysis section)
10. Create figures


## Generating Future SOWs for DU Optimization
### Generating synthetic streamflows
Steps for generating streamflows:

1. Navigate to the `Make_RDMs/` directory
2. Use historical generator to generate 1000 synthetically generated streamflows
   - Run `submit_single_generation_set.sh`, this calls the MATLAB script `generate_streamflows.m` which in turn calls a script called `generate_sample.m` which uses the `stress_dynamic.m` script to create streamflow realizations
   - `stress_dynamic.m` reads in `RDM_LHS_inflows.csv` which has the sinusoidal parameters sampled from values in Trindade et al. (2020)
3. Combine historical record with the generated streamflows. This is done with `JLWTPModel_combineHistoricalSyntheticInflows.R` in the `optimizationRDM/` folder. The script prints new inflow files to the `final_synthetic_inflows/` folder

### Generating synthetic demand records
Demand generation overall has the following steps:

1. generate an RDM sample with full set of DU factors
2. add demand multiplier factors `demand_rdm_op.csv` and transpose (4x1000matrix)
3. Run `pwl_demands.py`
4. Run `JLWTPModel_buildAnnualDemandProjections_avgMGDs.R` to get the correlation structure with the inflows
5. Run `JLWTPModel_add_pwl_trends.R` on Hopper and it will generate the final demand files (stored in `synthetic_demands_pwl/`, which needs to be created first).

## DU Optimization
1. Navigate to Code/Optimization
2. Download the Borg MOEA (must request access) from http://borgmoea.org/. To replicate the full experiment, a parallel version of the algorithm is required
3. Compile Waterpaths using `make gcc`
4. Construct ROF tables using the `Make_tables.sh` script
5. recompile WaterPaths using `make borg`
6. Run the optimization across 150k NFE

## Create SOWs for DU re-evaluation
1. create folders for each of the 2,000 streamflow samples
    a. Use the `make_input_folders.sh` script, may need adjusting. Each RDM factor needs its own folder. All RDM folders are in a subfolder called "RDM_inflows_demands". Each RDM folder has the following structure:
        i. final_synthetic_inflows
            - evaporation
        ii. inflow_demand_distributions
        iii. synthetic_demand_variation_multiplier
        iv. synthetic_demands_pwl
        v. synthetic_inflows
            - evaporation
2. Use MOEAframework to generate DU samples (see command below)
    
    ```bash
    java -cp MOEAFramework-2.13-Demo.jar org.moeaframework.analysis.sensitivity.SampleGenerator --method latin --numberOfSamples 2000 --parameterFile RDM_ranges.txt --output RDM_LHS.csv
    ```
    
3. generate streamflows with from each sinusoidal sample
    - The work is done by stress_dynamic.m
    - This is called via matlab by generate_sample.m, which is in turn called via generate_streamflows.m
    - generate_streamflows.m is parallelized with pythonCreateDUstreamflows.py
    - This is submitted with submitPython_streamflows.sh (takes around 5.5 hours on hopper)
4. combine with records with historical
    - work is done with JLWTPModel_combineHistoricalSyntheticInflows.R
    - This is called by pythonCombineHistoricalSytheticInflows.py
    - This is called by submitPython_combineHistSyn.sh
5. apply RDM factors to demands average annual demand factors
    - Using the peicewise linear approach to demand generation, detailed above
    - The R script JLWTPModel_conditionAndBuildDemandRealizations.R 
    - This is called via MPI with pythonConditionBuildDemands.py
    - This is submitted with submitPython_demands.sh  (note: this takes a little over 3 hours on a cluster with 40 cores)
7. Create DU reeval rdm files locally, use factors values in RDM_pwl_demand_25_DUReeval.txt and add them to the Utilities, Policies and WaterSources files


## DU reevaluation
1. Copy SOWs to the DUReevaluation folder
2. Navigate to Code/DUReevaluation
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

## Pathways Disruption Analysis
1. Navigate to code/pathwaysDisruption
2. construct ROF tables using the make_tables.sh bash script (this will need to be edited in accordance with the cluster being used, the file path must be edited as well as the number of cores, partitions etc., note that the timing may need to be changed depending on the number of available processors)
3. Copy the TestFiles directory from the DU reevaluation directory
4. Compile waterPaths with 'make gcc'
5. Run disruption analysis with the bash script
