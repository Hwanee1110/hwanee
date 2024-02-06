clear all 

local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies\data"

use "`dropboxdir'\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807.dta", clear

rename _merge _merge1

drop if buyer_nuts2==""

merge m:1 buyer_nuts2 using "C:\Users\Ryu00006\OneDrive - Universiteit Utrecht\Desktop\European reigonal policy\nuts2_id.dta"

drop if nuts2_id==.

gen region_big=0
replace region_big=1 if nuts2_id==7| nuts2_id==8| nuts2_id==10 | nuts2_id==13|nuts2_id==16



collapse (sum) total_spending_type, by(nuts2_id year)


gen year_2011 = year == 2011
gen year_2015 = year == 2015
gen year_2019 = year == 2019

xtset nuts2_id year

xtreg total_spending_type i.year_2011 i.year_2015 i.year_2019, fe

xtreg total_spending_type i.nuts2_id  year_2011 year_2015 year_2019, vce(cluster nuts2_id)


test year_2011 year_2015 year_2019

use "C:\Users\Ryu00006\Dropbox\european subsidies\data\total_spending_nuts2.dta", clear

collapse (sum) total_spending_nuts2, by(nuts2_id year)


//regional elections in Spain were held in 2007,2011,2015,and 2019

//test whether spending increased in election year


gen year_2011 = year == 2011
gen year_2015 = year == 2015
gen year_2019 = year == 2019
xtset nuts2_id year

xtreg total_spending_nuts2 i.nuts2_id year_2011 year_2015 year_2019, vce(cluster nuts2_id)


test year_2011 year_2015 year_2019


//test whether spending increased in the previous year of election

gen year_2010 = year == 2010
gen year_2014 = year == 2014
gen year_2018 = year == 2018

xtreg total_spending_nuts2 i.nuts2_id year_2010 year_2014 year_2018, vce(cluster nuts2_id)

test year_2010 year_2014 year_2018

//test whether spending increased in the year after of election

gen year_2008 = year == 2008
gen year_2012 = year == 2012
gen year_2016 = year == 2016

xtreg total_spending_nuts2 i.nuts2_id year_2008 year_2012 year_2016, vce(cluster nuts2_id)

test year_2008 year_2012 year_2016


forvalues id = 1/19 {
    local y_pos = -1 * _n // Adjust this to position the labels below the x-axis
    twoway (line total_spending_nuts2 year if nuts2_id == `id'), ///
        title("Total Spending for Region `id'") ///
        ylabel(, format(%9.0g)) ///
        ytitle("Total Spending") ///
        xtick(2007(1)2019) ///
        xlabel(2007(1)2019, labsize(small)) ///
        text(`y_pos' 2007 "2007", color(red)) ///
        text(`y_pos' 2011 "2011", color(red)) ///
        text(`y_pos' 2015 "2015", color(red)) ///
        text(`y_pos' 2019 "2019", color(red)) ///
        name(graph`id', replace)
    graph save "C:\Users\Ryu00006\Dropbox\european subsidies\graph\changes_in_spending\graph_region_`id'.gph", replace
}

cd "C:\Users\Ryu00006\Dropbox\european subsidies\graph\changes_in_spending\"



graph combine graph_region_1.gph graph_region_2.gph graph_region_3.gph ///
graph_region_4.gph graph_region_5.gph graph_region_6.gph ///
graph_region_7.gph graph_region_8.gph graph_region_9.gph ///
graph_region_10.gph graph_region_11.gph graph_region_12.gph ///
graph_region_13.gph graph_region_14.gph graph_region_15.gph ///
graph_region_16.gph graph_region_17.gph graph_region_18.gph ///
graph_region_19.gph, ///
    rows(4) cols(5) imargin(0 0 0 0) ycommon xcommon
