clear

cd "/home/jafar/RA/data"

use "lfsInformal.dta", clear

recode Age (10/14=1 child) (15/24 = 2 young) (25/44=3 prime) (45/64=4 old) (65/200 = 5 retired), gen(ageCategory)

order ageCategory, after(Age)


gen total = Adj_IW_Seasonly/4


gen employed = (Employment==1) * Adj_IW_Seasonly/4

gen unemployed = (Employment==3) * Adj_IW_Seasonly/4





gen wage_earner = (job1Class == 4)*Adj_IW_Seasonly/4 
 
gen wage_earner2 = (job1Class == 4 & !inlist(staffNum, 1))*Adj_IW_Seasonly/4

gen uninsured = (job1Class == 4 & insurance == 2)*Adj_IW_Seasonly/4 //similar to the second criteria of recent report of SCI
					// concides with what erfani(2018) calls administrative informal employment

gen uninsured2 = (job1Class == 4 & insurance == 2 & !inlist(staffNum, 1))*Adj_IW_Seasonly/4


// The following index is similar to the fifth criteria of the recent report of SCI about informal employment  
// concides with what erfani(2018) calls non-administrative informal employment except that this index includes second
// job classification as well 
gen self_emp = (job1Class == 2 | job1Class == 3 | job2Class==2 | job2Class==3)*Adj_IW_Seasonly/4 

gen small = (inlist(staffNum, 1) & job1Class == 4)*Adj_IW_Seasonly/4




gen construction = (sector=="Construction")*Adj_IW_Seasonly/4


gen manufacturing = (sector=="Manufacturing")*Adj_IW_Seasonly/4


gen hotel_restu = (sector=="Hotels and restaurants")*Adj_IW_Seasonly/4


gen transit = (sector=="Transport, storage and communications")*Adj_IW_Seasonly/4





compress

save "./informal/informalIndicator.dta", replace


by Year Province_ID, sort: gen sample_num = _N


collapse (min) sample_num (sum) workingAge=total employed unemployed uninsured uninsured2 wage_earner wage_earner2 self_emp ///
                                small   construction    manufacturing    hotel_restu  transit ///
                                if inrange(ageCategory,2,4), by(Year Province_ID)

 

drop if sample_num<30




replace uninsured = uninsured/wage_earner*100

replace uninsured2 = uninsured2/wage_earner2*100

replace self_emp = self_emp/employed*100

gen unemp = (unemployed / (employed + unemployed))*100

replace small = small/wage_earner*100

replace wage_earner = wage_earner/employed*100



compress
save "./informal/informalIndicatorCol.dta", replace
