cd"C:\Users\Ryu00006\Dropbox\european subsidies\data"
*local dropboxdir "D:\Dropbox\european subsidies\data"

use "Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear

drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"
egen nuts2_id = group(buyer_nuts2)

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


preserve
collapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer change_after nuts2_id after2013, by(industry2 year buyer_id)


rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

gen sub_per_interaction = after2013*subsidy

eststo clear
eststo: reghdfe spending subsidy sub_per_interaction, absorb(procurere_time year_type2 type2_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace


//in period after 2013, the subsidy had a lower impact on spending although the p-value is 0.066



*** Model 2 *** 
*******************************************
*** shares ***
rename total_spending_type total_spending_type2

drop total_spending_type2 total_spending_type3 total_spending_type4
sort industry2 
by industry2: egen total_spending_type2 = total(robust_lot_estimated_price_eur)
sort industry3 
by industry3: egen total_spending_type3 = total(robust_lot_estimated_price_eur)
sort industry4 
by industry4: egen total_spending_type4 = total(robust_lot_estimated_price_eur)

sort buyer_id industry2
by buyer_id industry2: egen total_spending_type2_procurer = total(robust_lot_estimated_price_eur)
gen share_type2_procurer = total_spending_type2_procurer/total_spending_type2

sort buyer_id industry3
by buyer_id industry3: egen total_spending_type3_procurer = total(robust_lot_estimated_price_eur)
gen share_type3_procurer = total_spending_type3_procurer/total_spending_type3

sort buyer_id industry4
by buyer_id industry4: egen total_spending_type4_procurer = total(robust_lot_estimated_price_eur)
gen share_type4_procurer = total_spending_type4_procurer/total_spending_type4

gen l_cofunding_real = log(confunding_real)

*** 2 ***
preserve

collapse (sum) confunding confunding_real (mean) share_type2_procurer cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer after2013, by(industry2 year buyer_id)


rename share_type2_procurer share
rename confunding_real subsidy


gen sub_per_interaction = after2013*subsidy


eststo clear
eststo: reghdfe share subsidy, absorb(type2_procurer procurere_time year_type2)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace