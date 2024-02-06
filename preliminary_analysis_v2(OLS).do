cd "C:\Users\Ryu00006\Dropbox\european subsidies\data"
use "Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear

***************
*** gen FEs ***
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

// gen log_robust_lot_estimated_price =log(robust_lot_estimated_price_eur)
// replace confunding = cofinancing_rate*log_robust_lot_estimated_price
// replace confunding_real = cofinancing_rate_real*log_robust_lot_estimated_price


*** Model 1 *** 
*** 2 ***
preserve

collapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer change_after nuts2_id, by(industry2 year buyer_id)

keep if nuts2_id==2|nuts2_id==9|nuts2_id==15|nuts2_id==16|nuts2_id==11|nuts2_id==19|nuts2_id==7|nuts2_id==8

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

*reg robust_lot_estimated_price confunding ,r
eststo clear
eststo: reghdfe spending subsidy, absorb(procurere_time year_type2 type2_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace

//log
// gen log_robust_lot_estimated_price =log(robust_lot_estimated_price_eur)
// replace confunding = cofinancing_rate*log_robust_lot_estimated_price
// replace confunding_real = cofinancing_rate_real*log_robust_lot_estimated_price
// 
// collapse (sum) log_robust_lot_estimated_price confunding confunding_real (first) cofinancing_rate (mean) cofinancing_rate_expected procurere_time year_type2 type2_procurer change_after, by(industry2 year buyer_id)
//
// rename log_robust_lot_estimated_price spending
// rename confunding_real subsidy
//
// eststo clear
// eststo: reghdfe spending subsidy, absorb(procurere_time year_type2 type2_procurer) 
// estadd local yearindustry "Yes", replace
// estadd local authorityindustry "Yes", replace
// estadd local yearauthority "Yes", replace
// estadd local cpvdogits "2", replace




*reghdfe spending  (subsidy = rate_change), old absorb(procurere_time year_type2 type2_procurer) 
// reg spending change_after, r
//
// ivreg spending (subsidy = change_after)
// ivreghdfe spending (subsidy = change_after), absorb(year_type2 type2_procurer) 


restore

*** 3 ***
preserve

collapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) cofinancing_rate cofinancing_rate_expected procurere_time year_type3 type3_procurer change_after nuts2_id, by(industry3 year buyer_id)

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

keep if nuts2_id==2|nuts2_id==9|nuts2_id==15|nuts2_id==16|nuts2_id==11|nuts2_id==19|nuts2_id==7|nuts2_id==8

*reg robust_lot_estimated_price_eur confunding ,r
eststo: reghdfe spending subsidy, absorb(procurere_time year_type3 type3_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "3", replace


//log
// preserve
// gen log_robust_lot_estimated_price =log(robust_lot_estimated_price_eur)
// replace confunding = cofinancing_rate*log_robust_lot_estimated_price
// replace confunding_real = cofinancing_rate_real*log_robust_lot_estimated_price
//
// collapse (sum) log_robust_lot_estimated_price confunding confunding_real (first) cofinancing_rate (mean) cofinancing_rate_expected procurere_time year_type3 type3_procurer change_after, by(industry3 year buyer_id)
//
// rename log_robust_lot_estimated_price spending
// rename confunding_real subsidy
//
// eststo clear
// eststo: reghdfe spending subsidy, absorb(procurere_time year_type3 type3_procurer) 
// estadd local yearindustry "Yes", replace
// estadd local authorityindustry "Yes", replace
// estadd local yearauthority "Yes", replace
// estadd local cpvdogits "3", replace


restore

*** 4 ***
preserve

collapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) cofinancing_rate cofinancing_rate_expected procurere_time year_type4 type4_procurer change_after nuts2_id, by(industry4 year buyer_id)

// keep if nuts2_id==2|nuts2_id==9|nuts2_id==15|nuts2_id==16|nuts2_id==11|nuts2_id==19|nuts2_id==7|nuts2_id==8


rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

*reg robust_lot_estimated_price_eur confunding ,r
eststo: reghdfe spending subsidy, absorb(procurere_time year_type4 type4_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "4", replace

//log
preserve
gen log_robust_lot_estimated_price =log(robust_lot_estimated_price_eur)
replace confunding = cofinancing_rate*log_robust_lot_estimated_price
replace confunding_real = cofinancing_rate_real*log_robust_lot_estimated_price

collapse (sum) log_robust_lot_estimated_price confunding confunding_real (first) cofinancing_rate (mean) cofinancing_rate_expected procurere_time year_type4 type4_procurer change_after, by(industry4 year buyer_id)

rename log_robust_lot_estimated_price spending
rename confunding_real subsidy

eststo clear
eststo: reghdfe spending subsidy, absorb(procurere_time year_type4 type4_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "4", replace


restore


//OLS estimates
esttab, keep(subsidy) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearindustry authorityindustry yearauthority cpvdogits N, label("Year-type FE" "Local authority-type FE" "Year-local authority FE" "Detailedness of type" "N"  ))

*** In percentages
preserve

collapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by(industry2 year buyer_id)
gen l_robust_lot_estimated_price_eur = log(robust_lot_estimated_price_eur)
gen l_confunding_real = log(confunding_real)
reghdfe l_robust_lot_estimated_price_eur l_confunding_real, absorb(procurere_time year_type2 type2_procurer)

restore


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

collapse (sum) confunding confunding_real (mean) share_type2_procurer cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by(industry2 year buyer_id)

rename share_type2_procurer share
rename confunding_real subsidy

*reg share_type2_procurer confunding_real ,r
*reghdfe share_type2_procurer confunding_real, absorb(procurere_time year_type2 type2_procurer) 
* this one shows collinearity?
eststo clear
eststo: reghdfe share subsidy, absorb(type2_procurer procurere_time year_type2)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace

* reghdfe share_type2_procurer l_cofunding_real, absorb(type2_procurer procurere_time year_type2)
* not much here either

restore


*** 3 ***
preserve

collapse (sum) confunding confunding_real (mean) share_type3_procurer cofinancing_rate cofinancing_rate_expected procurere_time year_type3 type3_procurer, by(industry3 year buyer_id)

rename share_type3_procurer share
rename confunding_real subsidy

*reg share_type3_procurer confunding_real ,r
eststo: reghdfe share subsidy, absorb(type3_procurer procurere_time year_type3)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "3", replace

restore



*** 4 ***
preserve

collapse (sum) confunding confunding_real (mean) share_type4_procurer cofinancing_rate cofinancing_rate_expected procurere_time year_type4 type4_procurer, by(industry4 year buyer_id)

rename share_type4_procurer share
rename confunding_real subsidy

*reg share_type3_procurer confunding_real ,r
eststo: reghdfe share subsidy, absorb(type4_procurer procurere_time year_type4)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "4", replace

restore

esttab, keep(subsidy) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearindustry authorityindustry yearauthority cpvdogits N, label("Year-type FE" "Local authority-type FE" "Year-local authority FE" "Detailedness of type" "N"  ))


** log
preserve

collapse (sum) confunding confunding_real (mean) share_type2_procurer cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by(industry2 year buyer_id)


log, text replace
reghdfe share_type2_procurer confunding_real, absorb(procurere_time year_type2 type2_procurer) 
reghdfe share_type2_procurer confunding_real, absorb(type2_procurer procurere_time year_type2)
log close

restore