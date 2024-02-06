cd"C:\Users\Ryu00006\Dropbox\european subsidies\data"
*local dropboxdir "D:\Dropbox\european subsidies\data"

use "Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear

***************
*** gen FEs ***
drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"
egen nuts2_id = group(buyer_nuts2)

gegen industry1 = group(cpv_category)
gegen procurere_time = group(buyer_id year)
gegen year_type2 = group(year industry2)
gegen year_type3 = group(year industry3)
gegen year_type4 = group(year industry4)
gegen type2_procurer = group(industry2 buyer_id)
gegen type3_procurer = group(industry3 buyer_id)
gegen type4_procurer = group(industry4 buyer_id)

gen confunding = cofinancing_rate*robust_lot_estimated_price_eur
gen cofinancing_rate_real = cofinancing_rate
replace cofinancing_rate_real = 0 if cofinancing_rate==.
gen confunding_real = cofinancing_rate_real*robust_lot_estimated_price_eur


// gen log_robust_lot_estimated_price =log(robust_lot_estimated_price_eur)
// replace confunding = cofinancing_rate*log_robust_lot_estimated_price
// replace confunding_real = cofinancing_rate_real*log_robust_lot_estimated_price


//
// preserve
// gcollapse (sum) confunding_real, by (nuts2_id year industry2)
// rename confunding_real total_subsidy_nuts2
// save "total_subsidy_nuts2.dta", replace
// restore
//
//
// preserve
// gcollapse (sum) robust_lot_estimated_price_eur, by (nuts2_id year industry2)
// rename robust_lot_estimated_price_eur total_spending_nuts2
// save "total_spending_nuts2.dta", replace
// restore


*** CPV 2 pro IV
*** CPV 4 pak

// eststo clear

*** 2 ***
preserve
// preserve
// bysort nuts2_id year industry2: egen total_subsidy2 = total(confunding_real)
// bysort nuts2_id year industry2: egen total_spending2 = total(robust_lot_estimated_price_eur)
// gcollapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer total_subsidy2 total_spending2, by(industry2 year buyer_id)
// rename robust_lot_estimated_price_eur spending
// rename confunding_real subsidy
// bysort buyer_id: egen buyer_size=sum(spending )
// eststo model_noweights1: ivreghdfe spending (subsidy = total_subsidy_nuts2), absorb(year_type2 type2_procurer) 
// estadd local yearindustry "Yes", replace
// estadd local authorityindustry "Yes", replace
// estadd local yearauthority "Yes", replace
// estadd local cpvdogits "2", replace
// restore


gcollapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by(industry2 year buyer_id)

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

*drop if nuts2_id == 7.75
*drop if nuts2_id ==10.5 
*drop if nuts2_id > 11 & nuts2_id < 12
*drop if nuts2_id == 12.5
*drop if total_subsidy_nuts2==0
bysort buyer_id: egen buyer_size=sum(spending)

merge m:1 nuts2_id industry2 year using "total_subsidy_nuts2.dta"
// join, by(nuts2_id industry2 year) from("total_subsidy_nuts2.dta")

drop _merge
merge m:1 nuts2_id industry2 year using "total_spending_nuts2.dta"
// join, by(nuts2_id industry2 year) from("total_spending_nuts2.dta")

// eststo clear
// eststo: reghdfe subsidy  total_subsidy_nuts2, absorb(year_type2 type2_procurer) 
//
*** IV Regression - CPV2

// ivreghdfe spending (subsidy = total_subsidy_nuts2)
eststo clear
eststo model_noweights1: ivreghdfe spending (subsidy = total_subsidy_nuts2), absorb(year_type2 type2_procurer)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace



// gcollapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by(industry2 year buyer_id)
//
// rename robust_lot_estimated_price_eur spending
// rename confunding_real subsidy
//
// bysort buyer_id: egen buyer_size=sum(spending)
//
// merge m:1 nuts2_id industry2 year using "total_subsidy_nuts2.dta"
//
// drop _merge
// merge m:1 nuts2_id industry2 year using "total_spending_nuts2.dta"
//
// eststo model_noweights1: ivreghdfe spending (subsidy = total_subsidy_nuts2), absorb(year_type2 type2_procurer) 
// estadd local yearindustry "Yes", replace
// estadd local authorityindustry "Yes", replace
// estadd local yearauthority "Yes", replace
// estadd local cpvdogits "2", replace























*** the same with weights according to buyer_size

//  ivreghdfe spending (subsidy = total_subsidy_nuts2) [aweight=buyer_size]

eststo model_weights1: ivreghdfe spending (subsidy = total_subsidy_nuts2) [aweight=buyer_size], absorb( year_type2 type2_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "2", replace




**


restore



*** 3 ***
preserve

gcollapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) industry2 nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type3 type3_procurer, by(industry3 year buyer_id)

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

*drop if nuts2_id == 7.75
*drop if nuts2_id ==10.5 
*drop if nuts2_id > 11 & nuts2_id < 12
*drop if nuts2_id == 12.5
*drop if total_subsidy_nuts2==0

bysort buyer_id: egen buyer_size=sum(spending )

*merge m:1 nuts2_id industry2 year using "`dropboxdir'\total_subsidy_nuts2.dta"
join, by(nuts2_id industry2 year) from("total_subsidy_nuts2.dta")

drop _merge
*merge m:1 nuts2_id industry2 year using "`dropboxdir'\total_spending_nuts2.dta"
join, by(nuts2_id industry2 year) from("total_spending_nuts2.dta")


*** IV Regression - CPV3

ivreghdfe spending (subsidy = total_subsidy_nuts2)


eststo model_noweight2: ivreghdfe spending (subsidy = total_subsidy_nuts2), absorb( year_type3 type3_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "3", replace

*** the same with weights according to buyer_size

ivreghdfe spending (subsidy = total_subsidy_nuts2) [aweight=buyer_size]


eststo model_weights2: ivreghdfe spending (subsidy = total_subsidy_nuts2) [aweight=buyer_size], absorb( year_type3 type3_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "3", replace


restore



*** 4 ***
preserve

gcollapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) industry2 nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type4 type4_procurer, by(industry4 year buyer_id)

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

*drop if nuts2_id == 7.75
*drop if nuts2_id ==10.5 
*drop if nuts2_id > 11 & nuts2_id < 12
*drop if nuts2_id == 12.5
*drop if total_subsidy_nuts2==0

bysort buyer_id: egen buyer_size=sum(spending )

*merge m:1 nuts2_id industry2 year using "`dropboxdir'\total_subsidy_nuts2.dta"
join, by(nuts2_id industry2 year) from("total_subsidy_nuts2.dta")

drop _merge
*merge m:1 nuts2_id industry2 year using "`dropboxdir'\total_spending_nuts2.dta"
join, by(nuts2_id industry2 year) from("total_spending_nuts2.dta")


*** IV Regression - CPV4

ivreghdfe spending (subsidy = total_subsidy_nuts2)

eststo model_noweight3: ivreghdfe spending (subsidy = total_subsidy_nuts2), absorb( year_type4 type4_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "4", replace

*** the same with weights according to buyer_size

ivreghdfe spending (subsidy = total_subsidy_nuts2)[aweight=buyer_size]


eststo model_weights3: ivreghdfe spending (subsidy = total_subsidy_nuts2)[aweight=buyer_size], absorb( year_type4 type4_procurer) 
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Yes", replace
estadd local cpvdogits "4", replace


restore

esttab model_noweight1 model_noweight2 model_noweight3 using "`dropboxdir'\..\output\model1_iv.tex", keep(subsidy) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearindustry authorityindustry yearauthority cpvdogits N, label("Year-type FE" "Local authority-type FE" "Year-local authority FE" "Detailedness of type" "N"  ))

esttab model_weights1 model_weights2 model_weights3 using "`dropboxdir'\..\output\model1_iv_with_weights.tex", keep(subsidy) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearindustry authorityindustry yearauthority cpvdogits N, label("Year-type FE" "Local authority-type FE" "Year-local authority FE" "Detailedness of type" "N"  ))


*********************************************************************
*** Total budget changes??
* Vita: not sure what this is. The variable total_subsidy_budget_nuts2 is calculated the same as total_subsidy_nuts2 above.
* So I guess this is just not per industry???

* no need to do this I guess?
preserve
gcollapse (sum) confunding_real, by (nuts2_id year )
rename confunding_real total_subsidy_budget_nuts2
save "total_budget_subsidy_nuts2.dta", replace
restore


preserve

gcollapse (sum) robust_lot_estimated_price_eur confunding confunding_real (mean) nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by( year buyer_id)

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

*merge m:1 nuts2_id year using "`dropboxdir'\total_budget_subsidy_nuts2.dta"
join, by(nuts2_id year) from("total_budget_subsidy_nuts2.dta")
drop _merge


bysort buyer_id: egen buyer_size=sum(spending )
eststo: ivreghdfe spending (subsidy = total_subsidy_budget_nuts2) if buyer_size<65000000, absorb( year buyer_id) 
estadd local yearfe "Yes", replace
estadd local authorityfe "Yes", replace
estadd local weighting "No", replace

* does not show anything with not weighting

ivreghdfe spending (subsidy = total_subsidy_budget_nuts2)  [aweight=buyer_size]

eststo: ivreghdfe spending (subsidy = total_subsidy_budget_nuts2)  [aweight=buyer_size], absorb( year buyer_id)
estadd local yearfe "Yes", replace
estadd local authorityfe "Yes", replace
estadd local weighting "Yes", replace

restore

*esttab using "`dropboxdir'\..\output\model1_iv.tex", keep(subsidy) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearfe authorityfe weighting N, label("Year FE" "Authority FE" "Weighting" "N"  ))