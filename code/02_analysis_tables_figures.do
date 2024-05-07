/*

this file does the same analysis for teams visiting established hosts (i.e. have 2015-2024 seasons) who:
	1) got negative social media attention in 2020 (Alabama, Florida, UC Davis, S.E. Missouri, Auburn, Nebraska, Bowling Green);
	2) never had a black gymnast (BYU, Boise State, Gustavus Adolphus, UW-La Crosse); and
	3) teams who have always had at least two black gymnasts (Florida again, Michigan State, UCLA, West Virginia)

*/

clear all
frames reset
cap log close
discard

*ssc install outreg2
*ssc install schemepack

set scheme white_tableau

*edit this to be the path with all the team-year csv files
global route "/Users/tmac/Desktop/uneven_bars"

cap mkdir "$route/output"


******************************************
*Investigate the Black gymnasts' selection
******************************************
// pending
*open the Black crosswalk and get moving!!
import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear

reshape long roster, i(team gymnast black) j(year)
drop if missing(roster)
drop roster

gen black_count = black
collapse (mean) black (sum) black_count, by(team year)

bysort team: egen min = min(black_count)
*br if min>1 // these teams with all 10 seasons are consistently selected by multiple Black gymnasts: Florida (already done), Michigan State, UCLA, West Virginia

collapse black, by(team)
*br if black==0 // these teams with all 10 seasons have never been selected by a Black gymnast: BYU, Boise State, Gustavus Adolphus, UW-La Crosse


***********************************************
*Open a Frame for Each Team and Set Up the Loop
***********************************************
foreach team in alabama florida ucdavis semo auburn nebraska bg byu boise gustavus uwlc michstate ucla wvu {

	// define the proper case and variable-compatible local values used in the loops:
	if "`team'"=="alabama" {
		local title "Alabama"
		local vartitle alabama
	}
	
	else if "`team'"=="florida" {
		local title "Florida"
		local vartitle florida
	}
	
	else if "`team'"=="ucdavis" {
		local title "UC Davis"
		local vartitle ucdavis
	}
	
	else if "`team'"=="semo" {
		local title "S.E. Missouri"
		local vartitle semo
	}
	
	else if "`team'"=="auburn" {
		local title "Auburn"
		local vartitle auburn
	}
	
	else if "`team'"=="nebraska" {
		local title "Nebraska"
		local vartitle nebraska
	}
	
	else if "`team'"=="bg" {
		local title "Bowling Green"
		local vartitle bg
	}
	
	else if "`team'"=="byu" {
		local title "BYU"
		local vartitle byu
	}
	
	else if "`team'"=="boise" {
		local title "Boise State"
		local vartitle boise
	}
	
	else if "`team'"=="gustavus" {
		local title "Gustavus Adolphus"
		local vartitle gustavus
	}
	
	else if "`team'"=="uwlc" {
		local title "UW-La Crosse"
		local vartitle uwlc
	}
	
	else if "`team'"=="michstate" {
		local title "Michigan State"
		local vartitle michstate
	}
	
	else if "`team'"=="ucla" {
		local title "UCLA"
		local vartitle ucla
	}
	
	else {
		local title "West Virginia"
		local vartitle wvu
	}
	
	
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
	if "`title'"=="Alabama" {
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
	if "`title'"=="Alabama" {
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
	if "`title'"=="Alabama" {
		cap erase "$route/output/table3_fe_regs.xml" // this lets us reset the table on each fresh run!
	}
	else {
		di "yeehaw!"
	}

	*equation 3
	reg score black_at black at i.event, vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs.xml", excel append keep(black_at black at 2.event 3.event 4.event) label dec(3) cttop(eq3 `vartitle')
	
	*equation 4
	xi: reg score black_at i.event i.gymnast i.meet_id, vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs.xml", excel append keep(black_at 2.event 3.event 4.event) label dec(3) addtext(Gymnast Effects, X, Meet Effects, X) cttop(eq4 `vartitle')


	***********************************
	*Table 4: Triple Difference Results
	***********************************
	// done
	*run the fixed effects regressions split by year and put them into tables
	if "`title'"=="Alabama" {
		cap erase "$route/output/table4_tripledif_regs.xml" // this lets us reset the table on each fresh run!
	}
	else {
		di "yeehaw again!"
	}

	*run the regression from equation 6
	xi: reg score black_at black_at_pf i.event i.gymnast i.gymnast*postfloyd i.meet_id, vce(cluster meet_id) noomit
	outreg2 using "$route/output/table4_tripledif_regs.xml", excel append keep(black_at black_at_pf _Ievent_2 _Ievent_3 _Ievent_4) label dec(3) addtext(Gymnast Effects, X, Meet Effects, X, Gymnast-by-PostFloyd, X) cttop(triple `vartitle')
	
	////////////
	
	drop _I*
	
	di "now leaving frame `vartitle'"
	frame change default
}

erase "$route/output/table3_fe_regs.txt"
erase "$route/output/table4_tripledif_regs.txt"
