local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies"

use "`dropboxdir'\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807_regionstatus.dta", clear

drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"

*this creates a basic summary stats about contracts
bysort year: egen p5_price = pctile(robust_lot_estimated_price), p(5)
bysort year: egen p95_price = pctile(robust_lot_estimated_price), p(95)
bysort year: egen count_tender_id = count(tender_id)

preserve 
collapse (mean) count_tender_id, by(year)
twoway (line count_tender_id year)

// bysort year: egen avg_value = mean(robust_lot_estimated_price)

//mean price
preserve 
drop if robust_lot_estimated_price < p5_price | robust_lot_estimated_price > p95_price
collapse (mean) robust_lot_estimated_price, by(year)
twoway (line robust_lot_estimated_price year)
restore 

bysort year: egen totaL_value = sum(robust_lot_estimated_price)
preserve 
collapse (sum) robust_lot_estimated_price, by(year)
twoway (line robust_lot_estimated_price year)

//without top and low 5%
preserve 
drop if robust_lot_estimated_price < p5_price | robust_lot_estimated_price > p95_price
collapse (sum) robust_lot_estimated_price, by(year)
twoway (line robust_lot_estimated_price year)


bysort year: summarize robust_lot_estimated_price, detail

bysort year: egen mean_price = mean(robust_lot_estimated_price)
bysort year: egen sd_price = sd(robust_lot_estimated_price)
bysort year: egen p5_price = pctile(robust_lot_estimated_price), p(5)
bysort year: egen p95_price = pctile(robust_lot_estimated_price), p(95)


preserve
collapse (mean) mean_price sd_price p5_price p95_price, by(year)
twoway (line mean_price year) (line sd_price year) (line p5_price year) (line p95_price year)

*this creates a basic summary stats about subsidy
bysort year: egen count_subsidy = total(eu_funded==1)
twoway (line count_subsidy year)

bysort year: egen p5_sub = pctile(eu_subsidy), p(5)
bysort year: egen p95_sub = pctile(eu_subsidy), p(95)
bysort year: egen avg_subsidy = mean(eu_subsidy)

preserve
drop if eu_subsidy < p5_sub | eu_subsidy > p95_sub
collapse (mean) eu_subsidy, by(year)
twoway (line eu_subsidy year)
restore

bysort year: egen totaL_subsidy = sum(eu_subsidy)
twoway (line totaL_subsidy year)

preserve
drop if eu_subsidy < p5_sub | eu_subsidy > p95_sub
collapse (sum) eu_subsidy, by(year)
twoway (line eu_subsidy year)
restore