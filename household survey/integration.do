**** append wage income tables

cd "/home/jafar/RA/data/HIES/wageIncome"

clear

/// Urban

forvalues y = 84/98 {
    use "wageIncome_urban_`y'.dta"
    gen year = `y'
    
    if `y'==85 {
    rename ADDRESS Address
     }
    
    capture confirm numeric variable Address
                if !_rc {
			tostring Address, replace format("%12.0f")
                }
                else {
			
	                }
    
    capture confirm numeric variable DYCOL15
                if !_rc {
			
                }
                else {
			destring DYCOL15, replace force
                }
		
    capture confirm numeric variable DYCOL04
                if !_rc {
			
                }
                else {
			destring DYCOL04, replace force
                }
		
    save "wageIncome_urban_`y'.dta", replace
}



use "wageIncome_urban_84.dta", clear

forvalues y = 85/98 {
    append using "wageIncome_urban_`y'.dta", force
}


save "urban_wageIncome.dta", replace




/// Rural

forvalues y = 84/98 {
    use "wageIncome_rural_`y'.dta"
    gen year = `y'
    

    if `y'==85 {
       rename ADDRESS Address
     }
    
        capture confirm numeric variable Address
                if !_rc {

			tostring Address, replace format("%12.0f")
                }
                else {

                }
    
    capture confirm numeric variable DYCOL15
                if !_rc {
			
                }
                else {
			destring DYCOL15, replace force
                }
		
    capture confirm numeric variable DYCOL04
                if !_rc {
			
                }
                else {
			destring DYCOL04, replace force
                }

    save "wageIncome_rural_`y'.dta", replace
}


use "wageIncome_rural_84.dta", clear

forvalues y = 85/98 {
    append using "wageIncome_rural_`y'.dta", force
}

save "rural_wageIncome.dta", replace

append using "urban_wageIncome.dta", gen(urban)

compress
save "wageIncome.dta", replace



**** append wage demographic information tables

cd "/home/jafar/RA/data/HIES/socio"

clear

// urban

forvalues y = 84/98 {
    use "socio_urban_`y'.dta", clear
    gen year = `y'  
    if `y'==85 {
    rename ADDRESS Address
    }
    capture confirm numeric variable Address
                if !_rc {
			tostring Address, replace format("%12.0f")
                }
    capture confirm numeric variable DYCOL06
                if !_rc {
			tostring DYCOL06, replace format("%12.0f")
                }
    capture confirm numeric variable DYCOL07
                if !_rc {
			tostring DYCOL07, replace format("%12.0f")
                }
    capture confirm numeric variable DYCOL08
                if !_rc {
			tostring DYCOL08, replace format("%12.0f")
                }

    save "socio_urban_`y'.dta", replace
}


use "socio_urban_84.dta", clear

forvalues y = 85/98 {
    append using "socio_urban_`y'.dta"
}


save "urban_demographics.dta", replace



// Rural

forvalues y = 84/98 {
    use "socio_rural_`y'.dta", clear
    gen year = `y'
    if `y'==85 {
        rename ADDRESS Address
    }
    
    capture confirm numeric variable Address
                if !_rc {
			tostring Address, replace format("%12.0f")
                }
    capture confirm numeric variable DYCOL06
                if !_rc {
			tostring DYCOL06, replace format("%12.0f")
                }
    capture confirm numeric variable DYCOL07
                if !_rc {
			tostring DYCOL07, replace format("%12.0f")
                }
    capture confirm numeric variable DYCOL08
                if !_rc {
			tostring DYCOL08, replace format("%12.0f")
                }
        
    save "socio_rural_`y'.dta", replace
}



use "socio_rural_84.dta", clear

forvalues y = 85/98 {
    append using "socio_rural_`y'.dta"
}

save "rural_demographics.dta", replace


append using "urban_demographics.dta", gen(urban)

rename (DYCOL01 DYCOL03-DYCOL10) ///
(no relation gender age literacy studying deg labor married)

bysort year urban Address no: gen duplicate=_n

count if duplicate>1


compress
save "demographics.dta", replace

**** append weight tables

/// 84-89

cd "/home/jafar/RA/data/HIES/weights"


forvalues y=84/98{
    
    use "w`y'.dta", clear
        
    rename (HHID Year) (Address year)
    
    capture confirm numeric variable Address
                if !_rc {
			tostring Address, replace format("%12.0f")
                }
    
    if inlist(`y', 84, 85, 86){
	
	replace Address="0"+Address if strlen(Address)==8
	replace Address="00"+Address if strlen(Address)==7
	
    }
    
    gen urban=1 if (inlist(year, 84, 85, 86) & substr(Address, 1, 1)=="1")
    replace urban=0 if (inlist(year, 84, 85, 86) & substr(Address, 1, 1)=="0")
    
    replace urban=1 if ((!inlist(year, 84, 85, 86)) & substr(Address, 1, 1)=="1")
    replace urban=0 if ((!inlist(year, 84, 85, 86)) & substr(Address, 1, 1)=="2")
    
    save "weight`y'.dta", replace
    
}


use "weight84", clear

forvalues y=85/98 {
	append using "weight`y'.dta"
}

save "weight.dta", replace
