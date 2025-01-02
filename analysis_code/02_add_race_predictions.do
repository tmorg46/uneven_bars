/*

this file starts by cleaning the predicted ethnicities crosswalk. it then takes the full dataset of scores, connects them to our predicted ethnicities, and anonymizes the gymnasts' names out of the final analysis dataset

*/

clear all
set seed 46 // I just like this seed; we're generating a random variable later, so we need it set for replicability's sake

*edit this to be the path with all the team-year csv files
global route "C:\Users\toom\Desktop\uneven_bars"


*open the raw predictions file
import delimited ///
	using "C:\Users\toom\Desktop\uneven_bars\data\FairFace\prediction_outputs.csv" ///
	, varn(1) bindquote(strict) clear // we need bindquote for consistent imports here

	
*step one is to clean the gymnast's names:
split face_name_align, parse("_face0.png")
split face_name_align1, parse("detected_faces\")
rename face_name_align12 gymnast // now the names are isolated!


*step two is make a random id for the gymnasts so we can use that for fixed effects instead of the names later:
gen gymnast_sort = runiform(0,1) // it's random on seed 46 from above.

sort gymnast_sort
drop gymnast_sort // now we're randomly sorted, so let's make an id:

gen gymnast_id = _n // there's a random id now!! yay!


*step three is tempfile this so we can merge it into the big score dataset:
replace race = "Latino/Hispanic" if race=="Latino_Hispanic" // just make it prettier
keep gymnast gymnast_id race // these are the only three variables we need for the rest of the project

gen ncaa_race = race // the NCAA has white, black, hisp/lat, and several more that don't align with FairFace, so I'll code the non-matching ones into an other category:
replace ncaa_race = "Other" if race!="White" & race!="Black" & race!="Latino/Hispanic"

tempfile racewalk
save `racewalk', replace


*step four is to open the big file and merge these onto it!
import delimited ///
	using "C:\Users\toom\Desktop\uneven_bars\data\all_scores_2015-2024.csv" ///
	, varn(1) bindquote(strict) clear

merge m:1 gymnast using `racewalk', keep(1 3) nogen // now all the gymnasts with scores have a predicted race and a randomized ID attached! yay!

drop gymnast // and now we don't need the names anymore, so they're gone, and we're ready to rumble!
sort team year meetnum event score
save "${route}/data/analysis_set.dta", replace // yeehaw!

