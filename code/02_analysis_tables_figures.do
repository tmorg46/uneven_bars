/*

this file does the our analysis for every team in the entire NCAA that got visited by other teams over 2015-2024

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


******************************************
*Investigate the Black gymnasts' selection
******************************************
/* done
*open the Black crosswalk and get moving!!
import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear

reshape long roster, i(team gymnast black) j(year)
drop if missing(roster)
drop roster

gen black_count = black
gen all_count = 1
collapse (mean) black (sum) black_count all_count, by(team)

rename black percent_black
save "$route/data/black_rates.dta", replace // this will make a cool graph later
*/


***********************************************
*Open a Frame for Each Team and Set Up the Loop
***********************************************
// done
local iteration = 0 // nothing has run yet!

use "$route/data/all_scores_cleaned.dta", clear
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
	use "$route/data/all_scores_cleaned.dta", clear

	egen meet_id = concat(date host meettitle), punct(" / ")


	*this piece of the analysis is regular-season focused on a team's vistors, so:
	drop if playoffs==1 | team=="`title'"
	drop playoffs


	*reshape the dataset so score is in one column and mark the events
	rename (vault bars beam floor) (score1 score2 score3 score4)
	reshape long score, i(gymnast meettitle date host) j(event)
	drop if score==.
	
	label define event_lbl 1 "vault" 2 "bars" 3 "beam" 4 "floor"
	label values event event_lbl


	*now narrow it to those team-years in which a team visited `title'
	gen at = host=="`title'"
	bysort team year: egen visited_`vartitle' = sum(at)
	drop if visited_`vartitle'==0
	drop visited_`vartitle'


	*generate some indicators we'll need later
	gen black_at = black*at
	gen postfloyd = year>2020
	gen black_pf = postfloyd*black
	gen at_pf = postfloyd*at
	gen black_at_pf = postfloyd*black_at


	***************************************
	*Table 1: Team-Years Included in Sample
	***************************************
	// done
	cap log close
	if "`iteration'"=="1" {
		log using "$route/output/table1_by_team.txt", text replace nomsg
	}
	
	else {
		log using "$route/output/table1_by_team.txt", text append nomsg
	}
	
	di ""
	di "===================="
	di ""
	di "the teams that visited `title'"
	tab team year
	
	log close
	

	***********************************************
	*Figure 2: Kernel Density Estimations of Scores
	***********************************************

	*label the black indicator for these graphs
	cap label define black_lbl 1 "Black" 0 "not Black"
	label values black black_lbl

	*cook 'em up! limit them to the ones 8.85 and above just to make them look nice
	twoway kdensity score if (black==0 & at==0 & score>=8.85), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) || ///
	///
	kdensity score if (black==0 & at==1 & score>=8.85), lcolor("0 73 89 30") lwidth(thick) || ///
	///
	kdensity score if (black==1 & at==0 & score>=8.85), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || ///
	///
	kdensity score if (black==1 & at==1 & score>=8.85), lcolor("85 80 0 50") lwidth(thick) ///
	///
	by(black, cols(1) note("") legend(position(11))) ///
	///
	legend(order(2 "non-Black gymnasts at `title'" 1 "non-Black gymnasts not at `title'" 4 "Black gymnasts at `title'" 3 "Black gymnasts not at `title'")) plotregion(lwidth(thin) lcolor(black)) scheme(white_tableau) legend(position(6)) ///
	///
	xtitle("Score") ytitle("") yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xtick(8.875(.125)10) xlabel(9(.25)10) ysize(8) xsize(6.5)

	graph export "$route/output/figure2_densities_`vartitle'.png", width(1080) replace
	graph close


	**********************************
	*Table 2: Score Summary Statistics
	**********************************
	// done
	*create summary tables for each event for variables of interest
	cap log close
	if "`iteration'"=="1" {
		log using "$route/output/table2_by_team.txt", text replace nomsg
	}
	else {
		log using "$route/output/table2_by_team.txt", text append nomsg
	}
	
	foreach event of numlist 1/4 {
		di "-----------------"
		di "scores for `event' at `title'"
		di "1 vault 2 bars 3 beam 4 floor"
		di " "
		sum score if event==`event'
		sum black if event==`event'
		sum at if event==`event'
		sum black_at if event==`event'
		di " "
		di "-----------------"
	}
	log close


	********************************************
	*Table 3: Fixed Effects Regression Estimates
	********************************************
	// done
	*run the fixed effects regressions and put them into tables
	if "`iteration'"=="1" {
		cap erase "$route/output/table3_fe_regs.xml" // this lets us reset the table on each fresh run!
	}
	else {
		di "yeehaw!" // I'm if-else paranoid
	}

	*equation 3
	xi: reg score black_at black at i.event, vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs.xml", excel append keep(black_at _Ievent_2 _Ievent_3 _Ievent_4) label dec(3) cttop(eq3 `vartitle')
	
	*equation 4
	xi: reg score black_at i.event i.gymnast i.meet_id, vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs.xml", excel append keep(black_at _Ievent_2 _Ievent_3 _Ievent_4) label dec(3) addtext(Gymnast Effects, X, Meet Effects, X) cttop(eq4 `vartitle')
	
	
	*copy the frame to get the estimate on black_at for a cool figure later
	cap frame copy `vartitle' parmest
	cap frame change parmest
	
	parmest, format(estimate min95 max95 %8.4f p %8.1e) list(,) saving("$route\output\eq4_figure2_`vartitle'.dta", replace)
	
	use "$route\output\eq4_figure2_`vartitle'.dta", clear
	gen team = "`title'"
	
	keep if _n==1 
	
	if "`iteration'"=="1" {
		save "$route/data/figure2_set.dta", replace // the file doesn't exist yet or needs to be replaced, so this happens on the first run
	}
	
	else {
		append using "$route/data/figure2_set.dta"
		save "$route/data/figure2_set.dta", replace // now there's an append to add the estimate with all the other ones
	}
	
	erase "$route\output\eq4_figure2_`vartitle'.dta" // kill the little files
	frame change `vartitle'
	cap frame drop parmest


	***********************************
	*Table 4: Triple Difference Results
	***********************************
	// done
	*run the fixed effects regressions split by year and put them into tables
	if "`iteration'"=="1" {
		cap erase "$route/output/table4_tripledif_regs.xml" // this lets us reset the table on each fresh run!
	}
	else {
		di "yeehaw again!" // :)
	}

	*run the regression from equation 6
	xi: reg score black_at black_at_pf i.event i.gymnast i.gymnast*postfloyd i.meet_id, vce(cluster meet_id) noomit
	outreg2 using "$route/output/table4_tripledif_regs.xml", excel append keep(black_at black_at_pf _Ievent_2 _Ievent_3 _Ievent_4) label dec(3) addtext(Gymnast Effects, X, Meet Effects, X, Gymnast-by-PostFloyd, X) cttop(triple `vartitle')
	
	
	*copy the frame to get the estimates on black_at and black_at_pf for a cool figure later
	cap frame copy `vartitle' parmest
	cap frame change parmest
	
	parmest, format(estimate min95 max95 %8.4f p %8.1e) list(,) saving("$route\output\eq6_figure3_`vartitle'.dta", replace)
	
	use "$route\output\eq6_figure3_`vartitle'.dta", clear
	gen team = "`title'"
	
	keep if _n==1 | _n==2
	
	if "`iteration'"=="1" {
		save "$route/data/figure3_set.dta", replace // the file doesn't exist yet or needs to be replaced, so this happens on the first run
	}
	
	else {
		append using "$route/data/figure3_set.dta"
		save "$route/data/figure3_set.dta", replace // now there's an append to add the estimate with all the other ones
	}
	
	erase "$route\output\eq6_figure3_`vartitle'.dta" // kill the little files
	frame change `vartitle'
	cap frame drop parmest
	
	////////////
	
	drop _I*
	
	di "now leaving frame `vartitle'"
	frame change `vartitle'
}

erase "$route/output/table3_fe_regs.txt"
erase "$route/output/table4_tripledif_regs.txt"
*/


**************************************************
*make the cool figures based on Black gymnast rate
**************************************************
// pending
*start with figure 2!
use "$route/data/figure2_set", clear

merge m:1 team using "$route/data/black_rates.dta", keep(1 3) nogen // this will give us the X-axis variable percent_black

gen color = (min95>0) // mark the 95% CIs above 0 with a 1
replace color = 2 if max95<0 // and the ones below with a 2

graph twoway rcap min95 max95 percent_black if color==0 & parm=="black_at" || ///
	scatter estimate percent_black if color==0 & parm=="black_at", mcolor(eltblue) || ///
	rcap min95 max95 percent_black if color==1 & parm=="black_at", color(green)|| ///
	scatter estimate percent_black if color==1 & parm=="black_at", m(T) mcolor(forest_green) mlabel(team) || ///
	rcap min95 max95 percent_black if color==2 & parm=="black_at", color(cranberry) || ///
	scatter estimate percent_black if color==2 & parm=="black_at", m(S) mcolor(red) mlabel(team) ///
	graphregion(color(white)) ///
	ytitle(Effect of being Black at a given University) xtitle(% Black gymnasts ever competed) xsize(7) legend(position(6) rows(1) holes(1 3 5) order(2 4 6) label(2 "CI includes 0") label(4 "CI above 0") label(6 "CI below 0"))

graph export "$route/output/figure2_eq4_CIs.png", as(png) width(1080) replace


*now do figure 3!
use "$route/data/figure3_set", clear

merge m:1 team using "$route/data/black_rates.dta", keep(1 3) nogen // this will give us the X-axis variable percent_black

gen color = (min95>0) // mark the 95% CIs above 0 with a 1
replace color = 2 if max95<0 // and the ones below with a 2

graph twoway rcap min95 max95 percent_black if color==0 & parm=="black_at_pf" || ///
	scatter estimate percent_black if color==0 & parm=="black_at_pf", mcolor(eltblue) || ///
	rcap min95 max95 percent_black if color==1 & parm=="black_at_pf", color(green) || ///
	scatter estimate percent_black if color==1 & parm=="black_at_pf", m(T) mcolor(forest_green) || ///
	rcap min95 max95 percent_black if color==2 & parm=="black_at_pf", color(cranberry) || ///
	scatter estimate percent_black if color==2 & parm=="black_at_pf", m(S) mcolor(red) mlabel(team) ///
	graphregion(color(white)) ///
	ytitle(Effect of being Black at a given University after 2020 (triple dif)) xtitle(% Black gymnasts ever competed) xsize(7) legend(position(6) rows(1) holes(1 3 5) order(2 4 6) label(2 "CI includes 0") label(4 "CI above 0") label(6 "CI below 0"))

graph export "$route/output/figure3_eq6_CIs_post.png", as(png) width(1080) replace // this one is the postfloyd estimate, aka the triple dif stuff






