cd "/home/jafar/RA/data"

use "uninsured.dta", clear


replace min_mean = min_mean*100

replace min_med = min_med*100


// use "uninsuredYouth.dta", clear


// use "uninsuredLessEdu.dta", clear

foreach v of varlist uninsured  below below1_23 min_mean min_med unemp CPI small {
		
	preserve

	collapse(mean) `v'_i_mean=`v', by(Province_ID)

	save "iMean.dta", replace

	restore


	preserve

	collapse(mean) `v'_t_mean=`v', by(Year)

	save "tMean.dta", replace

	restore


	egen `v'_it_mean = mean(`v')

	merge m:1 Province_ID using "iMean.dta", nogen

	merge m:1 Year using "tMean.dta", nogen

	gen `v'_tilde = `v' - `v'_i_mean - `v'_t_mean + `v'_it_mean


	summarize `v' `v'_tilde

}


