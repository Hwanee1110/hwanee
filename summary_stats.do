local dir "C:\Users\Ryu00006\Dropbox\european subsidies"
local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies\data"

use "`dropboxdir'\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear

egen industry_one = group(cpv_category)

cd "`dir'"
*** summary basic variables
eststo clear
gen robust_bid_final_price_k = robust_bid_final_price_eur / 1000
estpost summarize robust_bid_final_price_k, listwise
// estpost summarize  robust_bid_final_price_eur , listwise
esttab, cells("mean sd min max") nomtitle 


eststo clear
gen eu_subsidy_k = eu_subsidy / 1000
estpost summarize  eu_subsidy_k , listwise
esttab, cells("mean sd min max") nomtitle 
// estpost summarize  eu_subsidy , listwise


eststo clear
estpost summarize  robust_bid_final_price_k if eu_funded==1 , listwise
esttab, cells("mean sd min max") nomtitle


//to create logged summary
gen logged_robust_bid_final_price = log(robust_bid_final_price)

eststo clear
estpost summarize logged_robust_bid_final_price, listwise
esttab, cells("mean sd min max") nomtitle 
eststo clear
estpost summarize  logged_robust_bid_final_price if eu_funded==1 , listwise
esttab, cells("mean sd min max") nomtitle

*** THA VARIATION
preserve

gen before2013 = 0
replace before2013 = 1 if year<=2013

gcollapse (mean) cofinancing_rate cofinancing_rate_expected , by(buyer_nuts2 before2013)

tab cofinancing_rate_expected if before2013==1
tab cofinancing_rate_expected if before2013==0

tab cofinancing_rate if before2013==1
tab cofinancing_rate if before2013==0

* count changes

restore

*** TABLE 1 - 
preserve

collapse (sum) robust_bid_final_price_eur, by (industry_one)

drop if industry_one==.
egen sum_prices = sum(robust_bid_final_price_eur)
gen shares = robust_bid_final_price_eur/sum_prices*100


label variable shares "Share"

eststo clear
estpost tabstat shares, by(industry_one) stat(mean)
esttab, cells("mean") nomtitle replace

restore

*** TABLE 2
* share within_industries
preserve
collapse (mean) eu_funded, by (industry_one)


drop if industry_one==.
label variable eu_funded "Share"
replace eu_funded = eu_funded*100


eststo clear
estpost tabstat eu_funded, by(industry_one) stat(mean)
esttab, cells("mean") nomtitle replace
restore

*** TABLE 3
preserve
collapse (sum) robust_bid_final_price_eur, by (industry_one after2013)
drop if industry_one==.

egen sum_prices_before = sum(robust_bid_final_price_eur) if after2013==0
gen shares_before = robust_bid_final_price_eur/sum_prices_before*100 if after2013==0

egen sum_prices_after = sum(robust_bid_final_price_eur) if after2013==1
gen shares_after = robust_bid_final_price_eur/sum_prices_after*100 if after2013==1

label variable shares_before "Share Before"
label variable shares_after "Share After"

eststo clear
estpost tabstat shares_before shares_after in 1/28, by(industry_one)
esttab, nomtitle replace cells("shares_before shares_after")
restore


*** TABLE 4
preserve

collapse (mean) eu_funded, by (industry_one after2013)

gen eu_funded_before = eu_funded*100 if after2013 == 0 
gen eu_funded_after = eu_funded*100 if after2013 == 1

label variable eu_funded_before "Share Before"
label variable eu_funded_after "Share After"

eststo clear
estpost tabstat eu_funded_before eu_funded_after in 1/28, by(industry_one)
esttab, nomtitle
restore

*eststo clear
*estpost tabstat eu_funded_before eu_funded_after, by(industry_one) stat(mean)
*esttab  using "./output/sum_table_4.tex", cells("eu_funded_before eu_funded_after") nomtitle replace




*** Figure 1 based on counts
gen construction_change = .
gen construction_nochange = .
replace construction_change = 0 if construction==0 & rate_change==1
replace construction_change = 1 if construction==1 & rate_change==1
replace construction_nochange = 0 if construction==0 & rate_change==0
replace construction_nochange = 1 if construction==1 & rate_change==0


preserve 
*keep if eu_funded==1
keep if year>2010
keep if year<=2017

collapse (mean) construction_change construction_nochange, by (year)

sort year
tsset year

label variable construction "Share of Construction Works"
label variable construction_change "Share of Construction Works - Transitioned"
label variable construction_nochange "Share of Construction Works - Non-Transitioned"


tsline construction_change construction_nochange, xline(2013) legend(cols(1))

graph save "Graph" "./output/graph_construction_1.gph", replace
graph export "./output/graph_construction_1.png", replace

restore


*** Figure 2 based on volumes (sums of prices)
gen change_price = 0
replace change_price = robust_bid_final_price_eur if rate_change==1

gen construction_change_price = 0
replace construction_change_price = robust_bid_final_price_eur if construction_change==1


gen nochange_price = 0
replace nochange_price = robust_bid_final_price_eur if rate_change==0

gen construction_nochange_price = 0
replace construction_nochange_price = robust_bid_final_price_eur if construction_nochange==1

*egen sum_prices_after = sum(robust_bid_final_price_eur) if after2013==1

preserve 
*keep if eu_funded==1
keep if year>2010
keep if year<=2017

collapse (sum) change_price nochange_price construction_change_price construction_nochange_price, by (year)

gen share_change = construction_change_price/change_price
gen share_nochange = construction_nochange_price/nochange_price

label variable share_change "Share of Construction Works - Transitioned"
label variable share_nochange "Share of Construction Works - Non-Transitioned"

sort year
tsset year

tsline share_change share_nochange, xline(2013) legend(cols(1))

graph save "Graph" "./output/graph_construction_2.gph", replace
graph export "./output/graph_construction_2.png", replace

restore

* Figure1b
preserve 
keep if eu_funded==1
keep if year>2010
keep if year<=2017

collapse (mean) construction construction_change construction_nochange, by (year)

sort year
tsset year

label variable construction "Share of Construction Works"
label variable construction_change "Share of Construction Works - Transitioned"
label variable construction_nochange "Share of Construction Works - Non-Transitioned"


tsline construction_change construction_nochange, xline(2013) legend(cols(1))

graph save "Graph" "./output/graph_construction_3.gph", replace
graph export "./output/graph_construction_3.png", replace

restore


* Figure2b
*** only confunded
preserve 
keep if eu_funded==1
keep if year>2010
keep if year<=2017

collapse (sum) change_price nochange_price construction_change_price construction_nochange_price, by (year)

gen share_change = construction_change_price/change_price
gen share_nochange = construction_nochange_price/nochange_price

label variable share_change "Share of Construction Works - Transitioned"
label variable share_nochange "Share of Construction Works - Non-Transitioned"

sort year
tsset year

tsline share_change share_nochange, xline(2013) legend(cols(1))

graph save "Graph" "./output/graph_construction_4.gph", replace
graph export "./output/graph_construction_4.png", replace

restore