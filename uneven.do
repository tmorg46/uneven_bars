*****************************

*version 3.0

/* 

Uneven Bars? Evidence of Intergroup Anxiety in Women's Gymnastics
Code by Tommy Morgan
Data and Paper(s) by:
Tommy Morgan, Abbe McBride, Lizzie Mukai, Seth Cannon, Eli Morse

*/

*replace this first global with your path to the "big_data_folder"
global route V:\FHSS-JoePriceResearch\RA_work_folders\Tommy_Morgan\uneven\big_data_folder

clear
discard

{ // install outreg2 for later
ssc install outreg2, replace
}

{ // make a bunch of globals to make the code nice
*create variable globals by type
global num_vars year meet atbyu vsbyu poc black vault bars beam floor ifnd
global string_vars team venue athlete vtjudge1 vtjudge2 ubjudge1 ubjudge2 bbjudge1 bbjudge2 fxjudge1 fxjudge2 vtjudge3 vtjudge4 ubjudge3 ubjudge4 bbjudge3 bbjudge4 fxjudge3 fxjudge4 vtjudge5 vtjudge6 ubjudge5 ubjudge6 bbjudge5 bbjudge6 fxjudge5 fxjudge6
global varlist $num_vars $string_vars
global clean_events vault_clean bars_clean beam_clean floor_clean

*create variables by category
global descriptors team year meet venue atbyu vsbyu poc black gymnast
global events vault bars beam floor
global interactions black_atbyu
global vault_judges vtjudge1 vtjudge2
global bars_judges ubjudge1 ubjudge2
global beam_judges bbjudge1 bbjudge2
global floor_judges fxjudge1 fxjudge2
}


**********************************
*Cleaning and Creating the Dataset
**********************************

{ // this code puts every .csv in the raw_data folder together!
cd "$route\raw_data"
tempfile building
save `building', emptyok
local filenames : dir "$route\raw_data" files "*.csv"
foreach f of local filenames {
	import delimited using `"`f'"' , rowrange(1:10000) varnames(1) stringcols(_all) clear
	append using `building'
	save `"`building'"', replace
	}
save "$route\appended_data", replace

}

{ // drop the useless rows (no venue, no gymnast, didn't come to BYU that season)
drop if missing(venue)
drop if missing(athlete)
drop if team=="Boise State" & year=="2017"
drop if team=="SUU" & year=="2020"
}

foreach v in $varlist { // fill in blanks everywhere with .
	replace `v'="." if `v'==""
}

{ // narrow it down to the regular season
keep if vtjudge3=="."
drop nd fxjudge3 fxjudge4 fxjudge5 fxjudge6 bbjudge3 bbjudge4 bbjudge5 bbjudge6 ubjudge3 ubjudge4 ubjudge5 ubjudge6 vtjudge3 vtjudge4 vtjudge5 vtjudge6
}

foreach v in $num_vars { // destring the numeric variables by force
	rename `v' `v'pre
	destring `v'pre, generate (`v') force
	drop `v'pre
}

foreach v in $events { // eliminate misinput event scores
	replace `v'=. if `v'>10 | `v'<=0
}

{ // create the interaction term
gen black_atbyu = black*atbyu
}

{ // rename athlete gymnast
rename athlete gymnast
}

{ // save the full cleaned set, tidy up the folder
cd "$route"
erase appended_data.dta
cd "$route\workspace"
save clean_data, replace
}


*******************************
*Clean and Prep Individual Sets
*******************************
	
foreach v in $events { // create split datasets for each event
	*reopen the full clean set
	cd "$route\workspace"
	use clean_data, clear
	
	*keep only the relevant variables
	local vjudges `v'_judges
	keep `v' $descriptors $interactions $`vjudges'
	drop if `v'==.
	rename ($`vjudges') (judge1 judge2)
	drop if judge1=="."
	drop if judge2=="."

	*save the new narrow set as clean
	save `v'_clean, replace
	
}

{ // drop the lower third percentile of scores in each event and prep for appending

*lower third percentile cutoff in vault is 9.3
use vault_clean, clear
gen event="vault"
drop if vault<9.3
rename vault score
save vault_clean, replace

*lower third percentile cutoff in bars is 8.85
use bars_clean, clear
gen event="bars"
drop if bars<8.85
rename bars score
save bars_clean, replace

*lower third percentile cutoff in beam is 9
use beam_clean, clear
gen event="beam"
drop if beam<9
rename beam score
save beam_clean, replace

*lower third percentile 
use floor_clean, clear
gen event="floor"
drop if floor<9
rename floor score
save floor_clean, replace

}

foreach event in $clean_events { // create the all-events score set by appending the other ones

append using `event'
save allevents_clean, replace

}


*************
*Run Analysis
*************

foreach file in $clean_events allevents_clean { // get summary stats for each event and the big set
	
	*open the file
	cd "$route\workspace"
	use `file', clear
	
	*create and output the table
	cd "$route\output"
	reg score black atbyu black_atbyu
	outreg2 using sumtable_`file', word replace sum(log) addstat(Observations, e(N)) keep(score black atbyu black_atbyu) eqkeep(mean sd) sortvar(score black atbyu black_atbyu) label(proper)
	
	*cleanup
	erase sumtable_`file'.txt
	
}

foreach file in $clean_events { // get the regressions for the basic model for each event
	
	*open the file
	cd "$route\workspace"
	use `file', clear
	
	*create and output the tables
	cd "$route\output"
	
	*basic form, no controls
	reg score black_atbyu black atbyu, vce(cl gymnast) noomit
	outreg2 using regtable_`file', word replace keep(black_atbyu black atbyu) label dec(3)
	
	*both gymnast and venue effects
	xi: reg score black_atbyu i.gymnast i.venue, vce(cl gymnast) noomit
	outreg2 using regtable_`file', word append keep(black_atbyu) label dec(3) addtext(Venue Effects, X, Gymnast Effects, X)
		
	*gymnast, venue, year, and judge effects
	xi: reg score black_atbyu i.gymnast i.venue i.year i.judge1 i.judge2, vce(cl gymnast) noomit
	outreg2 using regtable_`file', word append keep(black_atbyu) label dec(3) addtext(Venue Effects, X, Gymnast Effects, X, Year Effects, X, Judge Effects, X)
	
	*all fixed effects
	xi: reg score black_atbyu i.gymnast i.venue i.year i.judge1 i.judge2 i.gymnast*i.year i.judge1*i.black i.judge2*i.black, vce(cl gymnast) noomit
	outreg2 using regtable_`file', word append keep(black_atbyu) label dec(3) addtext(Venue Effects, X, Gymnast Effects, X, Year Effects, X, Judge Effects, X, Gymnast-Year Effects, X, Judge-Race Effects, X)
		
	*clean up the folder
	erase regtable_`file'.txt
	
}

{ // get the regressions for the allevents set, adding event effects

*open the file
cd "$route\workspace"
use allevents_clean, clear
	
*create and output the tables
cd "$route\output"
	
*basic form, no controls
reg score black_atbyu black atbyu, vce(cl gymnast) noomit
outreg2 using regtable_allevents, word replace keep(black_atbyu black atbyu) label dec(3)
	
*both gymnast and venue effects
xi: reg score black_atbyu i.gymnast i.venue, vce(cl gymnast) noomit
outreg2 using regtable_allevents, word append keep(black_atbyu) label dec(3) addtext(Venue Effects, X, Gymnast Effects, X)
		
*gymnast, venue, event, year, and judge effects
xi: reg score black_atbyu i.gymnast i.venue i.event i.year i.judge1 i.judge2, vce(cl gymnast) noomit
outreg2 using regtable_allevents, word append keep(black_atbyu) label dec(3) addtext(Venue Effects, X, Gymnast Effects, X, Event Effects, X, Year Effects, X, Judge Effects, X)
	
*all fixed effects
xi: reg score black_atbyu i.gymnast i.venue i.event i.year i.judge1 i.judge2 i.gymnast*i.year i.judge1*i.black i.judge2*i.black, vce(cl gymnast) noomit
outreg2 using regtable_allevents, word append keep(black_atbyu) label dec(3) addtext(Venue Effects, X, Gymnast Effects, X, Event Effects, X, Year Effects, X, Judge Effects, X, Gymnast-Year Effects, X, Judge-Race Effects, X)
		
*clean up the folder
erase regtable_allevents.txt

}

// Tables 1-6 are handmade using the summary and regression tables from the Run Analysis Section

****************
*Make the Graphs
****************

{ // make Figure 1: the vault kernel densities

*open the vault file
cd "$route\workspace"
use vault_clean, clear

*make the graph
twoway kdensity score if(black==0 & atbyu==0), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) xtitle("Score") ytitle("Density") title(Distribution of vault scores, color(black) span) plotregion(lwidth(thin) lcolor(black)) yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xlabel(8.875(.125)10) || kdensity score if (black==0 & atbyu==1), lcolor("0 73 89 30") lwidth(thick) || kdensity score if (black==1 & atbyu==0), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || kdensity score if (black==1 & atbyu==1), lcolor("85 80 0 50") lwidth(thick) legend(order(4 "Black gymnasts at BYU" 3 "Black gymnasts, not at BYU" 2 "non-Black gymnasts at BYU" 1 "non-Black gymnasts, not at BYU") col(1) pos(11) ring(0))

*export the graph
graph export "$route\output\figure1_vault_densities.png", as(png) replace
	
}

{ // make Figure 2: the floor kernel densities

*open the vault file
cd "$route\workspace"
use floor_clean, clear

*make the graph
twoway kdensity score if(black==0 & atbyu==0), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) xtitle("Score") ytitle("Density") title(Distribution of floor scores, color(black) span) plotregion(lwidth(thin) lcolor(black)) yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xlabel(8.875(.125)10) || kdensity score if (black==0 & atbyu==1), lcolor("0 73 89 30") lwidth(thick) || kdensity score if (black==1 & atbyu==0), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || kdensity score if (black==1 & atbyu==1), lcolor("85 80 0 50") lwidth(thick) legend(order(4 "Black gymnasts at BYU" 3 "Black gymnasts, not at BYU" 2 "non-Black gymnasts at BYU" 1 "non-Black gymnasts, not at BYU") col(1) pos(11) ring(0))

*export the graph
graph export "$route\output\figure2_floor_densities.png", as(png) replace
	
}

{ // make Figure 3: the beam kernel densities

*open the vault file
cd "$route\workspace"
use beam_clean, clear

*make the graph
twoway kdensity score if(black==0 & atbyu==0), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) xtitle("Score") ytitle("Density") title(Distribution of beam scores, color(black) span) plotregion(lwidth(thin) lcolor(black)) yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xlabel(8.875(.125)10) || kdensity score if (black==0 & atbyu==1), lcolor("0 73 89 30") lwidth(thick) || kdensity score if (black==1 & atbyu==0), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || kdensity score if (black==1 & atbyu==1), lcolor("85 80 0 50") lwidth(thick) legend(order(4 "Black gymnasts at BYU" 3 "Black gymnasts, not at BYU" 2 "non-Black gymnasts at BYU" 1 "non-Black gymnasts, not at BYU") col(1) pos(11) ring(0))

*export the graph
graph export "$route\output\figure3_beam_densities.png", as(png) replace
	
}

{ // make Figure 4: the bars kernel densities

*open the vault file
cd "$route\workspace"
use bars_clean, clear

*make the graph
twoway kdensity score if(black==0 & atbyu==0), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) xtitle("Score") ytitle("Density") title(Distribution of bars scores, color(black) span) plotregion(lwidth(thin) lcolor(black)) yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xlabel(8.875(.125)10) || kdensity score if (black==0 & atbyu==1), lcolor("0 73 89 30") lwidth(thick) || kdensity score if (black==1 & atbyu==0), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || kdensity score if (black==1 & atbyu==1), lcolor("85 80 0 50") lwidth(thick) legend(order(4 "Black gymnasts at BYU" 3 "Black gymnasts, not at BYU" 2 "non-Black gymnasts at BYU" 1 "non-Black gymnasts, not at BYU") col(1) pos(11) ring(0))

*export the graph
graph export "$route\output\figure4_bars_densities.png", as(png) replace
	
}

{ // make Figure 5: the all-events kernel densities

*open the vault file
cd "$route\workspace"
use allevents_clean, clear

*make the graph
twoway kdensity score if(black==0 & atbyu==0), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) xtitle("Score") ytitle("Density") title(Distribution of scores in all events, color(black) span) plotregion(lwidth(thin) lcolor(black)) yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xlabel(8.875(.125)10) || kdensity score if (black==0 & atbyu==1), lcolor("0 73 89 30") lwidth(thick) || kdensity score if (black==1 & atbyu==0), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || kdensity score if (black==1 & atbyu==1), lcolor("85 80 0 50") lwidth(thick) legend(order(4 "Black gymnasts at BYU" 3 "Black gymnasts, not at BYU" 2 "non-Black gymnasts at BYU" 1 "non-Black gymnasts, not at BYU") col(1) pos(11) ring(0))

*export the graph
graph export "$route\output\figure5_allevents_densities.png", as(png) replace
	
}


