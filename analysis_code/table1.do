**************************************************************
*Table 1: Comparing our demographic ratios to the overall NCAA
**************************************************************
// done
use "${route}/data/analysis_set.dta", clear

collapse score, by(gymnast_id year ncaa_race) // get it down to a gymnast count by race and year to get a unique count of scorers

cap log close 
log using "${route}/output/table1.txt", text replace nomsg

foreach year of numlist 2015/2024 {
	
	di "tabs for `year':"
	tab ncaa_race if year==`year' // we want to go year-by-year so it gives us %ages as well as counts to make it easier for the table!
}

log close
*/