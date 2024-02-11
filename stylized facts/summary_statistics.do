cd "/home/jafar/RA/data/"

import delimited using "provinceName.csv", case(preserve) stringcols(_all) clear

merge 1:m Province_ID using "uninsured.dta", nogen

sort Province_ID Year

replace min_mean = min_mean * 100

replace min_med = min_med * 100


collapse (mean) uninsured_mean=uninsured affected_mean=affected unemp_mean=unemp small_mean=small ///
		bind_mean = bind    below_mean=below   below1_1_mean = below1_1    below1_2_mean = below1_2  below1_3_mean = below1_3 ///
		below1_23_mean = below1_23      mean_min_mean=mean_min           med_min_mean=med_min ///
		min_mean_mean = min_mean        min_med_mean = min_med /// 
        (sd)   uninsured_sd=uninsured    affected_sd=affected   unemp_sd=unemp   small_sd=small ///
	        below_sd=below      below1_23_sd = below1_23 ///
	       mean_min_sd=mean_min        med_min_sd=med_min ///
	       min_mean_sd=min_mean        min_med_sd=min_med ///
	, by(Province_Full_Name) 


order _all, alpha

sort uninsured_mean


// format affected_mean-uninsured_sd %6.5f

foreach var of varlist affected_mean-uninsured_sd {
  replace `var' = round(`var', 0.01)
}


label variable Province_Full_Name "Province"
label variable uninsured_mean "avg. uninsured (\%)"
label variable uninsured_sd "sd. uninsured (\%)"
label variable affected_mean "avg. affected (\%)"
label variable affected_sd "sd. affected (\%)"
label variable below_mean "avg. below (\%)"
label variable below_sd "sd. below (\%)"
label variable below1_23_mean "avg. below1\_23 (\%)"
label variable below1_23_sd "sd. below1\_23 (\%)"



preserve

gen id = _n

keep if inlist(id, 1, 2, 3, 4, 5, 6, 26, 27, 28, 29, 30, 31)

texsave Province_Full_Name uninsured_mean uninsured_sd below1_23_mean below1_23_sd ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat1Slide.tex", ///
frag replace size(small) width("\linewidth") hlines(6) varlabels nofix

restore


texsave Province_Full_Name uninsured_mean uninsured_sd below1_23_mean below1_23_sd ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat1.tex", ///
frag nofix replace size(normalsize) location("hb") width("\linewidth") varlabels ///
label("sumstat1") title("Descriptive statistics I") ///
footnote("\emph{Notes:} This table shows descriptive statistics of the uninsured rate and the incidence of the minimum wage law in Iranian provinces form 2005 to 2018. The latter is calculated by the baseline measure \emph{below1\_23} defined as the fraction of wage-earners whose wages are lower than 1.23 \(\times\) national minimum wage in a given year. avg and sd stand for average (arithmetic mean) and standard deviation, respectively.  Provinces are sorted in an ascending order based on their average uninsured rate.\\ \emph{Source:} Labor Force Survey (Columns 1-2) and Household Income and Expenditure Survey (Columns 3-4)")



////



label variable unemp_mean "avg. unemp. (\%)"
label variable unemp_sd "sd. unemp. (\%)"
label variable small_mean "avg. small (\%)"
label variable small_sd "sd. small (\%)"




preserve

gen id = _n

keep if inlist(id, 1, 2, 3, 4, 5, 6, 26, 27, 28, 29, 30, 31)


texsave Province_Full_Name small_mean small_sd unemp_mean unemp_sd  ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat2Slide.tex", ///
frag replace size(small) width("\linewidth") hlines(6) varlabels nofix 

restore



texsave Province_Full_Name small_mean small_sd unemp_mean unemp_sd ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat2.tex", ///
nofix frag replace size(normalsize) location("hb") width("\linewidth") varlabels ///
label("sumstat2") title("Descriptive statistics II") ///
footnote("\emph{Notes:} This table displays descriptive statistics of two variables of my study: the fraction of wage earners working in a firm with less than 5 workers (small) and the unemployment rate (unemp) of Iranina provinces form 2005 to 2018. avg and sd stand for average (arithmetic mean) and standard deviation, respectively. Similar to Table \ref{sumstat1}, provinces are sorted in an ascending order based on their average uninsured rate. \\ \emph{Source:} Labor Force Survey")


//////////////////////

label variable below_mean "avg. below (\%)"
label variable below_sd "sd. below (\%)"
label variable mean_min_mean "avg. mean-min"
label variable mean_min_sd "sd. mean-min"
label variable min_mean_mean "avg. min-mean (\%)"
label variable min_mean_sd "sd. min-mean (\%)"
label variable min_med_mean "avg. min-med (\%)"
label variable min_med_sd "sd. min-med (\%)"
label variable below1_23_mean "avg. below1\_23 (\%)"
label variable below1_23_sd "sd. below1\_23 (\%)"


texsave Province_Full_Name  below_mean  below_sd   min_mean_mean  min_mean_sd  min_med_mean   min_med_sd  ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat3.tex", ///
nofix frag replace size(normalsize) location("hb") width("\linewidth") varlabels ///
label("sumstat3") title("Descriptive statistics III") ///
footnote("\emph{Notes:} This table displays descriptive statistics of three measures for minimum wage bite in Iran's provinces from 2005 to 2018: \emph{below} defined as the fraction of wage earners in a province earning lower than national minimum wage level of the corresponding year, \emph{min-mean} defined as the national minimum wage over the average of wages in a given province in a year, and \emph{min-med} defined as the national minimum wage over the median of wages in a given province in a year. avg and sd stand for average (arithmetic mean) and standard deviation, respectively. Similar to Table \ref{sumstat1}, provinces are sorted in an ascending order based on their average uninsured rate. \\ \emph{Source:} Household Income and Expenditure Survey")


preserve

gen id = _n

keep if inlist(id, 1, 2, 3, 4, 5, 6, 26, 27, 28, 29, 30, 31)


texsave Province_Full_Name below1_23_mean  below1_23_sd   mean_min_mean  mean_min_sd  ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat3Slide.tex", ///
frag replace size(small) width("\hsize") hlines(6) varlabels nofix 

restore





//////
// estpost tabstat uninsured_mean affected_mean unemp_mean loghe_mean in 1/10, /// 
// by(Province_Full_Name) format

// esttab using "/home/jafar/Dropbox/RA/secondPres/tables/sumStat.tex" ///
// , cells("Province_Full_Name uninsured_mean affected_mean unemp_mean loghe_mean") ///
// noobs nomtitle nonumber varwidth(20) drop(Total)
/////


///////////// Document /////////////

label variable uninsured_mean "uninsured (\%)"

label variable below_mean "\(w<w_{min}\) (\%)"

label variable below1_1_mean "\(w< 1.1MW(\%)\)"

label variable below1_23_mean "\(w< 1.23w_{min}\) (\%)"

label variable below1_3_mean "wage \(<\) 1.3\(\times\)MW"

label variable bind_mean  "\(w_{min}< w <1.23w_{min}\)"

gen factor1= ((uninsured_mean - below_mean)/uninsured_mean)*100

label variable factor1 "\(f_1\) (\%)"

gen factor2= ((uninsured_mean - below1_23_mean)/uninsured_mean)*100

label variable factor2 "\(f_2\) (\%)"

foreach var of varlist factor1 factor2 {
  replace `var' = round(`var', 0.01)
}

texsave Province_Full_Name  uninsured_mean    below_mean     below1_23_mean  factor1   factor2   ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/sumStat4.tex", ///
nofix frag replace size(normalsize) location("hb") width("\linewidth") varlabels ///
label("sumstat4") title("Comparison between the fraction of uninsured wage-earners and those with different wages (province-level)") ///
footnote("\emph{Notes}: This table contains the average (arithmetic mean) of uninsured rate (Column 2) as well as the averages of the fraction of wage-earners whose wages are lower than minimum wage (Column 3) and 1.23\(\times\)minimum wage (Column 4) in provinces of Iran from 2005 to 2018. \(f_1\) (Column 5) and \(f_2\) (Column 6) show the calculated values of \eqref{f1} and \eqref{f2}, respectively . \\ \emph{Source}: Iran's Labor Force Survey (Column 1) and Iran's Household Income and Expenditure Survey (Columns 2 and 3)")


//////////// nominal MW ////////////////

import delimited using "/home/jafar/RA/data/CPI/nationalMW8397.csv", clear case(preserve)

label variable Year "Year"

label variable nationalMW "National minimum wage (IRR)"

replace Year = Year + 1921

gen increase = ((nationalMW[_n]-nationalMW[_n-1])/nationalMW[_n])*100

texsave Year nationalMW   ///
using "/home/jafar/Dropbox/RA/EnglishThesis/tables/nationalMW.tex", ///
nofix frag replace size(normalsize) location("hb") width("0.5\linewidth") varlabels ///
label("nationalMW") title("National nominal minimum wage in Iran (2005-2018)") ///
footnote("\emph{Notes:} This table reports the national minimum wage in the nominal term from 2005-2018. \\ \emph{Source:} Ministry of Cooperatives, Labour, and Social Welfare")
