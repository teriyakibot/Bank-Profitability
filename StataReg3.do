capture clear
capture log close
set more off

*merge data
cd "C:/Users/Admin/Desktop/Desktop/data/data/StataRegression"

log using StataReg3.log, text replace

use "bank_cha.dta", clear
merge m:1 security_num using "security_location.dta"
drop _merge
merge m:1 year using "macro_cleaned.dta"
drop _merge
merge m:1  year 城市 using "cleaned_mkt_sum.dta"
drop _merge
*merge m:1 城市 year using "cleaned_provincial_unemployment.dta"
*drop _merge
merge m:1 year 城市 using "employ_shock.dta"
drop _merge


drop if year>2016 | year<2008 
gen de_security_num = substr(security_num,-10,.)
destring de_security_num, replace
save "regression_panel.dta", replace
use "regression_panel.dta", clear
drop if roae == "NA"
drop if roaa == "NA"
*drop if asset == "NA"
*drop if equity == "NA"
drop if diversification == "NA"

destring roaa, replace
destring roae, replace
destring asset, replace
gen logasset = log(asset)
destring equity, replace
destring diversification, replace

gen lever = asset/equity
*gen mkt_unemploy = mktization*unemploy_rate

winsor2 roaa , replace cuts (1 99)
winsor2 roae , replace cuts (1 99)
winsor2 lever , replace cuts (1 99)
winsor2 diversification , replace cuts (1 99)

gen logasset_mkt = logasset*mktization
gen lever_mkt = lever*mktization

gen logasset_employshock = logasset*employ_shock
gen lever_employshock = lever*employ_shock

//roae
 
//OLS
reg roae lever logasset diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num), replace

//interact with mktization
reg roae lever logasset logasset_mkt diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 
reg roae lever lever_mkt logasset diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 

//interact with employ_shock
reg roae lever logasset logasset_employshock diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 
reg roae lever lever_employshock logasset diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num)

//single mktization
generate province_num = 城市
destring province_num, replace force
gen province_year = province_num*year
reg roae lever logasset diversification mktization i.城市#year i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 

//roaa

//OLS
reg roaa lever logasset diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 

//interact with mktization
reg roaa lever logasset logasset_mkt diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 
reg roaa lever lever_mkt logasset diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 

//interact with employ_shock
reg roaa lever logasset logasset_employshock diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 
reg roaa lever lever_employshock logasset diversification mktization employ_shock i.year i.de_security_num, cluster(城市)
outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 

*use "regression_panel.dta", clear
*drop if roaa == "NA"
*drop if diversification == "NA"
*destring roaa, replace
*destring asset, replace
*destring equity, replace
*destring diversification, replace
*destring unemploy_rate, replace
*gen capitalization = asset/equity-1
*gen mkt_unemploy = mktization*unemploy_rate

//OLS
*reg roaa equity asset diversification mktization unemploy_rate i.year i.de_security_num, cluster(城市)
*outreg2 using Table1_1, excel dec(4) drop(_I* o._I* _I.de_security_num) 

//OLS
*xi: reg health eduy i.yob if yob>=1965 & yob<1985, cluster(yob)
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) replace

//First stage
*xi: reg eduy halfdummy2 i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob)
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*)

*IV estimation
*xi: ivreg2 health (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*)

*xi: ivreg2 healthstatus (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 ill (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 chronic (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 hospital (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 fdepression (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 forgetfull (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 depressed (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 nervous (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 restless (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 hopeless (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 difficult (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 meaningless (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985, cluster(yob) partial(i.yob i.birth_prov) first
*outreg2 using Table2_1, excel dec(3) drop(_I* o._I*) 


*Heterogenous effect
*xi: ivreg2 healthstatus (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & male==1, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) replace

*xi: ivreg2 healthstatus (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & male==0, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 healthstatus (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & urbanhk_12==1, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 healthstatus (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & urbanhk_12==0, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 depressed (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & male==1, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*)

*xi: ivreg2 depressed (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & male==0, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 depressed (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & urbanhk_12==1, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) 

*xi: ivreg2 depressed (eduy=halfdummy2) i.yob i.birth_prov if yob>=1965 & yob<1985 & urbanhk_12==0, cluster(yob) partial(i.yob i.birth_prov)
*outreg2 using Table2_2, excel dec(3) drop(_I* o._I*) 


cap log close 
