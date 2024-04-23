/*

https://hub.arcgis.com/datasets/esri::usa-states-generalized/explore?location=31.622371%2C-86.166902%2C3.63

*/

global route "/Users/tmac/Desktop/uneven_bars"

import delimited using "$route/data/school_latlons.csv", varn(1) clear

rename (lat lon) (_Y _X)

drop if team=="Alaska"

save "$route/data/school_coords.dta", replace



cd "$route/data/cb_2021_us_state_500k"

shp2dta using cb_2021_us_state_500k, data(data) coord(coords) replace

use coords, clear

merge m:1 _ID using data, keep(1 3) nogen

drop if inlist(STATEFP, "02", "15", "72", "60", "66", "69", "78")

gen states = 1

append using "$route/data/school_coords.dta"

recode states (.=0)


twoway area _Y _X if states==1, cmiss(n) fi(25) col(gray) leg(off) ysc(off) yla(,nogrid) xla(,nogrid) xsc(off) graphr(fc(white)) || scatter _Y _X if states==0 & had2021==0 || scatter _Y _X if states==0 & had2021==1
