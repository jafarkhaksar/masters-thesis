clear

use /home/jafar/RA/data/lfsRaw/lfs8486sector.dta

rename(F2_D03 F3_D07 F3_D08 F3_D28 F3_D29) (relation sector occ former_sector former_occ)

destring sector, replace force

destring former_sector, replace force


gen employed = (ActivityStatus==1) * IW10_Yearly

gen unemployed = (ActivityStatus==2) * IW10_Yearly

************************************

gen construction=0

replace construction = IW10_Yearly if (sector>=4510 & sector<=4552) & employed!=0


gen manufacturing=0

replace manufacturing = IW10_Yearly if (sector>=1512 & sector<=3720) & employed!=0


gen hotel_restu = 0

replace hotel_restu = IW10_Yearly if(sector>=5510 & sector<=5529) & employed!=0


gen transit = 0

replace transit = IW10_Yearly if(sector>=6010 & sector<=6429) & employed!=0



************************************


gen former_construction=0

replace former_construction = IW10_Yearly if (former_sector>=4510 & former_sector<=4552) & unemployed!=0


gen former_manufacturing=0

replace former_manufacturing = IW10_Yearly if (former_sector>=1512 & former_sector<=3720) & unemployed!=0


gen former_hotel_restu = 0

replace former_hotel_restu = IW10_Yearly if(former_sector>=5510 & former_sector<=5529) & unemployed!=0


gen former_transit = 0

replace former_transit = IW10_Yearly if(former_sector>=6010 & former_sector<=6429) & unemployed!=0



**************************************

tostring pkey, replace

gen year = substr(pkey, 1, 2)

gen province_id = substr(pkey, 3, 2)


// consider ages

collapse(sum) total = IW10_Yearly construction           manufacturing          hotel_restu         transit ///
				  former_construction    former_manufacturing   former_hotel_restu  former_transit ///
	, by(year province_id)



gen unemp_construction = (former_construction/(former_construction+construction))*100

gen unemp_manufacturing = (former_manufacturing/(former_manufacturing+manufacturing))*100

gen unemp_hotel_restu = (former_hotel_restu/(former_hotel_restu+hotel_restu))*100

gen unemp_transit = (former_transit/(former_transit+transit))*100



save /home/jafar/RA/data/lfsRaw/lfs8486sectorCol.dta, replace


*****************************************************************************

use /home/jafar/RA/data/lfsRaw/lfs8791sector.dta, clear

rename(F2_D01 F2_D03 F2_D07 F3_D09 F3_D10 F3_D41 F3_D42) (radif relation age occ sector former_occ former_sector)

destring age, replace force

drop if age<15
drop if age>64

destring sector, replace force

destring former_sector, replace force


gen employed = (ActivityStatus==1) * IW10_Yearly

gen unemployed = (ActivityStatus==2) * IW10_Yearly

************************************

gen construction=0

replace construction = IW10_Yearly if (sector>=4510 & sector<=4550) & employed!=0


gen manufacturing=0

replace manufacturing = IW10_Yearly if (sector>=1512 & sector<=3800) & employed!=0


gen hotel_restu = 0

replace hotel_restu = IW10_Yearly if(sector>=5510 & sector<=5527) & employed!=0


gen transit = 0

replace transit = IW10_Yearly if(sector>=6010 & sector<=6309) & employed!=0


************************************


gen former_construction=0

replace former_construction = IW10_Yearly if (former_sector>=4510 & former_sector<=4550) & unemployed!=0


gen former_manufacturing=0

replace former_manufacturing = IW10_Yearly if (former_sector>=1512 & former_sector<=3800) & unemployed!=0


gen former_hotel_restu = 0

replace former_hotel_restu = IW10_Yearly if(former_sector>=5510 & former_sector<=5527) & unemployed!=0


gen former_transit = 0

replace former_transit = IW10_Yearly if(former_sector>=6010 & former_sector<=6309) & unemployed!=0


**************************************

tostring pkey, replace

gen year = substr(pkey, 1, 2)

gen province_id = substr(pkey, 3, 2)



collapse(sum) total = IW10_Yearly construction           manufacturing          hotel_restu           transit ///
				  former_construction    former_manufacturing   former_hotel_restu    former_transit ///
	, by(year province_id)



gen unemp_construction = (former_construction/(former_construction+construction))*100

gen unemp_manufacturing = (former_manufacturing/(former_manufacturing+manufacturing))*100

gen unemp_hotel_restu = (former_hotel_restu/(former_hotel_restu+hotel_restu))*100

gen unemp_transit = (former_transit/(former_transit+transit))*100

save /home/jafar/RA/data/lfsRaw/lfs8791sectorCol.dta, replace

********************************************************************************


use /home/jafar/RA/data/lfsRaw/lfs9295sector.dta, clear

drop IW15_Yearly

rename (IW10_Yearly) (IW_Yearly)

append using /home/jafar/RA/data/lfsRaw/lfs9698sector.dta

rename(F2_D01 F2_D03 F2_D07 F3_D09 F3_D10 F3_D41 F3_D42) (radif relation age occ sector former_occ former_sector)

destring age, replace force

drop if age<15
drop if age>64

destring sector, replace force

destring former_sector, replace force


gen employed = (ActivityStatus==1) * IW_Yearly

gen unemployed = (ActivityStatus==2) * IW_Yearly

************************************

gen construction=0

replace construction = IW_Yearly if (sector>=41000 & sector<=43900) & employed!=0


gen manufacturing=0

replace manufacturing = IW_Yearly if (sector>=10101 & sector<=34000) & employed!=0


gen hotel_restu = 0

replace hotel_restu = IW_Yearly if(sector>=55100 & sector<=56310) & employed!=0


gen transit = 0

replace transit = IW_Yearly if(sector>=49110 & sector<=52290) & employed!=0


************************************


gen former_construction=0

replace former_construction = IW_Yearly if (former_sector>=41000 & former_sector<=43900) & unemployed!=0


gen former_manufacturing=0

replace former_manufacturing = IW_Yearly if (former_sector>=10101 & former_sector<=34000) & unemployed!=0


gen former_hotel_restu = 0

replace former_hotel_restu = IW_Yearly if(former_sector>=55100 & former_sector<=56310) & unemployed!=0


gen former_transit = 0

replace former_transit = IW_Yearly if(former_sector>=49110 & former_sector<=52290) & unemployed!=0


**************************************

tostring pkey, replace

gen year = substr(pkey, 1, 2)

gen province_id = substr(pkey, 3, 2)



collapse(sum) total = IW_Yearly   construction           manufacturing          hotel_restu             transit ///
				  former_construction    former_manufacturing   former_hotel_restu      former_transit  ///
	, by(year province_id)



gen unemp_construction = (former_construction/(former_construction+construction))*100

gen unemp_manufacturing = (former_manufacturing/(former_manufacturing+manufacturing))*100

gen unemp_hotel_restu = (former_hotel_restu/(former_hotel_restu+hotel_restu))*100

gen unemp_transit = (former_transit/(former_transit+transit))*100

save /home/jafar/RA/data/lfsRaw/lfs9298sectorCol.dta, replace

*************************** append *****************************

use /home/jafar/RA/data/lfsRaw/lfs8486sectorCol.dta, clear


append using /home/jafar/RA/data/lfsRaw/lfs8791sectorCol.dta


append using /home/jafar/RA/data/lfsRaw/lfs9298sectorCol.dta



rename (year province_id) (Year Province_ID)



compress

save /home/jafar/RA/data/lfsFormerSector.dta, replace
