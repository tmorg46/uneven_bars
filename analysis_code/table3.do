***************************************************
*Table 3: Team-years included in sample for Alabama
***************************************************
// done
use "${route}/data/analysis_set.dta", clear

keep if meetnum < 10 				// we only do through meet 9...
keep if host!=""	 				// with non-neutral hosts...
keep if meettitle=="no meet title"	// and no meet title (i.e. invitationals, playoffs)

gen at = host=="Alabama"
bysort team year: egen visited_bama = sum(at)
drop if visited_bama==0 | team=="Alabama" // now it's only the teams that visited Alabama in those seasons!!

cap log close
log using "${route}/output/table3.txt", text replace nomsg

tab team year

log close
*/