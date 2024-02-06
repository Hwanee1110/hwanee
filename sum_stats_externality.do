clear all
local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies"

use "`dropboxdir'\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807_regionstatus.dta"

drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"


gen code=substr(cpvs , 1, 8)
drop _merge

join, by(code) from("C:\Users\Ryu00006\Dropbox\european subsidies\intermediate_outputs\cpv_w_externalities.dta")
drop if _merge==2

gen externality=_merge==3
sum externality
gen eu=eu_funded==1
bysort eu: sum externality
bysort eu: sum externality [aweight=robust_lot_estimated_price]

gen infrastructure=cpv_category=="Doprava" | cpv_category=="TechnickÃ© sluÅ¾by"  | cpv_category=="StavebnictvÃ­"
gen infrastructure_externalit=externality==1 & infrastructure==1
gen other_externality=externality==1 & infrastructure==0

bysort eu: sum externality
bysort eu: sum infrastructure_externalit

// preserve 
// gen first_period=year<=2013
//
// bysort first_period: sum externality if eu==1
// bysort first_period: sum infrastructure_externalit  if eu==1
// bysort first_period: sum other_externality   if eu==1
//
// gcollapse (sum) bid_final_price , by(eu_funded externality )
//
// save "`dropboxdir'\data\main_data_w_externality_measures", replace
//
// restore


***************************************************************************************
*** Dif-in-dif analysis

gen above_threshold=robust_lot_estimated_price>40000& robust_lot_estimated_price!=.
keep if above_threshold==1


***with treatment 



* TREATED/CONTROL 1 - broad ----
gen treated_broad_2 = .
*drop if buyer_nuts2=="ES63"| buyer_nuts2=="ES64"| buyer_nuts2=="ES70"| buyer_nuts2=="ESZZ"
replace treated_broad_2 = 1 if ( (period2007_2013 == "eligible-convergence" & period2014_2020 == "more-developed") | (period2007_2013 == "phasing-out-convergence" & period2014_2020 == "more-developed") | (period2007_2013 == "phasing-in-competitiveness" & period2014_2020 == "more-developed") | (period2007_2013 == "eligible-convergence" & period2014_2020 == "transition") )
/*
|((period2007_2013 == "phasing-out-convergence") & period2014_2020 == "transition")
*/

replace treated_broad_2 = 0 if ((period2007_2013 == "eligible-competitiveness") & period2014_2020 == "more-developed")



*drop if buyer_nuts2=="ES63"| buyer_nuts2=="ES64"| buyer_nuts2=="ES70"| buyer_nuts2=="ESZZ"
gen treated_new_policy = .
replace treated_new_policy = 1 if   (period2007_2013 == "eligible-convergence") & (period2014_2020 == "less-developed")
replace treated_new_policy = 0 if (period2007_2013 == "eligible-competitiveness") & (period2014_2020 == "more-developed")


//why would you do that?
// bysort buyer_id: egen data_pre=min(after2013)
// keep if data_pre==0

bysort buyer_id  year: egen total=sum(robust_lot_estimated_price)
gen externality_payment=externality*robust_lot_estimated_price
gen externality_payment_infras=infrastructure_externalit*robust_lot_estimated_price

bysort buyer_id  year: egen total_externality=sum(externality_payment)
bysort buyer_id  year: egen total_externality_infra=sum(externality_payment_infras)


gen externality_share=total_externality /total
gen externality_share_infra=total_externality_infra /total


*** COLLAPSE to study buyer_id-years
gcollapse (mean) treated_new_policy rate_change externality_share_infra  externality_share  treated_broad_2 after2013, by(year buyer_id )

gen treatmenr=treated_broad_2*after2013
gen treatment_new=after2013*treated_new_policy 


reghdfe externality_share treatmenr if year!=. , absorb(buyer_id  year)
reghdfe externality_share_infra treatmenr if year!=. , absorb(buyer_id  year)
reghdfe externality_share_infra treatment_new if year!=. , absorb(buyer_id  year)

reg externality_share  treatmenr treated_broad_2   i.year
reg externality_share_infra  treatmenr treated_broad_2   i.year
reg externality_share_infra  treatment_new treated_new_policy   i.year


*** This could presented
label variable treatmenr "Treatment Broad"
label variable treatment_new "Treatment New Policy"
label variable externality_share "Externality"
label variable externality_share_infra "Externality Infrastructure"


eststo clear
eststo: reghdfe externality_share treatmenr if year!=. &  year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share treatment_new if year!=. &  year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatmenr if year!=. &  year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatment_new if year!=. &  year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace

esttab




eststo clear
eststo: reghdfe externality_share treatmenr if year!=.  , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share treatment_new if year!=.  , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatmenr if year!=. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatment_new if year!=. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace

esttab


// esttab using "C:\Users\Ryu00006\Dropbox\european subsidies\output\model_did_externality.tex", keep(treatmenr treatment_new) noomitted  label se(4) replace star(* 0.10 ** 0.05 *** 0.01) stats(buyerid year N, label("Authority FE" "Year FE" "Detailedness of type" "N"  ))


// binscatter externality_share  year if year>=2011 & year<2016 ,   by(treated_broad_2 ) linetype(lfit)
// binscatter externality_share_infra  year if year>=2011 & year<2016 ,   by(treated_broad_2 ) linetype(qfit)
// binscatter externality_share_infra  year if year>=2010 & year<2018 ,    by(treated_broad_2 ) linetype(lfit)
// graph export "`dropboxdir'\output\did_externality_infrastructure.png", as(png) replace
//
// binscatter externality_share_infra  year if year>=2011 & year<2017 ,  by(treated_broad_2 ) linetype(qfit)


*** This one is to be used
binscatter externality_share year if year>=2010 & year<2018 , rd(2013.5)  by(treated_new_policy ) linetype(lfit)
//
// binscatter externality_share year if year>=2010 & year<2018 , by(treated_new_policy ) linetype(lfit)
//
// graph export "`dropboxdir'\..\output\did_externality_after2013.png", as(png) replace
//
// binscatter externality_share_infra year if year>=2010 & year<2018 , rd(2013.5)  by(treated_new_policy ) linetype(lfit)
//
//
// binscatter externality_share year if year>=2010 & year<2018 , rd(2013.5)  by(treated_new_policy ) linetype(lfit)








****only with regions with 2,9,15,16,11,19,7,8
clear all

local dropboxdir "C:\Users\Ryu00006\Dropbox\european subsidies"

use "`dropboxdir'\data\Spain_MasterTenderAnalyticsWithDGFCRate_Vita20190807_regionstatus.dta"

drop if tender_id==""
drop if buyer_nuts2==""
drop if buyer_nuts2=="ESZZ"
keep if nuts2_id==2|nuts2_id==9|nuts2_id==15|nuts2_id==16|nuts2_id==11|nuts2_id==7|nuts2_id==8

gen code=substr(cpvs , 1, 8)
drop _merge

join, by(code) from("C:\Users\Ryu00006\Dropbox\european subsidies\intermediate_outputs\cpv_w_externalities.dta")
drop if _merge==2

gen externality=_merge==3
sum externality
gen eu=eu_funded==1
bysort eu: sum externality
bysort eu: sum externality [aweight=robust_lot_estimated_price]

gen infrastructure=cpv_category=="Doprava" | cpv_category=="TechnickÃ© sluÅ¾by"  | cpv_category=="StavebnictvÃ­"
gen infrastructure_externalit=externality==1 & infrastructure==1
gen other_externality=externality==1 & infrastructure==0

bysort eu: sum externality
bysort eu: sum infrastructure_externalit



**********did
gen above_threshold=robust_lot_estimated_price>40000& robust_lot_estimated_price!=.
keep if above_threshold==1

* TREATED/CONTROL 1 - broad ----
gen treated_broad = .

replace treated_broad = 1 if ((period2007_2013 == "eligible-convergence") & period2014_2020 == "more-developed") | ((period2007_2013 == "phasing-out-convergence" | period2007_2013 == "phasing-in-competitiveness") & period2014_2020 == "more-developed") | ((period2007_2013 == "eligible-convergence") & period2014_2020 == "transition") | ((period2007_2013 == "eligible-convergence") & period2014_2020 == "more-developed") | ((period2007_2013 == "phasing-out-convergence") & period2014_2020 == "transition")
replace treated_broad = 0 if ((period2007_2013 == "eligible-competitiveness") & period2014_2020 == "more-developed")


gen treated_new_policy = .
replace treated_new_policy = 1 if   (period2007_2013 == "eligible-convergence") & (period2014_2020 == "less-developed")
replace treated_new_policy = 0 if (period2007_2013 == "eligible-competitiveness") & (period2014_2020 == "more-developed")



bysort buyer_id: egen data_pre=min(after2013)
keep if data_pre==0

bysort buyer_id  year: egen total=sum(robust_lot_estimated_price)
gen externality_payment=externality*robust_lot_estimated_price
gen externality_payment_infras=infrastructure_externalit*robust_lot_estimated_price

bysort buyer_id  year: egen total_externality=sum(externality_payment)
bysort buyer_id  year: egen total_externality_infra=sum(externality_payment_infras)


gen externality_share=total_externality /total
gen externality_share_infra=total_externality_infra /total


*** COLLAPSE to study buyer_id-years
gcollapse (mean) treated_new_policy rate_change externality_share_infra  externality_share  treated_broad after2013, by(year buyer_id )

gen treatmenr=treated_broad*after2013
gen treatment_new=after2013*treated_new_policy 


reghdfe externality_share treatmenr if year!=. , absorb(buyer_id  year)
reghdfe externality_share_infra treatmenr if year!=. , absorb(buyer_id  year)
reghdfe externality_share_infra treatment_new if year!=. , absorb(buyer_id  year)

reg externality_share  treatmenr treated_broad_2   i.year
reg externality_share_infra  treatmenr treated_broad_2   i.year
reg externality_share_infra  treatment_new treated_new_policy   i.year


*** This could presented
label variable treatmenr "Treatment Broad"
label variable treatment_new "Treatment New Policy"
label variable externality_share "Externality"
label variable externality_share_infra "Externality Infrastructure"

eststo clear
eststo: reghdfe externality_share treatmenr if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share treatment_new if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatmenr if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace
eststo: reghdfe externality_share_infra treatment_new if year!=. & year<2017 & year>2010. , absorb(buyer_id  year)
estadd local buyerid "Yes", replace
estadd local year "Yes", replace

esttab