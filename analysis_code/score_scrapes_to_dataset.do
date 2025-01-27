/*

this file gets all the unique gymnast-by-team observations from our scrapes, creates a unique event-by-meet id, and saves the full dataset to be published

*/

clear all

*edit this to be the path with all the team-year csv files, unless you're running everything from the 00_run_everything file
*global route "C:/Users/toom/Desktop/uneven_bars"


************************************************************
*tempfile the team-division crosswalk to merge on at the end
************************************************************
import delimited ///
	using "${route}/data/team_divisions.csv" ///
	, varn(1) bindquote(strict) clear

tempfile divisions
save `divisions', replace // okay, moving on to the real stuff:


********************************
*append all the files together!!
********************************
// make an empty file that we'll use as an append base
clear
tempfile appender
save `appender', emptyok

*define the local with all the csv files
cd "${route}/data/scrapes"
local files: dir "${route}/data/scrapes" files "*.csv"

*run through each csv file and append it to the ever growing append tempfile
foreach f of local files {
	import delimited using `"`f'"', varn(1) clear
	append using `appender'
	save `appender', replace
}


**************************************
*fix name inconsistencies and errors!!
**************************************
// there's a bunch of gymnasts whose names are missing or weird on RTN:

*some gymnasts are blank on RTN, let's fix those:
replace gymnast = "Grace Woolfolk" if gymnast=="" & team=="Iowa State"
replace gymnast = "Polina Poliakova" if gymnast=="" & team=="Rutgers"
replace gymnast = "Carleigh Stillwagon" if gymnast=="" & team=="Western Michigan" // these are the missing names

*fixing typos and misspellings:
replace gymnast = "Desire' Stephens" if gymnast=="DesirÃ© Stephens" // obvious weird thing
replace gymnast = "Marie Priest" if gymnast=="Narah Priest" // this was a weird typo on one single meet, there is no Narah Priest as far as I can find
replace gymnast = "Ava Kelley" if gymnast=="Ava Kelly" & team=="Springfield College" // they spelled her name wrong and there's another Ava Kelly at Southern Conn
replace gymnast = "Jessica Miley" if gymnast=="Jessisca Miley" // this is just a raw extra-S typo
replace gymnast = "Maddie Vitolo" if gymnast=="Maddie Viltolo" // and an extra-L classic
replace gymnast = "Kaitlin DeGuzman" if gymnast=="Kaitlin Deguzman" // they didn't capitalize her name at Kentucky but did at Clemson
replace gymnast = "Sophia LeBlanc" if gymnast=="Sophia Leblanc" // another caps issue here
replace gymnast = subinstr(gymnast, "  ", " ", .) // there's a bunch of double space gaps for no reason

*gymnasts with name changes across teams or over time:
replace gymnast = "Sunny Hasebe" if gymnast=="Haruka Hasebe" // this is a Winona State gymnast with two names she's used for scores
replace gymnast = "Lindsey Hunter-Kempler" if team=="BYU" & (gymnast=="Linsey Hunter-Kempler" | gymnast=="Lindsey Hunter") // she got married and hyphenated her name
replace gymnast = "Natasha Marsh" if team=="BYU" & gymnast=="Natasha Trejo" // she got married and changed her name
replace gymnast = "Shannon Evans" if team=="BYU" & gymnast=="Shannon Hortman" // so did she

*there are two different Abbie Thompson:
replace gymnast = "Abbie Thompson (Cornell)" if gymnast=="Abbie Thompson" & team=="Cornell"
replace gymnast = "Abbie Thompson (Denver)" if gymnast=="Abbie Thompson" & team=="Denver"

*there are two different Emily Anderson:
replace gymnast = "Emily Anderson (Gustavus Adolphus)" if gymnast=="Emily Anderson" & team=="Gustavus Adolphus"
replace gymnast = "Emily Anderson (Hamline)" if gymnast=="Emily Anderson" & team=="Hamline"

*there are two different Emily Leese:
replace gymnast = "Emily Leese (Rutgers)" if gymnast=="Emily Leese" & team=="Rutgers"
replace gymnast = "Emily Leese (UW-Eau Claire)" if gymnast=="Emily Leese" & team=="UW-Eau Claire"

*there are two different Emily White:
replace gymnast = "Emily White (North Carolina)" if gymnast=="Emily White" & team=="North Carolina"
replace gymnast = "Emily White (Arizona State)" if gymnast=="Emily White" & team=="Arizona State"

*there are two different Emma Brown:
replace gymnast = "Emma Brown (Ursinus College)" if gymnast=="Emma Brown" & team=="Ursinus College"
replace gymnast = "Emma Brown (Denver)" if gymnast=="Emma Brown" & team=="Denver"

*there are two different Gabrielle Johnson:
replace gymnast = "Gabrielle Johnson (Central Michigan)" if gymnast=="Gabrielle Johnson" & team=="Central Michigan"
replace gymnast = "Gabrielle Johnson (Winona State)" if gymnast=="Gabrielle Johnson" & team=="Winona State"

*there are two different Jordan William:
replace gymnast = "Jordan Williams (UCLA)" if gymnast=="Jordan Williams" & team=="UCLA"
replace gymnast = "Jordan Williams (S.E. Missouri)" if gymnast=="Jordan Williams" & team=="S.E. Missouri"

*there are two different Katie Bailey:
replace gymnast = "Katie Bailey (Alabama)" if gymnast=="Katie Bailey" & team=="Alabama"
replace gymnast = "Katie Bailey (Lindenwood)" if gymnast=="Katie Bailey" & team=="Lindenwood"

*there are two different Lauren Miller:
replace gymnast = "Lauren Miller (Air Force)" if gymnast=="Lauren Miller" & team=="Air Force"
replace gymnast = "Lauren Miller (LIU)" if gymnast=="Lauren Miller" & team=="LIU"

*there are two different Lauren Wong:
replace gymnast = "Lauren Wong (Cornell)" if gymnast=="Lauren Wong" & team=="Cornell"
replace gymnast = "Lauren Wong (Utah)" if gymnast=="Lauren Wong" & team=="Utah"

*there are two different Leah Smith:
replace gymnast = "Leah Smith (Towson)" if gymnast=="Leah Smith" & team=="Towson"
replace gymnast = "Leah Smith (Arkansas)" if gymnast=="Leah Smith" & team=="Arkansas"

*there are two different Maya Davis:
replace gymnast = "Maya Davis (Brown)" if gymnast=="Maya Davis" & team=="Brown"
replace gymnast = "Maya Davis (Lindenwood)" if gymnast=="Maya Davis" & team=="Lindenwood"

*there are two different Olivia Williams:
replace gymnast = "Olivia Williams (Centenary College)" if gymnast=="Olivia Williams" & team=="Centenary College"
replace gymnast = "Olivia Williams (Bowling Green)" if gymnast=="Olivia Williams" & team=="Bowling Green"

*there are two different Payton Murphy:
replace gymnast = "Payton Murphy (Cornell)" if gymnast=="Payton Murphy" & team=="Cornell"
replace gymnast = "Payton Murphy (Western Michigan)" if gymnast=="Payton Murphy" & team=="Western Michigan"

*there are two different Payton Smith:
replace gymnast = "Payton Smith (Rhode Island College)" if gymnast=="Payton Smith" & team=="Rhode Island College"
replace gymnast = "Payton Smith (Auburn)" if gymnast=="Payton Smith" & team=="Auburn"

*there are two different Samantha Henry:
replace gymnast = "Samantha Henry (Cornell)" if gymnast=="Samantha Henry" & team=="Cornell"
replace gymnast = "Samantha Henry (Kent State)" if gymnast=="Samantha Henry" & team=="Kent State"

*there are two different Shannon Farrell:
replace gymnast = "Shannon Farrell (Rutgers)" if gymnast=="Shannon Farrell" & team=="Rutgers"
replace gymnast = "Shannon Farrell (Alaska)" if gymnast=="Shannon Farrell" & team=="Alaska"

*there are two different Sophie Schmitz:
replace gymnast = "Sophie Schmitz (Centenary College)" if gymnast=="Sophie Schmitz" & team=="Centenary College"
replace gymnast = "Sophie Schmitz (Gustavus Adolphus)" if gymnast=="Sophie Schmitz" & team=="Gustavus Adolphus"

*there are two different Sydney Smith:
replace gymnast = "Sydney Smith (Fisk)" if gymnast=="Sydney Smith" & team=="Fisk"
replace gymnast = "Sydney Smith (Southern Conn.)" if gymnast=="Sydney Smith" & team=="Southern Conn."

*there are two different Sydney Ewing:
replace gymnast = "Sydney Ewing (LSU)" if gymnast=="Sydney Ewing" & team=="LSU"
replace gymnast = "Sydney Ewing (Michigan State)" if gymnast=="Sydney Ewing" & team=="Michigan State"


********************************************
*fix meet title inconsistencies and errors!!
********************************************
// there's a bunch of meets whose titles are missing on RTN:
*fix the BIG 5 Meet from 2024:
replace meettitle = "BIG 5 Meet" if date=="Feb-23-2024" & host==""

*fix the Alabama-Auburn Elevate the Stage from 2015:
replace meettitle = "Elevate The Stage" if date=="Mar-08-2015" & host==""

*fix the West Chester Pink Invite from 2019:
replace meettitle = "Pink Invite" if date=="Feb-22-2019" & host==""

*fix the Cancun Classic from 2019:
replace meettitle = "Cancun Classic" if date=="Jan-04-2019" & host==""

// there are two untitled meets involving Georgia in March 2023 (their 10th & 11th meets, which were also Arkansas' 9th and Michigan's 10th, respectively). They had to do some emergency repairs to their arena so they went to a semi-neutral site nearby... so they /kinda/ hosted, but not enough to mark them as hosts (for the purposes of this project) or to title the meet. their event_meet_id made below is still unique for both of the meets due to the different dates of the meets and due to those two meets being the only two (untitled & no-host) meets in the sample.


***********************************************
*final formatting: reshape & numeric ids & save
***********************************************
// now we'd like to generate a string that uniquely identifies events within meets, but it needs a reshape:
rename (vault bars beam floor) (score1 score2 score3 score4)
reshape long score, i(meettitle date host gymnast) j(event)
drop if score==. // good stuff, now let's move along:

merge m:1 team using `divisions', nogen // now we've got divisions attached to the teams!

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

*and now we're done!
compress
sort team year meetnum event score
export delimited using "${route}/data/all_scores_2015-2024.csv", replace // and we're done!







