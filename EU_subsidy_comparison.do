***this section is to see the changes of EU subsidy amount over time for each region***

***first using subsidy data***
use "C:\Users\Ryu00006\Dropbox\european subsidies\data\total_budget_subsidy_nuts2.dta",clear

drop if nuts2_id==20
drop if nuts2_id==.

list

forvalues id = 1/19 {
    twoway (line total_subsidy_budget_nuts2 year if nuts2_id == `id'), ///
        title("Total subsidy for Region `id'") ///
        ylabel(, format(%9.0g)) ///
        ytitle("Total subsidy") ///
        xtick(2007(1)2019) ///
        xlabel(2007(1)2019, labsize(small))

    local filename "C:\\Users\\Ryu00006\\Dropbox\\european subsidies\\graph\\changes_in_subsidy\\graph_region_`id'.gph"
    graph save "`filename'", replace
}

***second using main dataset***

use "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta",clear 



drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"
egen nuts2_id = group(buyer_nuts2)



//changes in number of subsidised contracts
preserve
collapse (sum) eu_funded, by(year nuts2_id)
twoway (line eu_funded year, by(nuts2_id)), xline(2014, lcolor(red))
restore

// sort nuts2_id
// tab year
// tab nuts2_id


//changes in proportion of subsidised contracts and logged subsidy amount
preserve
bysort year: egen contract_number = count(tender_id) if eu_funded==1
bysort nuts2_id year: egen subsidised_contract_n = count(tender_id) if eu_funded==1
// bysort year: tab contract_number
gen proportion_contract=subsidised_contract_n/contract_number
bysort nuts2_id year: egen eu_subsidy_sum = total(eu_subsidy) if eu_funded==1
gen log_sub = log(eu_subsidy_sum)
sort nuts2_id year

collapse (firstnm) proportion_contract eu_subsidy_sum log_sub, by(nuts2_id year)

replace proportion_contract = 0 if proportion_contract == .
replace eu_subsidy_sum = 0 if eu_subsidy_sum == .
replace log_sub = 0 if log_sub == .

twoway (line proportion_contract year, by(nuts2_id)), xline(2014, lcolor(red))
twoway (line eu_subsidy_sum year, by(nuts2_id)), xline(2014, lcolor(red))
twoway (line log_sub year, by(nuts2_id)), xline(2014, lcolor(red))
restore




***to test if subsidy has decreased before and after 2014***
use "C:\Users\Ryu00006\Dropbox\european subsidies\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta",clear 

drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"
egen nuts2_id = group(buyer_nuts2)

bysort year: egen eu_subsidy_sum_year = total(eu_subsidy) if eu_funded==1
bysort nuts2_id year: egen eu_subsidy_sum = total(eu_subsidy) if eu_funded==1
gen proportion_sub = eu_subsidy_sum/eu_subsidy_sum_year
collapse (sum) eu_subsidy (firstnm) proportion_sub, by(nuts2_id year)
gen log_sub=log(eu_subsidy)
gen period = year > 2013


drop if year==2008

twoway (line log_sub year, by(nuts2_id)), xline(2014, lcolor(red))
twoway (line proportion_sub year, by(nuts2_id)), xline(2014, lcolor(red))


//less to more

// preserve
// keep if nuts2_id==1
// tsset year
// // tsline eu_subsidy
// ttest eu_subsidy, by(period)
// ttest log_sub, by(period)
// ttest proportion_sub, by(period)
// restore

preserve
keep if nuts2_id==2
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore


preserve
keep if nuts2_id==9
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore

// preserve
// keep if nuts2_id==10
// tsset year
// // tsline eu_subsidy
// ttest log_sub, by(period)
// ttest eu_subsidy, by(period)
// ttest proportion_sub, by(period)
// restore
//
//
// preserve
// keep if nuts2_id==13
// tsset year
// // tsline eu_subsidy
// ttest log_sub, by(period)
// ttest eu_subsidy, by(period)
// ttest proportion_sub, by(period)
// restore


preserve
keep if nuts2_id==15
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore

preserve
keep if nuts2_id==16
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore

// preserve
// keep if nuts2_id==17
// tsset year
// // tsline eu_subsidy
// ttest log_sub, by(period)
// ttest eu_subsidy, by(period)
// ttest proportion_sub, by(period)
// restore
//
// preserve
// keep if nuts2_id==18
// tsset year
// // tsline eu_subsidy
// ttest log_sub, by(period)
// ttest eu_subsidy, by(period)
// ttest proportion_sub, by(period)
// restore

//region2 and region9 experience a decrease in subsidy


//stayed less or stayed as transition
preserve
keep if nuts2_id==11
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore


preserve
keep if nuts2_id==19
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore




//stayed more developed
preserve
keep if nuts2_id==7
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore

preserve
keep if nuts2_id==8
tsset year
// tsline eu_subsidy
ttest log_sub, by(period)
ttest eu_subsidy, by(period)
ttest proportion_sub, by(period)
restore


gen region_status=""
replace region_status="less to more" if nuts2_id== 1|nuts2_id== 2|nuts2_id== 17
replace region_status="less to transition" if nuts2_id==10|nuts2_id== 15|nuts2_id== 16|nuts2_id== 18
replace region_status="more to transition" if nuts2_id==19
replace region_status = "stayed more" if nuts2_id == 3 | nuts2_id == 4 | nuts2_id == 5 | nuts2_id == 6 | nuts2_id == 7 | nuts2_id == 8 | nuts2_id == 9 | nuts2_id == 12 | nuts2_id == 13 | nuts2_id == 14
replace region_status="stayed less" if nuts2_id==11

// sort year nuts2_id
//
// forvalues id = 1/19 {
//     twoway (line proportion_contract year if nuts2_id == `id'), ///
//         title("EU subsidy change `id'") ///
//         ylabel(, format(%9.0g)) ///
//         ytitle("Proportion of subsidised contract") ///
//         xtick(2007(1)2019) ///
//         xlabel(2007(1)2019, labsize(small))
//
//     local filename "C:\\Users\\Ryu00006\\Dropbox\\european subsidies\\graph\\changes_in_subsidy\\graph_region_`id'.gph"
//     graph save "`filename'", replace
// }
//
// forvalues id = 1/19 {
//     twoway (line eu_subsidy_sum year if nuts2_id == `id'), ///
//         title("EU subsidy change `id'") ///
//         ylabel(, format(%9.0g)) ///
//         ytitle("Amount of subsidy by region status") ///
//         xtick(2007(1)2019) ///
//         xlabel(2007(1)2019, labsize(small))
//
// }
//
// forvalues id = 1/19 {
//     twoway (line log_sub year if nuts2_id == `id'), ///
//         title("EU subsidy change `id'") ///
//         ylabel(, format(%9.0g)) ///
//         ytitle("Amount of subsidy by region status (log)") ///
//         xtick(2007(1)2019) ///
//         xlabel(2007(1)2019, labsize(small))
//
// }



***by region status***
preserve

collapse (sum) proportion_contract eu_subsidy_sum log_sub, by(region_status year)
twoway (line proportion_contract year),xline(2014) by(region_status)
twoway (line eu_subsidy_sum year),xline(2014) by(region_status)
twoway (line log_sub year),xline(2014) by(region_status)
restore



