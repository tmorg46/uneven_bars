*****************************************************
*Table 2: Average Scores by Event, Division, and Race
*****************************************************
// done
// we're gonna swap through summarizing scores by these categories and putting the means and sd's into locals
use "${route}/data/analysis_set.dta", clear

keep if meettitle=="no meet title" & host!="" // only the ordinary meets!!

// we'll mark the locals as panel_race_event_stat:

*start with the all races row from panel 1: all gymnasts
sum score
local all_all_overall_score = r(mean)
local all_all_overall_stdev = r(sd)

sum score if event==1
local all_all_vault_score = r(mean)
local all_all_vault_stdev = r(sd)

sum score if event==2
local all_all_bars_score = r(mean)
local all_all_bars_stdev = r(sd)

sum score if event==3
local all_all_beam_score = r(mean)
local all_all_beam_stdev = r(sd)

sum score if event==4
local all_all_floor_score = r(mean)
local all_all_floor_stdev = r(sd)

*now the white gymnast only row from panel 1: all gymnasts
sum score if race=="White"
local all_white_overall_score = r(mean)
local all_white_overall_stdev = r(sd)

sum score if event==1 & race=="White"
local all_white_vault_score = r(mean)
local all_white_vault_stdev = r(sd)

sum score if event==2 & race=="White"
local all_white_bars_score = r(mean)
local all_white_bars_stdev = r(sd)

sum score if event==3 & race=="White"
local all_white_beam_score = r(mean)
local all_white_beam_stdev = r(sd)

sum score if event==4 & race=="White"
local all_white_floor_score = r(mean)
local all_white_floor_stdev = r(sd)

*now the black gymnast only row from panel 1: all gymnasts
sum score if race=="Black"
local all_black_overall_score = r(mean)
local all_black_overall_stdev = r(sd)

sum score if event==1 & race=="Black"
local all_black_vault_score = r(mean)
local all_black_vault_stdev = r(sd)

sum score if event==2 & race=="Black"
local all_black_bars_score = r(mean)
local all_black_bars_stdev = r(sd)

sum score if event==3 & race=="Black"
local all_black_beam_score = r(mean)
local all_black_beam_stdev = r(sd)

sum score if event==4 & race=="Black"
local all_black_floor_score = r(mean)
local all_black_floor_stdev = r(sd)

*start with the all races row from panel 2: only D1 gymnasts
sum score if division==1
local d1_all_overall_score = r(mean)
local d1_all_overall_stdev = r(sd)

sum score if event==1 & division==1
local d1_all_vault_score = r(mean)
local d1_all_vault_stdev = r(sd)

sum score if event==2 & division==1
local d1_all_bars_score = r(mean)
local d1_all_bars_stdev = r(sd)

sum score if event==3 & division==1
local d1_all_beam_score = r(mean)
local d1_all_beam_stdev = r(sd)

sum score if event==4 & division==1
local d1_all_floor_score = r(mean)
local d1_all_floor_stdev = r(sd)

*now the white gymnast only row from panel 2: only D1 gymnasts
sum score if race=="White" & division==1
local d1_white_overall_score = r(mean)
local d1_white_overall_stdev = r(sd)

sum score if event==1 & race=="White" & division==1
local d1_white_vault_score = r(mean)
local d1_white_vault_stdev = r(sd)

sum score if event==2 & race=="White" & division==1
local d1_white_bars_score = r(mean)
local d1_white_bars_stdev = r(sd)

sum score if event==3 & race=="White" & division==1
local d1_white_beam_score = r(mean)
local d1_white_beam_stdev = r(sd)

sum score if event==4 & race=="White" & division==1
local d1_white_floor_score = r(mean)
local d1_white_floor_stdev = r(sd)

*now the black gymnast only row from panel 2: only D1 gymnasts
sum score if race=="Black" & division==1
local d1_black_overall_score = r(mean)
local d1_black_overall_stdev = r(sd)

sum score if event==1 & race=="Black" & division==1
local d1_black_vault_score = r(mean)
local d1_black_vault_stdev = r(sd)

sum score if event==2 & race=="Black" & division==1
local d1_black_bars_score = r(mean)
local d1_black_bars_stdev = r(sd)

sum score if event==3 & race=="Black" & division==1
local d1_black_beam_score = r(mean)
local d1_black_beam_stdev = r(sd)

sum score if event==4 & race=="Black" & division==1
local d1_black_floor_score = r(mean)
local d1_black_floor_stdev = r(sd)

*start with the all races row from panel 3: only non-D1 gymnasts
sum score if division!=1
local nond1_all_overall_score = r(mean)
local nond1_all_overall_stdev = r(sd)

sum score if event==1 & division!=1
local nond1_all_vault_score = r(mean)
local nond1_all_vault_stdev = r(sd)

sum score if event==2 & division!=1
local nond1_all_bars_score = r(mean)
local nond1_all_bars_stdev = r(sd)

sum score if event==3 & division!=1
local nond1_all_beam_score = r(mean)
local nond1_all_beam_stdev = r(sd)

sum score if event==4 & division!=1
local nond1_all_floor_score = r(mean)
local nond1_all_floor_stdev = r(sd)

*now the white gymnast only row from panel 3: only non-D1 gymnasts
sum score if race=="White" & division!=1
local nond1_white_overall_score = r(mean)
local nond1_white_overall_stdev = r(sd)

sum score if event==1 & race=="White" & division!=1
local nond1_white_vault_score = r(mean)
local nond1_white_vault_stdev = r(sd)

sum score if event==2 & race=="White" & division!=1
local nond1_white_bars_score = r(mean)
local nond1_white_bars_stdev = r(sd)

sum score if event==3 & race=="White" & division!=1
local nond1_white_beam_score = r(mean)
local nond1_white_beam_stdev = r(sd)

sum score if event==4 & race=="White" & division!=1
local nond1_white_floor_score = r(mean)
local nond1_white_floor_stdev = r(sd)

*now the black gymnast only row from panel 3: only non-D1 gymnasts
sum score if race=="Black" & division!=1
local nond1_black_overall_score = r(mean)
local nond1_black_overall_stdev = r(sd)

sum score if event==1 & race=="Black" & division!=1
local nond1_black_vault_score = r(mean)
local nond1_black_vault_stdev = r(sd)

sum score if event==2 & race=="Black" & division!=1
local nond1_black_bars_score = r(mean)
local nond1_black_bars_stdev = r(sd)

sum score if event==3 & race=="Black" & division!=1
local nond1_black_beam_score = r(mean)
local nond1_black_beam_stdev = r(sd)

sum score if event==4 & race=="Black" & division!=1
local nond1_black_floor_score = r(mean)
local nond1_black_floor_stdev = r(sd)

*and now let's put that stuff into a goll-darn table!!!!
putexcel set "${route}/output/table2", sheet(table2, replace) modify // we're replacing the sheet but modifying the document as a whole; this avoids deleting other tables later but still lets us refresh this table on each rerun
putexcel A2  = "Panel 1: All Gymnasts" ///
		 A3  = "white"	///
		 A5  = "black"	///
		 A7  = "all"	///
		 ///
		 A10 = "Panel 2: Only D1 Gymnasts" ///
		 A11 = "white"	///
		 A13 = "black"	///
		 A15 = "all"	///
		 ///
		 A18 = "Panel 3: Only non-D1 Gymnasts" ///
		 A19 = "white"	///
		 A21 = "black"	///
		 A23 = "all"	// gotta get the row titles
		 
putexcel B1  = "Vault"	///
		 C1  = "Bars"	///
		 D1  = "Beam"	///
		 E1  = "Floor"	///
		 F1  = "All Events" // and the column titles

*here comes panel 1: all gymnasts!
putexcel B3  = `all_white_vault_score'	///
		 C3  = `all_white_bars_score'	///
		 D3  = `all_white_beam_score'	///
		 E3  = `all_white_floor_score'	///
		 F3  = `all_white_overall_score' ///
		 ///
		 B4  = `all_white_vault_stdev'	///
		 C4  = `all_white_bars_stdev'	///
		 D4  = `all_white_beam_stdev'	///
		 E4  = `all_white_floor_stdev'	///
		 F4  = `all_white_overall_stdev' ///
		 ///
		 B5  = `all_black_vault_score'	///
		 C5  = `all_black_bars_score'	///
		 D5  = `all_black_beam_score'	///
		 E5  = `all_black_floor_score'	///
		 F5  = `all_black_overall_score' ///
		 ///
		 B6  = `all_black_vault_stdev'	///
		 C6  = `all_black_bars_stdev'	///
		 D6  = `all_black_beam_stdev'	///
		 E6  = `all_black_floor_stdev'	///
		 F6  = `all_black_overall_stdev' ///
		 ///
		 B7  = `all_all_vault_score'	///
		 C7  = `all_all_bars_score'		///
		 D7  = `all_all_beam_score'		///
		 E7  = `all_all_floor_score'	///
		 F7  = `all_all_overall_score' ///
		 ///
		 B8  = `all_all_vault_stdev' 	///
		 C8  = `all_all_bars_stdev'		///
		 D8  = `all_all_beam_stdev'		///
		 E8  = `all_all_floor_stdev'	///
		 F8  = `all_all_overall_stdev', nformat(#0.00) // that's panel 1!
		 
*here comes panel 2: only D1 gymnasts!
putexcel B11 = `d1_white_vault_score'	///
		 C11 = `d1_white_bars_score'	///
		 D11 = `d1_white_beam_score'	///
		 E11 = `d1_white_floor_score'	///
		 F11 = `d1_white_overall_score' ///
		 ///
		 B12 = `d1_white_vault_stdev'	///
		 C12 = `d1_white_bars_stdev'	///
		 D12 = `d1_white_beam_stdev'	///
		 E12 = `d1_white_floor_stdev'	///
		 F12 = `d1_white_overall_stdev' ///
		 ///
		 B13 = `d1_black_vault_score'	///
		 C13 = `d1_black_bars_score'	///
		 D13 = `d1_black_beam_score'	///
		 E13 = `d1_black_floor_score'	///
		 F13 = `d1_black_overall_score' ///
		 ///
		 B14 = `d1_black_vault_stdev'	///
		 C14 = `d1_black_bars_stdev'	///
		 D14 = `d1_black_beam_stdev'	///
		 E14 = `d1_black_floor_stdev'	///
		 F14 = `d1_black_overall_stdev' ///
		 ///
		 B15 = `d1_all_vault_score'	///
		 C15 = `d1_all_bars_score'	///
		 D15 = `d1_all_beam_score'	///
		 E15 = `d1_all_floor_score'	///
		 F15 = `d1_all_overall_score' ///
		 ///
		 B16 = `d1_all_vault_stdev' ///
		 C16 = `d1_all_bars_stdev'	///
		 D16 = `d1_all_beam_stdev'	///
		 E16 = `d1_all_floor_stdev'	///
		 F16 = `d1_all_overall_stdev', nformat(#0.00) // that's panel 2!
		 
*here comes panel 3: only non-D1 gymnasts!
putexcel B19 = `nond1_white_vault_score'	///
		 C19 = `nond1_white_bars_score'	///
		 D19 = `nond1_white_beam_score'	///
		 E19 = `nond1_white_floor_score'	///
		 F19 = `nond1_white_overall_score' ///
		 ///
		 B20 = `nond1_white_vault_stdev'	///
		 C20 = `nond1_white_bars_stdev'	///
		 D20 = `nond1_white_beam_stdev'	///
		 E20 = `nond1_white_floor_stdev'	///
		 F20 = `nond1_white_overall_stdev' ///
		 ///
		 B21 = `nond1_black_vault_score'	///
		 C21 = `nond1_black_bars_score'	///
		 D21 = `nond1_black_beam_score'	///
		 E21 = `nond1_black_floor_score'	///
		 F21 = `nond1_black_overall_score' ///
		 ///
		 B22 = `nond1_black_vault_stdev'	///
		 C22 = `nond1_black_bars_stdev'	///
		 D22 = `nond1_black_beam_stdev'	///
		 E22 = `nond1_black_floor_stdev'	///
		 F22 = `nond1_black_overall_stdev' ///
		 ///
		 B23 = `nond1_all_vault_score'	///
		 C23 = `nond1_all_bars_score'	///
		 D23 = `nond1_all_beam_score'	///
		 E23 = `nond1_all_floor_score'	///
		 F23 = `nond1_all_overall_score' ///
		 ///
		 B24 = `nond1_all_vault_stdev' ///
		 C24 = `nond1_all_bars_stdev'	///
		 D24 = `nond1_all_beam_stdev'	///
		 E24 = `nond1_all_floor_stdev'	///
		 F24 = `nond1_all_overall_stdev', nformat(#0.00) // that's panel 3! donezo!!

*/