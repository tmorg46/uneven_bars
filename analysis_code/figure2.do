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


*here's the first subfigure, with all the weeks
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
	///
	/// whole graph options incoming:
	graphregion(color(white)) 												///
	ytitle(Average score by race) 											///
	xtitle(Meet number)  xlabel(1(1)`iteration') xtick(0.5) xsize(6) 		///
	legend(																	///
		position(6) rows(2)	rowgap(0) order(4 5 6 1 2 3)					///
		size(medsmall)														///
		label(4 "Black") label(5 "Not White") label(6 "White") 				///
		label(1 "") label(2 "") label(3 "")) 								///
		caption("Lines are observation-weighted fractional polynomial fits" 	///
			, size(vsmall) placement(s) justification(center))				// yuh!!!
			
gr_edit .legend.plotregion1.label[1].yoffset = -1
gr_edit .legend.plotregion1.label[2].yoffset = -1
gr_edit .legend.plotregion1.label[3].yoffset = -1 // these move the text on the legend to justify them better with the two symbol markers

graph export "${route}/output/figure2a.png", as(png) width(1080) replace


*here's the second subfigure, with only through week 10
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
	///
	/// whole graph options incoming:
	graphregion(color(white)) 												///
	ytitle(Average score by race) 											///
	xtitle(Meet number)  xlabel(1(1)10) xtick(0.5) xsize(6) 				///
	legend(																	///
		position(6) rows(2)	rowgap(0) order(4 5 6 1 2 3)					///
		size(medsmall)														///
		label(4 "Black") label(5 "Not White") label(6 "White") 				///
		label(1 "") label(2 "") label(3 "")) 								///
		caption("Lines are observation-weighted fractional polynomial fits" 	///
			, size(vsmall) placement(s) justification(center))				// yuh!!!
		
gr_edit .legend.plotregion1.label[1].yoffset = -1
gr_edit .legend.plotregion1.label[2].yoffset = -1
gr_edit .legend.plotregion1.label[3].yoffset = -1 // these move the text on the legend to justify them better with the two symbol markers
	
graph export "${route}/output/figure2b.png", as(png) width(1080) replace // game!
*/