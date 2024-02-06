use "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\tender_data_with_population.dta", clear


drop _merge

// merge m:1 year buyer_nuts2 using "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\nuts2_id_light_data.dta"
//
// drop _merge
// drop MOUNT_TYPE
// drop URBN_TYPE
// drop COAST_TYPE

merge m:1 year buyer_nuts3 using "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\nuts3_id_light_data.dta"

drop _merge
merge m:1 buyer_nuts2 using "C:\Users\Ryu00006\Dropbox\european subsidies\data\regions-status-spain.dta"

save "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\tender_data_with_population.dta", replace