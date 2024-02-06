/*
local dir "C:\Users\Ryu00006\Dropbox\european subsidies"
local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies\data"

use "`dropboxdir'\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear

egen industry_one = group(cpv_category)

cd "`dir'"

egen nuts2_id = group(buyer_nuts2)

drop _merge


merge m:1 nuts2_id year using "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\population.dta" 

drop _merge

merge m:1 industry_one using "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\category_en.dta"

save "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\tender_data_with_population.dta", replace
*/


use "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\tender_data_with_population.dta", clear
drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"


egen procurere_time = group(buyer_id year)
egen year_type2 = group(year industry2)
egen year_type3 = group(year industry3)
egen year_type4 = group(year industry4)
egen type2_procurer = group(industry2 buyer_id)
egen type3_procurer = group(industry3 buyer_id)
egen type4_procurer = group(industry4 buyer_id)

gen confunding = cofinancing_rate*robust_lot_estimated_price_eur
gen cofinancing_rate_real = cofinancing_rate
replace cofinancing_rate_real = 0 if cofinancing_rate==.
gen confunding_real = cofinancing_rate_real*robust_lot_estimated_price_eur

gen change_after = 0
replace change_after = 1 if rate_change==1 & after2013==1

collapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer change_after nuts2_id population, by(industry2 year buyer_id)

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

eststo clear
eststo: reghdfe spending population subsidy, absorb(procurere_time year_type2 type2_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace




collapse (sum) subsidy (mean) population, by (year nuts2_id)
drop if year==2006
drop if year==2007

gen sub_per_cap = subsidy/population
twoway (line sub_per_cap year), by(nuts2_id)


egen n_region_year = count(one), by(year nuts2_id)
egen sub_n_region_year = count(one) if eu_funded==1, by(year nuts2_id)
preserve
collapse (sum) eu_subsidy (mean) population sub_n_region_year, by (year nuts2_id)
drop if year==2006
drop if year==2007
gen sub_per_cap = eu_subsidy/population

twoway (line sub_per_cap year), by(nuts2_id)
twoway (line n_region_year year), by(nuts2_id)
twoway (line eu_subsidy year), by(nuts2_id)