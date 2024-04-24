/*

this file gets all the unique gymnast-by-team observations, orders them for ease of putting together our race crosswalk, then applies our Black indicator, marks the playoffs, and saves the full dataset

*/

clear all

*edit this to be the path with all the team-year csv files
global route "/Users/tmac/Desktop/uneven_bars"


*make an empty file that we'll use as an append base
tempfile appender
save `appender', emptyok


*define the local with all the csv files
cd "$route/data/scrapes"
local files: dir "$route/data/scrapes" files "*.csv"


*run through each csv file and append it to the ever growing append tempfile
foreach f of local files {
	import delimited using `"`f'"', varn(1) clear
	append using `appender'
	save `appender', replace
}


*there's a couple gymnasts whose names are missing or weird on RTN that we found while handcoding black. In addition, some different gymnasts share names, while other gymnasts move teams. I'll fix them ahead of time here:
replace gymnast = "Grace Woolfolk" if gymnast=="" & team=="Iowa State"
replace gymnast = "Polina Poliakova" if gymnast=="" & team=="Rutgers"
replace gymnast = "Carleigh Stillwagon" if gymnast=="" & team=="Western Michigan" // these are the missing names

replace gymnast = "Desire' Stephens" if gymnast=="DesirÃ© Stephens" // obvious weird thing

replace gymnast = "Ava Kelley" if gymnast=="Ava Kelly" & team=="Springfield College" // they spelled her name wrong and there's another Ava Kelly at Southern Conn

replace gymnast = "Kaitlin DeGuzman" if gymnast=="Kaitlin Deguzman" // they didn't capitalize her name at Kentucky but did at Clemson
replace gymnast = "Sophia LeBlanc" if gymnast=="Sophia Leblanc" // another caps issue here

replace gymnast = "Lindsey Hunter-Kempler" if team=="BYU" & (gymnast=="Linsey Hunter-Kempler" | gymnast=="Lindsey Hunter") // she got married and hyphenated her name

replace gymnast = subinstr(gymnast, "  ", " ", .) // there's a bunch of double space gaps for no reason

replace gymnast = "Abbie Thompson (Cornell)" if gymnast=="Abbie Thompson" & team=="Cornell"
replace gymnast = "Abbie Thompson (Denver)" if gymnast=="Abbie Thompson" & team=="Denver"

replace gymnast = "Emily Anderson (Gustavus Adolphus)" if gymnast=="Emily Anderson" & team=="Gustavus Adolphus"
replace gymnast = "Emily Anderson (Hamline)" if gymnast=="Emily Anderson" & team=="Hamline"

replace gymnast = "Emily Leese (Rutgers)" if gymnast=="Emily Leese" & team=="Rutgers"
replace gymnast = "Emily Leese (UW-Eau Claire)" if gymnast=="Emily Leese" & team=="UW-Eau Claire"

replace gymnast = "Emily White (North Carolina)" if gymnast=="Emily White" & team=="North Carolina"
replace gymnast = "Emily White (Arizona State)" if gymnast=="Emily White" & team=="Arizona State"

replace gymnast = "Emma Brown (Ursinus College)" if gymnast=="Emma Brown" & team=="Ursinus College"
replace gymnast = "Emma Brown (Denver)" if gymnast=="Emma Brown" & team=="Denver"

replace gymnast = "Gabrielle Johnson (Central Michigan)" if gymnast=="Gabrielle Johnson" & team=="Central Michigan"
replace gymnast = "Gabrielle Johnson (Winona State)" if gymnast=="Gabrielle Johnson" & team=="Winona State"

replace gymnast = "Jordan Williams (UCLA)" if gymnast=="Jordan Williams" & team=="UCLA"
replace gymnast = "Jordan Williams (S.E. Missouri)" if gymnast=="Jordan Williams" & team=="S.E. Missouri"

replace gymnast = "Katie Bailey (Alabama)" if gymnast=="Katie Bailey" & team=="Alabama"
replace gymnast = "Katie Bailey (Lindenwood)" if gymnast=="Katie Bailey" & team=="Lindenwood"

replace gymnast = "Lauren Miller (Air Force)" if gymnast=="Lauren Miller" & team=="Air Force"
replace gymnast = "Lauren Miller (LIU)" if gymnast=="Lauren Miller" & team=="LIU"

replace gymnast = "Lauren Wong (Cornell)" if gymnast=="Lauren Wong" & team=="Cornell"
replace gymnast = "Lauren Wong (Utah)" if gymnast=="Lauren Wong" & team=="Utah"

replace gymnast = "Leah Smith (Towson)" if gymnast=="Leah Smith" & team=="Towson"
replace gymnast = "Leah Smith (Arkansas)" if gymnast=="Leah Smith" & team=="Arkansas"

replace gymnast = "Maya Davis (Brown)" if gymnast=="Maya Davis" & team=="Brown"
replace gymnast = "Maya Davis (Lindenwood)" if gymnast=="Maya Davis" & team=="Lindenwood"

replace gymnast = "Olivia Williams (Centenary College)" if gymnast=="Olivia Williams" & team=="Centenary College"
replace gymnast = "Olivia Williams (Bowling Green)" if gymnast=="Olivia Williams" & team=="Bowling Green"

replace gymnast = "Payton Murphy (Cornell)" if gymnast=="Payton Murphy" & team=="Cornell"
replace gymnast = "Payton Murphy (Western Michigan)" if gymnast=="Payton Murphy" & team=="Western Michigan"

replace gymnast = "Payton Smith (Rhode Island College)" if gymnast=="Payton Smith" & team=="Rhode Island College"
replace gymnast = "Payton Smith (Auburn)" if gymnast=="Payton Smith" & team=="Auburn"

replace gymnast = "Samantha Henry (Cornell)" if gymnast=="Samantha Henry" & team=="Cornell"
replace gymnast = "Samantha Henry (Kent State)" if gymnast=="Samantha Henry" & team=="Kent State"

replace gymnast = "Shannon Farrell (Rutgers)" if gymnast=="Shannon Farrell" & team=="Rutgers"
replace gymnast = "Shannon Farrell (Alaska)" if gymnast=="Shannon Farrell" & team=="Alaska"

replace gymnast = "Sophie Schmitz (Centenary College)" if gymnast=="Sophie Schmitz" & team=="Centenary College"
replace gymnast = "Sophie Schmitz (Gustavus Adolphus)" if gymnast=="Sophie Schmitz" & team=="Gustavus Adolphus"

replace gymnast = "Sydney Smith (Fisk)" if gymnast=="Sydney Smith" & team=="Fisk"
replace gymnast = "Sydney Smith (Southern Conn.)" if gymnast=="Sydney Smith" & team=="Southern Conn."

replace gymnast = "Sydney Ewing (LSU)" if gymnast=="Sydney Ewing" & team=="LSU"
replace gymnast = "Sydney Ewing (Michigan State)" if gymnast=="Sydney Ewing" & team=="Michigan State"

tempfile fullappend
save `fullappend', replace // save this to reopen and merge race onto later:


/* get the dataset down to a list of gymnasts by team-year (this is what we uploaded to Google Sheets to handcode race)
keep team year gymnast
sort team year gymnast
drop if team==team[_n-1] & year==year[_n-1] & gymnast==gymnast[_n-1] // now it's unique!

gen roster = 1 // use this for the reshape
reshape wide roster, i(team gymnast) j(year)

split gymnast // we want to sort on last names to make it easier when we handcode being black
sort team roster* gymnast2

keep team gymnast roster*

export delimited "$route/data/gymnasts_list.csv", replace
*/ 


*now open the handcoded race file to save as a tempfile to merge onto the fullappend set
import delimited using "$route/data/all_gymnasts_races.csv", varn(1) clear

keep black team gymnast

tempfile races
save `races', replace

use `fullappend', clear
merge m:1 team gymnast using `races', nogen // now all the gymnasts are marked as Black or not!!


*now we're gonna mark the meets that aren't regular season meets for future drops
gen playoffs = (strpos(meettitle, "Championship")>0) | (strpos(meettitle, "Regional")>0) | strpos(meettitle, "National")>0 | strpos(meettitle, "Conference")>0 | strpos(meettitle, "Qualifier")>0


*save the set!!
sort team year meetnum gymnast
compress
save "$route/data/all_scores_cleaned.dta", replace


