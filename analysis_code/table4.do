*******************************************************************
*Table 4a: Find venues with significant Black-to-White coefficients 
*******************************************************************
// done
*so let's start by tryna find the teams with significant coefficients on our diff-in-diff!
use "${route}/data/analysis_set.dta", clear

keep if division==1 // we only want the D1 teams and gymnasts:
levelsof team, local(teams) // this gets every team that has hosts a meet from the dataset!

local iteration = 0 // nothing has run yet, and we wanna run a replace vs. an append later...

cap log close
log using "${route}/output/table4a_log.txt", text replace nomsg // we gotta get the list of 

quietly {
	foreach team of local teams {

		local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
		
		local title "`team'" // now we've got which team we're focused on for this loop, and:
		local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each team name that works as a variable title

		// let's clean the dataset and prep it for a nice lil analysis:
		use "${route}/data/analysis_set.dta", clear
		
		keep if division==1	// just the D1 players...
		keep if meettitle=="no meet title" & host!="" // and just the ordinary meets
		
		keep if inlist(race, "White", "Black") // this is the Black-White comp section

		*this piece of the analysis is regular-season focused on a team's vistors, so:
		drop if team=="`title'"

		*now narrow it to those team-years in which a team visited a given school
		gen at = host=="`title'"
		bysort team year: egen visited_`vartitle' = sum(at) // this will mark each season for each team when they visited the host for this loop!
		
		drop if visited_`vartitle'==0 // because it's only for team-seasons visiting that host
		drop visited_`vartitle'

		*generate the key indicator variable!!
		gen black 	 = race=="Black"
		gen black_at = black*at
		
		*now we'll run our very excellent model, but we don't need 2000 lines of output:
		qui reg score black_at			///
			at black i.event i.teamid 	///
			, vce(cl event) noomit 		// and that's the model!
			
		*check if the p-value on the diff-in-diff coefficient is significant
		local p_`vartitle' = r(table)[4,1] // this is the p-value from the regression above!
		
		*if the p is significant, we're gonna want these three stats as well, without rerunning:
		local beta_`vartitle' = r(table)[1,1]
		local ster_`vartitle' = r(table)[2,1]
		local obsN_`vartitle' = `e(N)'
		local bnfr_`vartitle' = min(`p_`vartitle'' * 87, 1) // the bonferroni p, adjusted for 87 hosts

		if `p_`vartitle''<0.05 {
			noisily di "`title' ESTIMATE IS SIGNIFICANT!!!!!!!!"
			noisily di "beta: `beta_`vartitle''"
			noisily di "ster: `ster_`vartitle''"
			noisily di "pval: `p_`vartitle''"
			noisily di "observations: `obsN_`vartitle''"
			noisily di "bonferroni p: `bnfr_`vartitle''"
			noisily di "----"
		}
		else {
			noisily di "`title' estimate is not significant - Eq1 Black-White"
			noisily di "----"
		}
		
	} // end the for loop
} // end the quietly block

log close
*/



*******************************************************************
*Table 4b: Find venues with significant Black-to-White coefficients 
*******************************************************************
// done
*so let's start by tryna find the teams with significant coefficients on our diff-in-diff!
use "${route}/data/analysis_set.dta", clear

keep if division==1 // we only want the D1 teams and gymnasts:
levelsof team, local(teams) // this gets every team that has hosts a meet from the dataset!

local iteration = 0 // nothing has run yet, and we wanna run a replace vs. an append later...

cap log close
log using "${route}/output/table4b_log.txt", text replace nomsg // we gotta get the list of 

quietly {
	foreach team of local teams {

		local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
		
		local title "`team'" // now we've got which team we're focused on for this loop, and:
		local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each team name that works as a variable title

		// let's clean the dataset and prep it for a nice lil analysis:
		use "${route}/data/analysis_set.dta", clear
		
		keep if division==1	// just the D1 players...
		keep if meettitle=="no meet title" & host!="" // and just the ordinary meets
		
		keep if inlist(race, "White", "Black") // this is the Black-White comp section

		*this piece of the analysis is regular-season focused on a team's vistors, so:
		drop if team=="`title'"

		*now narrow it to those team-years in which a team visited a given school
		gen at = host=="`title'"
		bysort team year: egen visited_`vartitle' = sum(at) // this will mark each season for each team when they visited the host for this loop!
		
		drop if visited_`vartitle'==0 // because it's only for team-seasons visiting that host
		drop visited_`vartitle'

		*generate the key indicator variable!!
		gen black 	 = race=="Black"
		gen black_at = black*at
		
		*now we'll run our very excellent model, but we don't need 2000 lines of output:
		qui reg score black_at			 ///
			i.gymnast i.teamid i.emnumid ///
			, vce(cl emnumid) noomit 	 // and that's the model!
			
		*check if the p-value on the diff-in-diff coefficient is significant
		local p_`vartitle' = r(table)[4,1] // this is the p-value from the regression above!
		
		*if the p is significant, we're gonna want these three stats as well, without rerunning:
		local beta_`vartitle' = r(table)[1,1]
		local ster_`vartitle' = r(table)[2,1]
		local obsN_`vartitle' = `e(N)'
		local bnfr_`vartitle' = min(`p_`vartitle'' * 87, 1) // the bonferroni p, adjusted for 87 hosts

		if `p_`vartitle''<0.05 {
			noisily di "`title' ESTIMATE IS SIGNIFICANT!!!!!!!!"
			noisily di "beta: `beta_`vartitle''"
			noisily di "ster: `ster_`vartitle''"
			noisily di "pval: `p_`vartitle''"
			noisily di "observations: `obsN_`vartitle''"
			noisily di "bonferroni p: `bnfr_`vartitle''"
			noisily di "----"
		}
		else {
			noisily di "`title' estimate is not significant - Eq2 Black-White"
			noisily di "----"
		}
		
	} // end the for loop
} // end the quietly block

log close
*/