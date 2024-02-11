* The purpose of the following lines of code is to quantify the incidence of 
* a "national" minimum wage at the province level. That is, I intend to measure
* how strongly each province is affected by the national minimum wage policy.
* The previous literature suggests several ways to do so, some of which are based on
* where the national minimum wage is located on the wage distribution of a province
* (or other geographical unit). A classic example is Kaitz index, which is calculated via dividing
* national minimum wage by median wage of the respective province. Another measurement is
* the fraction of workers whose wages are lower than (a factor of) minimum wage.




cd "/home/jafar/RA/data/"

use "./HIES/wageIncome/wageIncome.dta", clear // a data set that I have prepared beforehand. 
                                              // This contains wage income data of the respondents of
					      // Iran Household Income and Expenditure Survey (2005-2018)
					  
					  
keep Address DYCOL01 DYCOL02  DYCOL05    DYCOL06    DYCOL07   DYCOL08   DYCOL10   DYCOL14 year urban

rename (DYCOL01 DYCOL02    DYCOL05    DYCOL06       DYCOL07        DYCOL08         DYCOL10          DYCOL14) ///
       (no      employed   division   hours_day     days_week      pre_reduction   monthly_salary   monthly_compensation)
       

drop if (days_week > 7 | hours_day > 16 | days_week < 1 | hours_day < 1) // drops some extereme values


drop if (division!=3 | employed!=1) // drops those are not private employee or are not employed


set type double 



******* handling duplicated observations

by year urban Address no, sort: gen duplicate=_n


by year urban Address no, sort: egen monthly_salary_min = min(monthly_salary)


replace monthly_salary=monthly_salary_min

drop monthly_salary_min

drop if duplicate>1

drop duplicate

************************************


* The demographic information of respondents are stored in separate tables
* in the row survey data so I have to merge these data to the wage income data.
* Again, I have prepared these data in advance and stored them in a dta format.
 
merge 1:1 year urban Address no using "./HIES/socio/demographics.dta", keepusing(year urban Address no gender age literacy studying deg) nogen keep(3)


drop if (age<15|age>64)



gen hours_month = hours_day * days_week * 4

gen hourly_salary = monthly_salary/hours_month

drop if hourly_salary==.



*** handling inconsistencies in coding the households address from 2005 (84 in Iranian Calender) to 2008 (86)

replace Address="0"+Address if (inlist(year, 84, 85, 86) & urban==0 & strlen(Address)==8)

replace Address="00"+Address if (inlist(year, 84, 85, 86) & urban==0 & strlen(Address)==7)

drop if strlen(Address)==5




*********** adding weights

merge m:1 Address year urban using "./HIES/weights/weight.dta", keepusing(Address year urban Weight) nogen keep(3) 

*************************



gen province_id = substr(Address, 2, 2)

order year province_id




tostring year, gen(Year)

gen Province_ID = province_id



***** adding minimum wage data

merge m:1 Year Province_ID using "./CPI/CPIMW8397.dta", nogen keep(3)

*****




drop if hourly_salary < 0.01*hourly_MW // drop extremes values




*** generating several variables to measure the incidence of minimum wage in several ways at the province level

gen between=((hourly_salary <= next_hourly_MW) & (hourly_salary >= hourly_MW))*Weight

gen affected=((hourly_salary >= former_hourly_MW) & (hourly_salary <= hourly_MW))*Weight

gen fraction_at = (hourly_salary>=0.95*hourly_MW  &  hourly_salary<=1.05*hourly_MW)*Weight



gen below= (hourly_salary < hourly_MW)*Weight 

gen below1_1 = (hourly_salary<1.1*hourly_MW)*Weight

gen below1_2 = (hourly_salary<1.2*hourly_MW)*Weight

gen below1_23 = (hourly_salary<1.23*hourly_MW)*Weight


gen below1_3 = (hourly_salary<1.3*hourly_MW)*Weight


gen below1_5 = (hourly_salary<1.5*hourly_MW)*Weight


gen bind = (hourly_salary<hourly_MW & hourly_MW<1.23*hourly_salary)*Weight


********************************************







*** checking if there are large enough number of observations at the province level 

by year province_id, sort: gen sample_num = _N 

****


compress
save "./HIES/wageIncome/wageIncomeCleaned.dta", replace





**** calculating min/median and some other indices 

tostring year, gen(year_st)

gen group = year_st+province_id


gen w_median = .                               

levelsof group, local(levels) 
qui foreach l of local levels { 
    summarize hourly_salary [w=Weight] if group == "`l'", detail 
    replace w_median = r(p50) if group == "`l'" 
 }


gen w_mean = .                               

levelsof group, local(levels) 
qui foreach l of local levels { 
    summarize hourly_salary [w=Weight] if group == "`l'"
    replace w_mean = r(mean) if group == "`l'" 
 }


gen med_min = w_median/hourly_MW

gen mean_min = w_mean/hourly_MW

gen min_med = hourly_MW / w_median

gen min_mean = hourly_MW / w_mean




collapse (min) med_min min_med  min_mean  mean_min hourly_MW sample_num CPI ///
        (sum) total=Weight          affected     between   below ///
	      bind       below1_3    below1_5 ///
	      below1_1   below1_2    below1_23 ///
	      fraction_at  ///
	, by(year province_id)
	
	
	

replace affected = (affected/total)*100

replace between = (between/total)*100

replace below = (below/total)*100

replace bind = (bind/total)*100

replace fraction_at = (fraction_at/total)*100





replace below1_1 = (below1_1/total)*100

replace below1_2 = (below1_2/total)*100

replace below1_23 = (below1_23/total)*100


replace below1_3 = (below1_3/total)*100

replace below1_5 = (below1_5/total)*100



bysort province_id (year): replace between = between[_n-1]



tostring year, replace

rename (year province_id) (Year Province_ID)





compress
save "./HIES/wageIncomeCol.dta", replace
