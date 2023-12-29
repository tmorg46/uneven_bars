*****************************

*version 5.0 -- 23 Dec 2023

/* 

Uneven Bars
Code by Tommy Morgan
Data by Tommy Morgan, Seth Cannon, Abbe McBride, Lizzie Mukai

*/

*replace this first global with your path to the folder that contains uneven_bars.do and the raw data
global route "/Users/tmac/Library/CloudStorage/Box-Box/uneven_bars"

clear all
discard
pause on

ssc install outreg2
ssc install parmest
ssc install schemepack

set scheme white_tableau

cap mkdir "$route/output"


*********************
*Cleaning the Dataset
*********************
// done!
*bring in the dataset
import delimited using "$route/uneven_bars_raw_data - data.csv", varn(1) clear


*generate some indicators we'll need later
gen black_atbyu = black*atbyu
gen postfloyd = year>2020
gen black_pf = postfloyd*black
gen atbyu_pf = postfloyd*atbyu
gen black_atbyu_pf = postfloyd*black_atbyu


*reshape the dataset so score is in one column and mark the events
rename (vault bars beam floor) (score1 score2 score3 score4)
reshape long score, i(gymnast meet_id) j(event)
drop if score==.

tostring event, replace
replace event = "vault" if event=="1"
replace event = "bars" if event=="2"
replace event = "beam" if event=="3"
replace event = "floor" if event=="4"


***************************************
*Table 1: Team-Years Included in Sample
***************************************
// done
tab team year
pause // type q to resume after copying the table


***********************************************
*Figure 2: Kernel Density Estimations of Scores
***********************************************

*label the black indicator for these graphs
cap label define black_lbl 1 "Black" 0 "not Black"
label values black black_lbl

*cook 'em up! limit them to the ones 8.85 and above just to make them look nice
twoway kdensity score if (black==0 & atbyu==0 & score>=8.85), lcolor("0 35 43 10") lpattern(dash) lwidth(medthick) || ///
///
kdensity score if (black==0 & atbyu==1 & score>=8.85), lcolor("0 73 89 30") lwidth(thick) || ///
///
kdensity score if (black==1 & atbyu==0 & score>=8.85), lcolor("42 34 0 20") lpattern(dash) lwidth(medthick) || ///
///
kdensity score if (black==1 & atbyu==1 & score>=8.85), lcolor("85 80 0 50") lwidth(thick) ///
///
by(event black, cols(2) note("") legend(position(11))) ///
///
legend(order(2 "non-Black gymnasts at BYU" 1 "non-Black gymnasts not at BYU" 4 "Black gymnasts at BYU" 3 "Black gymnasts not at BYU")) plotregion(lwidth(thin) lcolor(black)) scheme(white_tableau) legend(position(6)) ///
///
xtitle("Score") ytitle("") yscale(range(0 6.5)) ylabel(0(2)6) xscale(range(8.85 10)) xtick(8.875(.125)10) xlabel(9(.25)10) ysize(8) xsize(6.5)

graph rename figure2
graph export "$route/output/figure2_densities.png", width(1080) replace


**********************************
*Table 2: Score Summary Statistics
**********************************
// done
*create summary tables for each event for variables of interest
cap log close
log using "$route/output/table2_sumstats_log.txt", text replace
foreach event in vault bars beam floor {
	di "-----------------"
	di "scores for `event'"
	di " "
	sum score if event=="`event'"
	sum black if event=="`event'"
	sum atbyu if event=="`event'"
	sum black_atbyu if event=="`event'"
	di " "
	di "-----------------"
}
log close


********************************************
*Table 3: Fixed Effects Regression Estimates
********************************************
// done
*run the fixed effects regressions and put them into tables
cap erase "$route/output/table3_fe_regs.xml"

foreach event in vault bars beam floor {
	reg score black_atbyu black atbyu if event=="`event'", vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs", excel append keep(black_atbyu black atbyu) label(proper) dec(3) cttop(`event' row 1)
	
	areg score black_atbyu atbyu if event=="`event'", absorb(gymnast) vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs", excel append keep(black_atbyu atbyu) label(proper) dec(3) addtext(Gymnast Effects, X) cttop(`event' row 2)
	
	areg score black_atbyu black if event=="`event'", absorb(meet_id) vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs", excel append keep(black_atbyu black) label(proper) dec(3) addtext(Meet Effects, X) cttop(`event' row 3)
	
	xi: areg score black_atbyu i.meet_id if event=="`event'", absorb(gymnast) vce(cl meet_id) noomit
	outreg2 using "$route/output/table3_fe_regs", excel append keep(black_atbyu) label(proper) dec(3) addtext(Gymnast Effects, X, Meet Effects, X) cttop(`event' row 4)
}

erase "$route/output/table3_fe_regs.txt"


***********************************
*Table 4: Triple Difference Results
***********************************

*run the fixed effects regressions split by year and put them into tables, then try the joint tests
cap erase "$route/output/table4_prepost_regs.xml"

cap log close
log using "$route/output/table4_prepost_waldtest_logs.txt", text replace

foreach event in vault bars beam floor {
	*run the regression from equation 6, can't cluster because too many variables
	quietly xi: areg score black_atbyu black_atbyu_pf i.gymnast*postfloyd i.meet_id if event=="`event'", absorb(gymnast) r noomit
	quietly outreg2 using "$route/output/table4_prepost_regs", excel append keep(black_atbyu black_atbyu_pf) label(proper) dec(3) addtext(Gymnast Effects, X, Meet Effects, X, Gymnast-by-PostFloyd, X) cttop(`event' both)
	
	di "`event' tests areg"
	di "-----"
	test black_atbyu + black_atbyu_pf = 0
	test black_atbyu = black_atbyu_pf
	di "-----"
	di ""
}
erase "$route/output/table4_prepost_regs.txt"
log close




