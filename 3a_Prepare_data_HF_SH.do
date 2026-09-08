
* ======================================================================================================================
*   
*   Filename:		3a_Prepare_data_HF
*   Author:			M Johnson
*   Creation Date:	12/10/2024
*
* 	Purpose:		To merge the Countdown input data templates and produce the base analytical datasets that will be 
*					required for the Countdown implementation of the Maina method
*
*   Details:		Part 0: Set global variables
* 					Part 1: Import and rework individual data files
* 					Part 2: Merge and rework data files
* 					Part 3: Create data files for completeness of reporting by health facility/year
* 					Part 4: Create data files to identify low reporting by health facility/year
* 					Part 5: Identify reported outliers by health facility/year
* 					Appendix 1: Base script sourced from Countdown
*
* ======================================================================================================================


*-----------------------------------------------------------------------------------------------------------------------
* Part 0: Set global variables ####
*-----------------------------------------------------------------------------------------------------------------------
clear all
set maxvar 20000
set matsize 10000
set more off, permanently

* change current working directory
cd " ... "

global lastyear = 2020    			// Replace by the most recent year of your country data (e.g., 2020, etc.)

global threshold_low_rr = 90		//Threshold of low completeness of reporting by year. Default value 90%. To adjust the threshold as needed (e.g. 90%, 80%, 70%)

*-----------------------------------------------------------------------------------------------------------------------
* Part 1: Import and rework individual data files ####
*-----------------------------------------------------------------------------------------------------------------------
* import service data files
import excel "0c_ix_DHIMS2_template_svc_data_1_hf.xlsx", sheet("Sheet 1") firstrow case(lower) clear
save "0c_ix_DHIMS2_template_svc_data_1_hf.dta", replace

import excel "0c_x_DHIMS2_template_svc_data_2_hf.xlsx", sheet("Sheet 1") firstrow case(lower) clear
save "0c_x_DHIMS2_template_svc_data_2_hf.dta", replace

import excel "0c_xi_DHIMS2_template_svc_data_3_hf.xlsx", sheet("Sheet 1") firstrow case(lower) clear
save "0c_xi_DHIMS2_template_svc_data_3_hf.dta", replace

// merge files
use "0c_ix_DHIMS2_template_svc_data_1_hf.dta", clear

merge 1:1 orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month using "0c_x_DHIMS2_template_svc_data_2_hf.dta"
list orgunitlevel3 subdistrict_group year month _merge if _merge != 3	// to check discrepancy of key variables for merging
drop _merge

merge 1:1 orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month using "0c_xi_DHIMS2_template_svc_data_3_hf.dta"
list orgunitlevel3 subdistrict_group year month _merge if _merge != 3	// to check discrepancy of key variables for merging
drop _merge

gen _month = .
replace _month = 1 if month == "January"
replace _month = 2 if month == "February"
replace _month = 3 if month == "March"
replace _month = 4 if month == "April"
replace _month = 5 if month == "May"
replace _month = 6 if month == "June"
replace _month = 7 if month == "July"
replace _month = 8 if month == "August"
replace _month = 9 if month == "September"
replace _month = 10 if month == "October"
replace _month = 11 if month == "November"
replace _month = 12 if month == "December"

order orgunitlevel3 subdistrict_group organisationunitname organisationunitid year _month // order variables in the dataset
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year _month // sort the dataset by listed variables

save "3a_i_DHIMS2_template_svc_data_all_hf.dta", replace


* import reporting completeness file
import excel "0c_xiv_DHIMS2_template_rep_compl_hf.xlsx", sheet("Sheet 1") firstrow case(lower) clear

gen _month = .
replace _month = 1 if month == "January"
replace _month = 2 if month == "February"
replace _month = 3 if month == "March"
replace _month = 4 if month == "April"
replace _month = 5 if month == "May"
replace _month = 6 if month == "June"
replace _month = 7 if month == "July"
replace _month = 8 if month == "August"
replace _month = 9 if month == "September"
replace _month = 10 if month == "October"
replace _month = 11 if month == "November"
replace _month = 12 if month == "December"

order orgunitlevel3 subdistrict_group organisationunitname organisationunitid year _month
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year _month

save "3a_ii_DHIMS2_template_rep_compl_all_hf.dta", replace


*-----------------------------------------------------------------------------------------------------------------------
* Part 2: Merge and rework data files ####
*-----------------------------------------------------------------------------------------------------------------------
* import and merge data files
use "3a_i_DHIMS2_template_svc_data_all_hf.dta", clear

merge 1:1 orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month using "3a_ii_DHIMS2_template_rep_compl_all_hf.dta"
list orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month _merge if _merge != 3	//*Check discrepancy of key variables for merging
drop _merge

order orgunitlevel3 subdistrict_group organisationunitname organisationunitid year _month month
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year _month

egen _period = concat(_month year)
replace _period = "0" + _period if strlen(_period) == 5

gen double date = date(_period, "MY")
format date %td

gen _monthsubstr = substr(month, 1, 3)

egen datex = concat(_monthsubstr year)

drop _month _period _monthsubstr

order date datex, after(month)
lab var date "Date of data"
lab var datex "Date of data in string format"

* rename variables to fit with existing naming scheme
rename ( ///
	mi_1 mi_2 mi_3 mi_4 mi_6_7_8 pnc_2 mi_10 mi_11 mi_10_11 mi_12 mi_13 i_13 mi_14 mi_15 mi_17 mi_18 mi_17_18 md_1_12 md_13 ///
	d_1 d_2_5 d_2_7 opd_1 opd_2_25 ipd_1 ipd_2_13 ///
	mi_1_2_rc mi_1_2_exp mi_1_2_rate ///
	mi_4_rc mi_4_exp mi_4_rate ///
	pnc_2_rc pnc_2_exp pnc_2_rate ///
	mi_12_13_14_15_rc mi_12_13_14_15_exp mi_12_13_14_15_rate ///
	opd_1_rc opd_1_exp opd_1_rate ///
	d_1_rc d_1_exp d_1_rate ///
	ipd_1_rc ipd_1_exp ipd_1_rate ///
	mi_10_11_rc mi_10_11_exp mi_10_11_rate ///
)	///
( ///
	anc1 anc4 ipt2 idelv csection pnc48h fp_new fp_revisits fp_total bcg penta1 penta2 penta3 measles1 stillbirth_f stillbirth_m total_stillbirth under5_deaths maternal_deaths ///
	diar_total diar_under1 diar_under5 opd_total opd_under5 ipd_total ipd_under5 ///
	anc_rep_rec anc_rep_exp anc_rr ///
	idelv_rep_rec idelv_rep_exp idelv_rr ///
	pnc_rep_rec pnc_rep_exp pnc_rr ///
	vacc_rep_rec vacc_rep_exp vacc_rr ///
	opd_rep_rec opd_rep_exp opd_rr ///
	diar_rep_rec diar_rep_exp diar_rr ///
	ipd_rep_rec ipd_rep_exp ipd_rr ///
	fp_rep_rec fp_rep_exp fp_rr ///
)

order orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month date datex
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month

save "3a_v_DHIMS2_template_master_non_adjusted_dataset_hf.dta", replace


*-----------------------------------------------------------------------------------------------------------------------
* Part 3: Create data files for completeness of reporting by health facility/year ####
*-----------------------------------------------------------------------------------------------------------------------
* import data files
use "3a_v_DHIMS2_template_master_non_adjusted_dataset_hf.dta", clear

keep orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month anc_rr idelv_rr pnc_rr vacc_rr opd_rr diar_rr ipd_rr fp_rr

* create and merge a series of sub-datasets for each variable
foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr diar_rr ipd_rr fp_rr {
	preserve
	collapse (mean) `var', by(orgunitlevel3 subdistrict_group organisationunitname organisationunitid year)
	save "_completeness_hf`var'.dta", replace
	restore
}

use "_completeness_hfanc_rr", clear
local reshapeddistrict: dir . files "_completeness_hf*.dta"
	foreach file of local reshapeddistrict {
	merge 1:1 orgunitlevel3 subdistrict_group organisationunitname organisationunitid year using "`file'"
drop _merge
}

* save dataset in stata format
save "3a_vii_DHIMS2_completeness_by_hf_year.dta", replace
 			
local tmpfile: dir . files "_completeness_hf*.dta"
foreach file of local tmpfile {
	erase "`file'"
} // drop temporary files from the current directory


*-----------------------------------------------------------------------------------------------------------------------
* Part 4: Create data files to identify low reporting by health facility/year ####
*-----------------------------------------------------------------------------------------------------------------------
* reshape working file (from previous section)
reshape wide anc_rr fp_rr idelv_rr pnc_rr ipd_rr opd_rr diar_rr vacc_rr, i(orgunitlevel3 subdistrict_group organisationunitname organisationunitid) j(year)

* flag health facilities with reporting completeness below the 'low' DQ threshold of 90% (i.e. % of expected health facilities with a reported value) by service type in 2017
gen lowc_17_anc = 0
replace lowc_17_anc = 1 if anc_rr2017 < ${threshold_low_rr}

gen lowc_17_fp = 0
replace lowc_17_fp = 1 if fp_rr2017 < ${threshold_low_rr}

gen lowc_17_idelv = 0
replace lowc_17_idelv = 1 if idelv_rr2017 < ${threshold_low_rr}

gen lowc_17_pnc = 0
replace lowc_17_pnc = 1 if pnc_rr2017 < ${threshold_low_rr}

gen lowc_17_vacc = 0
replace lowc_17_vacc = 1 if vacc_rr2017 < ${threshold_low_rr}

gen lowc_17_opd = 0
replace lowc_17_opd = 1 if opd_rr2017 < ${threshold_low_rr}

gen lowc_17_diar = 0
replace lowc_17_diar = 1 if diar_rr2017 < ${threshold_low_rr}

gen lowc_17_ipd = 0
replace lowc_17_ipd = 1 if ipd_rr2017 < ${threshold_low_rr}

lab var lowc_17_anc "Health facility with ANC reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_fp "Health facility with Family Planning reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_idelv "Health facility with institutional delivery reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_pnc "Health facility with PNC reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_vacc "Health facility with vaccination reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_opd "Health facility with OPD visits reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_opd "Health facility with (all ages) diarrhoea service events reporting below ${threshold_low_rr}% in 2017"
lab var lowc_17_ipd "Health facility with IPD admissions reporting below ${threshold_low_rr}% in 2017"
lab define yesno_17 0 "No" 1 "Yes"
lab value lowc_17_anc lowc_17_fp lowc_17_idelv lowc_17_pnc lowc_17_vacc lowc_17_opd lowc_17_diar lowc_17_ipd yesno_17

* flag subdistricts with reporting completeness below the 'low' DQ threshold of 90% (i.e. % of expected health facilities with a reported value) by service type in 2018
gen lowc_18_anc = 0
replace lowc_18_anc = 1 if anc_rr2018 < ${threshold_low_rr}

gen lowc_18_fp = 0
replace lowc_18_fp = 1 if fp_rr2018 < ${threshold_low_rr}

gen lowc_18_idelv = 0
replace lowc_18_idelv = 1 if idelv_rr2018 < ${threshold_low_rr}

gen lowc_18_pnc = 0
replace lowc_18_pnc = 1 if pnc_rr2018 < ${threshold_low_rr}

gen lowc_18_vacc = 0
replace lowc_18_vacc = 1 if vacc_rr2018 < ${threshold_low_rr}

gen lowc_18_opd = 0
replace lowc_18_opd = 1 if opd_rr2018 < ${threshold_low_rr}

gen lowc_18_diar = 0
replace lowc_18_diar = 1 if diar_rr2018 < ${threshold_low_rr}

gen lowc_18_ipd = 0
replace lowc_18_ipd = 1 if ipd_rr2018 < ${threshold_low_rr}

lab var lowc_18_anc "Health facility with ANC reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_fp "Health facility with Family Planning reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_idelv "Health facility with institutional delivery reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_pnc "Health facility with PNC reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_vacc "Health facility with vaccination reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_opd "Health facility with OPD visits reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_diar "Health facility with (all ages) diarrhoea service events reporting below ${threshold_low_rr}% in 2018"
lab var lowc_18_ipd "Health facility with IPD admissions reporting below ${threshold_low_rr}% in 2018"
lab define yesno_18 0 "No" 1 "Yes"
lab value lowc_18_anc lowc_18_fp lowc_18_idelv lowc_18_pnc lowc_18_vacc lowc_18_opd lowc_18_diar lowc_18_ipd yesno_18

* flag subdistricts with reporting completeness below the 'low' DQ threshold of 90% (i.e. % of expected health facilities with a reported value) by service type in 2019
gen lowc_19_anc = 0
replace lowc_19_anc = 1 if anc_rr2019 < ${threshold_low_rr}

gen lowc_19_fp = 0
replace lowc_19_fp = 1 if fp_rr2019 < ${threshold_low_rr}

gen lowc_19_idelv = 0
replace lowc_19_idelv = 1 if idelv_rr2019 < ${threshold_low_rr}

gen lowc_19_pnc = 0
replace lowc_19_pnc = 1 if pnc_rr2019 < ${threshold_low_rr}

gen lowc_19_vacc = 0
replace lowc_19_vacc = 1 if vacc_rr2019 < ${threshold_low_rr}

gen lowc_19_opd = 0
replace lowc_19_opd = 1 if opd_rr2019 < ${threshold_low_rr}

gen lowc_19_diar = 0
replace lowc_19_diar = 1 if diar_rr2019 < ${threshold_low_rr}

gen lowc_19_ipd = 0
replace lowc_19_ipd = 1 if ipd_rr2019 < ${threshold_low_rr}

lab var lowc_19_anc "Health facility with ANC reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_fp "Health facility with Family Planning reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_idelv "Health facility with institutional delivery reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_pnc "Health facility with PNC reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_vacc "Health facility with vaccination reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_opd "Health facility with OPD visits reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_diar "Health facility with (all ages) diarrhoea service events reporting below ${threshold_low_rr}% in 2019"
lab var lowc_19_ipd "Health facility with IPD admissions reporting below ${threshold_low_rr}% in 2019"
lab define yesno_19 0 "No" 1 "Yes"
lab value lowc_19_anc lowc_19_fp lowc_19_idelv lowc_19_pnc lowc_19_vacc lowc_19_opd lowc_19_diar lowc_19_ipd yesno_19

* flag subdistricts with reporting completeness below the 'low' DQ threshold of 90% (i.e. % of expected health facilities with a reported value) by service type in 2020
gen lowc_20_anc = 0
replace lowc_20_anc = 1 if anc_rr2020 < ${threshold_low_rr}

gen lowc_20_fp = 0
replace lowc_20_fp = 1 if fp_rr2020 < ${threshold_low_rr}

gen lowc_20_idelv = 0
replace lowc_20_idelv = 1 if idelv_rr2020 < ${threshold_low_rr}

gen lowc_20_pnc = 0
replace lowc_20_pnc = 1 if pnc_rr2020 < ${threshold_low_rr}

gen lowc_20_vacc = 0
replace lowc_20_vacc = 1 if vacc_rr2020 < ${threshold_low_rr}

gen lowc_20_opd = 0
replace lowc_20_opd = 1 if opd_rr2020 < ${threshold_low_rr}

gen lowc_20_diar = 0
replace lowc_20_diar = 1 if diar_rr2020 < ${threshold_low_rr}

gen lowc_20_ipd = 0
replace lowc_20_ipd = 1 if ipd_rr2020 < ${threshold_low_rr}

lab var lowc_20_anc "Health facility with ANC reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_fp "Health facility with Family Planning reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_idelv "Health facility with institutional delivery reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_pnc "Health facility with PNC reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_vacc "Health facility with vaccination reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_opd "Health facility with OPD visits reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_diar "Health facility with (all ages) diarrhoea service events reporting below ${threshold_low_rr}% in 2020"
lab var lowc_20_ipd "Health facility with IPD admissions reporting below ${threshold_low_rr}% in 2020"
lab define yesno_20 0 "No" 1 "Yes"
lab value lowc_20_anc lowc_20_fp lowc_20_idelv lowc_20_pnc lowc_20_vacc lowc_20_opd lowc_20_diar lowc_20_ipd yesno_20

save "3a_vii_DHIMS2_LOW_completeness_by_hf_year.dta", replace


*-----------------------------------------------------------------------------------------------------------------------
* Part 5: Identify reported outliers by health facility/year ####
*-----------------------------------------------------------------------------------------------------------------------
* import data files
use "3a_v_DHIMS2_template_master_non_adjusted_dataset_hf.dta", clear

foreach var of varlist anc1 anc4 ipt2 {
	clonevar rr_`var' = anc_rr
}

foreach var of varlist idelv csection total_stillbirth stillbirth_f stillbirth_m maternal_deaths {
	clonevar rr_`var' = idelv_rr
}

foreach var of varlist pnc48h {
 	clonevar rr_`var' = pnc_rr
}

foreach var of varlist penta1 penta2 penta3 measles1 bcg {
	clonevar rr_`var' = vacc_rr
}

foreach var of varlist opd_total opd_under5 {
	clonevar rr_`var' = opd_rr
}

foreach var of varlist diar_total diar_under1 diar_under5 {
	clonevar rr_`var' = diar_rr
}

foreach var of varlist ipd_total ipd_under5 under5_deaths {
	clonevar rr_`var' = ipd_rr
}

foreach var of varlist fp_total fp_new fp_revisits {
	clonevar rr_`var' = fp_rr
}

// prepare very low reporting rate (i.e. outlier) adjustment variables
foreach var of varlist anc1 anc4 ipt2 idelv csection pnc48h bcg penta1 penta2 penta3 measles1 diar_total diar_under1 diar_under5 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f ///
	stillbirth_m under5_deaths maternal_deaths {
	gen lowc_`var' = 0 if rr_`var' >= 75 & rr_`var' <= 100
	replace lowc_`var' = 1 if rr_`var' < 75
	replace lowc_`var' = 9 if rr_`var' == .
	lab var lowc_`var' "Health facility with `var' very low monthly reporting rate"
	lab define lowc_`var' 0 ">=75% & <=100%" 1 "<75%" 9 "Missing"
	lab value lowc_`var' lowc_`var'
	
	bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid: egen maxlowc_`var' = max(lowc_`var') 
	replace maxlowc_`var' = 1 if maxlowc_`var' >= 1 
	
	bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid: egen rr_`var'_med = median(rr_`var') if rr_`var' >= 75 
	bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid: egen max_rr_`var'_med = max(rr_`var'_med) 
	replace rr_`var'_med = max_rr_`var'_med if rr_`var'_med == .
	replace rr_`var'_med = round(rr_`var'_med, .1)
	
	gen `var'_ratio_rep_med = round(`var' / `var'_med * 100, .1)
	lab var `var'_ratio_rep_med "Ratio reported `var' by median"
	
	clonevar rr_`var'_raw = rr_`var'
	lab var rr_`var'_raw "Raw reporting rate of `var'"
	
	clonevar rr_`var'_adj = rr_`var'
	replace rr_`var'_adj = round(rr_`var'_med, .1) if inlist(lowc_`var', 1, 9)
	lab var rr_`var'_adj "Adjusted reporting rate of `var'"
}

* save dataset in stata format
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year month
save "3a_v_DHIMS2_template_master_non_adjusted_dataset_hf.dta", replace






*-----------------------------------------------------------------------------------------------------------------------
* Appendix 1: Base script sourced from Countdown ####
*-----------------------------------------------------------------------------------------------------------------------

*********************************************************************************
*********************************************************************************
**			 COUNTDOWN TO 2030 / APHRC / GFF / UNICEF / WHO		
** PRODUCING NATIONAL AND SUBNATIONAL HEALTH STATISTICS USING RHIS DATA
**					CODES - DATA PREPARING (v1)
*********************************************************************************
*********************************************************************************
*
** Set Stata system capacity
*clear all
*set maxvar 20000
*set matsize 10000
*set more off,permanently
*
********************************************************************************************************************
********************************************************************************************************************
*
** DATA PROCESSING & CREATING DQA FILES & VARIABLES
*
********************************************************************************************************************
********************************************************************************************************************
* /*READ ME
*
*This first do.file is used for the overalll data processing to use for data quality assessment (DQA).
*Data will be imported from the Excel template used for compilation of DHIS2 data.
*Data will be transformed, merged into the appropriate format and new variables created
*
*There are a couple of changes to make in order to run these codes.
*See instructions for the changes from line 38 to 51
*
* */
********************************************************************************************************************
********************************************************************************************************************
*
**PARAMETERS TO CHANGE
*
** Change working folder directory as per the folder where dataset to analyze is located in your computer
*cd "C:\AMaiga\Dropbox\Countdown2030\CD-GFF\Workshop\2022-06_Nairobi_RHIS_WS\Analysis\Data"
*
** Rename your Excel DHIS-2 data file in this format
*// DHIS2_dataset_Tanzania    // Replace Tanzania by the name of your country
*
** Declare your country
*global country="Tanzania"    		 // Replace Tanzania by the name of your country
*
** Declare the most recent data year for your country
*global lastyear=2021    			 // Replace 2021 by the most recent year of your country data (e.g., 2020, etc.)
*
** Declare the threshold for low completeness of reporting
*global threshold_low_rr=90			//Threshold of low completeness of reporting by year. Default value 90%. To adjust the threshold as needed (e.g. 90%, 80%, 70%)
*
********************************************************************************************************************
********************************************************************************************************************
*
**PROCESSING "Priority_indicators sheet"
*
*import excel "DHIS2_dataset_${country}", sheet("Service_data_1") firstrow case(lower) clear
**br
*drop if inlist(_n, 1, 2)
*destring _all,replace
*duplicates list district year month
*drop if district=="" & year==. & month==""
*save "_${country}_service_data_1.dta",replace
*
*import excel "DHIS2_dataset_${country}", sheet("Service_data_2") firstrow case(lower) clear
**br
*drop if inlist(_n, 1, 2)
*drop l
*destring _all,replace
*duplicates list district year month
*drop if district=="" & year==. & month==""
*save "_${country}_service_data_2.dta",replace
*
*import excel "DHIS2_dataset_${country}", sheet("Service_data_3") firstrow case(lower) clear
**br
*drop if inlist(_n, 1, 2)
*drop i j
*destring _all,replace
*duplicates list district year month
*drop if district=="" & year==. & month==""
*save "_${country}_service_data_3.dta",replace
*
*use "_${country}_service_data_1.dta",clear
*merge 1:1 district year month using "_${country}_service_data_2.dta"
*list district year month anc1 penta1 _merge if _merge!=3	//*Check discrepancy of key variables for merging
*drop _merge
*merge 1:1 district year month using "_${country}_service_data_3.dta"
*list district year month anc1 stillbirth_total _merge if _merge!=3	//*Check discrepancy of key variables for merging
*drop _merge
**br 
*
**Check district and month spellling. They should be consistent accross spreadsheets
*tab1 district month
*
*foreach var of varlist district month {
*rename `var' _`var'
*encode _`var',gen(`var')
*}
*
**tab1 district month
*recode month (1=4) (2=8) (3=12) (4=2) (5=1) (6=7) (7=6) (8=3) (9=5) (10=11) (11=10) (12=9)  
*lab define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December",replace
*lab value month month
*
*egen _fp_total=rowtotal(fp_new fp_revisits)
*replace fp_total=_fp_total if fp_total==. & _fp_total!=.
*
*egen _stillbirth_total=rowtotal(stillbirth_fresh stillbirth_macerated)
*replace stillbirth_total=_stillbirth_total if stillbirth_total==. & _stillbirth_total!=.
*
*duplicates list district year month
*drop if district==. & year==. & month==.
*drop _*
*
*order district year month
*
*save "_${country}_service_data_all.dta",replace
*
*
*********************************
*
**PROCESSING "Reporting_completeness sheet"
*
*import excel "DHIS2_dataset_${country}", sheet("Reporting_completeness") firstrow case(lower) clear
**br
*drop if inlist(_n, 1, 2)
*destring _all,replace
*
**Check district and month spellling. They should be consistent accross spreadsheets
*tab1 district month
*
*foreach var of varlist district month {
*rename `var' _`var'
*encode _`var',gen(`var')
*}
*tab1 district month
*recode month (1=4) (2=8) (3=12) (4=2) (5=1) (6=7) (7=6) (8=3) (9=5) (10=11) (11=10) (12=9)  
*lab define month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December",replace
*lab value month month
*
*gen _anc_reporting_rate=(anc_reporting_received/anc_reporting_expected)*100
*gen _instdelivey_reporting_rate=(instdelivey_reporting_received/instdelivey_reporting_expected)*100
*gen _pnc_reporting_rate=(pnc_reporting_received/pnc_reporting_expected)*100
*gen _vacc_reporting_rate=(vacc_reporting_received/vacc_reporting_expected)*100
*gen _opd_reporting_rate=(opd_reporting_received/opd_reporting_expected)*100
*gen _ipd_reporting_rate=(ipd_reporting_received/ipd_reporting_expected)*100
*gen _fp_reporting_rate=(fp_reporting_received/fp_reporting_expected)*100
*
*replace anc_reporting_rate=_anc_reporting_rate if anc_reporting_rate==. & _anc_reporting_rate!=.
*replace instdelivey_reporting_rate=_instdelivey_reporting_rate if instdelivey_reporting_rate==. & _instdelivey_reporting_rate!=.
*replace pnc_reporting_rate=_pnc_reporting_rate if pnc_reporting_rate==. & _pnc_reporting_rate!=.
*replace vacc_reporting_rate=_vacc_reporting_rate if vacc_reporting_rate==. & _vacc_reporting_rate!=.
*replace opd_reporting_rate=_opd_reporting_rate if opd_reporting_rate==. & _opd_reporting_rate!=.
*replace ipd_reporting_rate=_ipd_reporting_rate if ipd_reporting_rate==. & _ipd_reporting_rate!=.
*replace fp_reporting_rate=_fp_reporting_rate if fp_reporting_rate==. & _fp_reporting_rate!=.
*
*foreach var of varlist anc_reporting_rate instdelivey_reporting_rate pnc_reporting_rate vacc_reporting_rate opd_reporting_rate ipd_reporting_rate fp_reporting_rate	 {
*replace `var'=round(`var',.1)
*}
*
*duplicates list district year month
*drop if district==. & year==. & month==.
*drop _*
*save "_${country}_completeness.dta",replace
*
*********************************
*
**PROCESSING "Population_data sheet"
*
*import excel "DHIS2_dataset_${country}", sheet("Population_data") firstrow case(lower) clear
**br
*drop if inlist(_n, 1, 2)
*destring _all,replace
*rename district_name district
*
*foreach var of varlist year total_population population_under_5years population_under_1year live_births total_births {
*replace `var'=round(`var',1)
*}
*
*foreach var of varlist district {
*rename `var' _`var'
*encode _`var',gen(`var')
*}
*sort district year total_population
*bysort district: gen _popgrowthrate=ln(total_population[_n]/total_population[_n-1])/(year[_n]-year[_n-1])*100
*bysort district: egen _meanpopgrowthrate=mean(ln(total_population[_n]/total_population[_n-1])/(year[_n]-year[_n-1]))
*replace _meanpopgrowthrate=_meanpopgrowthrate*100
*replace pop_growth_rate=_popgrowthrate if pop_growth_rate==. & _popgrowthrate!=.
*replace pop_growth_rate=_meanpopgrowthrate if pop_growth_rate==. & _meanpopgrowthrate!=.
*replace pop_growth_rate=round(pop_growth_rate,.1)
*duplicates list district year
*drop if district==. & year==.
*drop _*
*order district
*save "_${country}_population_data.dta",replace
*
*********************************
*
**PROCESSING "Admin_data sheet"
*
*import excel "DHIS2_dataset_${country}", sheet("Admin_data") firstrow case(lower) clear
**br
*drop if inlist(_n, 1, 2)
*drop if district_name=="" & first_admin_level=="" & total_number_health_facilities==""
*keep district_name first_admin_level gff_priority year_prioritization country number_hospitals total_number_health_facilities total_core_health_professionals number_hospital_beds urban_rural
*rename district_name district
*
**Check first administartive unit, district and month spellling. They should be consistent accross spreadsheets
*tab1 first_admin_level district
* 
*destring _all,replace
*
*foreach var of varlist district first_admin_level country	{
*rename `var' _`var'
*encode _`var',gen(`var')
*}
*
*rename gff_priority _gff_priority
*gen gff_priority=.
*replace gff_priority=1 if _gff_priority=="GFF priority"
*replace gff_priority=2 if _gff_priority=="Both GFF & other RMNCH program priority"
*replace gff_priority=3 if _gff_priority=="Other RMNCH program priority only"
*replace gff_priority=4 if _gff_priority=="None"
*replace gff_priority=5 if _gff_priority=="Don't know"
*lab define gff_priority 1 "GFF priority" 2 "Both GFF & other RMNCH program priority" 3 "Other RMNCH program priority only" 4 "None" 5 "Don't know"
*lab value gff_priority gff_priority
*lab var gff_priority "GFF priority area"
*
**br district gff_priority urban_rural first_admin_level year_prioritization country number_hospitals total_number_health_facilities total_core_health_professionals number_hospital_beds
*
*foreach var of varlist urban_rural  {
*replace `var'=lower(`var')
*replace `var'="rural" if inlist(`var', "r","ru","rura","rurale")
*replace `var'="urban" if inlist(`var', "u","ur","urb","urba","urbane","urbain","urbaine")
*replace `var'="mixed" if inlist(`var', "m","mi","mix","mixe","mixed","mixt","mixte","mixted")
*}
*replace urban_rural="1" if urban_rural=="rural"
*replace urban_rural="2" if urban_rural=="urban"
*replace urban_rural="3" if urban_rural=="mixed"
*destring urban_rural,replace
*lab define urban_rural 1 "Rural" 2 "Urban" 3 "Mixed",replace
*lab value urban_rural urban_rural
*duplicates list district
**drop if inlist(_n,1)		//In the event of duplicates: replace 1 by the obs number of the duplicate case and activate the code line
*drop if district==.
*drop _*
*order country first_admin_level urban_rural gff_priority year_prioritization district  
*save "_${country}_admin_data.dta",replace
*
*********************************
*
**MERGE OF FILES
*
*use "_${country}_service_data_all.dta",clear
*merge 1:1 district year month using "_${country}_completeness.dta"
*list district year month anc1 anc_reporting_rate _merge if _merge!=3	//*Check discrepancy of key variables for merging
*drop if _merge==2
*drop _merge
*merge m:1 district year using "_${country}_population_data.dta"
*list district year month anc1 total_population _merge if _merge!=3		//*Check discrepancy of key variables for merging
*drop if _merge==2
*drop _merge
*merge m:1 district using "_${country}_admin_data.dta"
*list district year month anc1 first_admin_level _merge if _merge!=3		//*Check discrepancy of key variables for merging
*drop if _merge==2
*drop _merge
*
*order country first_admin_level urban_rural gff_priority year_prioritization
*
**br district year month
*
*decode month,gen(_month)
*egen _period=concat(_month year)
*gen double date = date(_period, "MY")
*format date %td
*gen _monthsubstr=substr(_month,1,3)
*egen datex=concat(_monthsubstr year)
*drop _month _period _monthsubstr
*order date datex,after(month)
*lab var date "Date of data"
*lab var datex "Date of data in string format"
*
*rename (first_admin_level instdelivery anc_reporting_expected anc_reporting_received anc_reporting_rate instdelivey_reporting_expected instdelivey_reporting_received instdelivey_reporting_rate vacc_reporting_expected vacc_reporting_received vacc_reporting_rate opd_reporting_expected opd_reporting_received opd_reporting_rate ipd_reporting_expected ipd_reporting_received ipd_reporting_rate fp_reporting_expected fp_reporting_received fp_reporting_rate pnc_48h pnc_reporting_expected pnc_reporting_received pnc_reporting_rate pop_growth_rate total_population population_under_5years population_under_1year live_births total_births women_15_49_years number_hospitals total_number_health_facilities total_core_health_professionals number_hospital_beds stillbirth_total stillbirth_fresh stillbirth_macerated)	///
*(adminlevel_1 idelv anc_rep_exp anc_rep_rec anc_rr idelv_rep_exp idelv_rep_rec idelv_rr vacc_rep_exp vacc_rep_rec vacc_rr opd_rep_exp opd_rep_rec opd_rr ipd_rep_exp ipd_rep_rec ipd_rr fp_rep_exp fp_rep_rec fp_rr pnc48h pnc_rep_exp pnc_rep_rec pnc_rr pop_rate total_pop under5_pop under1_pop live_births total_births women15_49 total_hospitals total_facilities total_workers total_beds total_stillbirth stillbirth_f stillbirth_m)
*
*gen _anc_rr=round(anc_rep_rec / anc_rep_exp * 100, 1)				
*replace anc_rr=_anc_rr if anc_rr==. & _anc_rr!=.
*gen _idelv_rr=round(idelv_rep_rec / idelv_rep_exp * 100, 1)				
*replace idelv_rr=_idelv_rr if idelv_rr==. & _idelv_rr!=.
*gen _pnc_rr=round(pnc_rep_rec / pnc_rep_exp * 100, 1)				
*replace pnc_rr=_pnc_rr if pnc_rr==. & _pnc_rr!=.
*gen _vacc_rr=round(vacc_rep_rec / vacc_rep_exp * 100, 1)				
*replace vacc_rr=_vacc_rr if vacc_rr==. & _vacc_rr!=.
*gen _opd_rr=round(opd_rep_rec / opd_rep_exp * 100, 1)				
*replace opd_rr=_opd_rr if opd_rr==. & _opd_rr!=.
*gen _ipd_rr=round(ipd_rep_rec / ipd_rep_exp * 100, 1)				
*replace ipd_rr=_ipd_rr if ipd_rr==. & _ipd_rr!=.
*gen _fp_rr=round(fp_rep_rec / fp_rep_exp * 100, 1)				
*replace fp_rr=_fp_rr if fp_rr==. & _fp_rr!=.
*drop _*  
*order country urban_rural adminlevel_1 district year month date datex
*
*save "${country}_master_non_adjusted_dataset.dta",replace
*
**Drop temporary files
*local tmpfile: dir . files "_${country}_*.dta"
*foreach file of local tmpfile {
*erase "`file'"
*}
*
*
********************************************************************************************************************
*
**CREATING DATA FILES FOR COMPLETENESS SERVICE BY YEAR AT NATIONAL LEVEL
*
*use "${country}_master_non_adjusted_dataset.dta",clear		
*
**Keep variables of interest
*keep country urban_rural adminlevel_1 district year month anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr
*
*foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr	{
*preserve
*collapse country (mean) `var', by(year)
*save "_completeness_national`var'.dta",replace		
*restore
*}		 
*use "_completeness_nationalanc_rr",clear
*local reshapednational: dir . files "_completeness_national*.dta"
*foreach file of local reshapednational {
*merge 1:1 year using "`file'"
*drop _merge
*}
*foreach var of varlist anc_rr fp_rr idelv_rr pnc_rr ipd_rr opd_rr vacc_rr  {
*replace `var'=round(`var', 1)
*}
*save "${country}_Completeness_reporting_by_year_national.dta",replace	 
*									
**Drop temporary files					  
*local tmpfile: dir . files "_completeness_national*.dta"
*foreach file of local tmpfile {
*erase "`file'"
*}
*
*************************************
*
**CREATING DATA FILES FOR COMPLETENESS SERVICE BY AREA OF LOCATION (RURAL, URBAN, MIXED) AND BY YEAR
*
*use "${country}_master_non_adjusted_dataset.dta",clear		
*
**Keep variables of interest
*keep country urban_rural adminlevel_1 district year month anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr
*
*foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr	{
*preserve
*collapse country (mean) `var', by(urban_rural year)
*save "_completeness_urban_rural`var'.dta",replace		
*restore
*}		 
*use "_completeness_urban_ruralanc_rr",clear
*local reshapedurban_rural: dir . files "_completeness_urban_rural*.dta"
*foreach file of local reshapedurban_rural {
*merge 1:1 urban_rural year using "`file'"
*drop _merge
*}
*foreach var of varlist anc_rr fp_rr idelv_rr pnc_rr ipd_rr opd_rr vacc_rr  {
*replace `var'=round(`var', 1)
*}
*save "${country}_Completeness_reporting_by_urban_rural_&_year.dta",replace	 
*									
**Drop temporary files					  
*local tmpfile: dir . files "_completeness_urban_rural*.dta"
*foreach file of local tmpfile {
*erase "`file'"
*}
*															
*************************************
*
**CREATING DATA FILES FOR COMPLETENESS SERVICE BY SUB-ADMINISTRATIVE UNIT (e.g. region, province, state, etc.) AND BY YEAR
*
*use "${country}_master_non_adjusted_dataset.dta",clear		
*
**Keep variables of interest
*keep country urban_rural adminlevel_1 district year month anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr
*
*foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr	{
*preserve
*collapse country (mean) `var', by(adminlevel_1 year)
*save "_completeness_adminlevel_1`var'.dta",replace		
*restore
*}		 
*use "_completeness_adminlevel_1anc_rr",clear
*local reshapedadminlevel_1: dir . files "_completeness_adminlevel_1*.dta"
*foreach file of local reshapedadminlevel_1 {
*merge 1:1 adminlevel_1 year using "`file'"
*drop _merge
*}
*foreach var of varlist anc_rr fp_rr idelv_rr pnc_rr ipd_rr opd_rr vacc_rr  {
*replace `var'=round(`var', 1)
*}
*save "${country}_Completeness_reporting_by_adminlevel_1_&_year.dta",replace	 
*									
**Drop temporary files					  
*local tmpfile: dir . files "_completeness_adminlevel_1*.dta"
*foreach file of local tmpfile {
*erase "`file'"
*}
*
*************************************
*
**CREATING DATA FILES FOR COMPLETENESS SERVICE BY DISTRICT AND BY YEAR
*
*use "${country}_master_non_adjusted_dataset.dta",clear		
*
**Keep variables of interest
*keep country urban_rural adminlevel_1 district year month anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr
*
*foreach var of varlist anc_rr idelv_rr pnc_rr vacc_rr opd_rr ipd_rr fp_rr	{
*preserve
*collapse country urban_rural adminlevel_1 (mean) `var', by(district year)
*save "_completeness_district`var'.dta",replace		
*restore
*}		 
*									
*use "_completeness_districtanc_rr",clear
*local reshapeddistrict: dir . files "_completeness_district*.dta"
*foreach file of local reshapeddistrict {
*merge 1:1 district year using "`file'"
*drop _merge
*}		
*foreach var of varlist anc_rr fp_rr idelv_rr pnc_rr ipd_rr opd_rr vacc_rr  {
*replace `var'=round(`var', 1)
*}
*save "${country}_Completeness_reporting_by_district_&_year.dta",replace
* 			
**Drop temporary files					  
*local tmpfile: dir . files "_completeness_district*.dta"
*foreach file of local tmpfile {
*erase "`file'"
*}
*															
*************************************
*
**CREATING DATA FILES FOR LOW REPORTING RATE BY DISTRICT AND BY YEAR
*
**Reshape files
*reshape wide anc_rr fp_rr idelv_rr pnc_rr ipd_rr opd_rr vacc_rr, i(country urban_rural adminlevel_1 district) j(year)
*
** PERCENTAGE OF DISTRICTS BELOW ${threshold_low_rr}% COMPLETENESS in 2017
*gen lowc_17_anc = anc_rr2017 < ${threshold_low_rr}
*gen lowc_17_fp = fp_rr2017 < ${threshold_low_rr}
*gen lowc_17_idelv = idelv_rr2017 < ${threshold_low_rr}
*gen lowc_17_pnc = pnc_rr2017 < ${threshold_low_rr}
*gen lowc_17_vacc = vacc_rr2017 < ${threshold_low_rr}
*gen lowc_17_opd = opd_rr2017 < ${threshold_low_rr}
*gen lowc_17_ipd = ipd_rr2017 < ${threshold_low_rr}
*lab var lowc_17_anc "District with ANC reporting below ${threshold_low_rr}% in 2017"
*lab var lowc_17_fp "District with Family Planning reporting below ${threshold_low_rr}% in 2017"
*lab var lowc_17_idelv "District with institutional delivery reporting below ${threshold_low_rr}% in 2017"
*lab var lowc_17_pnc "District with PNC reporting below ${threshold_low_rr}% in 2017"
*lab var lowc_17_vacc "District with vaccination reporting below ${threshold_low_rr}% in 2017"
*lab var lowc_17_opd "District with OPD visits reporting below ${threshold_low_rr}% in 2017"
*lab var lowc_17_ipd "District with IPD admissions reporting below ${threshold_low_rr}% in 2017"
*lab define yesno 0 "No" 1 "Yes"
*lab value lowc_17_anc lowc_17_fp lowc_17_idelv lowc_17_pnc lowc_17_vacc lowc_17_opd lowc_17_ipd yesno
**summarize lowc_17_*
*
** PERCENTAGE OF DISTRICTS BELOW ${threshold_low_rr}% COMPLETENESS in 2018
*gen lowc_18_anc = anc_rr2018 < ${threshold_low_rr}
*gen lowc_18_fp = fp_rr2018 < ${threshold_low_rr}
*gen lowc_18_idelv = idelv_rr2018 < ${threshold_low_rr}
*gen lowc_18_pnc = pnc_rr2018 < ${threshold_low_rr}
*gen lowc_18_vacc = vacc_rr2018 < ${threshold_low_rr}
*gen lowc_18_opd = opd_rr2018 < ${threshold_low_rr}
*gen lowc_18_ipd = ipd_rr2018 < ${threshold_low_rr}
*lab var lowc_18_anc "District with ANC reporting below ${threshold_low_rr}% in 2018"
*lab var lowc_18_fp "District with Family Planning reporting below ${threshold_low_rr}% in 2018"
*lab var lowc_18_idelv "District with institutional delivery reporting below ${threshold_low_rr}% in 2018"
*lab var lowc_18_pnc "District with PNC reporting below ${threshold_low_rr}% in 2018"
*lab var lowc_18_vacc "District with vaccination reporting below ${threshold_low_rr}% in 2018"
*lab var lowc_18_opd "District with opd visits reporting below ${threshold_low_rr}% in 2018"
*lab var lowc_18_ipd "District with ipd admissions reporting below ${threshold_low_rr}% in 2018"
*lab value lowc_18_anc lowc_18_fp lowc_18_idelv lowc_18_idelv lowc_18_vacc lowc_18_opd lowc_18_ipd yesno
**summarize lowc_18_*
*
** PERCENTAGE OF DISTRICTS BELOW ${threshold_low_rr}% COMPLETENESS in 2019
*gen lowc_19_anc = anc_rr2019 < ${threshold_low_rr}
*gen lowc_19_fp = fp_rr2019 < ${threshold_low_rr}
*gen lowc_19_idelv = idelv_rr2019 < ${threshold_low_rr}
*gen lowc_19_pnc = pnc_rr2019 < ${threshold_low_rr}
*gen lowc_19_vacc = vacc_rr2019 < ${threshold_low_rr}
*gen lowc_19_opd = opd_rr2019 < ${threshold_low_rr}
*gen lowc_19_ipd = ipd_rr2019 < ${threshold_low_rr}
*lab var lowc_19_anc "District with ANC reporting below ${threshold_low_rr}% in 2019"
*lab var lowc_19_fp "District with Family Planning reporting below ${threshold_low_rr}% in 2019"
*lab var lowc_19_idelv "District with institutional delivery reporting below ${threshold_low_rr}% in 2019"
*lab var lowc_19_pnc "District with PNC reporting below ${threshold_low_rr}% in 2019"
*lab var lowc_19_vacc "District with vaccination reporting below ${threshold_low_rr}% in 2019"
*lab var lowc_19_opd "District with opd visits reporting below ${threshold_low_rr}% in 2019"
*lab var lowc_19_ipd "District with ipd admissions reporting below ${threshold_low_rr}% in 2019"
*lab value lowc_19_anc lowc_19_fp lowc_19_idelv lowc_19_pnc lowc_19_vacc lowc_19_opd lowc_19_ipd yesno
**summarize lowc_19_*
*
** PERCENTAGE OF DISTRICTS BELOW ${threshold_low_rr}% COMPLETENESS in 2020
*gen lowc_20_anc = anc_rr2020 < ${threshold_low_rr}
*gen lowc_20_fp = fp_rr2020 < ${threshold_low_rr}
*gen lowc_20_idelv = idelv_rr2020 < ${threshold_low_rr}
*gen lowc_20_pnc = pnc_rr2020 < ${threshold_low_rr}
*gen lowc_20_vacc = vacc_rr2020 < ${threshold_low_rr}
*gen lowc_20_opd = opd_rr2020 < ${threshold_low_rr}
*gen lowc_20_ipd = ipd_rr2020 < ${threshold_low_rr}
*lab var lowc_20_anc "District with ANC reporting below ${threshold_low_rr}% in 2020"
*lab var lowc_20_fp "District with family planning reporting below ${threshold_low_rr}% in 2020"
*lab var lowc_20_idelv "District with institutional delivery reporting below ${threshold_low_rr}% in 2020"
*lab var lowc_20_pnc "District with PNC reporting below ${threshold_low_rr}% in 2020"
*lab var lowc_20_vacc "District with vaccination reporting below ${threshold_low_rr}% in 2020"
*lab var lowc_20_opd "District with opd visits reporting below ${threshold_low_rr}% in 2020"
*lab var lowc_20_ipd "District with ipd admissions reporting below ${threshold_low_rr}% in 2020"
*lab value lowc_20_anc lowc_20_fp lowc_20_idelv lowc_20_pnc lowc_20_vacc lowc_20_opd lowc_20_ipd yesno
**summarize lowc_20_*
*
** PERCENTAGE OF DISTRICTS BELOW ${threshold_low_rr}% COMPLETENESS in 2021
*gen lowc_21_anc = anc_rr2021 < ${threshold_low_rr}
*gen lowc_21_fp = fp_rr2021 < ${threshold_low_rr}
*gen lowc_21_idelv = idelv_rr2021 < ${threshold_low_rr}
*gen lowc_21_pnc = pnc_rr2021 < ${threshold_low_rr}
*gen lowc_21_vacc = vacc_rr2021 < ${threshold_low_rr}
*gen lowc_21_opd = opd_rr2021 < ${threshold_low_rr}
*gen lowc_21_ipd = ipd_rr2021 < ${threshold_low_rr}
*lab var lowc_21_anc "District with ANC reporting below ${threshold_low_rr}% in 2021"
*lab var lowc_21_fp "District with family planning reporting below ${threshold_low_rr}% in 2021"
*lab var lowc_21_idelv "District with institutional delivery reporting below ${threshold_low_rr}% in 2021"
*lab var lowc_21_pnc "District with PNC reporting below ${threshold_low_rr}% in 2021"
*lab var lowc_21_vacc "District with vaccination reporting below ${threshold_low_rr}% in 2021"
*lab var lowc_21_opd "District with opd visits reporting below ${threshold_low_rr}% in 2021"
*lab var lowc_21_ipd "District with ipd admissions reporting below ${threshold_low_rr}% in 2021"
*lab value lowc_21_anc lowc_21_fp lowc_21_idelv lowc_21_pnc lowc_21_vacc lowc_21_opd lowc_21_ipd yesno
**summarize lowc_21_*
*
*save "${country}_Low_reporting_by_district_by_year.dta",replace	 									
*
*foreach var of varlist lowc_*	{
*lab value `var'
*egen mean`var'=mean(`var')
*replace `var'=round(mean`var'*100,.1)
*format `var' %5.1f
*drop mean*
*}	
*
*foreach var of varlist *_rr*	{
*egen mean`var'=mean(`var')
*replace `var'=round(mean`var',.1)
*format `var' %5.1f
*drop mean*
*}	
*
*save "${country}_Low_reporting_by_year.dta",replace	 									
*				  
*
********************************************************************************************************************
*
***CREATING FILES FOR ASSESSMENT OF REPORTING RATES OUTLIERS OVER TIME
*
*use "${country}_master_non_adjusted_dataset.dta",clear		
*
*foreach var of varlist anc1 anc4 ipt2 	{
*clonevar rr_`var'=anc_rr
*}	
*foreach var of varlist 	idelv sba csection total_stillbirth stillbirth_f stillbirth_m maternal_deaths	{
*clonevar rr_`var'=idelv_rr
*}	
*foreach var of varlist 	pnc48h	{
*clonevar rr_`var'=pnc_rr
*}
*foreach var of varlist penta1 penta3 measles1 bcg	{
*clonevar rr_`var'=vacc_rr
*}	
*foreach var of varlist opd_total opd_under5 	{
*clonevar rr_`var'=opd_rr
*}	
*foreach var of varlist 	ipd_total ipd_under5 under5_deaths	{
*clonevar rr_`var'=ipd_rr
*}
*foreach var of varlist fp_total fp_new fp_revisits		{
*clonevar rr_`var'=fp_rr
*}
*
*** Median Absolute Deviation (MAD) method to assess reporting rate outliers
**br district year month date anc1
*foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths   	{
*bysort district: egen `var'_mad=mad(`var') if rr_`var'>=75 & year<${lastyear}		// 75% reporting rate used
*bysort district: egen max_`var'_mad=max(`var'_mad)
*replace `var'_mad=max_`var'_mad if `var'_mad==.
*replace `var'_mad=round(`var'_mad,1)
*bysort district: egen `var'_med=median(`var') if rr_`var'>=75 & year<${lastyear}	// 75% reporting rate used
*bysort district: egen max_`var'_med=max(`var'_med)
*replace `var'_med=max_`var'_med if `var'_med==.
*replace `var'_med=round(`var'_med,1)
*bysort district: gen `var'_outlb5std=round(`var'_med - 1.4826*5*`var'_mad,1) 		/* Using Hampel X84 Method - lower bound 5 std from the median */
*bysort district: gen `var'_outub5std=round(`var'_med + 1.4826*5*`var'_mad,1)		/* Using Hampel X84 Method - uppper bound 5 std from the median */
*}		
*
**br district year month anc1 anc_rr
*foreach var of varlist anc1 anc4 ipt2 idelv sba csection pnc48h bcg penta1 penta3 measles1 opd_total opd_under5 ipd_total ipd_under5 fp_total fp_new fp_revisits total_stillbirth stillbirth_f stillbirth_m under5_deaths maternal_deaths		{
*gen lowc_`var'=0 if rr_`var'>=75 & rr_`var'<=100
*replace lowc_`var'=1 if rr_`var'<75
*replace lowc_`var'=9 if rr_`var'==. 
*lab var lowc_`var' "District with `var' very low monthly reporting rate"
*lab define 	lowc_`var' 0 ">=75% & <=100%" 1 "<75%" 9 "Missing"
*lab value lowc_`var' lowc_`var'
*bysort district: egen maxlowc_`var'=max(lowc_`var')
*replace maxlowc_`var'=1 if maxlowc_`var'>=1
*bysort district: egen rr_`var'_med=median(rr_`var') if rr_`var'>=75
*bysort district: egen max_rr_`var'_med=max(rr_`var'_med)
*replace rr_`var'_med=max_rr_`var'_med if rr_`var'_med==.
*replace rr_`var'_med=round(rr_`var'_med,.1)
*gen `var'_ratio_rep_med=round(`var'/`var'_med*100,.1)
*lab var `var'_ratio_rep_med "Ratio reported `var' by median"
*clonevar rr_`var'_raw=rr_`var'
*lab var rr_`var'_raw "Raw reporting rate of `var'"
*clonevar rr_`var'_adj=rr_`var'
*replace rr_`var'_adj=round(rr_`var'_med,.1) if inlist(lowc_`var',1,9)
*lab var rr_`var'_adj "Adjusted reporting rate of `var'"
*}	
*
*sort district year month
*save "${country}_master_non_adjusted_dataset.dta",replace						  
*
*
***************************************************************************************************************************************************************************
**END OF "1_Code_RHIS_Data_Preparation.do"
**NEXT: RUN "2_Code_RHIS_DQA_Completeness.do"
***************************************************************************************************************************************************************************					  
