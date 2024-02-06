use "C:\Users\Ryu00006\Dropbox\european subsidies\data\spain_gdp_nuts_level.dta", clear

keep if length(nuts3_region) == 5

replace C = subinstr(C, "d", "", .)
replace V = subinstr(V, "p", "", .)

destring C, replace

destring V, replace


rename B gdp2000
rename C gdp2001
rename D gdp2002
rename E gdp2003
rename F gdp2004
rename G gdp2005
rename H gdp2006
rename I gdp2007
rename J gdp2008
rename K gdp2009
rename L gdp2010
rename M gdp2011
rename N gdp2012
rename O gdp2013
rename P gdp2014
rename Q gdp2015
rename R gdp2016
rename S gdp2017
rename T gdp2018
rename U gdp2019
rename V gdp2020



reshape long gdp, i(nuts3_region) j(year)

save "C:\Users\Ryu00006\Dropbox\european subsidies\data\spain_gdp_nuts3.dta", replace