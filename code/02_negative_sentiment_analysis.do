/*

this file does the dif-in-dif and triple dif for the schools we think might have a negative environment based on gymnasts' social media posts around 2020

*/

clear all
frames reset
cap log close
discard

ssc install outreg2
ssc install schemepack

set scheme white_tableau

*edit this to be the path with all the team-year csv files
global route "/Users/tmac/Desktop/uneven_bars"

cap mkdir "$route/output"


***********************************************
*Open a Frame for Each Team and Set Up the Loop
***********************************************
foreach team in alabama florida ucdavis semo auburn nebraska bg {

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
	
	else {
		local title "Bowling Green"
		local vartitle bg
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

	tostring event, replace
	replace event = "vault" if event=="1"
	replace event = "bars" if event=="2"
	replace event = "beam" if event=="3"
	replace event = "floor" if event=="4"


	*now narrow it to those team-years in which a team visited `title'
	gen at`vartitle' = host=="`title'"
	bysort team year: egen visited_`vartitle' = sum(at`vartitle')
	drop if visited_`vartitle'==0
	drop visited_`vartitle'


	*generate some indicators we'll need later
	gen black_at`vartitle' = black*at`vartitle'
	gen postfloyd = year>2020
	gen black_pf = postfloyd*black
	gen at`vartitle'_pf = postfloyd*at`vartitle'
	gen black_at`vartitle'_pf = postfloyd*black_at`vartitle'


	***************************************
	*Table 1: Team-Years Included in Sample
	***************************************
	// done
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
	twoway kdensity score if (black==0 & at`vartitle'==0 & score>=8.85), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) || ///
	///
	kdensity score if (black==0 & at`vartitle'==1 & score>=8.85), lcolor("0 73 89 30") lwidth(thick) || ///
	///
	kdensity score if (black==1 & at`vartitle'==0 & score>=8.85), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || ///
	///
	kdensity score if (black==1 & at`vartitle'==1 & score>=8.85), lcolor("85 80 0 50") lwidth(thick) ///
	///
	by(event black, cols(2) note("") legend(position(11))) ///
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
	log using "$route/output/table2_sumstats_log_`vartitle'.txt", text replace
	foreach event in vault bars beam floor {
		di "-----------------"
		di "scores for `event'"
		di " "
		sum score if event=="`event'"
		sum black if event=="`event'"
		sum at`vartitle' if event=="`event'"
		sum black_at`vartitle' if event=="`event'"
		di " "
		di "-----------------"
	}
	log close


	********************************************
	*Table 3: Fixed Effects Regression Estimates
	********************************************
	// done
	*run the fixed effects regressions and put them into tables
	cap erase "$route/output/table3_fe_regs_`vartitle'.xml"

	foreach event in vault bars beam floor {
		*equation 3
		reg score black_at`vartitle' black at`vartitle' if event=="`event'", vce(cl meet_id) noomit
		outreg2 using "$route/output/table3_fe_regs_`vartitle'.xml", excel append keep(black_at`vartitle' black at`vartitle') label(proper) dec(3) cttop(`event' row 1)
		
		*equation 4
		xi: reg score black_at`vartitle' i.gymnast i.meet_id if event=="`event'", vce(cl meet_id) noomit
		outreg2 using "$route/output/table3_fe_regs_`vartitle'.xml", excel append keep(black_at`vartitle') label(proper) dec(3) addtext(Gymnast Effects, X, Meet Effects, X) cttop(`event' row 4)
	}

	erase "$route/output/table3_fe_regs_`vartitle'.txt"


	***********************************
	*Table 4: Triple Difference Results
	***********************************

	*run the fixed effects regressions split by year and put them into tables, then try the joint tests
	cap erase "$route/output/table4_prepost_regs_`vartitle'.xml"

	cap log close
	log using "$route/output/table4_prepost_waldtest_logs_`vartitle'.txt", text replace

	foreach event in vault bars beam floor {
		*run the regression from equation 6
		quietly xi: reg score black_at`vartitle' black_at`vartitle'_pf i.gymnast i.gymnast*postfloyd i.meet_id if event=="`event'", vce(cluster meet_id) noomit
		outreg2 using "$route/output/table4_prepost_regs_`vartitle'.xml", excel append keep(black_at`vartitle' black_at`vartitle'_pf) label(proper) dec(3) addtext(Gymnast Effects, X, Meet Effects, X, Gymnast-by-PostFloyd, X) cttop(`event' both)
		
		di "`event' tests areg"
		di "-----"
		test black_at`vartitle' + black_at`vartitle'_pf = 0
		test black_at`vartitle' = black_at`vartitle'_pf
		di "-----"
		di ""
	}
	erase "$route/output/table4_prepost_regs_`vartitle'.txt"
	log close
	
	////////////
	
	drop _I*
	
	di "now leaving frame `vartitle'"
	frame change default
}
