***************************************************
*Table 3: Team-years included in sample for Alabama
***************************************************
// done
use "${route}/data/analysis_set.dta", clear

keep if meetnum < 11 // we only do through meetweek 10...
keep if host!=""	 // with non-neutral hosts!

gen at = host=="Alabama"
bysort team year: egen visited_bama = sum(at)
drop if visited_bama==0 | team=="Alabama" // now it's only the teams that visited Alabama in those seasons!!

cap log close
log using "${route}/output/table3.txt", text replace nomsg

tab team year

log close
*/