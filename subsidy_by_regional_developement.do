use"C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\tender_with_region_status_population_light_data.dta" ,clear

drop _merge
merge m:1 buyer_nuts2 using "C:\Users\Ryu00006\Dropbox\european subsidies\data\changes in funding procurement.dta"

drop if buyer_nuts2=="ESZZ"

gen status0=1
replace status0=. if status_pre==""
replace status0=2 if status_pre=="t"
replace status0=3 if status_pre=="d"

gen status1=1
replace status1=. if status_post==""
replace status1=2 if status_post=="t"
replace status1=3 if status_post=="d"

***
preserve
collapse (sum) eu_subsidy population eu_funded (mean) status0 status1, by (nuts2_id year)
collapse (sum) eu_subsidy population eu_funded, by (status0 year)
drop if year>2013
bysort status0: tab eu_subsidy
restore
***
preserve
collapse (sum) eu_subsidy population eu_funded (mean) status0 status1, by (nuts2_id year)
collapse (sum) eu_subsidy population eu_funded, by (status1 year)
drop if year<2014
bysort status1: tab eu_subsidy
restore


******subsidy breakdown*******
use "C:\Users\Ryu00006\Dropbox\european subsidies\dofiles_jihwan\data\tender_with_region_status_population_light_data.dta" ,clear

drop _merge
merge m:1 buyer_nuts2 using "C:\Users\Ryu00006\Dropbox\european subsidies\data\changes in funding procurement.dta"

drop if buyer_nuts2=="ESZZ"

gen status0=1
replace status0=. if status_pre==""
replace status0=2 if status_pre=="t"
replace status0=3 if status_pre=="d"

gen status1=1
replace status1=. if status_post==""
replace status1=2 if status_post=="t"
replace status1=3 if status_post=="d"

//less developed
preserve 
keep if year<2014 
keep if eu_funded==1 
keep if status0==1
tab cpv_category
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(cpv_category) stat(sum)
tabstat robust_bid_final_price, by(cpv_category) stat(sum) 
tabstat robust_bid_final_price, by(cpv_category) stat(fre)
restore

***thresholds changed after 2011 and 2017
//Before 2011
// Works: 5,278,000
//Supply: Between 137,000 or 211,000 depending on their object and type contracting entity
//Service:Between 137,000 or 211,000 depending on their object and type contracting entity

drop if (year < 2011 & robust_bid_final_price < 5278000 & supply_type == "WORKS") | (year < 2011 & robust_bid_final_price < 137000 & (supply_type == "SERVICES" | supply_type == "SUPPLIES" | supply_type == "OTHER"))

//After 2011 
// Works: 4,845,000
//Supply: Between 125,000 or 193,000 depending on their object and type contracting entity
//Service:Between 125,000 or 193,000 depending on their object and type contracting entity

drop if (year < 2018 & robust_bid_final_price < 4845000 & supply_type == "WORKS") | (year < 2018 & robust_bid_final_price < 125000 & (supply_type == "SERVICES" | supply_type == "SUPPLIES" | supply_type == "OTHER")) 

//After 2017 
// Works: 5,225,000
//Supply: Between 144,000 or 221,000 depending on their object and type contracting entity
//Service:Between 144,000 or 221,000 depending on their object and type contracting entity

drop if (year > 2017 & robust_bid_final_price < 5225000 & supply_type == "WORKS") | (year > 2017 & robust_bid_final_price < 144000 & (supply_type == "SERVICES" | supply_type == "SUPPLIES" | supply_type == "OTHER"))

//contracts
//mean
preserve 
collapse (mean) robust_bid_final_price, by(year)
twoway (line robust_bid_final_price year)
restore 

//sum
preserve 
collapse (sum) robust_bid_final_price, by(year)
twoway (line robust_bid_final_price year)

//number
preserve 
bysort year: egen count_tender_id = count(tender_id)
collapse (mean) count_tender_id, by(year)
twoway (line count_tender_id year)


//subsidy
//mean
preserve
keep if eu_funded==1 
collapse (mean) eu_subsidy, by(year)
twoway (line eu_subsidy year)
restore 

//sum
preserve 
keep if eu_funded==1 
collapse (sum) eu_subsidy, by(year)
twoway (line eu_subsidy year)

//number
preserve
keep if eu_funded==1  
bysort year: egen count_tender_id = count(tender_id)
collapse (mean) count_tender_id, by(year)
twoway (line count_tender_id year)

***************