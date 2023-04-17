## Create Baseline Demand Projections for WaterPaths
##  D Gorelick (Jan 2020)
## -----------------------------------

rm(list=ls())
setwd("C:/Users/dgorelic/OneDrive - University of North Carolina at Chapel Hill/UNC/Research/WSC/Coding/WP/RealizationGeneration")
utilities = c("cary", "durham", "owasa", "raleigh", "pittsboro", "chatham")

## ----- demand scenarios ----------------------------------
# (a) as projected, using trwsp 2014 report (in MGDs) 
#     PITTSBORO BASED ON 2019 TOWN REPORT BY CDM SMITH AND SUPPLEMENTED WITH
#        CHATHAM COUNTY 2019 HAZEN + SAWYER REPORT AND ONLINE POWERBI
#     CHATHAM PROJECTIONS ALSO UPDATED BASED ON THIS TOOL
o_dem_proj = c(8.1,8.3,9.0,9.7,10.2,10.8,11.3,11.9,12.4,12.9)
d_dem_proj = c(28,30.7,32.4,34.2,36.1,38.1,40,41.9,43.1,44.4)
r_dem_proj = c(58.2,64.4,71.3,78.2,84.8,91.3,97,102.7,108.9,115)
c_dem_proj = c(20.9,25,28.8,31.9,34.8,37.3,39.2,40.8,41.2,41.4) # cary is cary + apex 
mw_dem_proj = c(2.0,2.5,2.8,2.9,3.3,3.4,3.5,3.5,3.6,3.6) # morrisville demands only
p_dem_proj = c(0.53,1.06,1.39,1.74,2.2,2.56,3.25,3.65,4.98,5.58) # just pittsboro, projections in 2019 revised heavily downwards relative to 2014
ch_dem_proj = c(2.05,2.1,2.16,2.23,2.29,2.35,2.41,2.48,2.54,2.6) # just chatham county, very low relative to 2014 assumptions, like Pittsboro

# JUNE 2020: CORRECTED SO THAT CARY DEMAND IS CARY + APEX + MORRISVILLE
# BUT NOT RTP, AS IT WAS BEFORE
c_dem_proj = (c_dem_proj + mw_dem_proj)

# ----- project demands annually ---------------------------
# projections given in same order as utilities vector above
# (cary, durham, owasa, raleigh, pittsboro, chatham)
u_sets = matrix(NA, nrow = 6, ncol = 60)
DAYS_IN_WEEK = 7
i = 1
for (period in 1:9) {
  u_sets[1,i:(i+5)] = seq(c_dem_proj[period], c_dem_proj[period+1], 
                          length.out = 6)
  u_sets[2,i:(i+5)] = seq(d_dem_proj[period], d_dem_proj[period+1], 
                          length.out = 6)
  u_sets[3,i:(i+5)] = seq(o_dem_proj[period], o_dem_proj[period+1], 
                          length.out = 6)
  u_sets[4,i:(i+5)] = seq(r_dem_proj[period], r_dem_proj[period+1], 
                          length.out = 6)
  u_sets[5,i:(i+5)] = seq(p_dem_proj[period], p_dem_proj[period+1], 
                          length.out = 6)
  u_sets[6,i:(i+5)] = seq(ch_dem_proj[period], ch_dem_proj[period+1], 
                          length.out = 6)
  i = i + 5
}

# projections are extended 10+ years beyond 2060 for modeling 
# by linear extrapolation of last 5 years of TRWSP projections
for (period in 10) {
  u_sets[1,i:ncol(u_sets)] = seq(c_dem_proj[period], (c_dem_proj[period]-c_dem_proj[period-1])+c_dem_proj[period], 
                          length.out = length(i:ncol(u_sets)))
  u_sets[2,i:ncol(u_sets)] = seq(d_dem_proj[period], (d_dem_proj[period]-d_dem_proj[period-1])+d_dem_proj[period], 
                          length.out = length(i:ncol(u_sets)))
  u_sets[3,i:ncol(u_sets)] = seq(o_dem_proj[period], (o_dem_proj[period]-o_dem_proj[period-1])+o_dem_proj[period], 
                          length.out = length(i:ncol(u_sets)))
  u_sets[4,i:ncol(u_sets)] = seq(r_dem_proj[period], (r_dem_proj[period]-r_dem_proj[period-1])+r_dem_proj[period], 
                          length.out = length(i:ncol(u_sets)))
  u_sets[5,i:ncol(u_sets)] = seq(p_dem_proj[period], (p_dem_proj[period]-p_dem_proj[period-1])+p_dem_proj[period], 
                          length.out = length(i:ncol(u_sets)))
  u_sets[6,i:ncol(u_sets)] = seq(ch_dem_proj[period], (ch_dem_proj[period]-ch_dem_proj[period-1])+ch_dem_proj[period], 
                          length.out = length(i:ncol(u_sets)))
  i = i + 5
}

# THESE ARE 60 YEARS LONG, 14 MORE YEARS THAN 46 (2015-2060)
# LAST 14 YEARS ARE JUST LINEAR EXTRAPOLATION OF GROWTH BETWEEN 2055-2060
for (u in 1:6) {
  write.table(u_sets[u,], paste("annual_demand_projections_avgMGD/", utilities[u], 
                                "_annual_demand_projections_MGD.csv", sep = ""), 
              row.names = FALSE, col.names = FALSE, sep = ",")
}

# do a set that has units of MGW rather than MGD
u_sets = u_sets * DAYS_IN_WEEK

# THESE ARE 60 YEARS LONG, 14 MORE YEARS THAN 46 (2015-2060)
# LAST 14 YEARS ARE JUST LINEAR EXTRAPOLATION OF GROWTH BETWEEN 2055-2060
for (u in 1:6) {
  write.table(u_sets[u,], paste("annual_demand_projections_avgMGD/", utilities[u], 
                                "_annual_demand_projections_MGW.csv", sep = ""), 
              row.names = FALSE, col.names = FALSE, sep = ",")
}

