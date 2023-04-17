# -*- coding: utf-8 -*-
"""
Created 8/24/2020
Build RDM factor csv files for WaterPaths
@author: dgorelic
"""

import pandas as pd
import numpy as np
import os

# read RDM_LHS.txt to get factors that do change
# should be 17 factors, in this order:
#   Demand_A 0.000001 0.13
#   Demand_T 3000 6000
#   Demand_P 600 1200
#   Bond_term  0.8 1.2 
#   Bond_interest  0.6 1.2
#   Discount  0.6 1.4 
#   O_res  0.8 1.2 
#   D_res  0.8 1.2 
#   C_res  0.8 1.2
#   R_res  0.8 1.2 
#   P_res  0.8 1.2
#   Ch_res  0.8 1.2 
#   Evap  0.9 1.1
#   JLWTP_low_Permit 0.75 1.5
#   JLWTP_low_Constr 1.0 1.2
#   JLWTP_high_Permit 0.75 1.5
#   JLWTP_high_Constr 1.0 1.2
os.chdir('C:\\Users\\dgorelic\\OneDrive - University of North Carolina at Chapel Hill\\UNC\\Research\\WSC\\Coding\\WP\\RealizationGeneration/RDMfactor_sets')
RDM = np.loadtxt('RDM_LHS.txt', delimiter = ' ')
RDM = pd.DataFrame(RDM)
RDM.columns = ['d_A', 'd_T', 'd_P', 
               'Bond Term', 'Bond Interest Rate', 'Discount Rate', 
               'OWASA Restriction Factor', 
               'Durham Restriction Factor', 
               'Cary Restriction Factor', 
               'Raleigh Restriction Factor', 
               'Pittsboro Restriction Factor', 
               'Chatham Restriction Factor', 
               'Evaporation Factor', 
               'WJLWTP Low Permitting Factor', 'WJLWTP Low Construction Factor', 
               'WJLWTP High Permitting Factor', 'WJLWTP High Construction Factor']

# build policies file
# this is 6 factors, one for each utility's Restriction Stage Multipliers
# NOTE: Chatham is Utility ID 4, Pittsboro is Utility ID 5, so their order
# below is swapped relative to how the LHS is done above
RDM_Policies = RDM[['OWASA Restriction Factor', 
                    'Durham Restriction Factor', 
                    'Cary Restriction Factor', 
                    'Raleigh Restriction Factor', 
                    'Chatham Restriction Factor', 
                    'Pittsboro Restriction Factor']]
RDM_Policies.to_csv('WJLWTP_rdm_policies.csv', index = False, header = False)

# build water sources file
# most complicated file - will contain evap factor, plus WJLWTP factors,
# but must add placeholders for all other infrastructure 
# all sources with IDs have 2 RDM factors, even if already online
n_sources = 34; n_realizations = 1000
wjlwtp_low_id = [29*2+1,31*2+1]; wjlwtp_high_id = [30*2+1,32*2+1]
RDM_WaterSources = pd.DataFrame(1, index = range(0,n_realizations), 
                                columns = range(0,(1+n_sources*2)))
RDM_WaterSources.iloc[:,0] = RDM['Evaporation Factor'].values
for w_id in wjlwtp_low_id:
    RDM_WaterSources.iloc[:,w_id] = RDM['WJLWTP Low Permitting Factor'].values
    RDM_WaterSources.iloc[:,(w_id+1)] = RDM['WJLWTP Low Construction Factor'].values
for w_id in wjlwtp_high_id:    
    RDM_WaterSources.iloc[:,w_id] = RDM['WJLWTP High Permitting Factor'].values
    RDM_WaterSources.iloc[:,(w_id+1)] = RDM['WJLWTP High Construction Factor'].values
RDM_WaterSources.to_csv('WJLWTP_rdm_watersources.csv', index = False, header = False)

# build utilities file
# factors are (in this order): 
#   demand multiplier (set to 1 for this study)
#   bond term
#   bond interest rate
#   discount rate
n_factors = 4; n_realizations = 1000
RDM_Utilities = pd.DataFrame(1, index = range(0,n_realizations), 
                                columns = range(0,(n_factors)))
RDM_Utilities.iloc[:,1:n_factors] = RDM[['Bond Term', 
                                         'Bond Interest Rate', 
                                         'Discount Rate']].values
RDM_Utilities.to_csv('WJLWTP_rdm_utilities.csv', index = False, header = False)   
    
# build file for sinusoidal factors    
RDM_Sinusoidal = RDM[['d_A', 'd_T', 'd_P']]
RDM_Sinusoidal.to_csv('demand_factors.csv', index = False, header = False)
    