/*

this file computes the fraction of gymnasts ever at a program who were Black (overall as well as pre- and post-floyd) and uses that as a "signal" as to the amicability of the environment to Black gymnasts in analysis

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


*********************************
*Build the Black Selection Signal
*********************************
// pending
*open the Black crosswalk and get moving!!
import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear

reshape long roster, i(team gymnast black) j(year)
drop if missing(roster)
drop roster

drop if gymnast==gymnast[_n-1] & gymnast==gymnast[_n+1] & team==team[_n-1] & team==team[_n+1] // this leaves the earliest year a gymnast recorded a score in a meet as a member of a given team and the latest year

collapse black, by(team)
