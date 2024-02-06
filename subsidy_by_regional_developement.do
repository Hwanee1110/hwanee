******subsidy breakdown*******
//above thresholds
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

//composition of contracts

//period 2007-2013
//less developed 
preserve 
keep if year<2014 
keep if eu_funded==1 
keep if status0==1
tab industry_one
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(industry_one) stat(sum)
// tabstat robust_bid_final_price, by(industry_one) stat(sum)
restore

//transition
preserve 
keep if year<2014 
keep if eu_funded==1 
keep if status0==2
tab industry_one
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(industry_one) stat(sum)
// tabstat robust_bid_final_price, by(industry_one) stat(sum)
restore

//more-developed
preserve 
keep if year<2014 
keep if eu_funded==1 
keep if status0==3
tab industry_one
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(industry_one) stat(sum)
// tabstat robust_bid_final_price, by(industry_one) stat(sum)
restore

//period 2014-2020
//less developed 
preserve 
keep if year>2013 
keep if eu_funded==1 
keep if status0==1
tab industry_one
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(industry_one) stat(sum)
// tabstat robust_bid_final_price, by(industry_one) stat(sum)
restore

//transition
preserve 
keep if year>2013 
keep if eu_funded==1 
keep if status0==2
tab industry_one
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(industry_one) stat(sum)
// tabstat robust_bid_final_price, by(industry_one) stat(sum)
restore

//more-developed
preserve 
keep if year>2013 
keep if eu_funded==1 
keep if status0==3
tab industry_one
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(industry_one) stat(sum)
// tabstat robust_bid_final_price, by(industry_one) stat(sum)
restore

******************************************************************************************
//check subsidy trends by regional status
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


bysort nuts2_id year: egen num_nuts2 = sum(one)
bysort nuts2_id year: egen num_sub_nuts2 = sum(one) if eu_funded==1

bysort nuts2_id year: egen sum_nuts2 = sum(robust_bid_final_price)
bysort nuts2_id year: egen sum_sub_nuts2 = sum(robust_bid_final_price) if eu_funded==1

collapse (sum) robust_bid_final_price eu_subsidy (mean) status0 status1 (firstnm) num_nuts2 num_sub_nuts2 sum_nuts2 sum_sub_nuts2, by(nuts2_id year)

gen pro_num = num_sub_nuts2/num_nuts2
gen pro_sum = sum_sub_nuts2/sum_nuts2
replace pro_num=0 if pro_num==.
replace pro_sum=0 if pro_sum==.

preserve
drop if year>2013
collapse  pro_num, by(status0 year) 
twoway (line pro_num year if status0==1) (line pro_num year if status0==2) (line pro_num year if status0==3), ytitle("Proportion of Subsidised Contract (Number)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore

preserve
drop if year>2013
collapse pro_sum , by(status0 year) 
twoway (line pro_sum year if status0==1) (line pro_sum year if status0==2) (line pro_sum year if status0==3), ytitle("Proportion of Subsidised Contract (Sum)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore

preserve
drop if year<2014
collapse  pro_num, by(status1 year) 
twoway (line pro_num year if status1==1) (line pro_num year if status1==2) (line pro_num year if status1==3), ytitle("Proportion of Subsidised Contract (Number)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore

preserve
drop if year<2014
collapse pro_sum , by(status1 year) 
twoway (line pro_sum year if status1==1) (line pro_sum year if status1==2) (line pro_sum year if status1==3), ytitle("Proportion of Subsidised Contract (Sum)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore


//check subsidy trends by regional status
//only with contracts above thresholds
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

drop if (year < 2011 & robust_bid_final_price < 5278000 & supply_type == "WORKS") | (year < 2011 & robust_bid_final_price < 137000 & (supply_type == "SERVICES" | supply_type == "SUPPLIES" | supply_type == "OTHER"))

drop if (year < 2018 & robust_bid_final_price < 4845000 & supply_type == "WORKS") | (year < 2018 & robust_bid_final_price < 125000 & (supply_type == "SERVICES" | supply_type == "SUPPLIES" | supply_type == "OTHER")) 

drop if (year > 2017 & robust_bid_final_price < 5225000 & supply_type == "WORKS") | (year > 2017 & robust_bid_final_price < 144000 & (supply_type == "SERVICES" | supply_type == "SUPPLIES" | supply_type == "OTHER"))

bysort nuts2_id year: egen num_nuts2 = sum(one)
bysort nuts2_id year: egen num_sub_nuts2 = sum(one) if eu_funded==1

bysort nuts2_id year: egen sum_nuts2 = sum(robust_bid_final_price)
bysort nuts2_id year: egen sum_sub_nuts2 = sum(robust_bid_final_price) if eu_funded==1

collapse (sum) robust_bid_final_price eu_subsidy (mean) status0 status1 (firstnm) num_nuts2 num_sub_nuts2 sum_nuts2 sum_sub_nuts2, by(nuts2_id year)

gen pro_num = num_sub_nuts2/num_nuts2
gen pro_sum = sum_sub_nuts2/sum_nuts2
replace pro_num=0 if pro_num==.
replace pro_sum=0 if pro_sum==.

preserve
drop if year>2013
collapse  pro_num, by(status0 year) 
twoway (line pro_num year if status0==1) (line pro_num year if status0==2) (line pro_num year if status0==3), ytitle("Proportion of Subsidised Contract (Number)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore

preserve
drop if year>2013
collapse pro_sum , by(status0 year) 
twoway (line pro_sum year if status0==1) (line pro_sum year if status0==2) (line pro_sum year if status0==3), ytitle("Proportion of Subsidised Contract (Sum)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore

preserve
drop if year<2014
collapse  pro_num, by(status1 year) 
twoway (line pro_num year if status1==1) (line pro_num year if status1==2) (line pro_num year if status1==3), ytitle("Proportion of Subsidised Contract (Number)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore

preserve
drop if year<2014
collapse pro_sum , by(status1 year) 
twoway (line pro_sum year if status1==1) (line pro_sum year if status1==2) (line pro_sum year if status1==3), ytitle("Proportion of Subsidised Contract (Sum)") legend(label(1 "Less Developed") label(2 "Transition") label(3 "More Developed"))
restore