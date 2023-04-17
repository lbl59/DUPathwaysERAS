for REL in {1..1999}
do
	rm -r updated_RDM_inflows_demands/RDM_${REL}/synthetic_demand_variation_multiplier
	rm -r updated_RDM_inflows_demands/RDM_${REL}/inflow_demand_distributions
	rm -r updated_RDM_inflows_demands/RDM_${REL}/synthetic_inflows
done
