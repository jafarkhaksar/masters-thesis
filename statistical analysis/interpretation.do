cd "~/RA"

use "./data/informal/informalIndicator.dta", clear

set type double

collapse (sum) uninsured wage_earner ///
if inrange(ageCategory,2,4), by(Year)



replace uninsured = uninsured/wage_earner*100


merge 1:m Year using "./data/HIES/wageIncome/wageIncomeCleaned.dta", nogen keep(3)


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


collapse (min) uninsured    med_min   mean_min  monthly_MW ///
        (sum) total=Weight  below     below1_23 ///
	      below1_3    below1_5   ///
	, by(Year)



replace below = (below/total)*100

replace below1_23 = (below1_23/total)*100

replace below1_3 = (below1_3/total)*100

replace below1_5 = (below1_5/total)*100

gen gap = uninsured - below

gen gap2 = uninsured - below1_23


gen factor1 = (gap / uninsured)*100

gen factor2 = (gap2 / uninsured)*100


destring Year, gen(year)

replace year = year + 1921


save "/home/jafar/RA/data/speculation.dta", replace

****************** experiment

collapse (mean)   below    below1_23    below1_3   below1_5   uninsured    med_min   mean_min


******************


label variable uninsured "uninsured (\%)"

label variable below "\(w<w_{min}\) (\%)"

label variable below1_23 "\(w<1.23w_{min}\) (\%)"

label variable gap "gap 1"

label variable year "year"

label variable gap2 "gap 2"

label variable factor1 "\(f_1\) (\%)"

label variable factor2 "\(f_2\) (\%)"


foreach var of varlist uninsured below below1_23 gap gap2 mean_min factor1 factor2 {
  replace `var' = round(`var', 0.01)
}





texsave year  uninsured    below  below1_23  factor1  factor2 ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/speculation.tex", ///
nofix frag replace size(normalsize) location("hb") width("\linewidth") varlabels ///
label("speculation") title("Comparison between the fraction of uninsured wage-earners and those with different wages (2005--2018)") ///
footnote("\emph{Notes}: This table compares the uninsured rate (Column 1) with the fraction of wage-earners whose wages are lower than the minimum wage (Column 2) and 1.23\(\times\) minimum wage (Column 3) in each year from 2005 to 2018. \(f_1\) (Column 5) and \(f_2\) (Column 6) show the calculated values of \eqref{f1} and \eqref{f2}, respectively. \\ \emph{Source}: Iran's Labor Force Survey (Column 2) and Iran's Household Income and Expenditure Survey (Columns 3 and 4)")



///////// TOTAL

cd "~/RA"

use "./data/informal/informalIndicator.dta", clear

set type double

collapse (sum) uninsured wage_earner ///
if inrange(ageCategory,2,4)


replace uninsured = uninsured/wage_earner*100


use "./data/HIES/wageIncome/wageIncomeCleaned.dta", replace


gen w_median = .

gen w_mean = .                               
                             


qui summarize hourly_salary [w=Weight], detail 

replace w_median = r(p50)

replace w_mean = r(mean)






collapse (min)    w_median   w_mean       ///
        (sum)     total=Weight  below     below1_23   ///
	          below1_3    below1_5       ///
	(mean)    hourly_MW
	

	
replace below = (below/total)*100

replace below1_23 = (below1_23/total)*100

replace below1_3 = (below1_3/total)*100

replace below1_5 = (below1_5/total)*100


gen med_min = w_median/hourly_MW

gen mean_min = w_mean/hourly_MW
