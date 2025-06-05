/*

this file gets the dataset we need compiled!\

the cleaned scores are scraped from RoadtoNationals.com and hosted
	at the following GitHub repository:
	github.com/tmorg46/ncaa_wag_scores
	
I've also included the file as downloaded from that repo here
	to facilitate not needing to redownload it every time :)

*/

clear all

*edit this to be the path with all the team-year csv files, unless you're running everything from the 00_run_everything file
*global route "C:/Users/toom/Desktop/uneven_bars"


**********************************************************
*tempfile the team-division crosswalk to merge on in a sec
**********************************************************
import delimited using ///
	"${route}/data/team_divisions.csv" ///
	, varn(1) bindquote(strict) clear

tempfile divisions
save `divisions', replace // okay, moving on to the real stuff:


********************************************************************
*open the clean scores file, narrow it, reshape & numeric ids & save
********************************************************************
// the scores come from my github that I link at the top of this file
import delimited ///
	"${route}/data/cleaned_scores.csv" ///
	, varn(1) clear
	
drop event_title  // we know these, and we'll label them ourselves later
drop if year>2024 // we're only going from 2015-2024 for this paper

merge m:1 team using `divisions', keep(1 3) nogen // now we've got divisions attached to the teams!

egen event_meet_id = concat(event date host meettitle), punct(" / ") // and now we have a unique event-within-meet identifier! but we'll want a numeric version for fixed effects later as well:

sort event_meet_id
gen emnumid  = 1
gen emchange = event_meet_id!=event_meet_id[_n-1]
replace emnumid = emnumid[_n-1] + emchange in 2/L // this block creates a unique group id (called emnumid for event-meet-numeric-id) for each event-by-meet identifier!
drop emchange

sort team
gen teamid = 1
gen swaps  = team!=team[_n-1]
replace teamid = teamid[_n-1] + swaps in 2/L // and now we've got one for teams as well, again for fixed effects later. We'll also make one for gymnasts in do-file 2 once we get race predictions on there
drop swaps


*now we want to make a measure of the number of meets a gymnast has competed over her career
gen datenum = date(date,"MDY") // this will let us sort meets correctly in order
sort gymnast datenum

gen career_meetnum=1 									 //  this will be the career meet count...
gen swapmeet = date!=date[_n-1]							 //  so mark when a meet changes...
replace career_meetnum = career_meetnum[_n-1] + swapmeet /// and count up across meets...
	if gymnast==gymnast[_n-1] 							 //  and within gymnasts!
drop swapmeet


*and now we're done!
compress
sort team year meetnum event score
export delimited using "${route}/data/all_scores_2015-2024.csv", replace // and we're done!







