/*

tables und figures!!

*/

clear all
frames reset
cap log close
discard
pause on

/* do the installs if you haven't already
ssc install outreg2
ssc install parmest
ssc install schemepack
*/

set scheme white_tableau

set maxvar 20000 // we need more than the default 5,000 for some of our fixed effects, so we can use a reasonable number that's larger than the total number of gymnasts (4,720) plus the total number of event-by-meets (14,319), i.e. 20,000

*edit this to be the path with all the team-year csv files
global route "C:\Users\toom\Desktop\uneven_bars"

cap mkdir "${route}/output"


***************************************************
*Table 1: Team-years included in sample for Alabama
***************************************************
// done
use "${route}/data/analysis_set.dta", clear

keep if meetnum < 11 // we only do through meetweek 10 in the main analysis!

gen at = host=="Alabama"
bysort team year: egen visited_bama = sum(at)
drop if visited_bama==0 | team=="Alabama" // now it's only the teams that visited Alabama in those seasons!!

cap log close
log using "${route}/output/table1.txt", text replace nomsg

tab team year

log close
*/


**************************************************************
*Table 2: Comparing our demographic ratios to the overall NCAA
**************************************************************
// done
use "${route}/data/analysis_set.dta", clear

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
// done
// we're gonna swap through summarizing scores by these categories and putting the means and sd's into locals
use "${route}/data/analysis_set.dta", clear

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


*******************************************************************
*Table 4a: Find venues with significant Black-to-White coefficients 
*******************************************************************
// done
*so let's start by tryna find the teams with significant coefficients on our diff-in-diff!
use "${route}/data/analysis_set.dta", clear

local iteration = 0 // nothing has run yet, and we wanna run a replace vs. an append later...
levelsof host, local(teams) // this gets every team that has hosts a meet from the dataset!

cap log close
log using "${route}/output/table4a_log.txt", text replace nomsg // we gotta get the list of 

quietly {
	foreach team of local teams {

		local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
		
		local title "`team'" // now we've got which team we're focused on for this loop, and:
		local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each team name that works as a variable title

		// let's clean the dataset and prep it for a nice lil analysis:
		use "${route}/data/analysis_set.dta", clear
		
		keep if meetnum < 11 // we're only checking meets before week 11 via Figure 2 logic
		
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
			, vce(cl emnumid) noomit 	// and that's the model!
			
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
			noisily di "`title' estimate is not significant."
			noisily di "----"
		}
		
	} // end the for loop
} // end the quietly block

log close
*/


*****************************************************************
*Table 4b: Find venues with significant White-to-not coefficients 
*****************************************************************
// done
*so let's start by tryna find the teams with significant coefficients on our diff-in-diff!
use "${route}/data/analysis_set.dta", clear

local iteration = 0 // nothing has run yet, and we wanna run a replace vs. an append later...
levelsof host, local(teams) // this gets every team that has hosts a meet from the dataset!

cap log close
log using "${route}/output/table4b_log.txt", text replace nomsg // we gotta get the list of 

quietly {
	foreach team of local teams {

		local iteration = `iteration' + 1 // this will let us replace logs and output files that need appends later
		
		local title "`team'" // now we've got which team we're focused on for this loop, and:
		local vartitle = ustrregexra(lower("`team'"), "\W|_", "", .) // this gives a chimchar-esque version of each team name that works as a variable title

		// let's clean the dataset and prep it for a nice lil analysis:
		use "${route}/data/analysis_set.dta", clear
		
		keep if meetnum < 11 // we're only checking meets before week 11 via Figure 2 logic

		*this piece of the analysis is regular-season focused on a team's vistors, so:
		drop if team=="`title'"

		*now narrow it to those team-years in which a team visited a given school
		gen at = host=="`title'"
		bysort team year: egen visited_`vartitle' = sum(at) // this will mark each season for each team when they visited the host for this loop!
		
		drop if visited_`vartitle'==0 // because it's only for team-seasons visiting that host
		drop visited_`vartitle'

		*generate the key indicator variable!!
		gen white    = race=="White"
		gen white_at = white*at
		
		*now we'll run our very excellent model, but we don't need 2000 lines of output:
		qui reg score white_at			 ///
			i.gymnast i.teamid i.emnumid ///
			, vce(cl emnumid) noomit 	// and that's the model!
			
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
			noisily di "`title' estimate is not significant."
			noisily di "----"
		}
		
	} // end the for loop
} // end the quietly block

log close
*/


*************************************************
*Figure 1: Average scores by race and meet number
*************************************************
// done
*here's the code for figure 1, which motivates the narrowing to meetweek 10 in this figure
use "${route}/data/analysis_set.dta", clear

keep if host!="" // we only want meets hosted by a specific school for this project!!

gen untitled = meettitle=="no meet title" // this gives us a binary for 'normal' meets

local iteration = 0 // this will let us set the size of the dataset for the figure
levelsof meetnum, local(nums) // now we can iterate through each meet week

foreach num of local nums { 
	
	local iteration = `iteration' + 1 // this will let us set the number of observations for the figure dataset after the loops
	
	sum untitled if meetnum==`num'
	
	local frac_untitled_`num' = `r(mean)' // save the fraction of untitled meets...
	local obs_`num' 		  = `r(N)'	  // and the score counts...
	local meet_`num'		  = `num'	  // by meet number!
}

clear

local obs = `iteration' // one fraction per meetnum
set obs `obs'

gen meetnum = 0
gen obs = 0
gen frac_untitled = 0 // need the variables to exist to replace their values!

local obs_num = 0 // for filling in each row, as used below:

foreach num of local nums {
	
	local obs_num = `obs_num' + 1 // row by row replaces:
	
	replace meetnum    		= `meet_`num''  		in `obs_num' // now we've got a row...
	replace obs		   		= `obs_`num''   		in `obs_num' // for each meet number...
	replace frac_untitled 	= `frac_untitled_`num'' in `obs_num' // and its stats!
}

twoway ///
	scatter frac_untitled meetnum [fw=obs]	///
		, m(Oh)	mcolor(gs5)					///
	|| ///
	scatter frac_untitled meetnum	///		
		, m(o) mcolor(gs1)			///
	graphregion(color(white)) 										 ///
	ytitle(Fraction of scores) 										 ///
	xtitle(Meet number)  xlabel(1(1)`iteration') xtick(0.5) xsize(6) ///
	legend(															 ///
		position(6) rows(1) order(2 1) 								 ///
		label(2 "Fraction of scores from untitled meets")			 ///
		label(1 "Relative number of scores in meet week")) 			// yuh!!!


graph export "${route}/output/figure1.png", as(png) width(1080) replace // and now we've got the figure!!!
*/


*************************************
*Figures 2a & 2b: Parallel trends????
*************************************
// pending
*here's the code for the "parallel trends" figures
use "${route}/data/analysis_set.dta", clear

keep if host!="" // we only want meets hosted by a specific school for this project!!

gen black   = race=="Black"
gen white   = race=="White"
gen n_white = race!="White" // we want these for the forloop down yonder, for the three lines we're putting on the figure

local iteration = 0 // this will let us set the size of the dataset for the figure
levelsof meetnum, local(nums) // now we can iterate through each meet week

foreach num of local nums {
	
	local iteration = `iteration' + 1 // this will let us set the number of observations for the figure dataset after the loops
	
	foreach check in black white n_white {
		
		sum score if `check'==1 & meetnum==`num' // for example, white==1 & meetnum==6

		cap local score`num'_`check' = `r(mean)' // save the score in a local
		cap local obs`num'_`check'   = `r(N)' 	 // save the count of observations for weighting
		cap local meet`num'_`check'  = `num' 	 // save the meet number in another local
	}
}

clear

local obs = `iteration' * 3 // three per meetnum: white, black, and not_white
set obs `obs'

gen meetnum = 0
gen obs = 0
gen score_mean = 0
gen check = "" // need the variables to exist to replace their values!

local obs_num = 0 // for filling in each row, as used below:

foreach num of local nums {
	foreach check in black white n_white {
		
		local obs_num = `obs_num' + 1 // row by row replaces:

		cap replace meetnum    = `meet`num'_`check''  in `obs_num'
		cap replace obs		   = `obs`num'_`check''   in `obs_num'
		cap replace score_mean = `score`num'_`check'' in `obs_num'
		cap replace check      = "`check'" 			  in `obs_num' // now we've made a row out of this line's meetnum, i.e. a row for white scores in meet week 6, etc.
	}
}

drop if obs==0

*here's the first figure, with all the weeks
twoway ///
	fpfit score_mean meetnum [fw=obs] if check=="black"   /// poly-fit for Black gymnasts
		, lpattern(shortdash) lcolor(gs10)				  ///
		|| ///
	fpfit score_mean meetnum [fw=obs] if check=="n_white" /// poly-fit for not-White gymnasts
		, lpattern(dash) lcolor(gs11) 					  ///
		|| ///
	fpfit score_mean meetnum [fw=obs] if check=="white"	  /// poly-fit for White gymnasts
		, lpattern(shortdash_dot) lcolor(gs9) 			  ///
		|| ///
	scatter score_mean meetnum if check=="black"		/// scatter for Black gymnasts
		, m(S) msize(small) mcolor(gs2) 				///
		|| ///
	scatter score_mean meetnum if check=="n_white"		/// scatter for non-White gymnasts
		, m(T) msize(small) mcolor(gs2) 				///
		|| ///
	scatter score_mean meetnum if check=="white"		/// scatter for White gymnasts
		, m(O) msize(small) mcolor(gs2) 				///
	graphregion(color(white)) 										 ///
	ytitle(Average score by race) 									 ///
	xtitle(Meet number)  xlabel(1(1)`iteration') xtick(0.5) xsize(6) /// 
	legend(															 ///
		position(6) rows(2) holes(1 2 3) order(4 5 6) 				 ///
		label(4 "Black") label(5 "Not White") label(6 "White"))		// yuh!!

graph export "${route}/output/figure2a.png", as(png) width(1080) replace

*here's the third figure, with only through week 10
twoway ///
	fpfit score_mean meetnum [fw=obs] 			///
		if check=="black" & meetnum<11 			/// poly-fit for Black gymnasts
		, lpattern(shortdash) lcolor(gs10)		///
		|| ///
	fpfit score_mean meetnum [fw=obs] 			///
		if check=="n_white"	& meetnum<11		/// poly-fit for not-White gymnasts
		, lpattern(dash) lcolor(gs10) 			///
		|| ///
	fpfit score_mean meetnum [fw=obs] 			///
		if check=="white" & meetnum<11			/// poly-fit for White gymnasts
		, lpattern(shortdash_dot) lcolor(gs10) 	///
		|| ///
	scatter score_mean meetnum			 	///
		if check=="black" & meetnum<11		/// scatter for Black gymnasts
		, m(S) msize(small) mcolor(gs2) 	///
		|| ///
	scatter score_mean meetnum			 	///
		if check=="n_white" & meetnum<11	/// scatter for non-White gymnasts
		, m(T) msize(small) mcolor(gs2) 	///
		|| ///
	scatter score_mean meetnum			 	///
		if check=="white" & meetnum<11		/// scatter for White gymnasts
		, m(O) msize(small) mcolor(gs2) 	///
	graphregion(color(white)) 								///
	ytitle(Average score by race) 							///
	xtitle(Meet number)  xlabel(1(1)10) xtick(0.5) xsize(6) ///
	legend(													///
		position(6) rows(2) holes(1 2 3) order(4 5 6) 		///
		label(4 "Black") label(5 "Not White") label(6 "White")) // yuh!!!
	
graph export "${route}/output/figure2b.png", as(png) width(1080) replace // game!
*/


// all done!
