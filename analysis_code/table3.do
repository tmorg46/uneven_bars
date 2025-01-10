***************************************************
*Table 3: Team-years included in sample for Alabama
***************************************************
// done
use "${route}/data/analysis_set.dta", clear

keep if division==1	// just the D1 players...
keep if meettitle=="no meet title" & host!="" // and just the ordinary meets

gen at = host=="Alabama"
bysort team year: egen visited_bama = sum(at)
drop if visited_bama==0 | team=="Alabama" // now it's only the teams that visited Alabama in those seasons!!

cap log close
log using "${route}/output/table3.txt", text replace nomsg

tab team year

log close
*/