***instead of number of contracts sigend, focusing on the weighted amount of contracts

use "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear
preserve 
keep if year<2014
keep if eu_funded==1
tab cpv_category
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(cpv_category) stat(sum) 
//sum amount
tabstat robust_bid_final_price, by(cpv_category) stat(sum) 
restore





preserve 
keep if year<2014
keep if eu_funded==0
tab cpv_category
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(cpv_category) stat(sum) 
restore

preserve 
keep if year>2013
keep if eu_funded==1
tab cpv_category
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(cpv_category) stat(sum) 
//sum amount
tabstat robust_bid_final_price, by(cpv_category) stat(sum) 
restore



preserve 
keep if year>2013
keep if eu_funded==0
tab cpv_category
egen total = total(robust_bid_final_price)
gen proportion =(robust_bid_final_price/total)*100
tabstat proportion, by(cpv_category) stat(sum) 
restore


// egen total = total(robust_bid_final_price), by(year)
// gen proportion = (robust_bid_final_price / total) * 100
//
// preserve
// collapse (sum) proportion (mean) eu_funded, by(year cpv_category)
// drop if year==.
// drop if year==2006
// egen industry_one=group(cpv_category)
// reg proportion 


































cd "C:\Users\Ryu00006\Dropbox\european subsidies"
use "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807_regionstatus.dta", clear

drop _merge
merge m:1 buyer_nuts2 using "C:\Users\Ryu00006\Dropbox\european subsidies\data\changes in funding procurement.dta"

drop if buyer_nuts2=="ESZZ"

gen change=0
replace change=1 if status_pre!=status_post

gen status0=1
replace status0=. if status_pre==""
replace status0=2 if status_pre=="t"
replace status0=3 if status_pre=="d"

gen status1=1
replace status1=. if status_post==""
replace status1=2 if status_post=="t"
replace status1=3 if status_post=="d"

* For regions that did not change status
tabulate industry1 if after2013 == 0 & change == 0

* For regions that changed status
tabulate industry1 if after2013 == 0 & change == 1

* For regions that did not change status
tabulate industry1 if after2013 == 1 & change == 0

* For regions that changed status
tabulate industry1 if after2013 == 1 & change == 1




// gen industry_post=.
// replace industry_post=industry1 if after2013==1
//
// gen industry_pre=.
// replace industry_pre=industry1 if after2013==0




********************************
********** Exploration of Types
// tab cpv_category
//
// tab cpv_category if eu_funded==0
// tab cpv_category if eu_funded==1
//
// tab cpv_category if eu_funded==0 & year <= 2013
// tab cpv_category if eu_funded==1 & year <= 2013
// * before 2013
// * the share of contruction works fo cofunded contracts was 46.8%, and for non-confunded 12.2% only
// * for industrial machinery, 4.1% for non-confunded and 15% for confunded
// * for IT, no biggger change before 2013
//
// tab cpv_category if eu_funded==0 & year > 2013
// tab cpv_category if eu_funded==1 & year > 2013
// * after 2013
// * for construction, the change was from 19% for non-confunded to 23.7% for cofunded
// * for industrial machinery, the change was from 4.5% for non-confunded to 29.6% for cofunded
// * for IT, 9% (non-cofunded) to 14.2% (cofunded)


egen type_period = group(after2013 eu_funded)
egen type_rate = group(after2013 change)


//To compare the composition of contracts, categorized by whether they are EU-funded (EU_funded == 0 or EU_funded == 1) and whether they are after 2013 (after2013 == 0 or after2013 == 1)
eststo clear
estpost tabulate cpv_category type_period
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) 
* 1 - eu_funded: 0, after2013: 0
* 2 - eu_funded: 1, after2013: 0
* 3 - eu_funded: 0, after2013: 1
* 4 - eu_funded: 1, after2013: 1


//To compare the composition of contracts, categorized by whether they are EU-funded (change == 0 or change == 1) and whether they are after 2013 (after2013 == 0 or after2013 == 1)
eststo clear
estpost tabulate cpv_category type_rate
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace
* 1 - change: 0, after2013: 0
* 2 - change: 1, after2013: 0
* 3 - change: 0, after2013: 1
* 4 - change: 1, after2013: 1



//To compare the composition of contracts, categorized by whether they are EU-funded (change == 0 or change == 1) and whether they are after 2013 (after2013 == 0 or after2013 == 1) for eu_funded==0
eststo clear
estpost tabulate cpv_category type_rate if eu_funded==0
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace


//To compare the composition of contracts, categorized by whether they are EU-funded (change == 0 or change == 1) and whether they are after 2013 (after2013 == 0 or after2013 == 1) for eu_funded==1
eststo clear
estpost tabulate cpv_category type_rate if eu_funded==0
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace

//compare the amount




*** ONLY CONFUNDED ***
preserve 
keep if eu_funded==1
collapse (sum) one robust_bid_final_price_eur, by (year)

sort year
tsset year

tsline one, xline(2013)

restore

* Share of EU confunded by month
* I could also calculate share of some industries
gen date  = date(award_date, "YMD")
gen date_ann_in_month = year(date)*12+month(date)
gen reform_date = 2013*12


********



preserve
keep if year>=2011 & year<=2018
gen robust_bid_final_price_eur_avg = robust_bid_final_price_eur


collapse (sum) robust_bid_final_price_eur price_eu_contracts one (mean) robust_bid_final_price_eur_avg eu_funded reform_date construction machinery, by (date_ann_in_month)

sort date_ann_in_month
tsset date_ann_in_month

sum reform_date, meanonly
local reform_date = r(mean)

tsline robust_bid_final_price_eur price_eu_contracts, xline(`reform_date')


tsline price_eu_contracts, xline(`reform_date')



tsline eu_funded construction machinery, xline(`reform_date')


restore





*********** MODEL 1 ************
eststo clear
eststo:  quietly reghdfe eu_funded cofinancing_rate, absorb(year_industry2 authority_industry2 year_authority)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Year", replace
estadd local cpvdogits "2", replace

eststo:  quietly reghdfe eu_funded cofinancing_rate, absorb(year_industry3 authority_industry3 year_authority)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Year", replace
estadd local cpvdogits "3", replace

eststo:  quietly reghdfe eu_funded cofinancing_rate, absorb(year_industry4 authority_industry4 year_authority)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Year", replace
estadd local cpvdogits "4", replace

esttab, keep(cofinancing_rate) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearindustry authorityindustry yearauthority cpvdogits N, label("Year-type FE" "Local authority-type FE" "Year-local authority FE" "Detailedness of type" "N"  ))


*********** MODEL 2 ************
eststo clear

eststo:  quietly reghdfe share cofinancing_rate, absorb(year_industry2 authority_industry2 year_authority)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Year", replace
estadd local cpvdogits "2", replace

eststo:  quietly reghdfe share3 cofinancing_rate, absorb(year_industry3 authority_industry3 year_authority)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Year", replace
estadd local cpvdogits "3", replace

eststo:  quietly reghdfe share4 cofinancing_rate, absorb(year_industry4 authority_industry4 year_authority)
estadd local yearindustry "Yes", replace
estadd local authorityindustry "Yes", replace
estadd local yearauthority "Year", replace
estadd local cpvdogits "4", replace

esttab, keep(cofinancing_rate) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(yearindustry authorityindustry yearauthority cpvdogits N, label("Year-type FE" "Local authority-type FE" "Year-local authority FE" "Detailedness of type" "N"  ))