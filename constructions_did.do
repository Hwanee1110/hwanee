local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies"
*local dropboxdir "D:\Dropbox\european subsidies\data"

use "`dropboxdir'\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807_regionstatus.dta", clear

gen above_threshold=robust_lot_estimated_price>40000& robust_lot_estimated_price!=.
keep if above_threshold==1

***************************************************************
* TREATED/CONTROL 1 - broad ----
gen treated_broad_2 = .
*drop if buyer_nuts2=="ES63"| buyer_nuts2=="ES64"| buyer_nuts2=="ES70"| buyer_nuts2=="ESZZ"
replace treated_broad_2 = 1 if ((period2007_2013 == "eligible-convergence") & period2014_2020 == "more-developed") | ((period2007_2013 == "phasing-out-convergence" | period2007_2013 == "phasing-in-competitiveness") & period2014_2020 == "more-developed") | ((period2007_2013 == "eligible-convergence") & period2014_2020 == "transition") | ((period2007_2013 == "eligible-convergence") & period2014_2020 == "more-developed")
replace treated_broad_2 = 0 if ((period2007_2013 == "eligible-competitiveness") & period2014_2020 == "more-developed")

*drop if buyer_nuts2=="ES63"| buyer_nuts2=="ES64"| buyer_nuts2=="ES70"| buyer_nuts2=="ESZZ"
gen treated_new_policy = .
replace treated_new_policy = 1 if   (period2007_2013 == "eligible-convergence") & (period2014_2020 == "less-developed")
replace treated_new_policy = 0 if (period2007_2013 == "eligible-competitiveness") & (period2014_2020 == "more-developed")



bysort buyer_id: egen data_pre=min(after2013)
keep if data_pre==0

bysort buyer_id  year: egen total=sum(robust_lot_estimated_price)
gen construction_payment=construction*robust_lot_estimated_price
bysort buyer_id  year: egen total_constr=sum(construction_payment )
 
gen machinery_payment=construction*robust_lot_estimated_price

bysort buyer_id  year: egen total_machinery=sum(machinery_payment )


gen construction_share=total_constr /total
gen machinery_share=machinery_payment /total

*preserve
gcollapse (mean) rate_change  machinery_share construction_share treated_new_policy treated_broad_2 after2013, by(year buyer_id )

gen treatmenr=treated_broad_2*after2013
gen treatment_new=after2013*treated_new_policy 
bysort after2013: sum construction_share

reghdfe construction_share treatmenr if year!=. , absorb(buyer_id  year)
reghdfe machinery_share treatmenr if year!=. , absorb(buyer_id  year)

reg construction_share  treatmenr treated_broad_2   i.year
reg machinery_share treatmenr treated_broad_2   i.year

*reghdfe construction_share tr2 if year!=. , absorb(buyer_id  year)

*************************************************
*** DiD Construction

label variable treatmenr "Treatment Broad"
label variable treatment_new "Treatment New Policy"
label variable construction_share "Construction"
label variable machinery_share "Machinery"

eststo clear
eststo: reghdfe construction_share treatmenr if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
*eststo: reghdfe construction_share treatment_new if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
*estadd local buyerid "Yes", replace
*estadd local year "Yes", replace
eststo: reghdfe machinery_share treatmenr if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
*eststo: reghdfe machinery_share treatment_new if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
*estadd local buyerid "Yes", replace
*estadd local year "Yes", replace

esttab using "`dropboxdir'\output\model_did_construction.tex", keep(treatmenr) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(buyerid year N, label("Authority FE" "Year FE" "Detailedness of type" "N"  ))
***???

*out of pocet 


*************************************************
*** Graphs
label variable year "Year"
label variable treated_broad_2 "Treated"

binscatter construction_share  year if year>=2010 & year<2019 ,  rd(2013) by(treated_broad_2 ) linetype(lfit) xtitle(Year) ytitle(Share of Construction) legend(lab(1 Control) lab(2 Treated))
binscatter construction_share  year if year>=2011 & year<2017 ,  rd(2013.5) by(treated_broad_2 ) linetype(qfit) xtitle(Year) ytitle(Share of Construction) legend(lab(1 Control) lab(2 Treated))
graph export "`dropboxdir'\output\did_constructions_new.png", as(png) replace

*binscatter construction_share  year if year>=2010 & year<2018 ,  rd(2013.5) by(treated_broad_2 ) linetype(qfit)

binscatter machinery_share  year if year>=2010 & year<2019 ,  rd(2013.5) by(treated_broad_2 ) linetype(lfit) xtitle(Year) ytitle(Share of Machinery) legend(lab(1 Control) lab(2 Treated))
binscatter machinery_share  year if year>=2011 & year<2017 ,  rd(2013.5) by(treated_broad_2 ) linetype(qfit) xtitle(Year) ytitle(Share of Machinery) legend(lab(1 Control) lab(2 Treated))
graph export "`dropboxdir'\output\did_machinery_new.png", as(png) replace