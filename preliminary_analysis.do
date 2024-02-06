cd "C:\Users\Ryu00006\Dropbox\european subsidies"
use "data/Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear


*cancellation_date -  never cancelled?
tab updated_completion_date
tab cancellation_date
tab updated_price
tab amendment_date_last
* no obs.

********************************
********** Exploration of Types
tab cpv_category
tabulate eu_funded, summarize(robust_bid_final_price_eur)

tab cpv_category if eu_funded==0
tab cpv_category if eu_funded==1
* among cofunded projects there are more construction works, industrial machinery, IT
* for construction, the share was 17.% for non-confunded and 28% for confunded
* for industrial machinery, 4.4% for non-confunded and 26.8% for confunded
* for IT, 9.8% for non-confunded and 14.2% for confunded

* on the other hand, the shares are much lower for transportation, energy, technical materials, healthcare and raw materials

tab cpv_category if eu_funded==0 & year <= 2013
tab cpv_category if eu_funded==1 & year <= 2013
* before 2013
* the share of contruction works fo cofunded contracts was 46.8%, and for non-confunded 12.2% only
* for industrial machinery, 4.1% for non-confunded and 15% for confunded
* for IT, no biggger change before 2013

tab cpv_category if eu_funded==0 & year > 2013
tab cpv_category if eu_funded==1 & year > 2013
* after 2013
* for construction, the change was from 19% for non-confunded to 23.7% for cofunded
* for industrial machinery, the change was from 4.5% for non-confunded to 29.6% for cofunded
* for IT, 9% (non-cofunded) to 14.2% (cofunded)

egen industry_one = group(cpv_category)
levelsof industry_one, local(ids)
// foreach i in `ids' {
// 	sum eu_funded if industry_one == `i'
// }
//
// eststo clear
// foreach i in `ids' {
// 	estpost sum eu_funded if industry_one == `i'
// }
// esttab
//
// * share within_industries
// eststo clear
// estpost tabstat eu_funded, by(industry_one) stat(mean)
// esttab, cells("mean") nomtitle 
//
// * share within_industries -- before and after
// gen eu_funded_before = eu_funded if after2013 == 0 
// gen eu_funded_after = eu_funded if after2013 == 1
//
// eststo clear
// estpost tabstat eu_funded_before eu_funded_after, by(industry_one) stat(mean) columns(statistics)
// esttab, cells("mean") nomtitle 

replace cofinancing_rate_expected=0.8 if buyer_nuts2=="ES70" & year<2014


// *** CHECKING
// preserve
// tab industry_one, sum(eu_funded)
// keep if after2013==0
// restore
// ****


drop if buyer_nuts2=="ESZZ"
egen nuts2_id = group(buyer_nuts2)
tab nuts2_id



eststo clear
estpost tabulate cpv_category eu_funded
esttab , cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}"))


egen type_period = group(after2013 eu_funded)
eststo clear
estpost tabulate cpv_category type_period
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace




* Let us not consider this one whete it went up
*keep if buyer_nuts2!="ES70"

*


egen type_rate = group(after2013 change)
* 1 - change: 0, after2013: 0
* 2 - change: 1, after2013: 0
* 3 - change: 0, after2013: 1
* 4 - change: 1, after2013: 1

sum type_rate if after2013==0 & change==0
sum type_rate if after2013==0 & change==0


eststo clear
estpost tabulate cpv_category type_rate
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace


preserve

keep if eu_funded==1

eststo clear
estpost tabulate cpv_category type_rate
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace

restore



preserve

keep if change==1

eststo clear
estpost tabulate cpv_category type_period
esttab, cell(colpct(fmt(2)) b(fmt(g) par keep(Total))) collabels(none) unstack noobs nonumber nomtitle   eqlabels(, lhs("Type"))    varlabels(, blist(Total "\hline @width}{break}")) replace

restore


*** CASE STUDY on CONSTRCTION ***
eststo clear
eststo:  quietly logit construction i.eu_funded##i.after2013, r
eststo:  quietly logit construction i.eu_funded##i.change, r
eststo:  quietly logit construction i.eu_funded##i.after2013##i.change, r
esttab,  noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(N, label("N"))


********************************


*** Table 1 0 summary
********************************
gen one = 1
egen N_year = count(one), by (year)


preserve 

gen price_to_sum_eucontracts = price_eu_contracts
collapse (sum) one price_to_sum_eucontracts eu_subsidy (mean) robust_bid_final_price_eur eu_funded, by (year)

rename one nr_contracts
rename robust_bid_final_price_eur avg_price
gen avg_p_eu_funded = price_to_sum_eucontracts/(nr_contracts*eu_funded)
gen total_eu_funded = price_to_sum_eucontracts

drop price_to_sum_eucontracts

gen avg_eu_subsidy = eu_subsidy/(nr_contracts*eu_funded)
gen total_eu_subsidy = eu_subsidy

drop eu_subsidy

dataout, save(output/yearly_data.tex) tex replace

sort year
tsset year

* for these we really have data
keep if year>=2011 & year<=2018

tsline nr_contracts, xline(2013)
tsline avg_price, xline(2013)
tsline eu_funded, xline(2013)

restore


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

*** only construction
preserve

keep if cpv_category == "StavebnictvÃ­"
collapse (mean) robust_bid_final_price_eur eu_funded N_year reform_date, by (date_ann_in_month)

sort date_ann_in_month
tsset date_ann_in_month

sum reform_date, meanonly
local reform_date = r(mean)


tsline eu_funded, xline(`reform_date')
tsline robust_bid_final_price_eur, xline(`reform_date')

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


