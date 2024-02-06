use "C:\Users\Ryu00006\Dropbox\european subsidies\data\nuts3_light_data.dta", clear

rename buyer_nuts3 nuts3_region


merge m:1 nuts3_region year using "C:\Users\Ryu00006\Dropbox\european subsidies\data\spain_gdp_nuts3.dta"

keep if year>2007 & year<2020


***correlation between night light and GDP
rename _mean mean_light
rename _sum sum_light
rename _count count_light

scatter gdp mean_light

correlate gdp mean_light

pwcorr gdp mean_light, sig





scatter gdp sum_light

correlate gdp sum_light

pwcorr gdp sum_light, sig


***correlation between night light and subsidy
use "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate.dta",clear 
gegen nuts3_id = group(buyer_nuts3b)

gen confunding = cofinancing_rate*robust_lot_estimated_price_eur
gen cofinancing_rate_real = cofinancing_rate
replace cofinancing_rate_real = 0 if cofinancing_rate==.
gen confunding_real = cofinancing_rate_real*robust_lot_estimated_price_eur

preserve
gcollapse (sum) confunding_real, by (nuts3_id year)
rename confunding_real total_subsidy_nuts3
save "C:\Users\Ryu00006\Dropbox\european subsidies\data\total_subsidy_nuts3.dta", replace
restore

use "C:\Users\Ryu00006\Dropbox\european subsidies\data\nuts3_light_data.dta", clear
rename buyer_nuts3 nuts3_region
merge m:1 nuts3_region year using "C:\Users\Ryu00006\Dropbox\european subsidies\data\spain_gdp_nuts3.dta"
keep if year>2007 & year<2020

drop _merge

gegen nuts3_id = group(nuts3_region)


merge m:1 nuts3_id year using "C:\Users\Ryu00006\Dropbox\european subsidies\data\total_subsidy_nuts3.dta"


rename _mean mean_light
rename _sum sum_light
rename _count count_light

correlate gdp total_subsidy_nuts3

correlate sum_light total_subsidy_nuts3
