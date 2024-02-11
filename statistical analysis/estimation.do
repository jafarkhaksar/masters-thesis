cd "/home/jafar/RA/data/"

use "./HIES/wageIncomeCol.dta", clear



merge 1:1 Year Province_ID using "./informal/informalIndicatorCol.dta", keepusing(Year Province_ID uninsured unemp small) nogen keep(3)


label variable fraction_at ""
label variable bind ""
label variable below ""
label variable below1_1 ""
label variable below1_2 ""
label variable below1_23 ""
label variable below1_3 ""
label variable below1_5 ""
label variable mean_min ""
label variable med_min ""
label variable affected ""
label variable between ""
label variable small ""
label variable uninsured ""
label variable CPI ""


compress
save "uninsured.dta", replace




replace Province_ID="31" if Province_ID=="00"

destring Year Province_ID, replace


xtset Province_ID Year

tsset Province_ID Year

// xtreg

forvalues y=84/97 {
	gen yr`y' = Year==`y'
}



// fixed effect estimation

eststo clear


*******below1_23***********
reg uninsured below1_23 small unemp CPI yr85-yr97, cluster(Province_ID) level(95)
eststo pooled_ctrl
estadd local Years "Yes" , replace
estadd local Provinces "No" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


xtreg uninsured below1_23 yr85-yr97, fe cluster(Province_ID) level(95)
eststo fe
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


xtreg uninsured below1_23 small yr85-yr97, fe cluster(Province_ID) level(95)
eststo fe_small
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


xtreg uninsured below1_23 small unemp CPI yr85-yr97, fe cluster(Province_ID) level(95)
eststo fe_ctrl
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)




esttab pooled_ctrl fe fe_small fe_ctrl /// 
       using "/home/jafar/Dropbox/RA/secondPres/tables/fe.tex", replace booktabs ///
       p br nostar scalars(N N_g) keep(below small unemp CPI) width(\hsize) label       ///
       nonumbers mtitles("OLS" "FE" "FE" "FE") indicate("Years=yr85" "Provinces=_IProvince__2") ///
       addnote("Standard errors are clustered at the province level")


esttab pooled_ctrl fe fe_small fe_ctrl /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/fe.tex", replace booktabs ///
       p br nostar noobs scalars(Years Provinces N MeanDep N_clust) keep(below1_23 small unemp CPI) label width(0.7\hsize)      ///
       title("Estimation results of the unobserved effects model for all workers" \label{fe}) ///
       nonumbers mtitles("OLS" "LSDV" "LSDV" "LSDV")  ///
       postfoot( ///
       "\tabnotes{5}{\textit{Notes:} \textit{p}-values in brackets \newline" ///
       "This table reports the estimation results of equation \eqref{uem} for all workers. The dependent variable is the uninsured rate of a province in given year of the study period (2005-2018), with MeanDep denoting its arithmetic mean. Independent variables are as follows: the share of wage_earners whose wages are lower than 1.23\(\times\)minimum wage (below1_23), the once-lagged dependent variable (L.uninsured), the share of wage-earners working in a firm with less than 5 workers (small), the unemployment rate (unemp), and the consumer price index (CPI). The second column shows the pooled OLS estimation results while the remaining columns display least squares dummy variable (LSDV) or fixed effects estimation results. The standard errors are clustered at the province level, and N_clust denotes the number of clusters.}" ///
       )

**********************************







// Robustness check---using alternative MW incidence measures

use "uninsured.dta", clear

replace Province_ID="31" if Province_ID=="00"

destring Year Province_ID, replace


xtset Province_ID Year

tsset Province_ID Year

// xtreg

forvalues y=84/97 {
	gen yr`y' = Year==`y'
}


eststo clear



xtreg uninsured below unemp small CPI yr85-yr97, fe cluster(Province_ID)
eststo fe_below


xtreg uninsured mean_min unemp small CPI yr85-yr97, fe cluster(Province_ID)
eststo fe_mean_min


xtreg uninsured med_min unemp small CPI yr85-yr97, fe cluster(Province_ID)
eststo fe_med_min


esttab using "/home/jafar/Dropbox/RA/secondPres/tables/fe_robust.tex", replace booktabs ///
      p scalars(N N_g) keep(below mean_min med_min) width(\hsize) label       ///
      nonumbers mtitles("(1)" "(2)" "(3)")  ///
      addnote("Standard errors clustered by province.")

*****


///////////// dynamic panel data (Arellano Bond estimator)

cd "/home/jafar/RA/data/"

use "uninsured.dta", clear


replace Province_ID="31" if Province_ID=="00"

destring Year Province_ID, replace


xtset Province_ID Year

tsset Province_ID Year


forvalues y=84/97 {
	gen yr`y' = Year==`y'
}


sort Province_ID

by Province_ID: gen L_uninsured = uninsured[_n-1]

order L_uninsured, after(uninsured)

eststo clear


******************************** Difference GMM **************************

reg uninsured below L_uninsured small unemp CPI yr85-yr97, cluster(Province_ID) level(95)
eststo ols
estadd local Collapsed "" , replace
estadd local Years "Yes" , replace
estadd local Provinces "No" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)




xtabond2 uninsured below L_uninsured small unemp CPI yr85-yr96 , nodiffsargan level(95) ///
gmm(L_uninsured, lag(3 3)) iv(below small unemp CPI yr85-yr96, eq(diff)) nol orthogonal small robust two
eststo ab0
estadd local Collapsed "No" , replace
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


xtabond2 uninsured below L_uninsured small unemp CPI yr85-yr96, nodiffsargan level(95) ///
gmm(L_uninsured below small unemp CPI, lag(3 3)) iv(yr85-yr96, eq(diff)) nol orthogonal small robust two
eststo ab_ctrl
estadd local Collapsed "No" , replace
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)



xtabond2 uninsured below L_uninsured small unemp CPI yr85-yr96, nodiffsargan level(95) ///
gmm(L_uninsured below small unemp CPI, lag(3 3) collapse) iv(yr85-yr96, eq(diff)) nol orthogonal small two robust 
eststo ab_ctrl_col
estadd local Collapsed "Yes" , replace
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


esttab ols ab0 ab_ctrl ab_ctrl_col   ///
       using "/home/jafar/Dropbox/RA/secondPres/tables/ab.tex", replace booktabs   ///
       p br scalars(N ar2p j) keep(affected L_uninsured small unemp CPI) width(\hsize) label       ///
       nonumbers mtitles("OLS" "DGMM" "DGMM" "DGMM")  ///
       addnote("j denotes number of instruments")


esttab ols ab0 ab_ctrl ab_ctrl_col   /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/ab.tex", replace booktabs width(0.7\hsize) ///
       p br nostar noobs scalars(Years Provinces N MeanDep ar2p j Collapsed)  keep(below L_uninsured small unemp CPI) label       ///
       title("Estimation results of the dynamic panel data model for all workers" \label{ab}) ///
       nonumbers mtitles("OLS" "DGMM" "DGMM" "DGMM")  ///
       postfoot( ///
       "\tabnotesAB{5}{\textit{Notes:} \textit{p}-values in brackets \newline" ///
       "This table reports the estimation results of equation \eqref{dpdm} for all workers. The unit of observtion is province-year. The dependent variable is the uninsured rate of a province in given year of the study period (2005-2018), with MeanDep denoting its arithmetic mean. The first column reports the pooled OLS estimation results while the remaining columns shows those of difference GMM. In the second column, only the lagged dependent variable (L_uninsured) is considered as endogenous whearas, in the third and fourth columns, all explanatory variables are considered so. Each GMM column displays results of a two-step difference GMM estimation where only the second lags of endogenous variables are used as instruments to avoid the problem of instrument proliferation. Also, the forward orthogonal deviations transformation is used instead of first-differencing to maximize the sample size. The difference between the third and fourth columns is that the number of instruments (j) is further restricted in the latter via the collapsing technique. The standard errors are Windmeijer-corrected. ar2p denotes \textit{p}-value of the Arellano-Bond test for AR(2) in first differences. GMM estimatons and the related tests are implemented by \citeauthor{roodman2009xtabond2}'s (\citeyear{roodman2009xtabond2}) \texttt{xtabond2} Stata command.}" ///
       )
       
*********************SYSTEM GMM************************************
eststo clear

reg uninsured below L_uninsured small unemp CPI yr85-yr96, cluster(Province_ID) level(95)
eststo ols
estadd local Collapsed "" , replace
estadd local Years "Yes" , replace
estadd local Provinces "No" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)





xtabond2 uninsured below L_uninsured small unemp CPI yr85-yr96 , nodiffsargan level(95) ///
gmm(L_uninsured, lag(3 3)) iv(below small unemp CPI yr85-yr96, eq(level)) orthogonal small robust two
eststo ab0
estadd local Collapsed "No" , replace
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


xtabond2 uninsured below L_uninsured small unemp CPI yr85-yr96, nodiffsargan level(95) ///
gmm(L_uninsured below small unemp CPI, lag(3 3)) iv(yr85-yr96, eq(level)) orthogonal small robust two
eststo ab_ctrl
estadd local Collapsed "No" , replace
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)



xtabond2 uninsured below L_uninsured small unemp CPI yr85-yr96, nodiffsargan level(95) ///
gmm(L_uninsured below small unemp CPI, lag(3 3) collapse) iv(yr85-yr96, eq(level)) orthogonal small two robust 
eststo ab_ctrl_col
estadd local Collapsed "Yes" , replace
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)


esttab ols ab0 ab_ctrl ab_ctrl_col   /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/abSys.tex", replace booktabs width(0.7\hsize) ///
       p br nostar noobs scalars(Years Provinces N MeanDep ar2p j Collapsed)  keep(below L_uninsured small unemp CPI) label       ///
       title("Estimation results of the dynamic panel data model for all workers" \label{abSys}) ///
       nonumbers mtitles("OLS" "SGMM" "SGMM" "SGMM")  ///
       postfoot( ///
       "\tabnotesAB{5}{\textit{Notes:} \textit{p}-values in brackets \newline" ///
       "This table reports the estimation results of equation \eqref{dpdm} for all workers. The unit of observation is province-year. The dependent variable is the uninsured rate of a province in given year of the study period (2005-2018), with MeanDep denoting its arithmetic mean. The first column reports the pooled OLS estimation results while the remaining columns shows those of system GMM. In the second column, only the lagged dependent variable (L_uninsured) is considered as endogenous whereas, in the third and fourth columns, all explanatory variables are considered so. Each GMM column displays results of a two-step system GMM estimation where only the second lags of endogenous variables are used as instruments to avoid the problem of instrument proliferation. Also, the forward orthogonal deviations transformation is used instead of first-differencing to maximize the sample size. The difference between the third and fourth columns is that the number of instruments (j) is further restricted in the latter via the collapsing technique. The standard errors are Windmeijer-corrected. ar2p denotes \textit{p}-value of the Arellano-Bond test for AR(2) in first differences. GMM estimatons and the related tests are implemented by \citeauthor{roodman2009xtabond2}'s (\citeyear{roodman2009xtabond2}) \texttt{xtabond2} Stata command.}" ///
       )



*****************************LSDVC**********************************
xtset Province_ID Year

xtreg uninsured below1_23 l(1).uninsured yr85-yr97, fe cluster(Province_ID)
eststo lsdv1
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep = r(mean)



xtreg uninsured below1_23 l(1).uninsured small yr85-yr97, fe cluster(Province_ID)
eststo lsdv2
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)



xtreg uninsured below1_23 l(1).uninsured small unemp CPI yr85-yr97, fe cluster(Province_ID)
eststo lsdv3
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)



xtlsdvc uninsured below1_23 small unemp CPI yr85-yr97, initial(ab) bias(3) vcov(400) level(99)
eststo lsdvc
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)



esttab lsdv1 lsdv2 lsdv3 lsdvc   /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/lsdvc.tex", replace booktabs width(0.7\hsize) ///
       p br nostar noobs scalars(Years Provinces N MeanDep)  keep(below1_23 L.uninsured small unemp CPI) label       ///
       title("Estimation results of the dynamic panel data model for all workers" \label{lsdvc}) ///
       nonumbers mtitles("LSDV" "LSDV" "LSDV" "CLSDV")  ///
       postfoot( ///
       "\tabnotesAB{5}{\textit{Notes:} \textit{p}-values in brackets \newline" ///
       "This table reports the estimation results of equation \eqref{dpdm} for all workers. The unit of observation is province-year. The dependent variable is the uninsured rate of a province in given year of the study period (2005-2018), with MeanDep denoting its arithmetic mean. Independent variables are as follows: the share of wage-earners whose wages are lower than 1.23\(\times\)minimum wage (below1_23), the once-lagged dependent variable (L.uninsured), the share of wage-earners working in a firm with less than 5 workers (small), the unemployment rate (unemp), and the consumer price index (CPI). Columns 2-4 report the least squares dummy variable (LSDV) or fixed effects estimation results. Standard errors are clustered at the province level (31 clusters). The fifth column reports those of the corrected LSDV (CLSDV). The standard errors are obtained by calculating the standard deviation of 200 bootstrap replications of corrected LSDV estimates. These are implemented by \citeauthor{bruno2005estimation}'s (\citeyear{bruno2005estimation}) \texttt{xtlsdvc} Stata\textsuperscript{\textregistered} command.}" ///
       )
******************** LSDV Below ***********************
eststo clear


xtset Province_ID Year

xtreg uninsured below l(1).uninsured yr85-yr97, fe cluster(Province_ID)
eststo lsdv1
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep = r(mean)



xtreg uninsured below l(1).uninsured small yr85-yr97, fe cluster(Province_ID)
eststo lsdv2
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)



xtreg uninsured below l(1).uninsured small unemp CPI yr85-yr97, fe cluster(Province_ID)
eststo lsdv3
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep= r(mean)



xtlsdvc uninsured below small unemp CPI yr85-yr97, initial(ab) bias(3) vcov(200)
eststo lsdvc
estadd local Years "Yes" , replace
estadd local Provinces "Yes" , replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)



esttab lsdv1 lsdv2 lsdv3 lsdvc   /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/lsdvcSlide.tex", replace booktabs  ///
       p br nostar noobs scalars(N MeanDep)  keep(below L.uninsured small unemp CPI) label       ///
       title("Estimation results for all workers" \label{lsdvcSlide}) ///
       nonumbers mtitles("LSDV" "LSDV" "LSDV" "CLSDV")


*****************************************************       
       
*********************       
estwide ols ab0 ab_ctrl ab_ctrl_col   /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/abWide.tex", replace booktabs style(tex) alignment(c) nodepvar ///
       p br nostar scalars(N j ar2p) keep(affected L_uninsured small unemp CPI) label  width(0.7\hsize)    ///
       title("Estimation results of the dynamic panel data model for all workers" \label{ab}) ///
       nonumbers mtitles("OLS" "DGMM" "DGMM" "DGMM")  ///
       postfoot( ///
       "\tabnotesAB{5}{\textit{Notes:} \textit{p}-values in brackets \newline" ///
       "This table reports the estimation results of equation \eqref{dpdm} for all workers. The first column reports the pooled OLS estimation results while the remaining columns shows those of difference GMM. In the second column, only the lagged dependent variable (L_uninsured) is considered as endogenous whearas, in the third and fourth columns, all explanatory variables are considered so. Each GMM columns displays results of a two-step difference GMM estimation where only the second lags of endogenous variables are used as instruments to avoid the problem of instrument proliferation. Also, the forward orthogonal deviations transformation is used instead of first-differencing to maximize the sample size. The difference between the third and fourth columns is that the number of instruments (j) is further restricted in the latter via the collapsing technique. The standard errors are Windmeijer-corrected. ar2p denotes \textit{p}-value of the Arellano-Bond test for AR(2) in first differences. GMM estimatons and the related tests are implemented by \citeauthor{roodman2009xtabond2}'s (\citeyear{roodman2009xtabond2}) \texttt{xtabond2} Stata command.}" ///
       )


// robustness checks alternative minimum wage incidence measures

cd "/home/jafar/RA/data/"


use "uninsured.dta", clear


replace Province_ID="31" if Province_ID=="00"

destring Year Province_ID, replace


xtset Province_ID Year

tsset Province_ID Year


forvalues y=84/97 {
	gen yr`y' = Year==`y'
}


sort Province_ID

by Province_ID: gen L_uninsured = uninsured[_n-1] // missing value genereted



replace min_mean = min_mean*100


replace min_med = min_med*100

eststo clear



***below1_23
xtlsdvc uninsured below1_23 small unemp CPI yr85-yr97, initial(ab) bias(3) vcov(200)
eststo lsdvc
estadd local Years "Yes" , replace
estadd local Provinces "Yes", replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)

***


*** below
xtlsdvc uninsured below small unemp CPI yr85-yr97, initial(ab) bias(3) vcov(200)
eststo lsdvc_below
estadd local Years "Yes", replace
estadd local Provinces "Yes", replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)


*** min_mean
xtlsdvc uninsured min_mean small unemp CPI yr85-yr97, initial(ab) bias(3) vcov(200)
eststo lsdvc_min_mean
estadd local Years "Yes", replace
estadd local Provinces "Yes", replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)



*** min_mean
xtlsdvc uninsured min_med small unemp CPI yr85-yr97, initial(ab) bias(3) vcov(200)
eststo lsdvc_min_med
estadd local Years "Yes", replace
estadd local Provinces "Yes", replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)
***

label variable min_mean ""

label variable min_med ""



esttab   lsdvc  lsdvc_below lsdvc_min_mean   lsdvc_min_med /// 
         using "/home/jafar/Dropbox/RA/secondPres/tables/ab_alt.tex", replace booktabs ///
         p br nostar scalars(N j) keep(below below1_23 mean_min) width(\hsize) label       ///
         nonumbers mtitles("DGMM" "DGMM" "DGMM" "DGMM") ///
         addnote("j denotes number of instruments")



esttab lsdvc  lsdvc_below lsdvc_min_mean   lsdvc_min_med  /// 
       using "/home/jafar/Dropbox/RA/EnglishThesis/tables/lsdvcAlt.tex", replace booktabs width(0.7\hsize) ///
       p br nostar noobs scalars(N Years Provinces MeanDep)  /// 
       keep(below1_23 below min_mean min_med) label       ///
       title("Estimation results using alternative measures for minimum wage incidence" \label{lsdvcAlt}) ///
       nonumbers mtitles("CLSDV"   "CLSDV"   "CLSDV"  "CLSDV")  ///
       postfoot( ///
       "\tabnotesAB{5}{\textit{Notes:} \textit{p}-values in brackets \newline" ///
       "This table reports the estimation results of equation \eqref{dpdm} for all workers using alternative measures for minimum wage incidence. Each column shows the estimated effect of minimum wage on informal employment obtained by an alternative, namely, the fraction of wage earners whose wage levels are lower than the minimum wage level of a given year (below), the minimum wage over the arithmetic mean of wages in the percentage format (min_mean), and the minimum wage over the median of wages in the percentage format (min_med). The unit of observation is province-year. The dependent variable is the uninsured rate of a province in given year of the study period (2005-2018), with MeanDep denoting its arithmetic mean. All control variables in \eqref{dpdm} are present in the corresponding specifications. Year and province fixed effects are also included. The standard errors are obtained by calculating the standard deviation of 200 bootstrap replications of corrected LSDV estimates. These are implemented by \citeauthor{bruno2005estimation}'s (\citeyear{bruno2005estimation}) \texttt{xtlsdvc} Stata\textsuperscript{\textregistered} command.}" ///
       )

** width(0.7\hsize)


// PRE-2015 period 

cd "/home/jafar/RA/data/"

use "uninsured.dta", clear


replace Province_ID="31" if Province_ID=="00"

destring Year Province_ID, replace


xtset Province_ID Year

tsset Province_ID Year


forvalues y=84/97 {
	gen yr`y' = Year==`y'
}


sort Province_ID

by Province_ID: gen L_uninsured = uninsured[_n-1]



keep if Year<94


eststo clear

xtlsdvc uninsured below1_23 small unemp CPI yr85-yr93, initial(ab) bias(3) vcov(200)
eststo lsdvc_pre2014
estadd local Years "Yes", replace
estadd local Provinces "Yes", replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)


xtlsdvc uninsured below small unemp CPI yr85-yr93, initial(ab) bias(3) vcov(200)
eststo lsdvc_pre2014
estadd local Years "Yes", replace
estadd local Provinces "Yes", replace
qui sum `e(depvar)' if e(sample)
estadd scalar MeanDep  = r(mean)

***

