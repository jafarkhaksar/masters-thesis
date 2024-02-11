clear

cd "~/RA"


******** real minimum wage ***********


import delimit using "./data/CPI/nationalMW8397.csv", case(preserve)

gen realMW = nationalMW/nationalCPI

gen year = Year+1921

gr tw connected realMW year, name(realMW, replace) ///
xlabel(2004(2)2018, grid glw(.2) glp(dash)) xtitle("year") ytitle("real minimum wage")
gr export "./figures/realMW.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/realMW.png", as(png) replace
gr export "~/Dropbox/RA/EnglishThesis/figures/realMW.png", as(png) replace



******************** minimum wage incidence ***********************

cd "~/RA"

use "./data/HIES/wageIncomeCol.dta", clear

destring Year, gen(year)

// affected

preserve

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected affected year, by(Province_Full_Name) name(affected, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) xtitle("year") ytitle("fraction affected (%)")
gr export "./figures/affected_evolution_province.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/affected_evolution_province.png", as(png) replace

restore


preserve

replace year = year+1921
keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected affected year, by(Province_Full_Name) name(affected, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) xtitle("year") ytitle("fraction affected (%)")
gr export "~/Dropbox/RA/EnglishThesis/figures/affectedEvolutionProvince.png", as(png) replace

restore




// below
*** province-level

foreach v of varlist Year-fraction_at {
    label variable `v' ""
}

preserve

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected below below1_23 year, by(Province_Full_Name) name(below, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) xtitle("year") ytitle("")
gr export "./figures/below_evolution_province.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/below_evolution_province.png", as(png) replace

restore


preserve

replace year = year + 1921

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected below below1_23 year, by(Province_Full_Name) name(below, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(0(20)100) xtitle("year") ytitle("(%)")
gr export "~/Dropbox/RA/EnglishThesis/figures/belowEvolutionProvince.png", as(png) replace

restore


// med_min

preserve

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected med_min year, by(Province_Full_Name) name(med_min, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) xtitle("year") ytitle("Median/Min")
gr export "./figures/medmin_evolution_province.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/medmin_evolution_province.png", as(png) replace


restore


preserve

replace year = year + 1921

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected med_min year, by(Province_Full_Name) name(med_min, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) xtitle("year") ytitle("Median/Min")
gr export "~/Dropbox/RA/EnglishThesis/figures/medminEvolutionProvince.png", as(png) replace


restore



// mean_min

preserve

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected mean_min year, by(Province_Full_Name) name(mean_min, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) xtitle("year") ytitle("Mean/Min")
gr export "./figures/meanmin_evolution_province.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/meanmin_evolution_province.png", as(png) replace

restore


label variable min_mean "min/mean"

label variable min_med "min/median"


preserve

replace year = year + 1921

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected min_mean min_med year, by(Province_Full_Name) name(mean_min, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) xtitle("year") ytitle("")
gr export "~/Dropbox/RA/EnglishThesis/figures/meanminEvolutionProvince.png", as(png) replace

restore




*** country-wide

use "/home/jafar/RA/data/HIES/wageIncome/wageIncomeCleaned.dta", clear



gen w_median = .                               

levelsof year, local(levels) 
qui foreach l of local levels { 
    summarize hourly_salary [w=Weight] if year == `l', detail 
    replace w_median = r(p50) if year == `l'
 }


gen w_mean = .                               

levelsof year, local(levels) 
qui foreach l of local levels { 
    summarize hourly_salary [w=Weight] if year == `l'
    replace w_mean = r(mean) if year == `l'
 }



gen med_min = w_median/hourly_MW

gen mean_min = w_mean/hourly_MW


gen min_med = (hourly_MW/w_median)*100

gen min_mean = (hourly_MW/w_mean)*100


collapse (min) med_min min_med mean_min  min_mean hourly_MW ///
        (sum) total=Weight affected below below1_23, by(year)
	





replace affected = (affected/total)*100

replace below = (below/total)*100

replace below1_23 = (below1_23/total)*100




replace year = year + 1921

foreach v of varlist below1_23 below mean_min min_mean  med_min  min_med {
    label variable `v' ""
}


gr tw connected below below1_23 year, name(belowcountry, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(0(10)100) xtitle("year") ytitle("(%)")
gr export "./figures/below_evolution_country.png", as(png) replace
gr export "~/Dropbox/RA/EnglishThesis/figures/below_evolution_country.png", as(png) replace


gr tw connected min_mean min_med year, name(mean_min, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(0(10)100) xtitle("year") ytitle("(%)")
gr export "~/Dropbox/RA/EnglishThesis/figures/meanmin_evolution_country.png", as(png) replace


gr tw connected med_min year, name(med_min, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(1(0.1)1.6) xtitle("year") ytitle("Median/Min")
gr export "~/Dropbox/RA/EnglishThesis/figures/medmin_evolution_country.png", as(png) replace


// replace affected = affected/100

// replace below = below/100


drop hourly_MW total total_affected total_below


order year affected below med_min mean_min


rename (affected-mean_min) stat#, addnumber


reshape long stat, i(year) j(statistics)


label define MWbite 1 "fraction affected" 2 "fraction below" 3 "median/min" 4 "mean/min"

label values statistics MWbite


gr tw connected stat year if inlist(statistics, 1, 2) , by(statistics) name(MWbite1, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) ylabel(0(20)100) xtitle("year") ytitle("percent")
gr export "./figures/MWbite_evolution1.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/MWbite_evolution1.png", as(png) replace


gr tw connected stat year if inlist(statistics, 3, 4) , by(statistics) name(MWbite2, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) ylabel(0.8(0.2)1.8) xtitle("year") ytitle("")
gr export "./figures/MWbite_evolution2.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/MWbite_evolution2.png", as(png) replace




gen yearC = year + 1921

gr tw connected stat yearC if inlist(statistics, 1, 2) , by(statistics) name(MWbite, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(0(20)100) xtitle("year") ytitle("percentage")
gr export "~/Dropbox/RA/EnglishThesis/figures/MWbiteEvolution1.png", as(png) replace


gr tw connected stat yearC if inlist(statistics, 3, 4) , by(statistics) name(MWbite, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(0.8(0.2)1.8) xtitle("year") ytitle("")
gr export "~/Dropbox/RA/EnglishThesis/figures/MWbiteEvolution2.png", as(png) replace





************************************** Uninsured *************************************

cd "~/RA"

use "./data/informal/informalIndicatorCol.dta", clear

bysort Province_ID(Year): gen year = _n+83


preserve

keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected uninsured year, by(Province_Full_Name) name(uninsured, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) xtitle("year") ytitle("uninsured rate (%)")
gr export "./figures/uninsured_evolution_province.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/uninsured_evolution_province.png", as(png) replace

restore



preserve
replace year = year + 1921

drop if year == 2019
keep if inlist(Province_ID, "23", "06", "11", "29")
merge m:1 Province_ID using "./data/provinceName.dta", nogen keep(3) 
gr tw connected uninsured year, by(Province_Full_Name) name(uninsured, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) xtitle("year") ytitle("uninsured rate (%)")
gr export "~/Dropbox/RA/EnglishThesis/figures/uninsuredEvolutionProvince.png", as(png) replace

restore



*** country-wide (all workers)

cd "~/RA"

use "./data/informal/informalIndicator.dta", clear

collapse (sum) workingAge=total employed unemployed uninsured wage_earner self_emp ///
if inrange(ageCategory,2,4), by(Year)


replace uninsured = uninsured/wage_earner*100

gen wage_earner_percent = wage_earner/employed*100

replace self_emp = self_emp/employed*100


keep Year uninsured uninsured2 wage_earner_percent self_emp



order Year uninsured uninsured2 wage_earner_percent self_emp

rename (uninsured-self_emp) stat#, addnumber


reshape long stat, i(Year) j(statistics)


label define someLabels 1 "uninsured / wage earner" 2 "uninsured / employed" ///
                     3 "wage earner / employed" 4 "self employed / employed"

label values statistics someLabels

destring Year, replace

gr tw connected stat Year, by(statistics) name(someStat, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) ylabel(0(20)100) xtitle("year") ytitle("")
gr export "./figures/some_evolution.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/some_evolution.png", as(png) replace




gr tw connected stat Year if statistics==1, name(uninsured, replace) ///
xlabel(84(2)98, grid glw(.2) glp(dash)) ylabel(0(20)100) xtitle("year") ytitle("uninsured rate (%)")
gr export "./figures/uninsured_country.png", as(png) replace
gr export "~/Dropbox/RA/secondPres/figures/uninsured_country.png", as(png) replace



preserve
replace Year = Year + 1921
drop if Year == 2019

gr tw connected stat Year if statistics==1, name(uninsured, replace) ///
xlabel(2005(2)2018, grid glw(.2) glp(dash)) ylabel(0(20)100) xtitle("year") ytitle("uninsured rate (%)")
gr export "~/Dropbox/RA/EnglishThesis/figures/uninsuredCountry.png", as(png) replace

restore



***** country-wide (for demographic groups and different industries)

cd "~/RA"

use "./data/informal/informalIndicator.dta", clear


gen young = (Age<25 & Age>15)*Adj_IW_Seasonly/4

gen female = (Gender==2)*Adj_IW_Seasonly/4

gen less_edu = (inlist(Degree, 1, 2, 3))*Adj_IW_Seasonly/4 // how about NRs

gen rural = (Rural==2)*Adj_IW_Seasonly/4


gen tiny = (staffNum==1)*Adj_IW_Seasonly/4

replace small = (staffNum==2)*Adj_IW_Seasonly/4 // in the paper small refers to the first group

gen medium = (staffNum==3)*Adj_IW_Seasonly/4

gen large = (staffNum==4)*Adj_IW_Seasonly/4

gen huge = (staffNum==5)*Adj_IW_Seasonly/4



gen young_employed = (young!=0 & employed!=0)*Adj_IW_Seasonly/4

gen female_employed = (female!=0 & employed!=0)*Adj_IW_Seasonly/4

gen less_edu_employed = (less_edu!=0 & employed!=0)*Adj_IW_Seasonly/4

gen rural_employed = (rural!=0 & employed!=0)*Adj_IW_Seasonly/4



gen young_wage_earner = (young!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen female_wage_earner = (female!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen less_edu_wage_earner = (less_edu!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen rural_wage_earner = (rural!=0 & wage_earner!=0) * Adj_IW_Seasonly/4



gen manufacturing_wage_earner = (manufacturing!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen construction_wage_earner =  (construction!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen transit_wage_earner =  (transit!=0 & wage_earner!=0) * Adj_IW_Seasonly/4



gen tiny_wage_earner = (tiny!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen small_wage_earner = (small!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen medium_wage_earner = (medium!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen large_wage_earner = (large!=0 & wage_earner!=0) * Adj_IW_Seasonly/4

gen huge_wage_earner = (huge!=0 & wage_earner!=0) * Adj_IW_Seasonly/4



gen uninsured_employed = (uninsured!=0 & employed!=0) * Adj_IW_Seasonly/4

gen uninsured_wage_earner = (uninsured!=0 & wage_earner!=0) * Adj_IW_Seasonly/4



gen uninsured_young_wage_earner = (uninsured!=0 & young_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_female_wage_earner = (uninsured!=0 & female_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_less_edu_wage_earner = (uninsured!=0 & less_edu_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_rural_wage_earner = (uninsured!=0 & rural_wage_earner!=0) * Adj_IW_Seasonly/4



gen uninsured_manufact_wage_earner = (uninsured!=0 & manufacturing_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_construct_wage_earner = (uninsured!=0 & construction_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_transit_wage_earner = (uninsured!=0 & transit_wage_earner!=0) * Adj_IW_Seasonly/4


gen uninsured_tiny_wage_earner = (uninsured!=0 & tiny_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_small_wage_earner = (uninsured!=0 & small_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_medium_wage_earner = (uninsured!=0 & medium_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_large_wage_earner = (uninsured!=0 & large_wage_earner!=0) * Adj_IW_Seasonly/4

gen uninsured_huge_wage_earner = (uninsured!=0 & huge_wage_earner!=0) * Adj_IW_Seasonly/4





collapse (sum) workingAge=total   employed   wage_earner   uninsured   young   female  less_edu  rural ///
               young_employed     female_employed       less_edu_employed  rural_employed /// 
               manufacturing      construction          transit   ///
	       young_wage_earner  female_wage_earner    less_edu_wage_earner  rural_wage_earner ///
               manufacturing_wage_earner    construction_wage_earner    transit_wage_earner ///   
	       tiny_wage_earner             small_wage_earner           medium_wage_earner ///
	       large_wage_earner            huge_wage_earner ///
	       uninsured_employed           uninsured_wage_earner    /// 
	       uninsured_young_wage_earner      uninsured_female_wage_earner       uninsured_less_edu_wage_earner   uninsured_rural_wage_earner ///
	       uninsured_manufact_wage_earner    uninsured_construct_wage_earner   uninsured_transit_wage_earner /// 
	       uninsured_tiny_wage_earner        uninsured_small_wage_earner       uninsured_medium_wage_earner ///
	       uninsured_large_wage_earner       uninsured_huge_wage_earner ///
	      if inrange(ageCategory, 2, 4), by(Year)



gen p_wage_earner = (wage_earner / employed) * 100

gen p_young = (young_wage_earner / young_employed) * 100

gen p_female = (female_wage_earner / female_employed) * 100

gen p_less_edu = (less_edu_wage_earner / less_edu_employed) * 100

gen p_rural = (rural_wage_earner / rural_employed) * 100


gen p_manufacturing = (manufacturing_wage_earner / wage_earner) * 100

gen p_construction = (construction_wage_earner / wage_earner) * 100

gen p_transit = (transit_wage_earner / wage_earner) * 100


gen p_tiny = (tiny_wage_earner / wage_earner) * 100

gen p_small = (small_wage_earner / wage_earner) * 100

gen p_medium = (medium_wage_earner / wage_earner) * 100

gen p_large = (large_wage_earner / wage_earner) * 100

gen p_huge = (huge_wage_earner / wage_earner) * 100


gen ur = (uninsured_wage_earner / wage_earner) * 100

gen ur_young = (uninsured_young_wage_earner / young_wage_earner) * 100

gen ur_female = (uninsured_female_wage_earner / female_wage_earner) * 100

gen ur_less_edu = (uninsured_less_edu_wage_earner / less_edu_wage_earner) * 100

gen ur_rural = (uninsured_rural_wage_earner / rural_wage_earner) * 100



gen ur_manufacturing = (uninsured_manufact_wage_earner / manufacturing_wage_earner) * 100

gen ur_construction = (uninsured_construct_wage_earner / construction_wage_earner) * 100

gen ur_transit = (uninsured_transit_wage_earner / transit_wage_earner) * 100


gen ur_tiny = (uninsured_tiny_wage_earner / tiny_wage_earner) * 100

gen ur_small = (uninsured_small_wage_earner / small_wage_earner) * 100

gen ur_medium = (uninsured_medium_wage_earner / medium_wage_earner) * 100

gen ur_large = (uninsured_large_wage_earner / large_wage_earner) * 100

gen ur_huge = (uninsured_huge_wage_earner / huge_wage_earner) * 100



destring Year, gen(year)

replace year=year+1921


**** demographic groups *****

gr tw   connected ur ur_young ur_female ur_less_edu year, lp(l -- l -.) name("demo", replace) ///
	msymbol(O D T S) ///
	ylabel(0(10)100,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2005(2)2019, grid glw(.2) glp(dash)) xtitle("year") ytitle("percentage of uninsured wage earners") ///
	legend(order(1 "all" 2 "young" 3 "female" 4 "less educated") ///
	cols(2) position(6) ring(1) region(fc(gs16) lpattern(line)) size(8pt) symxsize(*.8)) ///
	yline(0,lpattern(line) lw(.1) lcolor(black))

	// title("Evolution of uninsured rate among Iranian") ///
	// note("Source: Author's calculations form Labor Force Survey, Statitical Center of Iran") ///
	
gr export "~/Dropbox/RA/EnglishThesis/figures/uninsuredDemo.png", as(png) replace



gr tw   connected p_wage_earner p_young p_female p_less_edu year,lp(l -- l -.) name("demo2", replace) ///
	msymbol(O D T S) ///
	ylabel(0(10)100,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2005(2)2019, grid glw(.2) glp(dash)) xtitle("year") ytitle("percentage of wage earners") ///
	legend(order(1 "all" 2 "young" 3 "female" 4 "less educated") ///
	cols(2) position(6) ring(1) region(fc(gs16) lpattern(line)) size(8pt) symxsize(*.8)) ///
	yline(0,lpattern(line) lw(.1) lcolor(black))

gr export "~/Dropbox/RA/EnglishThesis/figures/wageEarnerDemo.png", as(png) replace

**** industries *****

gr tw   connected ur ur_manufacturing ur_construction ur_transit year, lp(l -- l -.) name("industry", replace) ///
	msymbol(O D T S) ///
	ylabel(0(10)100,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2005(2)2019, grid glw(.2) glp(dash)) xtitle("year") ytitle("percentage of uninsured wage earners") ///
	legend(order(1 "all" 2 "manufacturing" 3 "construction" 4 "transportation") ///
	cols(2) position(6) ring(1) region(fc(gs16) lpattern(line)) size(8pt) symxsize(*.8)) ///
	yline(0,lpattern(line) lw(.1) lcolor(black))

	// title("Evolution of uninsured rate among Iranian") ///
	// note("Source: Author's calculations form Labor Force Survey, Statitical Center of Iran") ///
	
gr export "~/Dropbox/RA/EnglishThesis/figures/uninsuredIndustry.png", as(png) replace



gr tw   connected p_manufacturing p_construction p_transit year,lp(l -- l -.) name("Industry2", replace) ///
	msymbol(O D T S) ///
	ylabel(0(10)100,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2005(2)2019, grid glw(.2) glp(dash)) xtitle("year") ytitle("portion (%)") ///
	legend(order(1 "manufacturing" 2 "construction" 3 "transportation") ///
	cols(3) position(6) ring(1) region(fc(gs16) lpattern(line)) size(8pt) symxsize(*.8)) ///
	yline(0,lpattern(line) lw(.1) lcolor(black))

gr export "~/Dropbox/RA/EnglishThesis/figures/wageEarnerIndustry.png", as(png) replace


************* size of firm ********************

gr tw   connected ur ur_tiny ur_small ur_medium ur_large ur_huge year, lp(l -- l -.) name("size1", replace) ///
	msymbol(O D T S) ///
	ylabel(0(10)100,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2005(2)2019, grid glw(.2) glp(dash)) xtitle("year") ytitle("percentage of uninsured wage earners") ///
	legend(order(1 "all" 2 "1-4" 3 "5-9" 4 "10-19" 5 "20-49" 6 "50 <") ///
	cols(3) position(6) ring(1) region(fc(gs16) lpattern(line)) size(8pt) symxsize(*.8)) ///
	yline(0,lpattern(line) lw(.1) lcolor(black))

	// title("Evolution of uninsured rate among Iranian") ///
	// note("Source: Author's calculations form Labor Force Survey, Statitical Center of Iran") ///
	
gr export "~/Dropbox/RA/EnglishThesis/figures/uninsuredSize.png", as(png) replace


gr tw   connected p_tiny p_small p_medium p_large p_huge year, lp(l -- l -.) name("size2", replace) ///
	msymbol(O D T S) ///
	ylabel(0(10)100,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2005(2)2019, grid glw(.2) glp(dash)) xtitle("year") ytitle("portion (%)") ///
	legend(order(1 "1-4" 2 "5-9" 3 "10-19" 4 "20-49" 5 "50 <") ///
	cols(5) position(6) ring(1) region(fc(gs16) lpattern(line)) size(8pt) symxsize(*.8)) ///
	yline(0,lpattern(line) lw(.1) lcolor(black))

	// title("Evolution of uninsured rate among Iranian") ///
	// note("Source: Author's calculations form Labor Force Survey, Statitical Center of Iran") ///
	
gr export "~/Dropbox/RA/EnglishThesis/figures/wageEarnerSize.png", as(png) replace



**** scatters ****

use "/home/jafar/RA/data/uninsured.dta", clear

merge m:1 Province_ID using "/home/jafar/RA/data/provinceName.dta", nogen keep(3)

destring Year, gen(year)



forvalues y = 84(4)98 {
	gr tw scatter uninsured below1_23 if year==`y', ml(Province_Short_Name) ///
	name("year`y'", replace) xtitle("below (%)") ytitle("uninsured rate (%)")
	gr export "~/Dropbox/RA/secondPres/figures/scatter`y'.png", as(png) replace
	
	regress uninsured below1_23 if year==`y'
	avplot affected, ml(Province_Short_Name) name("Year`y'", replace) ///
	ytitle("uninsured") xtitle("below")
	gr export "~/Dropbox/RA/secondPres/figures/reg_scatter`y'.png", as(png) replace	
}




collapse (mean) uninsured below1_23, by(Province_Short_Name)

label variable below1_23 "below1_23"
label variable uninsured "uninsured rate"
label variable below "below"

 
gr tw scatter uninsured below1_23 , ml(Province_Short_Name) ///
	name("scatter", replace) xtitle("below1_23 (%)") ytitle("uninsured rate (%)") ///
	|| lfit uninsured below
	gr export "~/Dropbox/RA/secondPres/figures/scatter.png", as(png) replace
	gr export "~/Dropbox/RA/EnglishThesis/figures/scatter.png", as(png) replace


regress uninsured below1_23
avplot below, ml(Province_Short_Name) name("scatter2", replace) ///
	ytitle("uninsured") xtitle("below1_23")
	gr export "~/Dropbox/RA/secondPres/figures/scatter2.png", as(png) replace
	gr export "~/Dropbox/RA/EnglishThesis/figures/scatter2.png", as(png) replace

***************************************************
gr tw scatter uninsured below , ml(Province_Short_Name) ///
	name("scatter", replace) xtitle("below (%)") ytitle("uninsured rate (%)") ///
	|| lfit uninsured below
	gr export "~/Dropbox/RA/secondPres/figures/scatterBelow.png", as(png) replace
	gr export "~/Dropbox/RA/EnglishThesis/figures/scatterBelow.png", as(png) replace


regress uninsured below
avplot below, ml(Province_Short_Name) name("scatter2", replace) ///
	ytitle("uninsured") xtitle("below")
	gr export "~/Dropbox/RA/secondPres/figures/scatter2Below.png", as(png) replace
	gr export "~/Dropbox/RA/EnglishThesis/figures/scatter2Below.png", as(png) replace

**************** SSO insured stats *******************

import delimit using "/home/jafar/RA/data/tamin/totalMandatory.csv", case(preserve)

gen year = Year + 1921

gen million = privateMandatory/1000000

gr tw connected million year, name("mandatory", replace) ///
	ylabel(1(1)10,angle(0) grid glw(.2) glp(dash)) ///
	xlabel(2008(2)2021, grid glw(.2) glp(dash)) xtitle("year") ytitle("insured wage-earners (million)") ///
	// yline(0,lpattern(line) lw(.1) lcolor(black))
	gr export "~/Dropbox/RA/EnglishThesis/figures/mandatory.png", as(png) replace
