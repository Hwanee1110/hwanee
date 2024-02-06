
******summary of light data
use "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\nuts2_light_data.dta", clear
table buyer_nuts2 year, contents(sum _sum)
table buyer_nuts2 year, contents(sum _mean)

twoway (line _sum year if buyer_nuts2=="ES51")
preserve
drop  if buyer_nuts2=="ES51"
collapse (mean) _sum, by(year)
line _sum year


use "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\nuts3_id_light_data.dta" 
table buyer_nuts3b year, contents(sum _sum)
table buyer_nuts3b year, contents(sum _mean)


*** The effect of subsidy on light emission

use "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\tender_with_region_status_population_light_data.dta", clear

drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"

gen code=substr(cpvs , 1, 8)

egen nuts3_id = group(buyer_nuts3b)


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

rename robust_lot_estimated_price_eur spending
rename confunding_real subsidy

gen change_after = 0
replace change_after = 1 if rate_change==1 & after2013==1




preserve

gcollapse (sum) spending confunding subsidy _count _sum (mean) _mean nuts3_id nuts2_id cofinancing_rate cofinancing_rate_expected procurere_time year_type2 type2_procurer, by(industry2 year buyer_id)

bysort buyer_id: egen buyer_size=sum(spending )

*merge m:1 nuts2_id industry2 year using "`dropboxdir'\total_subsidy_nuts2.dta"

join, by(nuts2_id industry2 year) from("C:\Users\Ryu00006\Dropbox\european subsidies\data\total_subsidy_nuts2.dta")

drop _merge
*merge m:1 nuts2_id industry2 year using "`dropboxdir'\total_spending_nuts2.dta"
join, by(nuts2_id industry2 year) from("C:\Users\Ryu00006\Dropbox\european subsidies\data\total_spending_nuts2.dta")



// *** IV Regression - CPV2
// eststo model_noweight1: ivreghdfe spending (subsidy = total_subsidy_nuts2), absorb( year_type2 type2_procurer) 
// estadd local yearindustry "Yes", replace
// estadd local authorityindustry "Yes", replace
// estadd local yearauthority "Yes", replace
// estadd local cpvdogits "2", replace
//ivreghdfe doesn't work


// reghdfe spending subsidy, absorb(procurere_time year_type2 type2_procurer) 

// sysuse auto
// ivreghdfe _sum subsidy (subsidy = total_subsidy_nuts2), absorb(procurere_time procurere_time year_type2 type2_procurer, tol(1e-6)) 


// gen above_threshold=robust_lot_estimated_price>40000& robust_lot_estimated_price!=.
// keep if above_threshold==1


* TREATED/CONTROL 1 - broad ----
gen treated_broad_2 = .
*drop if buyer_nuts2=="ES63"| buyer_nuts2=="ES64"| buyer_nuts2=="ES70"| buyer_nuts2=="ESZZ"
replace treated_broad_2 = 1 if (period2007_2013 == "eligible-convergence" & period2014_2020 == "more-developed") | (period2007_2013 == "phasing-out-convergence" & period2014_2020 == "more-developed") | (period2007_2013 == "phasing-in-competitiveness" & period2014_2020 == "more-developed") | (period2007_2013 == "eligible-convergence" & period2014_2020 == "transition")

replace treated_broad_2 = 0 if (period2007_2013 == "eligible-competitiveness" & period2014_2020 == "more-developed")


*drop if buyer_nuts2=="ES63"| buyer_nuts2=="ES64"| buyer_nuts2=="ES70"| buyer_nuts2=="ESZZ"
gen treated_new_policy = .
replace treated_new_policy = 1 if   (period2007_2013 == "eligible-convergence") & (period2014_2020 == "less-developed")
replace treated_new_policy = 0 if (period2007_2013 == "eligible-competitiveness") & (period2014_2020 == "more-developed")




*** COLLAPSE to study buyer_id-years
gcollapse (mean) treated_new_policy rate_change externality_share_infra  externality_share  treated_broad_2 after2013, by(year buyer_id )

gen treatmenr=treated_broad_2*after2013
gen treatment_new=after2013*treated_new_policy 


reghdfe externality_share treatmenr if year!=. , absorb(buyer_id  year)
reghdfe externality_share_infra treatmenr if year!=. , absorb(buyer_id  year)
reghdfe externality_share_infra treatment_new if year!=. , absorb(buyer_id  year)

reg externality_share  treatmenr treated_broad_2   i.year
reg externality_share_infra  treatmenr treated_broad_2   i.year
reg externality_share_infra  treatment_new treated_new_policy   i.year


*** This could presented
label variable treatmenr "Treatment Broad"
label variable treatment_new "Treatment New Policy"
label variable externality_share "Externality"
label variable externality_share_infra "Externality Infrastructure"

eststo clear
eststo: reghdfe externality_share treatmenr if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share treatment_new if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatmenr if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatment_new if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace

esttab using "`dropboxdir'\..\output\model_did_externality.tex", keep(treatmenr treatment_new) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(buyerid year N, label("Authority FE" "Year FE" "Detailedness of type" "N"  ))


binscatter externality_share  year if year>=2011 & year<2016 ,   by(treated_broad_2 ) linetype(lfit)
binscatter externality_share_infra  year if year>=2011 & year<2016 ,   by(treated_broad_2 ) linetype(qfit)
binscatter externality_share_infra  year if year>=2010 & year<2018 ,    by(treated_broad_2 ) linetype(lfit)
graph export "`dropboxdir'\..\output\did_externality_infrastructure.png", as(png) replace

binscatter externality_share_infra  year if year>=2011 & year<2017 ,  by(treated_broad_2 ) linetype(qfit)


*** This one is to be used
binscatter externality_share year if year>=2010 & year<2018 , rd(2013.5)  by(treated_new_policy ) linetype(lfit)
graph export "`dropboxdir'\..\output\did_externality_after2013.png", as(png) replace