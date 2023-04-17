# c++ weekly demand calculation: 
# weeklyDemand = numdays*futureDemand[year-1]*(demandVariation[realization][week-1+ (year-1)*52]*UD.standardDeviations[week-1] + UD.averages[week-1]);
rm(list=ls())
setwd("/home/fs02/pmr82_0001/dfg42/make_RDMs/")
lowercase_utilities = c("raleigh", "cary", "durham", "owasa", "pittsboro", "chatham")
for (u in lowercase_utilities) {
  # read required data
  annual_demand_projection_MGD = as.matrix(read.csv(paste("annual_demand_projections_avgMGD/rdm_pwl/", u, 
                                                "_PWL_annual_demand_projections_MGD.csv", sep = ""), 
                                          header = FALSE))
  weekly_demand_variation = as.matrix(read.csv(paste("synthetic_demand_variation_multiplier/", u, 
                                               "_weekly_demand_variation.csv", sep = ""), 
                                               header = FALSE))
  weekly_means = c(t(read.csv(paste("weekly_unit_demands/", u, 
                                    "_weekly_unit_demand_means.csv", sep = ""), 
                              header = FALSE)))
  weekly_sds = c(t(read.csv(paste("weekly_unit_demands/", u, 
                                    "_weekly_unit_demand_sds.csv", sep = ""), 
                              header = FALSE)))
  
  # build the records
  weekly_synthetic_demand_realizations = matrix(NA, 
                                                nrow = nrow(weekly_demand_variation), 
                                                ncol = ncol(weekly_demand_variation))
  
  # include scaling of MGD up to MGW (multiply by 7)
  print(u); num_days_in_week = 7
  for (r in 1:nrow(weekly_demand_variation)) {
    #print(r)
    for (y in 0:(ncol(weekly_demand_variation)/52-1)) {
      for (w in 1:52) {
        weekly_synthetic_demand_realizations[r,(y*52+w)] = num_days_in_week * 
          annual_demand_projection_MGD[(y+1), r] * 
          (weekly_demand_variation[r,(y*52+w)] * weekly_sds[w] + weekly_means[w])
      }
    }
  }
  
  # write final sets
  write.table(weekly_synthetic_demand_realizations, paste("synthetic_demands_pwl/", u, 
                              "_synthetic_demands.csv", sep = ""), sep = ",",
              row.names = FALSE, col.names = FALSE)
}


