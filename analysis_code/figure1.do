********************************************************
*Figure 1: Fraction of untitle meets from each meet week
********************************************************
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
	scatter frac_untitled meetnum [fw=obs]	/// the big rings showing obs. counts
		, m(Oh)	mcolor(gs5)					///
	|| ///
	scatter frac_untitled meetnum			///	the little points showing means
		, m(o) mcolor(gs1)					///
	graphregion(color(white)) 										 ///
	ytitle(Fraction of scores) 										 ///
	xtitle(Meet number)  xlabel(1(1)`iteration') xtick(0.5) xsize(6) ///
	legend(															 ///
		position(6) rows(1) order(2 1) 								 ///
		label(2 "Fraction of scores from untitled meets")			 ///
		label(1 "Relative number of scores in meet week")) 			 // yuh!!!


graph export "${route}/output/figure1.png", as(png) width(1080) replace // and now we've got the figure!!!
*/
