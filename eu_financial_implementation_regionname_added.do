 use "C:\Users\Ryu00006\Dropbox\european subsidies\data\finance_implementation_EU_2014_2020.dta", clear

//  split programmetitle, parse("-") generate(region)
//  rename region1 region
//  drop region2 region3 region4
//
//  replace region = trim(region)
//
// merge m:1 region using "C:\Users\Ryu00006\Dropbox\european subsidies\data\region_name_match.dta"
//
// rename number nuts2id
//
// gen region_status = "" 
//
// replace region_status = "more developed" if inlist(nuts2id, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 17)
// replace region_status = "transition" if inlist(nuts2id, 10, 15, 16, 18, 19)
// replace region_status = "less developed" if nuts2id == 11

egen fund_type = group(fund)
//EAFRD=1
//EMFF=2
//ERDF=3
//ESF=4
//YEI=5

sort fund_type
by fund_type: egen sum_fund = total(eu_amount_planned)

by fund_type: sum sum_fund


***only for ESF and ERDF***
keep if fund=="ESF"| fund=="ERDF"

keep if category_of_region=="More developed"|category_of_region=="Transition"|category_of_region=="Less developed"

drop if region=="Employment training and education"| region=="Multi"| region=="SME Initiative"| region=="Smart Growth (merged 2017 with Multi"| region=="Social inclusion and social economy"| region=="Technical Assistance"| region=="Youth Employment"

replace region = "Castilla–La Mancha" if region == "Castilla"
rename nuts2id nuts2_id
sort nuts2 year

collapse (mean) eu_amount_planned national_amount_planned eu_co_financing, by(nuts2_id)

***investment by composition
graph pie eu_amount_planned if category_of_region=="More developed", over(to_short) plabel(_all percent)
graph pie eu_amount_planned if category_of_region=="Transition", over(to_short) plabel(_all percent)
graph pie eu_amount_planned if category_of_region=="Less developed", over(to_short) plabel(_all percent)

***to compare subsidy
preserve
collapse (sum) eu_amount_planned, by(nuts2id year)
list
// line eu_amount_planned year, by(nuts2id)
restore

preserve
collapse (sum) eu_amount_planned if fund=="ERDF", by(nuts2id year)
list
// line eu_amount_planned year, by(nuts2id)
restore