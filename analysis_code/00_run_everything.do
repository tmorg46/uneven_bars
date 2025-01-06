/*

Uneven Bars? Looking for Environmental Microaggression Effects in NCAA Women's Gymnastics

run all the other Stata code from this file!
you only have to change the one directory global!!

*/

clear all
frames reset
cap log close
discard
pause on

ssc install schemepack
set scheme white_tableau // it looks nice

set seed 46 // I just like this seed; we're generating a random variable when we add race predictions, so we need it set for replicability's sake

set maxvar 20000 // we need more than the default 5,000 for some of our fixed effects, so we can use a reasonable number that's larger than the total number of gymnasts (4,720) plus the total number of event-by-meets (14,319), i.e. 20,000

*edit this to be the path to the main directory download!
global route "C:/Users/toom/Desktop/uneven_bars"

cap mkdir "${route}/output"


***********************************************************
*turn all the scraped scores into a coherent single dataset
***********************************************************
do "${route}\analysis_code\score_scrapes_to_dataset.do"


************************************************
*add our FairFace race predictions to the scores
************************************************
do "${route}\analysis_code\add_race_predictions.do"


*******************************************************
*do all the analysis and make the cool tables + figures
*******************************************************
do "${route}/analysis_code/table1.do"
do "${route}/analysis_code/table2.do"
do "${route}/analysis_code/table3.do"
do "${route}/analysis_code/table4.do"
do "${route}/analysis_code/table5.do" // <--- this one takes a while

do "${route}/analysis_code/figure1.do"
do "${route}/analysis_code/figure2.do"










