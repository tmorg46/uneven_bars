/*

this file orders the big dataset for ease of putting together our race crosswalk, then applies our Black indicator and rates and saves the full dataset for our analysis, then makes all those figures and tables by doing our analysis!

*/

clear all
frames reset
cap log close
discard

/* do the installs if you haven't already
ssc install outreg2
ssc install parmest
ssc install schemepack
*/

set scheme white_tableau

*edit this to be the path with all the team-year csv files
global route "C:\Users\tmorg\Desktop\uneven_bars"

cap mkdir "$route/output"


*********************************************************
*get the list of all gymnasts so we can code Black or not
*********************************************************
/* done
*now open the handcoded race file to save as a tempfile to merge onto the full set
import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear

keep black team gymnast

tempfile races
save `races', replace


*bring that tempfile onto the big clean set!
import delimited using "$route/data/all_scores_2015-2024.csv", varn(1) clear
merge m:1 team gymnast using `races', keep(1 3) nogen // now all the gymnasts are marked as Black or not!!


*reshape the dataset so score is in one column and mark each of the events
rename (vault bars beam floor) (score1 score2 score3 score4)
reshape long score, i(gymnast meettitle date host) j(event)
drop if score==.

label define event_lbl 1 "vault" 2 "bars" 3 "beam" 4 "floor"
label values event event_lbl


*drop every meet that has a title on it (we want just normal, usual meets)
keep if meettitle=="no meet title"


*save the set!!
sort team year meetnum gymnast
compress
save "$route/data/pre_analysis_set.dta", replace
*/


************************************************
*narrow it down to teams included in our samples
************************************************
/* done
frames reset

local iteration = 0 // nothing has run yet!

use "$route/data/pre_analysis_set.dta", clear
levelsof host, local(teams) // this gets every team that has teams visit it

foreach team of local teams {

	local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
	
	local title "`team'"
	local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each teamname that works as a variable title
	
	frame create `vartitle' // do everything in its own frame to be organized and not need to worry about weird clears
	frame change `vartitle'


	*********************
	*Cleaning the Dataset
	*********************
	// done!
	*bring in the dataset and make a unique meet id
	use "$route/data/pre_analysis_set.dta", clear


	*this piece of the analysis is regular-season focused on a team's vistors, so:
	drop if team=="`title'"


	*now narrow it to those team-years in which a team visited a given school
	gen at = host=="`title'"
	bysort team year: egen visited_`vartitle' = sum(at)
	drop if visited_`vartitle'==0
	drop visited_`vartitle' at
	
	*save a tempfile to append at the end:
	tempfile `vartitle'
	save ``vartitle'', replace
}

clear

foreach team of local teams {
	local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each teamname that works as a variable title
	append using ``vartitle''
}

*now save the set!
duplicates drop // there's a lot of scores we use a lot of times
compress
save "$route/data/analysis_set.dta", replace
cap erase "$route/data/pre_analysis_set.dta"
*/


***************************************************
*Table 1: Team-Years Included in Sample for Alabama
***************************************************
/* done
use "$route/data/analysis_set.dta", clear

gen at = host=="Alabama"
bysort team year: egen visited_bama = sum(at)
drop if visited_bama==0 | team=="Alabama" // now it's only the teams that visited Alabama in those seasons!!

cap log close
log using "$route/output/table1.txt", text replace nomsg

tab team year

log close
*/


***********************************************
*Table 2: Comparing our total count to the NCAA
***********************************************
/* done
cap log close
log using "$route/output/table2.txt", text replace nomsg

foreach year of numlist 2015/2023 {
	*get the race list
	import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear
	keep black team gymnast
	tempfile races
	save `races', replace
	
	*bring that tempfile onto the big set!
	import delimited using "$route/data/all_scores_2015-2024.csv", varn(1) clear
	merge m:1 team gymnast using `races', keep(1 3) nogen
	
	*loop through each year and tab the gymnasts!!
	keep if year==`year'
	collapse black, by(gymnast)
	di "`year'"
	tab black
}

log close
*/


******************************************
*Table 3: Average Scores by Event and Race
******************************************
/* done
use "$route/data/analysis_set.dta", clear

cap log close
log using "$route/output/table3.txt", text replace nomsg // we can put this into a table later!!

foreach event in vault bars beam floor {
	foreach black in 0 1 {
		
		di "event: `event' | black? `black'"
		sum score if (black==`black') & (event=="`event'":event_lbl)
		di "+++++++++++++++++++"
		di ""
		
	}
}

log close
*/


*************************************************
*Figure 2: Average Scores by Race and Meet Number
*************************************************
/* done
use "$route/data/analysis_set.dta", clear

local iteration = 0 // this will let us set the size of the dataset for the figure
levelsof meetnum, local(nums) // now we can iterate through each meet week

foreach num of local nums {
	
	local iteration = `iteration' + 1 // this will let us track which meet number these scores are for
	
	foreach black in 0 1 {
		
		sum score if black==`black' & meetnum==`num'
		local score`num'_`black' = `r(mean)' // save the score in a local
		local min`num'_`black' = `r(mean)' - `r(sd)' // make the bottom of a +- 2 sd range
		local max`num'_`black' = `r(mean)' + `r(sd)' // make the top of a +- 2 sd range
		local meet`num'_`black' = `iteration' // save the meet number in another local
	}
}

clear

local obs = `iteration' * 2 // one for each meet for Black and not Black
set obs `obs'

gen meetnum = 0
gen score_mean = 0
gen min = 0
gen max = 0
gen black = 0 // need the variables to exist to replace their values

local newi = 0 // for new iteration, as used below for the ins

foreach num of local nums {
	foreach black in 0 1 {
		
		local newi = `newi' + 1
		
		replace meetnum = `meet`num'_`black'' in `newi'
		replace score_mean = `score`num'_`black'' in `newi'
		replace min = `min`num'_`black'' in `newi'
		replace max = `max`num'_`black'' in `newi'
		
		if "`black'"=="1" {
			replace black = 1 in `newi'
		}
		
		else {
			qui di "" // do nothing!
		}
		
	}
}

replace meetnum = meetnum - 0.1 if black==1
replace meetnum = meetnum + 0.1 if black==0


twoway lfit score_mean meetnum if black==1, color(green) text(9.725 7 `"`eq1'"', color(forest_green) size(medsmall)) || ///
	lfit score_mean meetnum if black==0, color(blue) text(9.565 7 `"`eq0'"', color(edkblue) size(medsmall)) || ///
	rcap min max meetnum if black==1, color(green%50) || ///
	scatter score_mean meetnum if black==1, m(S) mcolor(forest_green) || ///
	rcap min max meetnum if black==0, color(eltblue) || ///
	scatter score_mean meetnum if black==0, m(T) mcolor(edkblue) ///
	graphregion(color(white)) ///
	ytitle(Average Score by Race) xscale(range(1 10)) xtitle(Meet Number) xlabel(1(1)13) xsize(6) legend(position(6) rows(1) holes(2 5) order(4 6 1 3) label(4 "Black") label(6 "not Black") label(1 "Lines of Best Fit") label(3 "+/- 1 St. Dev."))
	
graph export "$route/output/figure2.png", as(png) width(1080) replace
*/


************************************************************
*Figure 3 Prep: Open a Frame for Each Team and Run the Model
************************************************************
/* done
frames reset

local iteration = 0 // nothing has run yet!

use "$route/data/analysis_set.dta", clear
levelsof host, local(teams) // this gets every team that has teams visit it

foreach team of local teams {

	local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
	
	local title "`team'"
	local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each teamname that works as a variable title
	
	frame create `vartitle' // do everything in its own frame to be organized and not need to worry about weird clears
	frame change `vartitle'


	*********************
	*Cleaning the Dataset
	*********************
	// done!
	*bring in the dataset and make a unique meet id
	use "$route/data/analysis_set.dta", clear


	*this piece of the analysis is regular-season focused on a team's vistors, so:
	drop if team=="`title'"


	*now narrow it to those team-years in which a team visited a given school
	gen at = host=="`title'"
	bysort team year: egen visited_`vartitle' = sum(at)
	drop if visited_`vartitle'==0
	drop visited_`vartitle'


	*generate the key indicator variable!!
	gen black_at = black*at


	**************************************************
	*Figure 3 Prep: Fixed Effects Regression Estimates
	**************************************************
	// done
	*run equation 4 from the paper, the dif-in-dif!
	qui xi: reg score black_at i.event i.gymnast i.meet_id, vce(cl meet_id) noomit
	
	*copy the frame to get the estimate on black_at for Figure 3
	cap frame copy `vartitle' parmest
	cap frame change parmest
	
	qui parmest, format(estimate min95 max95 %8.4f p %8.1e) list(,) saving("$route\output\eq4_figure3_`vartitle'.dta", replace)
	
	use "$route\output\eq4_figure3_`vartitle'.dta", clear
	gen team = "`title'"
	
	keep if _n==1 
	
	if "`iteration'"=="1" {
		save "$route/data/figure3_set.dta", replace // the file doesn't exist yet or needs to be replaced, so this happens on the first run
	}
	
	else {
		append using "$route/data/figure3_set.dta"
		save "$route/data/figure3_set.dta", replace // now there's an append to add the estimate with all the other ones
	}
	
	erase "$route\output\eq4_figure3_`vartitle'.dta" // kill the little files
	frame change `vartitle'
	cap frame drop parmest

	
	////////////
	
	drop _I* // kill all the fixed effects for fun
	
	di "now leaving frame `vartitle'"
	frame change `vartitle'
}

di "total iterations run: `iteration'" // :)
*/


*****************************************************
*Figure 3: Dif-in-Dif Estimates by Black Gymnast Rate
*****************************************************
/* done
*reopen the gymnast races file and make a rate of Black gymnast participation by team
import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear

reshape long roster, i(team gymnast black) j(year)
drop if missing(roster)
drop roster

collapse (mean) black, by(team)
rename black percent_black // this now marks all the teams by the percent of their total gymnasts ever who are Black

tempfile rates
save `rates', replace


*get the coefficient estimates open and bring on the team rates!
use "$route/data/figure3_set.dta", clear

merge m:1 team using `rates', keep(1 3) nogen // this will give us the X-axis variable percent_black for a figure

gen color = (min95>0) // mark the 95% CIs above 0 with a 1
replace color = 2 if max95<0 // and the ones below with a 2
replace color = 3 if team=="Pittsburgh" // we need this label to go to the left

graph twoway rcap min95 max95 percent_black if color==0, color(eltblue%50) || ///
	scatter estimate percent_black if color==0, mcolor(emidblue%50) || ///
	rcap min95 max95 percent_black if color==1, color(green)|| ///
	scatter estimate percent_black if color==1, m(T) mcolor(forest_green) mlabel(team) || ///
	rcap min95 max95 percent_black if color==2, color(cranberry) || ///
	scatter estimate percent_black if color==2, m(S) mcolor(red) mlabel(team) || ///
	rcap min95 max95 percent_black if color==3, color(green) || ///
	scatter estimate percent_black if color==3, m(T) mcolor(forest_green) mlabel(team) mlabp(9) ///
	graphregion(color(white)) ///
	ytitle(Estimated Effect of being Black at a given University) xtitle(% Black gymnasts ever competed on team) xsize(6) legend(position(6) rows(1) holes(1 3 5) order(2 4 6) label(2 "CI includes 0") label(4 "CI above 0") label(6 "CI below 0"))

graph export "$route/output/figure3_eq4_CIs.png", as(png) width(1080) replace
*/


***********************************************************
*Table 4 Prep: Open a Frame for Each Team and Run the Model
***********************************************************
/* done
frames reset

local iteration = 0 // nothing has run yet!
local teams `""Utica" "Pittsburgh" "Bridgeport" "Kent State" "Alabama" "Southern Conn." "Hamline""' // this gets the seven teams with statistically-different-than-zero estimates on Figure 3 into a local

foreach team of local teams {

	local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
	
	local title "`team'"
	local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each teamname that works as a variable title
	
	frame create `vartitle' // do everything in its own frame to be organized and not need to worry about weird clears
	frame change `vartitle'


	*********************
	*Cleaning the Dataset
	*********************
	// done!
	*bring in the dataset and make a unique meet id
	use "$route/data/analysis_set.dta", clear


	*this piece of the analysis is regular-season focused on a team's vistors, so:
	drop if team=="`title'"


	*now narrow it to those team-years in which a team visited a given school
	gen at = host=="`title'"
	bysort team year: egen visited_`vartitle' = sum(at)
	drop if visited_`vartitle'==0
	drop visited_`vartitle'


	*generate the key indicator variable!!
	gen black_at = black*at


	********************************************
	*Table 4: Fixed Effects Regression Estimates
	********************************************
	// done
	*run equation 4 from the paper, the dif-in-dif!
	qui xi: reg score black_at i.event i.gymnast i.meet_id, vce(cl meet_id) noomit
	
	if "`iteration'"=="1" {
		cap erase "$route/output/table4.txt" // this prevents extra columns along with the replace option below:
		outreg2 using "$route/output/table4", excel replace sdec(4) dec(3) cttop(`title') keep(black_at _Ievent_2 _Ievent_3 _Ievent_4)
	}
	
	else {
		outreg2 using "$route/output/table4", excel append sdec(4) dec(3) cttop(`title') keep(black_at _Ievent_2 _Ievent_3 _Ievent_4) // now it appends to the table from above!!
	}

	
	////////////
	
	drop _I* // kill all the fixed effects for fun
	
	di "now leaving frame `vartitle'"
	frame change `vartitle'
}

erase "$route/output/table4.txt" // clean up your messes!!

di "total iterations run: `iteration'" // :) this one should be 7
*/


