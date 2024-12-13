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
global route "C:\Users\toom\Desktop\uneven_bars"

cap mkdir "$route/output"


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


**************************************************************
*Table 2: Comparing our demographic ratios to the overall NCAA
**************************************************************
/* done
use "$route/data/analysis_set.dta", clear

collapse score, by(gymnast_id year ncaa_race) // get it down to a gymnast count by race and year to get a unique count of scorers

cap log close 
log using "${route}/output/table2.txt", text replace nomsg

foreach year of numlist 2015/2024 {
	
	di "tabs for `year':"
	tab ncaa_race if year==`year' // we want to go year-by-year so it gives us %ages as well as counts to make it easier for the table!
}

log close
*/


*****************************************************
*Table 3: Average Scores by Event, Division, and Race
*****************************************************
// we're gonna swap through summarizing scores by these categories and putting the means and sd's into locals
use "$route/data/analysis_set.dta", clear

keep if host!="" // we only want meets hosted by a specific school for this project!!

// we'll mark the locals as panel_race_event_stat:

*start with the all races row from panel 1: all gymnasts
sum score
local all_all_overall_score = r(mean)
local all_all_overall_stdev = r(sd)

sum score if event=="Vault"
local all_all_vault_score = r(mean)
local all_all_vault_stdev = r(sd)

sum score if event=="Uneven Bars"
local all_all_bars_score = r(mean)
local all_all_bars_stdev = r(sd)

sum score if event=="Balance Beam"
local all_all_beam_score = r(mean)
local all_all_beam_stdev = r(sd)

sum score if event=="Floor Exercise"
local all_all_floor_score = r(mean)
local all_all_floor_stdev = r(sd)

*now the white gymnast only row from panel 1: all gymnasts
sum score if race=="White"
local all_white_overall_score = r(mean)
local all_white_overall_stdev = r(sd)

sum score if event=="Vault" & race=="White"
local all_white_vault_score = r(mean)
local all_white_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & race=="White"
local all_white_bars_score = r(mean)
local all_white_bars_stdev = r(sd)

sum score if event=="Balance Beam" & race=="White"
local all_white_beam_score = r(mean)
local all_white_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & race=="White"
local all_white_floor_score = r(mean)
local all_white_floor_stdev = r(sd)

*now the black gymnast only row from panel 1: all gymnasts
sum score if race=="Black"
local all_black_overall_score = r(mean)
local all_black_overall_stdev = r(sd)

sum score if event=="Vault" & race=="Black"
local all_black_vault_score = r(mean)
local all_black_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & race=="Black"
local all_black_bars_score = r(mean)
local all_black_bars_stdev = r(sd)

sum score if event=="Balance Beam" & race=="Black"
local all_black_beam_score = r(mean)
local all_black_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & race=="Black"
local all_black_floor_score = r(mean)
local all_black_floor_stdev = r(sd)

*start with the all races row from panel 2: only D1 gymnasts
sum score if division==1
local d1_all_overall_score = r(mean)
local d1_all_overall_stdev = r(sd)

sum score if event=="Vault" & division==1
local d1_all_vault_score = r(mean)
local d1_all_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & division==1
local d1_all_bars_score = r(mean)
local d1_all_bars_stdev = r(sd)

sum score if event=="Balance Beam" & division==1
local d1_all_beam_score = r(mean)
local d1_all_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & division==1
local d1_all_floor_score = r(mean)
local d1_all_floor_stdev = r(sd)

*now the white gymnast only row from panel 2: only D1 gymnasts
sum score if race=="White" & division==1
local d1_white_overall_score = r(mean)
local d1_white_overall_stdev = r(sd)

sum score if event=="Vault" & race=="White" & division==1
local d1_white_vault_score = r(mean)
local d1_white_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & race=="White" & division==1
local d1_white_bars_score = r(mean)
local d1_white_bars_stdev = r(sd)

sum score if event=="Balance Beam" & race=="White" & division==1
local d1_white_beam_score = r(mean)
local d1_white_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & race=="White" & division==1
local d1_white_floor_score = r(mean)
local d1_white_floor_stdev = r(sd)

*now the black gymnast only row from panel 2: only D1 gymnasts
sum score if race=="Black" & division==1
local d1_black_overall_score = r(mean)
local d1_black_overall_stdev = r(sd)

sum score if event=="Vault" & race=="Black" & division==1
local d1_black_vault_score = r(mean)
local d1_black_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & race=="Black" & division==1
local d1_black_bars_score = r(mean)
local d1_black_bars_stdev = r(sd)

sum score if event=="Balance Beam" & race=="Black" & division==1
local d1_black_beam_score = r(mean)
local d1_black_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & race=="Black" & division==1
local d1_black_floor_score = r(mean)
local d1_black_floor_stdev = r(sd)

*start with the all races row from panel 3: only non-D1 gymnasts
sum score if division!=1
local nond1_all_overall_score = r(mean)
local nond1_all_overall_stdev = r(sd)

sum score if event=="Vault" & division!=1
local nond1_all_vault_score = r(mean)
local nond1_all_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & division!=1
local nond1_all_bars_score = r(mean)
local nond1_all_bars_stdev = r(sd)

sum score if event=="Balance Beam" & division!=1
local nond1_all_beam_score = r(mean)
local nond1_all_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & division!=1
local nond1_all_floor_score = r(mean)
local nond1_all_floor_stdev = r(sd)

*now the white gymnast only row from panel 3: only non-D1 gymnasts
sum score if race=="White" & division!=1
local nond1_white_overall_score = r(mean)
local nond1_white_overall_stdev = r(sd)

sum score if event=="Vault" & race=="White" & division!=1
local nond1_white_vault_score = r(mean)
local nond1_white_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & race=="White" & division!=1
local nond1_white_bars_score = r(mean)
local nond1_white_bars_stdev = r(sd)

sum score if event=="Balance Beam" & race=="White" & division!=1
local nond1_white_beam_score = r(mean)
local nond1_white_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & race=="White" & division!=1
local nond1_white_floor_score = r(mean)
local nond1_white_floor_stdev = r(sd)

*now the black gymnast only row from panel 3: only non-D1 gymnasts
sum score if race=="Black" & division!=1
local nond1_black_overall_score = r(mean)
local nond1_black_overall_stdev = r(sd)

sum score if event=="Vault" & race=="Black" & division!=1
local nond1_black_vault_score = r(mean)
local nond1_black_vault_stdev = r(sd)

sum score if event=="Uneven Bars" & race=="Black" & division!=1
local nond1_black_bars_score = r(mean)
local nond1_black_bars_stdev = r(sd)

sum score if event=="Balance Beam" & race=="Black" & division!=1
local nond1_black_beam_score = r(mean)
local nond1_black_beam_stdev = r(sd)

sum score if event=="Floor Exercise" & race=="Black" & division!=1
local nond1_black_floor_score = r(mean)
local nond1_black_floor_stdev = r(sd)

*and now let's put that stuff into a goll-darn table!!!!
putexcel set "${route}/output/table3", sheet(table3, replace) modify // we're replacing the sheet but modifying the document as a whole; this avoids deleting other tables later but still lets us refresh this table on each rerun
putexcel A2  = "Panel 1: All Gymnasts" ///
		 A3  = "white"	///
		 A5  = "black"	///
		 A7  = "all"	///
		 ///
		 A10 = "Panel 2: Only D1 Gymnasts" ///
		 A11 = "white"	///
		 A13 = "black"	///
		 A15 = "all"	///
		 ///
		 A18 = "Panel 3: Only non-D1 Gymnasts" ///
		 A19 = "white"	///
		 A21 = "black"	///
		 A23 = "all"	// gotta get the row titles
		 
putexcel B1  = "Vault"	///
		 C1  = "Bars"	///
		 D1  = "Beam"	///
		 E1  = "Floor"	///
		 F1  = "All Events" // and the column titles

*here comes panel 1: all gymnasts!
putexcel B3  = `all_white_vault_score'	///
		 C3  = `all_white_bars_score'	///
		 D3  = `all_white_beam_score'	///
		 E3  = `all_white_floor_score'	///
		 F3  = `all_white_overall_score' ///
		 ///
		 B4  = `all_white_vault_stdev'	///
		 C4  = `all_white_bars_stdev'	///
		 D4  = `all_white_beam_stdev'	///
		 E4  = `all_white_floor_stdev'	///
		 F4  = `all_white_overall_stdev' ///
		 ///
		 B5  = `all_black_vault_score'	///
		 C5  = `all_black_bars_score'	///
		 D5  = `all_black_beam_score'	///
		 E5  = `all_black_floor_score'	///
		 F5  = `all_black_overall_score' ///
		 ///
		 B6  = `all_black_vault_stdev'	///
		 C6  = `all_black_bars_stdev'	///
		 D6  = `all_black_beam_stdev'	///
		 E6  = `all_black_floor_stdev'	///
		 F6  = `all_black_overall_stdev' ///
		 ///
		 B7  = `all_all_vault_score'	///
		 C7  = `all_all_bars_score'		///
		 D7  = `all_all_beam_score'		///
		 E7  = `all_all_floor_score'	///
		 F7  = `all_all_overall_score' ///
		 ///
		 B8  = `all_all_vault_stdev' 	///
		 C8  = `all_all_bars_stdev'		///
		 D8  = `all_all_beam_stdev'		///
		 E8  = `all_all_floor_stdev'	///
		 F8  = `all_all_overall_stdev', nformat(#0.00) // that's panel 1!
		 
*here comes panel 2: only D1 gymnasts!
putexcel B11 = `d1_white_vault_score'	///
		 C11 = `d1_white_bars_score'	///
		 D11 = `d1_white_beam_score'	///
		 E11 = `d1_white_floor_score'	///
		 F11 = `d1_white_overall_score' ///
		 ///
		 B12 = `d1_white_vault_stdev'	///
		 C12 = `d1_white_bars_stdev'	///
		 D12 = `d1_white_beam_stdev'	///
		 E12 = `d1_white_floor_stdev'	///
		 F12 = `d1_white_overall_stdev' ///
		 ///
		 B13 = `d1_black_vault_score'	///
		 C13 = `d1_black_bars_score'	///
		 D13 = `d1_black_beam_score'	///
		 E13 = `d1_black_floor_score'	///
		 F13 = `d1_black_overall_score' ///
		 ///
		 B14 = `d1_black_vault_stdev'	///
		 C14 = `d1_black_bars_stdev'	///
		 D14 = `d1_black_beam_stdev'	///
		 E14 = `d1_black_floor_stdev'	///
		 F14 = `d1_black_overall_stdev' ///
		 ///
		 B15 = `d1_all_vault_score'	///
		 C15 = `d1_all_bars_score'	///
		 D15 = `d1_all_beam_score'	///
		 E15 = `d1_all_floor_score'	///
		 F15 = `d1_all_overall_score' ///
		 ///
		 B16 = `d1_all_vault_stdev' ///
		 C16 = `d1_all_bars_stdev'	///
		 D16 = `d1_all_beam_stdev'	///
		 E16 = `d1_all_floor_stdev'	///
		 F16 = `d1_all_overall_stdev', nformat(#0.00) // that's panel 2!
		 
*here comes panel 3: only non-D1 gymnasts!
putexcel B19 = `nond1_white_vault_score'	///
		 C19 = `nond1_white_bars_score'	///
		 D19 = `nond1_white_beam_score'	///
		 E19 = `nond1_white_floor_score'	///
		 F19 = `nond1_white_overall_score' ///
		 ///
		 B20 = `nond1_white_vault_stdev'	///
		 C20 = `nond1_white_bars_stdev'	///
		 D20 = `nond1_white_beam_stdev'	///
		 E20 = `nond1_white_floor_stdev'	///
		 F20 = `nond1_white_overall_stdev' ///
		 ///
		 B21 = `nond1_black_vault_score'	///
		 C21 = `nond1_black_bars_score'	///
		 D21 = `nond1_black_beam_score'	///
		 E21 = `nond1_black_floor_score'	///
		 F21 = `nond1_black_overall_score' ///
		 ///
		 B22 = `nond1_black_vault_stdev'	///
		 C22 = `nond1_black_bars_stdev'	///
		 D22 = `nond1_black_beam_stdev'	///
		 E22 = `nond1_black_floor_stdev'	///
		 F22 = `nond1_black_overall_stdev' ///
		 ///
		 B23 = `nond1_all_vault_score'	///
		 C23 = `nond1_all_bars_score'	///
		 D23 = `nond1_all_beam_score'	///
		 E23 = `nond1_all_floor_score'	///
		 F23 = `nond1_all_overall_score' ///
		 ///
		 B24 = `nond1_all_vault_stdev' ///
		 C24 = `nond1_all_bars_stdev'	///
		 D24 = `nond1_all_beam_stdev'	///
		 E24 = `nond1_all_floor_stdev'	///
		 F24 = `nond1_all_overall_stdev', nformat(#0.00) // that's panel 3! donezo!!


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
	
	gen bonferroni_p = p * 87
	replace bonferroni_p = 1 if bonferroni_p > 1
	
	format p %20.8g // this is to read them later for table 4
	
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
	ytitle(Estimated effect of being Black at a given University) xtitle(% Black gymnasts ever competed on team) xsize(6) legend(position(6) rows(1) holes(1 3 5) order(2 4 6) label(2 "CI includes 0") label(4 "CI above 0") label(6 "CI below 0"))

graph export "$route/output/figure3.png", as(png) width(1080) replace
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
	
	// you can get the p-values and bonferroni-p-values in this table from the Figure 3 dataset

	
	////////////
	
	drop _I* // kill all the fixed effects for fun
	
	di "now leaving frame `vartitle'"
	frame change `vartitle'
}

erase "$route/output/table4.txt" // clean up your messes!!

di "total iterations run: `iteration'" // :) this one should be 7
*/


***********************************************
*Figure 4 Prep: Bonferroni-corrected Dif-in-Dif
***********************************************
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


	**********************************************
	*Figure 4 Prep: Corrected Regression Estimates
	**********************************************
	// done
	set level 99.95 // this is about equal to 1 - (0.05/87), which approximates to 0.99942... and we're being conservative so I rounded up
	
	*run equation 4 from the paper, the dif-in-dif!
	qui xi: reg score black_at i.event i.gymnast i.meet_id, vce(cl meet_id) noomit
	
	*copy the frame to get the estimate on black_at for Figure 3
	cap frame copy `vartitle' parmest
	cap frame change parmest
	
	qui parmest, format(estimate min99_95 max99_95 %8.4f p %8.1e) list(,) saving("$route\output\eq4_figure4_`vartitle'.dta", replace)
	
	use "$route\output\eq4_figure4_`vartitle'.dta", clear
	gen team = "`title'"
	
	keep if _n==1 
	
	if "`iteration'"=="1" {
		save "$route/data/figure4_set.dta", replace // the file doesn't exist yet or needs to be replaced, so this happens on the first run
	}
	
	else {
		append using "$route/data/figure4_set.dta"
		save "$route/data/figure4_set.dta", replace // now there's an append to add the estimate with all the other ones
	}
	
	erase "$route\output\eq4_figure4_`vartitle'.dta" // kill the little files
	
	frame change `vartitle'
	cap frame drop parmest

	
	////////////
	
	drop _I* // kill all the fixed effects for fun
	
	di "now leaving frame `vartitle'"
	frame change `vartitle'
}

di "total iterations run: `iteration'" // :)
*/


***********************************
*Figure 4: Bonferroni-corrected CIs
***********************************
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
use "$route/data/figure4_set.dta", clear

merge m:1 team using `rates', keep(1 3) nogen // this will give us the X-axis variable percent_black for a figure


gen color = (min99_95>0) // mark the 99.94% CIs above 0 with a 1
replace color = 2 if max99_95<0 // and the ones below with a 2

graph twoway rcap min99_95 max99_95 percent_black if color==0, color(eltblue%50) || ///
	scatter estimate percent_black if color==0, mcolor(emidblue%50) || ///
	rcap min99_95 max99_95 percent_black if color==1, color(green)|| ///
	scatter estimate percent_black if color==1, m(T) mcolor(forest_green) mlabel(team) mlabpos(9) || ///
	rcap min99_95 max99_95 percent_black if color==2, color(cranberry) || ///
	scatter estimate percent_black if color==2, m(S) mcolor(red) mlabel(team) ///
	graphregion(color(white)) ///
	ytitle(Estimated effect of being Black at a given University) xtitle(% Black gymnasts ever competed on team) xsize(6) legend(position(6) rows(1) holes(1 3 5) order(2 4 6) label(2 "CI includes 0") label(4 "CI above 0") label(6 "CI below 0"))

graph export "$route/output/figure4.png", as(png) width(1080) replace
*/




