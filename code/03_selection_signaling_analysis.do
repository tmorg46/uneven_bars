/*

this file does the same analysis for teams visiting established hosts (i.e. have 2015-2024 seasons) who have never had a black gymnast (BYU, Boise State, Gustavus Adolphus, UW-La Crosse) and for teams who have always had at least two black gymnasts (Florida, Michigan State, UCLA, West Virginia)

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
*br if min>1 // these teams with all 10 seasons are consistently selected by multiple Black gymnasts: Florida, Michigan State, UCLA, West Virginia

collapse black, by(team)
*br if black==0 // these teams with all 10 seasons have never been selected by a Black gymnast: BYU, Boise State, Gustavus Adolphus, UW-La Crosse



