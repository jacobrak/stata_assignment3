use "Thorell_Lamers_HW3.dta", clear

* Vad var effekten av Stockholms trängselskatt på koldioxidutsläpp i Stockholms län? The varible we are intressed in is carbondioxid emissions
* We have a G of 2 
* We have a T of 20 from the years 1990-2010



* data
twoway                                ///
    (scatter co2 year if sthlm==1, connect(l)) ///
    (scatter co2 year if sthlm==0, connect(l)) ///
	 ,xline(2006.5) ///
    xtick(1990(1)2010, angle(70)) ///
    legend(label(1 "Stockholm") label(2 "Gothenburg")) ///
    graphregion(color(white))

* Delta
egen co2_s1 = mean(cond(sthlm==1, co2, .)), by(year)
egen co2_s0 = mean(cond(sthlm==0, co2, .)), by(year)

gen diff_co2 = co2_s1 - co2_s0 

scatter diff_co2 year if sthlm == 1, ///
    connect(l) ///
    xline(2006.5) ///
    xtick(1990(1)2010, angle(70)) ///
    title("Diff CO2 Stockholm - Gothenburg") ///
    graphregion(color(white))
	
* Regression

gen stockholm_post = sthlm*after
reg co2 sthlm after stockholm_post, r

* Part 2 

use "Thorell_Lamers_HW3.dta", clear

gen post_effect = sthlm*after

reg co2 i.year sthlm post_effect, r 

* part 3 
* Wide shape
use "Thorell_Lamers_HW3.dta", clear
drop antal_bi
reshape wide co2 after, i(year) j(sthlm)

* Create new varible
gen diff_co2 = co21 - co20

* Neway west round up
dis 0.75*_N^(1/3)
tsset year 
newey diff_co2 after1, lag(3) 

* part 3 
use "Thorell_Lamers_HW3.dta", clear
* Dummy for year
gen y2004 = (year==2004)
gen y2005 = (year==2005)

* interaction
gen y2004_sthlm = sthlm * y2004
gen y2005_sthlm = sthlm * y2005

reg co2 sthlm y2004 y2005 y2004_sthlm y2005_sthlm if year < 2006, r

forvalues z=0/2 {
	
	gen pre_`z'=sthlm*(year==2007-`z')
	gen post_`z'=sthlm*(year==2007+`z')
	
}

gen pre_3=sthlm*(year<=2007-3) // Binned end point -3
gen post_3=sthlm*(year>=2007+3) // Binned end point +3


reghdfe co2 sthlm  pre_3 pre_2 post_0 post_1 post_2 post_3 , absorb(year)
 