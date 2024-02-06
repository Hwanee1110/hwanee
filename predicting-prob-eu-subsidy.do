

use "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear


***************
*** gen FEs ***
egen industry1 = group(cpv_category)
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

* this is like 20 groups
egen nuts2_id = group(buyer_nuts2)
gen log_p = log(robust_bid_final_price_eur)

reghdfe eu_funded, absorb(i.industry4##i.year) vce(cluster nuts2) resid
predict eu_funded_hat, xbd

reghdfe eu_funded, absorb(beta=i.industry4##i.year alpha=nuts2) vce(cluster nuts2) resid
predict eu_funded_hat_2, xbd
gen eu_funded_hat_2_nonuts2=eu_funded_hat_2-alpha

*** budget share - jakej share jde na eu-funded....
* DiD - only construction
* DiD


*reghdfe eu_funded log_p if year<=2013, absorb(beta_2013=i.industry4 alpha_2013=nuts2) vce(cluster nuts2) resid
*predict eu_funded_hat_2013, xbd
*gen eu_funded_hat_2013_nonuts2=eu_funded_hat_2013-alpha_2013

gen cpv_fe=""
replace cpv_fe="pre"+industry_four if year<2014
replace cpv_fe="post"+industry_four if year>2013
egen cpv_fe_id = group(cpv_fe)

reg eu_funded i.industry4 if year<2014, r
predict eu_funded_hat_2013_pre, xb

reg eu_funded i.industry4 if year>=2014, r
predict eu_funded_hat_2013_post, xb

*** redefine the prediction to dummy
sum eu_funded_hat_2013_pre,d
local median = r(p50)
local p75 = r(p75)
local p90 = r(p90)
local p95 = r(p95)

gen dummy_eu_funded_es_2013_median = .
replace dummy_eu_funded_es_2013_median = 0 if eu_funded_hat_2013_pre<=`median'
replace dummy_eu_funded_es_2013_median = 1 if eu_funded_hat_2013_pre>`median'

gen dummy_eu_funded_es_2013_p75 = .
replace dummy_eu_funded_es_2013_p75 = 0 if eu_funded_hat_2013_pre<=`p75' 
replace dummy_eu_funded_es_2013_p75 = 1 if eu_funded_hat_2013_pre>`p75' 

gen dummy_eu_funded_es_2013_p90 = .
replace dummy_eu_funded_es_2013_p90 = 0 if eu_funded_hat_2013_pre<=`p90' 
replace dummy_eu_funded_es_2013_p90 = 1 if eu_funded_hat_2013_pre>`p90' 

gen dummy_eu_funded_es_2013_p95 = .
replace dummy_eu_funded_es_2013_p95 = 0 if eu_funded_hat_2013_pre<=`p95' 
replace dummy_eu_funded_es_2013_p95 = 1 if eu_funded_hat_2013_pre>`p95' 


**********************
gen cpv_4=industry_four
drop _merge

merge m:1 year cpv_4 using "C:\Users\Ryu00006\Dropbox\european subsidies\intermediate_outputs\eu_probs_prediction.dta"
rename eu_score eu_funded_prob_eu_data
rename eu_funded_hat_2_nonuts2 eu_funded_prob_es_data

*** redefine the prediction to dummy
gen dummy_eu_funded_eu05 = .
replace dummy_eu_funded_eu05 = 0 if eu_funded_prob_eu_data<=0.5
replace dummy_eu_funded_eu05 = 1 if eu_funded_prob_eu_data>0.5
gen dummy_eu_funded_es05 = . 
replace dummy_eu_funded_es05 = 0 if eu_funded_prob_es_data<=0.5
replace dummy_eu_funded_es05 = 1 if eu_funded_prob_es_data>0.5


*** alt 0.25 cutoff
gen dummy_eu_funded_eu025 = .
replace dummy_eu_funded_eu025 = 0 if eu_funded_prob_eu_data<0.25
replace dummy_eu_funded_eu025 = 1 if eu_funded_prob_eu_data>0.75
gen dummy_eu_funded_es025 = . 
replace dummy_eu_funded_es025 = 0 if eu_funded_prob_es_data<0.25
replace dummy_eu_funded_es025 = 1 if eu_funded_prob_es_data>0.75



drop _merge
merge m:1 buyer_nuts2 using "C:\Users\Ryu00006\Dropbox\european subsidies\data\regions-status-spain.dta"




save "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807_regionstatus.dta", replace




