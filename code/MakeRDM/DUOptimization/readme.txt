Readme file for RealizationGeneration Directory
Order of file use required to construct 
 synthetic inflow and demand realizations 
 for the Research Triangle across six utilities.
------------------------------------------------

Generating Inflows:
(1) requires folder of historical inflow files
(2) Run generate_sample.m MATLAB script to produce
    synthetic inflow sets for each inflow site
    (includes evaporation sites in subfolder)
    (best done over a cluster, use the
     submit_single_generation_set.sh shell script,
     may only be a copy on TheCube)
    NOTE: (August 2021) FOR APPLYING SINUSOIDAL FACTORS, READ IN 
	rdm_inflows_test_problem_reeval_aug2021.csv, with separate sinusoidal factors 
	created via Ubuntu and the following line of code:
	java -cp MOEAFramework-2.13-Demo.jar org.moeaframework.analysis.sensitivity.SampleGenerator --method latin --numberOfSamples 1000 --parameterFile RDM_ranges_justinflows.txt --output RDM_LHS_justinflows.csv
	WHERE RDM_LHS_justinflows.csv IS THE FILE THAT SHOULD BE REFERENCED 
	WITHIN THE MATLAB SCRIPTS CALLED IN STEP (2)

To Add Historical Records To Synthetic Inflow Realizations for WaterPaths Input Files:
(2b) Run JLWTPModel_combineHistoricalSyntheticInflows.R to
     append historical data to inflows and evaporation records
     and split and rename files to fit WaterPaths for the Triangle (need to create directoryies final_synthetic_inflows and subdirectory evaporation)
     (additionally, to split the files into 1,000 row sets for
      RDM analysis, see the bottom of the same script)
     NOTE: BOTTOM THIRD OF THIS SCRIPT IS FOR RE-EVALUATION FILE GENERATION
           AND SHOULD BE IGNORED IF PREPARING FOR OPTIMIZATION

Generating Demands WITHOUT Sinusoidal Perturbation:
(3) Requires unit demand files for 4 primary utilities
(4) Run JLWTPModel_buildAnnualDemandProjections_avgMGDs.R
    to create annual average MGD projections for 
    2015-2065 for each Triangle utility
(5) Run JLWTPModel_conditionAndBuildDemandRealizations.R
    to calculate joint inflow-demand empirical PDFs for
    each utility (both irrigation and non-irrigation
    seasons) and variations to be applied to weekly 
    synthetic demands for all realizations, and apply 
    variation factors along with annual trends to develop
    weekly synthetic demand realizations (need to create directories: synthetic_demands, annual_demand_projections_avgMGD, synthetic_demand_variation_multiplier)

To Apply Sinusoidal Signal to Demand Realizations:
(6) Requires MOEA Framework (Demo Version at least),
    demand_realization_params_pre_LHS_ranges.txt,
    and JLWTPModel_ApplySinusoidal.R
(7) Run the following command via Linux terminal (Ubuntu)
    in the folder containing the above files:
	java -cp MOEAFramework-2.13-Demo.jar org.moeaframework.analysis.sensitivity.SampleGenerator --method latin --numberOfSamples 1000 --parameterFile demand_realization_params_pre_LHS_ranges.txt --output LHS_1000_samples_file.txt
    to generate a LHS sample of sinusoidal parameters
    for 1,000 demand realizations
	(7A) 	UPDATE AUG 2020: New workflow to generate RDM samples
		for ALL parts of the modeling framework, including
		sinusoidal factors. Ignore step (7) above and do 
		the following: requires RDM_ranges.txt, make_rdm.py
		(NOTE: SOME PATHS MAY NEED TO BE RE-ROUTED BECAUSE
		 A SUB-FOLDER RDMfactor_sets WAS ADDED TO HOLD FILES)
	(7B)	Run this command in Ubuntu (CHANGE --numberOfSamples TO 500 FOR SEPT 2020 SET):
		java -cp MOEAFramework-2.13-Demo.jar org.moeaframework.analysis.sensitivity.SampleGenerator --method latin --numberOfSamples 1000 --parameterFile RDM_ranges.txt --output RDM_LHS.txt
	(7C)	Run make_rdm.py (CHANGING n_realizations AS NECESSARY) to generate the following RDM files:
			(1) demand_factors.csv - used to apply sinusoidal factors to demand realizations
			(2) WJLWTP_rdm_policies.csv - RDM factors for Restrictions class
			(3) WJLWTP_rdm_watersources.csv - RDM factors for WaterSources class
			(4) WJLWTP_rdm_utilities.csv - RDM factors for Utility class
(8) Run JLWTPModel_ApplySinusoidal.R
    to apply sinusoidal parameters to existing
    demand realizations created above
    LIKE ABOVE, ADJUST NUMBER OF REALIZATIONS READ
     IN THE SCRIPT IF THIS CHANGES

