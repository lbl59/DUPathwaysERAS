# Combine Historical and Synthetic Inflows into final sets for WaterPaths
# D Gorelick (Feb 2020)
# --------------------------------------------------------

rm(list=ls())
#setwd("/home/fs02/pmr82_0001/dfg42/make_RDMs/DUreevaluation/")

rel = commandArgs(trailingOnly=TRUE)
RDM_folder = paste('updated_RDM_inflows_demands/RDM_',rel, sep="")

weeks_to_copy = c(0, 1, 364, 728, 1092, 
                  1456, 1768, 2132, 2496, 2860, 
                  3172, 3536, 3900, 4264, 4576, 4940) + 1

hist_inflow = c('../historical/claytonGageInflow.csv',
                '../historical/crabtreeCreekInflow.csv',
                '../historical/updatedFallsLakeInflow.csv',
                '../historical/updatedJordanLakeInflow.csv',
                '../historical/updatedLakeWBInflow.csv',
                '../historical/updatedLillingtonInflow.csv',
                '../historical/updatedLittleRiverRaleighInflow.csv',
                '../historical/updatedLittleRiverInflow.csv',
                '../historical/updatedMichieInflow.csv',
                '../historical/updatedOWASAInflow.csv')
syn_inflow = c(paste(RDM_folder, '/', 'synthetic_inflows/claytonGageInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/crabtreeCreekInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedFallsLakeInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedJordanLakeInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedLakeWBInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedLillingtonInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedLittleRiverRaleighInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedLittleRiverInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedMichieInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/updatedOWASAInflow.csv', sep=""))
out_names = c('clayton_inflows.csv',
              'crabtree_inflows.csv',
              'falls_lake_inflows.csv',
              'jordan_lake_inflows.csv',
              'lake_wb_inflows.csv',
              'lillington_inflows.csv',
              'little_river_raleigh_inflows.csv',
              'updatedLittleRiverInflow.csv',
              'updatedMichieInflow.csv',
              'updatedOWASAInflow.csv')

for (i in 1:length(hist_inflow)) {
  # read in data
  SI = as.matrix(read.csv(syn_inflow[i], header = FALSE))
  HI = read.csv(hist_inflow[i], header = FALSE)
  
  # get last 50 historical years
  HI_long = c(t(HI[32:81,]))
  
  # append to front of synthetic record
  SI_full = t(apply(SI,1,function(x) {c(HI_long,x)}))
  
  # add weeks to account for leap year issues?
  for (w in sort(weeks_to_copy, decreasing = TRUE)) {
    SI_full = cbind(SI_full[,1:w], SI_full[,w], SI_full[,(w+1):ncol(SI_full)])
  }
  
  # export
  write.table(SI_full, paste(RDM_folder, '/',"final_synthetic_inflows/", out_names[i], sep = ""), 
              col.names = FALSE, row.names = FALSE, sep = ",")
  
  # export other OWASA flows
  if (hist_inflow[i] == hist_inflow[10]) {
    write.table(SI_full*31.4, paste(RDM_folder, '/',"final_synthetic_inflows/cane_creek_inflows.csv", sep=""), 
                col.names = FALSE, row.names = FALSE, sep = ",")
    write.table(SI_full*28.7, paste(RDM_folder, '/',"final_synthetic_inflows/university_lake_inflows.csv", sep=""), 
                col.names = FALSE, row.names = FALSE, sep = ",")
    write.table(SI_full*1.2, paste(RDM_folder, '/', "final_synthetic_inflows/stone_quarry_inflows.csv", sep=""), 
                col.names = FALSE, row.names = FALSE, sep = ",")
  }
  

  # export full Durham flows
  if (hist_inflow[i] == hist_inflow[9]) {
    # read in data for Little River
    SI = as.matrix(read.csv(syn_inflow[i-1], header = FALSE))
    HI = read.csv(hist_inflow[i-1], header = FALSE)
    
    # get last 50 historical years
    HI_long = c(t(HI[32:81,]))
    
    # append to front of synthetic record
    SI_full_LR = t(apply(SI,1,function(x) {c(HI_long,x)}))
    
    # add weeks to account for leap year issues?
    for (w in sort(weeks_to_copy, decreasing = TRUE)) {
      SI_full_LR = cbind(SI_full_LR[,1:w], SI_full_LR[,w], SI_full_LR[,(w+1):ncol(SI_full_LR)])
    }
    write.table(SI_full+SI_full_LR, paste(RDM_folder, '/',"final_synthetic_inflows/durham_inflows.csv", sep=""), 
                col.names = FALSE, row.names = FALSE, sep = ",")
  }
}

# repeat process for evaporation
hist_evap= c('../historical/fallsLakeEvap.csv',
                '../historical/lakeWheelerBensonEvap.csv',
                '../historical/updatedEvap.csv')
syn_evap = c(paste(RDM_folder, '/','synthetic_inflows/evaporation/updatedOWASAInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/evaporation/updatedFallsLakeInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/evaporation/updatedJordanLakeInflow.csv', sep=""),
               paste(RDM_folder, '/','synthetic_inflows/evaporation/updatedLakeWBInflow.csv', sep=""))
out_names = c(paste(RDM_folder, '/','final_synthetic_inflows/evaporation/durham_evap.csv', sep=""),
              paste(RDM_folder, '/','final_synthetic_inflows/evaporation/falls_lake_evap.csv', sep=""),
              paste(RDM_folder, '/','final_synthetic_inflows/evaporation/little_river_raleigh_evap.csv', sep=""),
              paste(RDM_folder, '/','final_synthetic_inflows/evaporation/owasa_evap.csv', sep=""),
              paste(RDM_folder, '/','final_synthetic_inflows/evaporation/wb_evap.csv', sep=""))

syn_mapper = c(1,2,3,1,4) # connect proper synthetic and historic records
hist_mapper = c(3,1,1,3,2)
for (i in 1:length(out_names)) {
  # read in data
  #print(syn_mapper[i]); print(hist_mapper[i])
  SI = as.matrix(read.csv(syn_evap[syn_mapper[i]], header = FALSE))
  HI = read.csv(hist_evap[hist_mapper[i]], header = FALSE)
  
  # get last 50 historical years
  HI_long = c(t(HI[32:81,]))
  
  # append to front of synthetic record
  SI_full = t(apply(SI,1,function(x) {c(HI_long,x)}))
  
  # add weeks to account for leap year issues?
  for (w in sort(weeks_to_copy, decreasing = TRUE)) {
    SI_full = cbind(SI_full[,1:w], SI_full[,w], SI_full[,(w+1):ncol(SI_full)])
  }
  
  # export
  write.table(SI_full, out_names[i], 
              col.names = FALSE, row.names = FALSE, sep = ",")
}



#base_folder = "synthetic_demands"
#out_names = c('chatham_synthetic_demands_sinusoidal5000.csv',
#              'cary_synthetic_demands_sinusoidal5000.csv',
#              'durham_synthetic_demands_sinusoidal5000.csv',
#              'owasa_synthetic_demands_sinusoidal5000.csv',
#              'pittsboro_synthetic_demands_sinusoidal5000.csv',
#              'raleigh_synthetic_demands_sinusoidal5000.csv')
#write_names = c('chatham_synthetic_demands_sinusoidal.csv',
#              'cary_synthetic_demands_sinusoidal.csv',
#              'durham_synthetic_demands_sinusoidal.csv',
##              'owasa_synthetic_demands_sinusoidal.csv',
 #             'pittsboro_synthetic_demands_sinusoidal.csv',
#              'raleigh_synthetic_demands_sinusoidal.csv')
#i = 1
#for (site in out_names) {
#  I = read.csv(paste(base_folder, site, sep = "/"), header = FALSE)
#  for (set in 0:4) {
#    write.table(I[(1000*set+1):(1000*(set+1)),], paste(base_folder, "/g", set, "/", write_names[i], sep = ""), 
#                row.names = FALSE, col.names = FALSE, sep = ",")
#  }
#  i = i + 1
#}


