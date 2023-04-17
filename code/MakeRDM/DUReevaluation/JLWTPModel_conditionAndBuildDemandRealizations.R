## Condition and Construct Demand Realizations for WaterPaths
##  D Gorelick (Jan 2020)
## -----------------------------------
## Extended by D. Gold (Nov 2021) to create DU samples

# realization number to be read from command line call (for parallel, this will be sent to command line from Python)
rel = commandArgs(trailingOnly=TRUE)

#rm(list=ls())
#setwd("/home/fs02/pmr82_0001/dfg42/make_RDMs/DUreevaluation/")
utilities = c("cary", "durham", "owasa", "raleigh", "pittsboro", "chatham")
sources   = c("updatedJordanLakeInflow", # cary (and chatham/pittsboro)
              "updatedMichieInflow", "updatedLittleRiverInflow", # durham
              "updatedOWASAInflow", # owasa
              "updatedFallsLakeInflow", "updatedLakeWBInflow", "updatedLittleRiverRaleighInflow", "crabtreeCreekInflow", # raleigh
              "updatedLillingtonInflow", "claytonGageInflow") # flow gages
evaps     = c("fallsLakeEvap", "lakeWheelerBensonEvap", "updatedEvap")

### ------- read utility/inflow data and assign to arrays for looping later --------
# for utilities without data, use neighbor data
n_weeks = 52; n_years_demand = 18; n_years_inflows = 81
raw_unit_demands = list(); raw_inflows = list(); raw_evap = list()

unit_demand_utilities = c("Cary", "Durham", "OWASA", "Raleigh")
for (i in 1:length(unit_demand_utilities)) {
  raw_unit_demands[[i]] = read.csv(paste("../weekly_unit_demands/", "updated", 
                                         unit_demand_utilities[i], 
                                         "UnitDemand.csv", sep = ""), 
                                   header = FALSE)
}

for (i in 1:length(sources)) {
  raw_inflows[[i]] = read.csv(paste("../historical/", sources[i], 
                                    ".csv", sep = ""), 
                              header = FALSE)
}

for (i in 1:length(evaps)) {
  raw_evap[[i]] = read.csv(paste("../historical/", evaps[i], 
                                    ".csv", sep = ""), 
                              header = FALSE)
}

### ----------- normalize  demand data ---------------------------
# THIS DOES NOT INCLUDE ADJUSTMENTS FOR RDM LIKE MULTIPLIERS ON UNIT DEMANDS
# OR GROWTH RATE
# this is a seasonal normalization for demand and streamflow

# remove average and sd from unit demand data seasonally
normalized_demand = list()
for (i in 1:length(unit_demand_utilities)) {
  if (unit_demand_utilities[i] == "Raleigh") {next} # raleigh has only 1 year of data, use Cary SD
  normalized_demand[[i]] = (raw_unit_demands[[i]] - rowMeans(raw_unit_demands[[i]])) / 
    apply(raw_unit_demands[[i]], MARGIN = 1, sd)
}

# log transform inflow data and combine Durham inflow sources
log_inflow = list()
log_inflow[[1]] = log(raw_inflows[[1]])
log_inflow[[2]] = log(raw_inflows[[2]] + raw_inflows[[3]]) # durham sources
for (i in 4:length(sources)) {
    log_inflow[[i-1]] = log(raw_inflows[[i]])
}

# update source names when Durham inflows are combined
sources   = c("updatedJordanLakeInflow", # cary (and chatham/pittsboro)
              "durhamInflow", # durham
              "updatedOWASAInflow", # owasa
              "updatedFallsLakeInflow", "updatedLakeWBInflow", "updatedLittleRiverRaleighInflow", "crabtreeCreekInflow", # raleigh
              "updatedLillingtonInflow", "claytonGageInflow") # flow gages

# normalize log inflows to match demand sets
normalized_log_inlfow = list(); normalized_log_inlfow_adjusted = list()

# hold other normalization stats for later
log_flow_weekly_means = array(NA, dim = c(n_weeks, length(sources)))
log_flow_weekly_sds = array(NA, dim = c(n_weeks, length(sources)))
log_flow_weekly_means_short = array(NA, dim = c(n_weeks, length(sources)))
log_flow_weekly_sds_short = array(NA, dim = c(n_weeks, length(sources)))

inflow_rows_to_match = n_years_inflows - n_years_demand + 1
for (i in 1:length(sources)) {
  # full record vs short one
  log_flow_source = t(log_inflow[[i]])
  log_flow_source_short = t(log_inflow[[i]][inflow_rows_to_match:nrow(log_inflow[[i]]),])
  
  # full record stats
  log_flow_weekly_means[,i] = as.numeric(as.character(rowMeans(log_flow_source)))
  log_flow_weekly_sds[,i] = as.numeric(as.character(apply(log_flow_source, MARGIN = 1, sd)))
  
  # short record stats
  log_flow_weekly_means_short[,i] = as.numeric(as.character(rowMeans(log_flow_source_short)))
  log_flow_weekly_sds_short[,i] = as.numeric(as.character(apply(log_flow_source_short, MARGIN = 1, sd)))
  
  # full record
  normalized_log_inlfow[[i]] = (log_flow_source - rowMeans(log_flow_source)) / 
    apply(log_flow_source, MARGIN = 1, sd)
  
  # adjusted record
  normalized_log_inlfow_adjusted[[i]] = (log_flow_source - rowMeans(log_flow_source_short)) / 
    apply(log_flow_source_short, MARGIN = 1, sd)
}

### --------- build PDF between inflow and demand ----------
# use normalized demand data crossed with inflows for cary, durham, owasa
n_weeks_irrigated = 23; non_irrig_season_1 = 16; non_irrig_season_2 = 13
pdf_rows = 16; pdf_cols = 17
full_data_utilities = c("cary", "durham", "owasa")
for (u in 1:length(full_data_utilities)) {
  # initialize data structures
  InflowsIrrigation = array(NA, dim = c(n_years_inflows, n_weeks_irrigated))
  DemandsIrrigation = array(NA, dim = c(n_years_demand, n_weeks_irrigated))
  InflowsNonIrrigation = array(NA, dim = c(n_years_inflows, non_irrig_season_1 + non_irrig_season_2))
  DemandsNonIrrigation = array(NA, dim = c(n_years_demand, non_irrig_season_1 + non_irrig_season_2))
  InflowDemandPDFirr = array(0, dim = c(pdf_rows, pdf_cols))
  InflowDemandPDFnonirr = array(0, dim = c(pdf_rows, pdf_cols))
  InflowDemandCDFirr = array(0, dim = c(pdf_rows, pdf_cols))
  InflowDemandCDFnonirr = array(0, dim = c(pdf_rows, pdf_cols))
  
  # fill inflow and demand structures, irrigation season
  # MAKE SURE THAT FIRST THREE ELEMENTS OF normalized_log_inlfow_adjusted ARE CARY, DURHAM, OWASA
  for (j in 1:n_weeks_irrigated) {
    for (i in 1:n_years_inflows) {InflowsIrrigation[i,j] = t(normalized_log_inlfow_adjusted[[u]])[i,j+16]}
    for (i in 1:n_years_demand) {DemandsIrrigation[i,j] = t(normalized_demand[[u]])[i,j+16]}
  }
  
  # non irrigation season, weeks 1 to 16 of the year and weeks 39 to 52
  for (j in 1:non_irrig_season_1) {
    for (i in 1:n_years_inflows) {InflowsNonIrrigation[i,j] = t(normalized_log_inlfow_adjusted[[u]])[i,j]}
    for (i in 1:n_years_demand) {DemandsNonIrrigation[i,j] = t(normalized_demand[[u]])[i,j]}
  }
  
  for (j in 1:non_irrig_season_2) {
    for (i in 1:n_years_inflows) {InflowsNonIrrigation[i,j+16] = t(normalized_log_inlfow_adjusted[[u]])[i,j+39]}
    for (i in 1:n_years_demand) {DemandsNonIrrigation[i,j+16] = t(normalized_demand[[u]])[i,j+39]}
  }
  
  # convert 2d inflow/demand tables to 1d
  # 2d matrices with years (rows) by weeks of year (columns) converted to 1d timeseries
  # that progress across each year (column) before moving up in year
  I_Irrig = c(t(InflowsIrrigation[(n_years_inflows-n_years_demand+1):n_years_inflows,1:n_weeks_irrigated]))
  D_Irrig = c(t(DemandsIrrigation))
  I_nonIrrig = c(t(InflowsNonIrrigation[(n_years_inflows-n_years_demand+1):n_years_inflows,]))
  D_nonIrrig = c(t(DemandsNonIrrigation))

  # make demand-inflow PDFs
  # rows_PDF = 16, cols_PDF = 17, size1 = size2 = 16
  size1 = 16; size2 = 16
  y_vector = seq((-1.0*(size1/4.0) + 0.5),((size1/4.0)+0.4), 0.5) # should be 16 elements?
  z_vector = seq((-1.0*(size2/4.0) + 0.5),((size2/4.0)+0.4), 0.5)
  
  # once for irrigation season
  for (i in 1:length(I_Irrig)) { # same as length of D_Irrig
    ycount = 0
    for (y in y_vector) {
      if (I_Irrig[i] < y & I_Irrig[i] >= y-0.5) { # locate bin for residual value
        zcount = 0
        for (z in z_vector) {
          if (D_Irrig[i] < z & D_Irrig[i] >= z-0.5) {
            InflowDemandPDFirr[ycount,zcount] = InflowDemandPDFirr[ycount,zcount] + 1
            InflowDemandPDFirr[ycount,size2+1]  = InflowDemandPDFirr[ycount,size2+1] + 1
          }
          zcount = zcount + 1
        }
      }
      ycount = ycount + 1
    }
  }
  
  # once for non-irrigation
  for (i in 1:length(I_nonIrrig)) { # same as length of D_nonIrrig
    ycount = 0
    for (y in y_vector) {
      if (I_nonIrrig[i] < y & I_nonIrrig[i] >= y-0.5) { # locate bin for residual value
        zcount = 0
        for (z in z_vector) {
          if (D_nonIrrig[i] < z & D_nonIrrig[i] >= z-0.5) {
            InflowDemandPDFnonirr[ycount,zcount]  = InflowDemandPDFnonirr[ycount,zcount] + 1
            InflowDemandPDFnonirr[ycount,size2+1] = InflowDemandPDFnonirr[ycount,size2+1] + 1
          }
          zcount = zcount + 1
        }
      }
      ycount = ycount + 1
    }
  }
  
  # calculate cumulative sums (CDFs) of the PDFs
  # double counting last column here??
  InflowDemandCDFirr = t(apply(InflowDemandPDFirr[,1:17], MARGIN = 1, cumsum))
  InflowDemandCDFnonirr = t(apply(InflowDemandPDFnonirr[,1:17], MARGIN = 1, cumsum))

  # output PDFs and CDFs
  write.table(InflowDemandPDFirr, sep = ",",
            paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", full_data_utilities[u], "_PDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
  write.table(InflowDemandPDFnonirr, sep = ",",
            paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", full_data_utilities[u], 
                  "_PDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
  write.table(InflowDemandCDFirr, sep = ",", 
           paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", full_data_utilities[u], 
                  "_CDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
  write.table(InflowDemandCDFnonirr, sep = ",", 
            paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", full_data_utilities[u], 
                  "_CDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
  
  # raleigh PDF/CDF set equal to Durham's
  if (full_data_utilities[u] == "durham") {
    write.table(InflowDemandPDFirr, sep = ",",
                paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", "raleigh",
                      "_PDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandPDFnonirr, sep = ",",
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "raleigh", 
                      "_PDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandCDFirr, sep = ",", 
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "raleigh", 
                      "_CDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandCDFnonirr, sep = ",", 
                paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", "raleigh", 
                      "_CDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
  }
  
  # pittsboro and chatham's set equal to Cary's because of Jordan Lake inflow importance
  if (full_data_utilities[u] == "cary") {
    write.table(InflowDemandPDFirr, sep = ",",
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "pittsboro",
                      "_PDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandPDFnonirr, sep = ",",
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "pittsboro", 
                      "_PDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandCDFirr, sep = ",", 
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "pittsboro", 
                      "_CDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandCDFnonirr, sep = ",", 
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "pittsboro", 
                      "_CDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    
    write.table(InflowDemandPDFirr, sep = ",",
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "chatham",
                      "_PDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandPDFnonirr, sep = ",",
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "chatham", 
                      "_PDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandCDFirr, sep = ",", 
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "chatham", 
                      "_CDF_irr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
    write.table(InflowDemandCDFnonirr, sep = ",", 
                paste("updated_RDM_inflows_demands/RDM_", rel,"/inflow_demand_distributions/", "chatham", 
                      "_CDF_nonirr.csv", sep = ""), row.names = FALSE, col.names = FALSE)
  }
}


### ---------- apply historical record statistics to synthetic records -----------
# normalize synthetic records accordingly, Raleigh is special case for last
# handle Pittsboro and Chatham separately also, using OWASA records
# result of this routine below is a list of three arrays containing all whitened
# realizations for each of three utilities with full demand data (cary, durham, owasa)
#rm(list=ls()) # clear memory from here
#setwd("/home/fs02/pmr82_0001/dfg42/make_RDMs/DUreevaluation/")
synthetic_record_inflows = c("updatedJordanLakeInflow", #cary
                             "updatedMichieInflow", "updatedLittleRiverInflow", #durham
                             "updatedOWASAInflow") #owasa

# read in data built in previous section of code of means and sds
log_means = read.table(paste("../historical/", "log_weekly_means.csv", sep = ""), 
                       sep = ",", header = TRUE)
log_sds   = read.table(paste("../historical/", "log_weekly_sds.csv", sep = ""), 
                       sep = ",", header = TRUE)

# also read in synthetic flows
inflows = list()
for (i in 1:length(synthetic_record_inflows)) {
  inflows[[i]] = read.csv(paste("updated_RDM_inflows_demands/RDM_", rel, "/synthetic_inflows/", synthetic_record_inflows[i], ".csv", sep = ""), 
                          header = FALSE)
}
relevant_inflows = list()
relevant_inflows[[1]] = inflows[[1]]
relevant_inflows[[2]] = inflows[[2]] + inflows [[3]] # combine durham flows
relevant_inflows[[3]] = inflows[[4]]
rm(inflows, i, synthetic_record_inflows)

# finally, read in cdfs
utilities = c("cary", "durham", "owasa", "raleigh", "pittsboro", "chatham")
utility_cdfs_irr = list(); utility_cdfs_nonirr = list()
utility_pdfs_irr = list(); utility_pdfs_nonirr = list()
for (u in 1:length(utilities)) {
  utility_cdfs_irr[[u]] = as.matrix(read.table(paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", utilities[u], 
                                    "_CDF_irr.csv", sep = ""), sep = ",", header = FALSE))
  utility_cdfs_nonirr[[u]] = as.matrix(read.table(paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", utilities[u], 
                                    "_CDF_nonirr.csv", sep = ""), sep = ",", header = FALSE))
  utility_pdfs_irr[[u]] = as.matrix(read.table(paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", utilities[u], 
                                    "_PDF_irr.csv", sep = ""), sep = ",", header = FALSE))
  utility_pdfs_nonirr[[u]] = as.matrix(read.table(paste("updated_RDM_inflows_demands/RDM_", rel, "/inflow_demand_distributions/", utilities[u], 
                                    "_PDF_nonirr.csv", sep = ""), sep = ",", header = FALSE))
}
rm(u)

# whiten synthetic records based on historical statistics
whitened_inflow_records = list()
for (i in 1:length(relevant_inflows)) {
  whitened_set = array(NA, dim = c(nrow(relevant_inflows[[i]]), ncol(relevant_inflows[[i]])))
  for (r in 1:nrow(relevant_inflows[[i]])) {
    cw = 1
    for (w in 1:ncol(relevant_inflows[[i]])) {
      whitened_set[r,w] = (log(relevant_inflows[[i]][r,w]) - 
                           log_means[cw,i]) / log_sds[cw,i]
      
      # cycle seasonal signal
      if (cw == 52) {cw = 1} else {cw = cw + 1}
    }
  }
  whitened_inflow_records[[i]] = whitened_set
}
rm(cw, i, r, w, whitened_set, relevant_inflows)

# get weekly demand variation based on inflow residual
time_period_years = 47 # length of simulated period plus two years at end

# links utility to it's closest inflow source match
# options:
# 1: Jordan Lake (Haw Inflows) - use for Cary, Pittsboro, Chatham
# 2: Durham Inflows (Michie/Little River) - use for Durham, Raleigh
# 3: OWASA Inflows - use for OWASA
utility_to_source_match = c(1,2,3,2,1,1) 
pdf_rows = 16; pdf_cols = 17
demandVariation = list(); truePDFs = list()
for (u in 1:length(utilities)) { 
  
  demVar_u = matrix(0, 
                    nrow = nrow(whitened_inflow_records[[utility_to_source_match[u]]]),
                    ncol = ncol(whitened_inflow_records[[utility_to_source_match[u]]]))
  truePDF = array(0, dim = c(pdf_rows, pdf_cols))
  for (r in 1:nrow(whitened_inflow_records[[utility_to_source_match[u]]])) {
    #print(r)
    for (y in 0:time_period_years) {
      for (w in 1:52) { # weeks in a year
        # find index for current flow in PDF
        flow_residual = whitened_inflow_records[[utility_to_source_match[u]]][r,(y*52+w)]
        trigger = FALSE; cnt = 0
        while (!trigger) {
          cnt = cnt + 1
          if (flow_residual < (cnt/2-3.5)) {trigger = TRUE}
          if (cnt > 16) {cnt = 16; break} # only 15 tiers to PDF
        }
        
        # assign to irr/non-irr PDF based on time of year
        # ------------------------------------------------------
        # ------------------------------------------------------
        # NOTE: it appears that the code to create the CDFs
        # doubles bin counts in final column used to give full
        # distribution, so all bin counts in that column read 
        # back here are divided by two
        # ------------------------------------------------------
        # ------------------------------------------------------
        if (w > 16 & w < 39) {
          flows_in_bin = as.numeric(utility_pdfs_irr[[u]][cnt,17]/2 - 1)
        } else {
          flows_in_bin = as.numeric(utility_pdfs_nonirr[[u]][cnt,17]/2 - 1)
        }
        
        # check for outliers, then set demand variation multiplier
        if (flows_in_bin < 0) {demandLevel = 4} else {
          if (flows_in_bin == 0) {demandLevel = 1}
          if (flows_in_bin == 0.5) {flows_in_bin = 1}
          
          # locate demand level greater than random number
          randDemand = runif(1, min = 0, max = flows_in_bin) + 1; cnt2 = 1
          if (w > 16 & w < 39) {
            while (as.numeric(utility_cdfs_irr[[u]][cnt,cnt2]) < randDemand) {cnt2 = cnt2 + 1}
          } else {
            while (as.numeric(utility_cdfs_nonirr[[u]][cnt,cnt2]) < randDemand) {cnt2 = cnt2 + 1}
          }
          
          # set final demand level from the PDF
          demandLevel = cnt2
          if (demandLevel > 16) {demandLevel = 16}
        }
        
        # what is the demand variation in every week?
        # previous version had the adjustment (demandLevel - 8) but
        # here I have -7 because of difference in indexing between C++ and R
        # translation meaning PDF is centered lower
        demVar_u[r,(y*52+w)] = (demandLevel - 7)/2 + runif(1, min = 0, max = 501)/1000
        if (w > 16 & w < 39) {
          truePDF[cnt,cnt2] = truePDF[cnt,cnt2] + 1
          truePDF[cnt,17] = truePDF[cnt,17] + 1
        }
      }
    }
  }
  # hold list of final stuff
  demandVariation[[u]] = demVar_u
  truePDFs[[u]] = truePDF
  
  # write each file for use later

  write.table(demVar_u, sep = ",", 
              paste("updated_RDM_inflows_demands/RDM_", rel, "/synthetic_demand_variation_multiplier/", utilities[u], 
                    "_weekly_demand_variation.csv", sep = ""), 
              row.names = FALSE, col.names = FALSE)
  
  write.table(truePDF, sep = ",", 
              paste("updated_RDM_inflows_demands/RDM_", rel, "/synthetic_demand_variation_multiplier/", utilities[u], 
                    "_full_synthetic_weekly_demand_PDF.csv", sep = ""), 
              row.names = FALSE, col.names = FALSE)
}


### ----------- build full demand timeseries --------------
# take annual projections, utility seasonality multipliers,
# and inflow-demand pdf demand variation factors
# to construct matching demand realizations for inflows
# for Raleigh, use unit demand "averages" of single year, Durham std deviations
# for Pittsboro/Chatham, use OWASA data
#rm(list=ls())
#setwd("/home/fs02/pmr82_0001/dfg42/make_RDMs/DUreevaluation/")
lowercase_utilities = c("raleigh", "cary", "durham", "owasa", "pittsboro", "chatham")
uppercase_utilities = c("Raleigh", "Cary", "Durham", "OWASA")


# c++ weekly demand calculation: 
# weeklyDemand = numdays*futureDemand[year-1]*(demandVariation[realization][week-1+ (year-1)*52]*UD.standardDeviations[week-1] + UD.averages[week-1]);
#rm(list=ls())
#setwd("/home/fs02/pmr82_0001/dfg42/make_RDMs/DUreevaluation/")
lowercase_utilities = c("raleigh", "cary", "durham", "owasa", "pittsboro", "chatham")
for (u in lowercase_utilities) {
  # read required data
  annual_demand_projection_MGD = as.matrix(read.csv(paste("annual_demand_projections_avgMGD/rdm_pwl/", u, 
                                                "_PWL_annual_demand_projections_MGD.csv", sep = ""), 
                                          header = FALSE))
  weekly_demand_variation = as.matrix(read.csv(paste("updated_RDM_inflows_demands/RDM_", rel, "/synthetic_demand_variation_multiplier/", u, 
                                               "_weekly_demand_variation.csv", sep = ""), 
                                               header = FALSE))
  weekly_means = c(t(read.csv(paste("../weekly_unit_demands/", u, 
                                    "_weekly_unit_demand_means.csv", sep = ""), 
                              header = FALSE)))
  weekly_sds = c(t(read.csv(paste("../weekly_unit_demands/", u, 
                                    "_weekly_unit_demand_sds.csv", sep = ""), 
                              header = FALSE)))
  
  # build the records
  weekly_synthetic_demand_realizations = matrix(NA, 
                                                nrow = nrow(weekly_demand_variation), 
                                                ncol = ncol(weekly_demand_variation))

  realization_demand_projection_MGD = annual_demand_projection_MGD[,strtoi(rel)]


  # include scaling of MGD up to MGW (multiply by 7)
  num_days_in_week = 7
  for (j in 1:nrow(weekly_demand_variation)) {
    #print(r)
    for (y in 0:(ncol(weekly_demand_variation)/52-1)) {
      for (w in 1:52) {
        weekly_synthetic_demand_realizations[j,(y*52+w)] = num_days_in_week * 
          realization_demand_projection_MGD[(y+1)] * 
          (weekly_demand_variation[j,(y*52+w)] * weekly_sds[w] + weekly_means[w])
      }
    }
  }
  
  # write final sets
  write.table(weekly_synthetic_demand_realizations, paste("updated_RDM_inflows_demands/RDM_", rel, "/synthetic_demands_pwl/", u, 
                              "_synthetic_demands.csv", sep = ""), sep = ",",
              row.names = FALSE, col.names = FALSE)
}












