
* ======================================================================================================================
*   
*   Filename:		3e_Produce_denominators_HF.do
*   Author:			M Johnson
*   Creation Date:	12/10/2024
*
* 	Purpose:		To produce final denominators and intervention coverage estimates for selected target health
*					indicators (Penta2, Penta3, Measles1, diarrhoea service events amongst u1s)
*
*   Details:		Part 0: Set global variables
* 					Part 1: Estimate coverage of Penta2 and Penta3 vaccinations based on denominators estimated from 
* 						DHIMS2 Penta1 actvity
* 					Part 2: Estimate coverage of measles1 vaccination based on denominators estimated from DHIMS2 
*						Penta1 actvity
* 					Part 3: Estimate coverage/utilisation of diarrhoea service based on denominator estimated from 
* 						DHIMS2 Penta1 actvity
* 					Appendix 1: Base script (1) sourced from Countdown (4a_Code_RHIS_DenominatorAssessment-FINAL.do)
* 					Appendix 2: Base script (2) sourced from Countdown (4b_Code_RHIS_DenominatorAssessment-FINAL.do)
*
* ======================================================================================================================


*-----------------------------------------------------------------------------------------------------------------------
* Part 0: Set global variables ####
*-----------------------------------------------------------------------------------------------------------------------
* change current working directory
cd " ... "

global firstyear = 2017    			 // Replace by the oldest year of your country data (e.g., 2018, etc.)

global lastyear = 2020    			 // Replace by the most recent year of your country data (e.g., 2020, etc.)

* change Maina parameters (country values to be obtained from contemporaneous household survey, in this case the 2017/18 MICS)
global nmr = 0.027  // national neonatal mortality rate
global pnmr = 0.014 // national post-neonatal mortality rate

global anc1_survey = 0.942 // ANC1 coverage

global penta1_survey = 0.952 // penta1 coverage (crude coverage amongst children aged 12-23 months)


*-----------------------------------------------------------------------------------------------------------------------
* Part 1: Estimate coverage of Penta2 and Penta3 vaccinations based on denominators estimated from DHIMS2 Penta1 
* actvity ####
*-----------------------------------------------------------------------------------------------------------------------
* import DHIMS2 dataset
use "3c_iii_DHIMS2_master_adjusted_dataset.dta", clear

// compute penta1 utilisation by year
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year
bysort year: egen tot_penta1 = total(penta1) // annual total utilisation of service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_penta1 = total(penta1) // subdistrict total utilisation of service by year

// compute number eligible for penta1 by year (denominator derived from DHIMS2 Penta1)
gen inftpenta1 = penta1 / ${penta1_survey} // uplift DHIMS2 Penta1 utilisation for rate of service non-utilisation as derived from household survey data
bysort year: egen tot_inftpenta1 = total(inftpenta1) // annual total eligible for Penta1 service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_inftpenta1 = total(inftpenta1) // health facility total eligible for Penta1 service by year

// compute coverage of Penta1 based on DHIMS2 Penta1 denominator
gen tot_cov_penta1 = 100 * tot_penta1 / tot_inftpenta1 // denominator for Penta1 is Penta1 (here derived from DHIMS2 Penta1)
lab var tot_cov_penta1 "Coverage of Penta1 based on DHIMS2 Penta1 denominator (overall)"

gen hf_cov_penta1 = 100 * hf_penta1 / hf_inftpenta1 // denominator for Penta1 is Penta1 (here derived from DHIMS2 Penta1)
lab var hf_cov_penta1 "Coverage of Penta1 based on DHIMS2 Penta1 denominator (health facility)"

// compute penta2 utilisation by year
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year
bysort year: egen tot_penta2 = total(penta2) // annual total utilisation of Penta2 service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_penta2 = total(penta2) // health facility total utilisation of Penta2 service by year

// compute coverage of Penta2 based on DHIMS2 Penta1 denominator
gen tot_cov_penta2 = 100 * tot_penta2 / tot_inftpenta1 // denominator for Penta2 is Penta1 (here derived from DHIMS2 Penta1)
lab var tot_cov_penta2 "Coverage of Penta2 based on DHIMS2 Penta1 denominator (overall)"

gen hf_cov_penta2 = 100 * hf_penta2 / hf_inftpenta1 // denominator for Penta2 is Penta1 (here derived from DHIMS2 Penta1)
lab var hf_cov_penta2 "Coverage of Penta2 based on DHIMS2 Penta1 denominator (health facility)"

// compute penta3 utilisation by year
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year
bysort year: egen tot_penta3 = total(penta3) // annual total utilisation of Penta3 service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_penta3 = total(penta3) // health facility total utilisation of Penta3 service by year

// compute coverage of Penta3 based on DHIMS2 Penta1 denominator
gen tot_cov_penta3 = 100 * tot_penta3 / tot_inftpenta1 // denominator for Penta3 is Penta1 (here derived from DHIMS2 Penta1)
lab var tot_cov_penta3 "Coverage of Penta3 based on DHIMS2 Penta1 denominator"

gen hf_cov_penta3 = 100 * hf_penta3 / hf_inftpenta1 // denominator for Penta3 is Penta1 (here derived from DHIMS2 Penta1)
lab var hf_cov_penta3 "Coverage of Penta3 based on DHIMS2 Penta1 denominator (health facility)"


*-----------------------------------------------------------------------------------------------------------------------
* Part 2: Estimate coverage of measles1 vaccination based on denominators estimated from DHIMS2 Penta1 actvity ####
*-----------------------------------------------------------------------------------------------------------------------
// compute measles1 utilisation by year
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year
bysort year: egen tot_measles1 = total(measles1) // annual total utilisation of service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_measles1 = total(measles1) // health facility total utilisation of service by year

// compute number eligible for measles1 by year (denominator derived from DHIMS2 Penta1)
gen inftmeasle = inftpenta1 * (1 - ${pnmr}) // measles1 vaccination given ~8 months after Penta1 in Ghana, so adjust for rate of post-neonatal mortality (i.e. aged 1 month to 12 months) from survey data for eligibility
bysort year: egen tot_inftmeasle = total(inftmeasle) // annual total eligible for service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_inftmeasle = total(inftmeasle) // health facility total eligible for service by year

// compute coverage of measles1 based on DHIMS2 Penta1 denominator
gen tot_cov_measles1 = 100 * tot_measles1 / tot_inftmeasle
lab var tot_cov_measles1 "Coverage of measles1 based on DHIMS2 Penta1 denominator"

gen hf_cov_measles1 = 100 * hf_measles1 / hf_inftmeasle // denominator for measles1 is measles1 (here derived from DHIMS2 Penta1)
lab var hf_cov_measles1 "Coverage of measles1 based on DHIMS2 Penta1 denominator (health facility)"


*-----------------------------------------------------------------------------------------------------------------------
* Part 3: Estimate coverage/utilisation of diarrhoea service based on denominator estimated from DHIMS2 Penta1 
* actvity ####
*-----------------------------------------------------------------------------------------------------------------------
// compute diarrhoea service events (under 1s) by year
sort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year
bysort year: egen tot_diar_under1 = total(diar_under1) // annual total utilisation of service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_diar_under1 = total(diar_under1) // health facility total utilisation of service by year

// convert number of diarrhoea service events into number of service users
gen tot_diar_under1_users = tot_diar_under1 / 1.82
gen hf_diar_under1_users = hf_diar_under1 / 1.82

// compute number eligible for diarrhoea service (under 1s) by year (denominator derived from DHIMS2 Penta1)
gen inftdiar = inftpenta1 * (1 - ${pnmr}) // utilisation of service within the 12 months after birth, so adjust downwards for rate of post-neonatal mortality (i.e. aged 1 month to 12 months) from survey data for eligibility
bysort year: egen tot_inftdiar = total(inftdiar) // annual total eligible for service
bysort orgunitlevel3 subdistrict_group organisationunitname organisationunitid year: egen hf_inftdiar = total(inftdiar) // health facility total eligible for service by year

// compute coverage of diarrhoea service (under 1s) based on DHIMS2 Penta1 denominator
gen tot_cov_diar_u1 = 100 * tot_diar_under1_users / tot_inftdiar
lab var tot_cov_diar_u1 "Coverage of diarrhoea service (under 1s) based on DHIMS2 Penta1 denominator"

gen hf_cov_diar_u1 = 100 * hf_diar_under1_users / hf_inftdiar // denominator for diarrhoea is diarrhoea (here derived from DHIMS2 Penta1)
lab var hf_cov_diar_u1 "Coverage of diarrhoea service (under 1s) based on DHIMS2 Penta1 denominator (health facility)"

save "3e_v_DHIMS2_master_adjusted_dataset_cov_estimates.dta", replace






*-----------------------------------------------------------------------------------------------------------------------
* Appendix 1: Base script (1) sourced from Countdown (4a_Code_RHIS_DenominatorAssessment-FINAL.do) ####
*-----------------------------------------------------------------------------------------------------------------------
***** COUNTRY ASSESSMENT OF DENOMINATORS IN DHIS-2
*
** PULL UP COUNTRY POPULATION DATA FROM THE TEMPLATE
** EXAMPLE USE WITH NIGER DATASET
*
** Change Working directory
/* CHANGE TO YOUR WORKING DIRECTORY */
*cd "C:\Users\Agbessi\Dropbox\IIP\COUNTDOWN2030\HealthFAcilityDataAnalysis\Workshop-June2022\Analysis\NIGER"
*
** Declare your country
*global country="Niger"
*
*
*use "${country}_master_adjusted_dataset", clear
*keep country district adminlevel_1 year total_pop under5_pop under1_pop pop_rate live_births women15_49 total_births
*rename total_pop pop_dhis2
*rename under5_pop under5_dhis2
*rename under1_pop under1_dhis2
*rename live_births livebirths_dhis2
*rename total_births allbirths_dhis2
*rename women15_49 wom15_49_dhis2
*
*bysort adminlevel_1 district year: gen firstrow=1 if _n==1
*keep if firstrow==1 
*sort country year
* 
*save popdata_${country}, replace 
*
* Merge with UN estiamtes (Note: Please change the working director to where the file "UN_Estimates_Workshop" is located)
* NOTE: UN estimates are included in a separate file named "UN_Estimates_Workshop" that should have been given to you; make sure you specify the file directory
*
*use "C:\Users\Agbessi\Dropbox\IIP\COUNTDOWN2030\HealthFAcilityDataAnalysis\Workshop-June2022\Analysis\UN_Estimates_Workshop", clear
*keep if country=="${country}"
*foreach var of varlist population under1y under5y wom15_49 cdr births cbr popgrowth {
*    rename `var' un_`var'
*	}
*
*encode country, gen(country1)
*drop country
*rename country1 country 
*sort country year
*merge 1:m country year using Popdata_${country}
*drop _m
*order country adminlevel_1 district year 
*sort country adminlevel_1 district year
*save Denominators_Analysis_${country}, replace 
*
** Compute total populations from DHIS-2 data
*
*foreach var of varlist pop_dhis2 under5_dhis2 under1_dhis2 livebirths_dhis2 allbirths_dhis2 wom15_49_dhis2 {
*    bysort year: egen tot`var'=total(`var')
*	replace tot`var'=tot`var'/1000
*}
*
** Compute demographic indicators from un estimates
*gen un_percent_under5=100*un_under5y/un_population
*gen un_percent_under1=100*un_under1y/un_population
*gen un_percent_wom15_49=100*un_wom15_49/un_population
*
** Compute demographic indicators from DHIS-2
*gen totpercent_under5=100*totunder5_dhis2 /totpop_dhis2
*gen totpercent_under1=100*totunder1_dhis2/totpop_dhis2
*gen totpercent_wom15_49=100*totwom15_49_dhis2/totpop_dhis2
*gen totcbr_dhis2=1000*totlivebirths_dhis2/totpop_dhis2
*gen totsbr_dhis2=1000*(totallbirths_dhis2-totlivebirths_dhis2)/totallbirths_dhis2
*
*bysort year: gen national=1 if _n==1
*sort national year
*bysort national: gen totpopgrowth=100*ln(totpop_dhis2/totpop_dhis2[_n-1])
*replace totpopgrowth=. if national==.
*
*gen totcdr_dhis2=totcbr_dhis2-10*totpopgrowth
*
** Generate ratios
*
*gen ratio_totpop = 100*totpop_dhis2/un_population if national==1
*gen ratio_totunder5=100*totunder5_dhis2/un_under5y if national==1
*gen ratio_totunder1=100*totunder1_dhis2/un_under1y if national==1
*gen ratio_totlivebirths=100*totlivebirths_dhis2/un_births if national==1
*gen ratio_totwom15_49=100*totwom15_49_dhis2/un_wom15_49 if national==1
*gen ratio_totpopgrowth=100*totpopgrowth/un_popgrowth if national==1
*
* Generate tables 
*capture log close
*log using denominators_tables_${country}.log, replace 
*sort national 
*list country year totpop_dhis2 totunder1_dhis2 totunder5_dhis2 totlivebirths_dhis2 totallbirths_dhis2 totwom15_49_dhis2 if national==1,  table noobs
*
*list country year totpopgrowth totpercent_under1 totpercent_under5 totpercent_wom15_49 totcbr_dhis2 totcdr_dhis2 totsbr_dhis2 if national==1,  table noobs
*
*list country year ratio_totpop ratio_totunder1 ratio_totunder5 ratio_totlivebirths ratio_totwom15_49 ratio_totpopgrowth if national==1,  table noobs
*log off
*
** Generate Excel file with the output: Look for file named denominators_tables_${country}.xls
*save tmp0, replace 
*keep if national==1
*collapse (max) totpop_dhis2 totunder1_dhis2 totunder5_dhis2 totlivebirths_dhis2 totallbirths_dhis2 totwom15_49_dhis2 totpopgrowth totpercent_under1 totpercent_under5 totpercent_wom15_49 totcbr_dhis2 totcdr_dhis2 totsbr_dhis2 ratio_totpop ratio_totunder1 ratio_totunder5 ratio_totlivebirths ratio_totwom15_49 ratio_totpopgrowth, by(country year)
*
*order country year
*export excel using "denominators_tables_${country}.xls", firstrow(variables) replace 
*
** Graphs
*use tmp0, clear 
*lab var un_population "Total Pop. - UN Estimate"
*lab var totpop_dhis2 "Total Pop. - DHIS-2"
*lab var year "Year"
*
** Note: You may need to adjust the ylab scale to fit your country
*
*twoway connected totpop_dhis2 un_population year if national==1, ylab(0 (5000) 30000, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("Population, in thousands", size(small)) title("Projected Total Population") saving("totpop_${country}", replace)
*
*lab var totunder1_dhis2 "Pop. Under 1 yr - DHIS-2"
*lab var un_under1y "Pop. Under 1 yr - UN Estimate"
*
*twoway connected totunder1_dhis2 un_under1y year if national==1, ylab(0 (200) 1200, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("Under one, in thousands") title("Projected Population Under One Year") saving("totunder1_${country}", replace)
*
*lab var totunder5_dhis2 "Pop. Under 5 - DHIS-2"
*lab var un_under5y "Pop. Under-5 - UN Estimate"
*twoway connected totunder5_dhis2 un_under5y year if national==1, ylab(0 (1000) 8000, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("Under five, in thousands") title("Projected Population Under 5 Year") saving("totunder5_${country}", replace)
*
*lab var totlivebirths_dhis2 "Live births - DHIS-2"
*lab var un_births "Live births - UN Estimate"
*
*twoway connected totlivebirths_dhis2 un_births year if national==1, ylab(0 (200) 1200, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("Live births, in thousands") title("Projected Live Births") saving("totlivebirths_Niger", replace)
*
*lab var totwom15_49_dhis2 "Women 15-49 - DHIS-2"
*lab var un_wom15_49 "Women 15-49 - UN Estimate"
*
*twoway connected totwom15_49_dhis2 un_wom15_49 year if national==1, ylab(0 (1000) 6000, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("Women 15-49, in thousands") title("Women 15-49 Years") saving("totwom15_49_${country}", replace)
*
*graph combine "totpop_${country}" "totunder1_${country}" "totunder5_${country}" "totlivebirths_${country}" "totwom15_49_${country}", rows(3) altshrink title("${country} - Denominator Assessment") saving("Denominator_Asst_${country}", replace)
*
*lab var ratio_totpop "Total Pop."
*lab var ratio_totunder1 "Under 1 Pop."
*lab var ratio_totunder5 "Under 5 Pop"
*lab var ratio_totlivebirths "Live Births"
*lab var ratio_totwom15_49 "Women 15-49"
*lab var ratio_totpopgrowth "Pop Growth"
*
*twoway connected ratio_totpop ratio_totunder1 ratio_totunder5 ratio_totlivebirths ratio_totwom15_49 ratio_totpopgrowth year if national==1, ylab(0 (50) 200, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("Ratio (%)") title("Ratio DHIS-2 to UN Estimates - ${country}", size(medium)) saving("ratios_${country}", replace) mcolor(blue gray orange green purple magenta) lcolor(blue gray orange green purple magenta)
*
*save tmp1, replace
******************************************************************************************
*** BY ADMIN-1 LEVEL 
*
*foreach var of varlist pop_dhis2 under5_dhis2 under1_dhis2 livebirths_dhis2 allbirths_dhis2 wom15_49_dhis2 {
*    bysort adminlevel_1 year: egen reg`var'=total(`var')
*	replace reg`var'=reg`var'/1000
*}
*
** Compute demographic indicators from DHIS-2
*gen regpercent_under5=100*regunder5_dhis2 /regpop_dhis2
*gen regpercent_under1=100*regunder1_dhis2/regpop_dhis2
*gen regpercent_wom15_49=100*regwom15_49_dhis2/regpop_dhis2
*gen regcbr_dhis2=1000*reglivebirths_dhis2/regpop_dhis2
*gen regsbr_dhis2=1000*(regallbirths_dhis2-reglivebirths_dhis2)/regallbirths_dhis2
*
*sort adminlevel_1 year
*bysort adminlevel_1 year: gen reg_index=1 if _n==1
*
*sort adminlevel_1 reg_index year 
*bysort adminlevel_1 reg_index: gen regpopgrowth=100*ln(regpop_dhis2/regpop_dhis2[_n-1])
*replace regpopgrowth=. if reg_index==.
*
*gen regcdr_dhis2=regcbr_dhis2-10*regpopgrowth
*
** Generate ratios
*
*gen ratio_reg_percent_under5=100*regpercent_under5/un_percent_under5
*gen ratio_reg_percent_under1=100*regpercent_under1/un_percent_under1
*gen ratio_reg_percent_wom15_49=100*regpercent_wom15_49/un_percent_wom15_49
*gen ratio_reg_percent_popgrowth=100*regpopgrowth/un_popgrowth 
*gen ratio_reg_percent_cbr=100*regcbr_dhis2/un_cbr 
*gen ratio_reg_percent_cdr=100*regcdr_dhis2/un_cdr 
*
*
*log on
*
*bysort adminlevel_1: list adminlevel_1 year regpop_dhis2 regunder1_dhis2 regunder5_dhis2 reglivebirths_dhis2 regallbirths_dhis2 regwom15_49_dhis2 if reg_index==1,  table noobs
*
*bysort adminlevel_1: list adminlevel_1  year regpopgrowth regpercent_under1 regpercent_under5 regpercent_wom15_49 regcbr_dhis2 regcdr_dhis2 regsbr_dhis2 if reg_index==1,  table noobs
*
*bysort adminlevel_1: list adminlevel_1 year ratio_reg_percent_popgrowth ratio_reg_percent_under1 ratio_reg_percent_under5 ratio_reg_percent_wom15_49 ratio_reg_percent_cbr ratio_reg_percent_cdr if reg_index==1,  table noobs
*
*log off 
*
** Create an Excel file with the outputs 
*save tmp2, replace 
*
*keep if reg_index==1
*collapse (max) regpop_dhis2 regunder1_dhis2 regunder5_dhis2 reglivebirths_dhis2 regallbirths_dhis2 regwom15_49_dhis2 regpopgrowth regpercent_under1 regpercent_under5 regpercent_wom15_49 regcbr_dhis2 regcdr_dhis2 regsbr_dhis2 ratio_reg_percent_popgrowth ratio_reg_percent_under1 ratio_reg_percent_under5 ratio_reg_percent_wom15_49 ratio_reg_percent_cbr ratio_reg_percent_cdr , by(country adminlevel_1 year)
*order country adminlevel_1 year
*
*export excel using "denominators_tables_${country}_admin1.xls", firstrow(variables) replace
*
*use tmp2, clear 
*
*lab var ratio_reg_percent_popgrowth "%Pop growth"
*lab var ratio_reg_percent_under1 "% Pop. under-1"
*lab var ratio_reg_percent_under5 "% Pop. under-5"
*lab var ratio_reg_percent_wom15_49 "% Women 15-49"
*
*twoway connected ratio_reg_percent_popgrowth ratio_reg_percent_under1 ratio_reg_percent_under5 ratio_reg_percent_wom15_49 year if reg_index==1, by(adminlevel_1, title("Ratio DHIS-2 to UN estimate", size(small))) ylab(0 (50) 200, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("Ratio (%)") saving("ratios_admin1_${country}", replace) mcolor(blue gray orange green purple magenta) lcolor(blue gray orange green purple magenta) 
*
*save denominators_data_assessment_${country}, replace 
*
*************************************************************************************************************
*** COMPUTE COVERAGE BASED ON PROJECTED LIVES BIRTHS
**** FOR THIS EXERCISE WE WILL COMPUTE COVERGAE OF ANC-1; DPT-1; AND BCG
*
** CALL THE ADJUSTED DATA 
*use "${country}_master_adjusted_dataset", clear
*
** SET YOUR PARAMETERS
*global pregloss=0.03 /* Pregnancy loss */
*global sbr=0.02 /* Stillbirth rate */
*global twin=0.035 /* Twin rate -- Obtain from DHS for NIGER */
*global nmr=0.024  /* neonatal mortality rate */
*
** Graph trend line of ANC-1, DPT-1, BCG and projected live births from DHIS-2
** Lives births 
*bysort district year: gen lb=live_births if _n==1
*bysort year: egen totlb_national=total(lb)
*bysort adminlevel_1 year: egen totlb_admin1=total(lb)
*
** ANC-1
*bysort year: egen totanc1_national=total(anc1)
*bysort adminlevel_1 year: egen totanc1_admin1=total(anc1)
*
** DPT-1
*bysort year: egen totpenta1_national=total(penta1)
*bysort adminlevel_1 year: egen totpenta1_admin1=total(penta1)
*
** BCG
*bysort year: egen totbcg_national=total(bcg)
*bysort adminlevel_1 year: egen totbcg_admin1=total(bcg)
*
** Compute estimated number of pregnancies
*gen totpreg_national=totlb_national/((1+${twin})*(1-${sbr})*(1-${pregloss}))
*gen totpreg_admin1=totlb_admin1/((1+${twin})*(1-${sbr})*(1-${pregloss}))
*
** Compute estimated number of infant eligible for penta1
*gen totinft_national=totlb_national-totlb_national*${nmr}
*gen totinft_admin1=totlb_admin1-totlb_admin1*${nmr}
*
*bysort year: gen national_index=1 if _n==1
*bysort adminlevel_1  year: gen admin1_index=1 if _n==1
*
** Compute coverage of ANC-1, penta1, and BCG based on projected lives births 
*gen cov_anc1_plb=100*totanc1_national/totpreg_national
*gen cov_penta1_plb=100*totpenta1_national/totinft_national
*gen cov_bcg_plb=100*totbcg_national/totlb_national
*
*gen cov_anc1_admin1_plb=100*totanc1_admin1/totpreg_admin1
*gen cov_penta1_admin1_plb=100*totpenta1_admin1/totinft_admin1
*gen cov_bcg_admin1_plb=100*totbcg_admin1/totlb_admin1
*
** Graph trends
*lab var totlb_national "Projected live births"
*lab var totanc1_national "Total ANC-1"
*lab var totpenta1_national "Total Penta-1"
*lab var totbcg_national "Total BCG"
*
*replace totlb_national=totlb_national/1000
*replace totanc1_national=totanc1_national/1000
*replace totpenta1_national=totpenta1_national/1000
*replace totbcg_national=totbcg_national/1000
*
*****National 
*twoway connected totlb_national totanc1_national totpenta1_national totbcg_national year if national_index==1, ylab(0 (200) 1200, labsize(tiny)) xlabel(,labsize(small)) scheme(s1color) ytitle("Number (in 1000s)", size(small)) title("Trends in Projected Live births, ANC-1, DPT-1, and BCG, NATIONAL", size(small)) saving("trends_utilization_${country}", replace) sort
*
*lab var cov_anc1_plb "Coverage ANC-1"
*lab var cov_penta1_plb "Coverage of Penta-1"
*lab var cov_bcg_plb "Coverage of BCG"
*
*twoway connected cov_anc1_plb cov_penta1_plb cov_bcg_plb year if national_index==1, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage of ANC-1, DPT-1, and BCG, DHIS-2 data, NATIONAL, Based on projected births", size(small)) saving("trends_coverage_plb_${country}", replace) sort
*
****************************************************************
***** By Admin-1
*lab var totlb_admin1 "Projected live births"
*lab var totanc1_admin1 "Total ANC-1"
*lab var totpenta1_admin1 "Total Penta-1"
*lab var totbcg_admin1 "Total BCG"
*
*replace totlb_admin1=totlb_admin1/1000
*replace totanc1_admin1=totanc1_admin1/1000
*replace totpenta1_admin1=totpenta1_admin1/1000
*replace totbcg_admin1=totbcg_admin1/1000
*
*twoway connected totlb_admin1 totanc1_admin1 totpenta1_admin1 totbcg_admin1 year if admin1_index==1, by(adminlevel_1, title("Trends in projected live births and service utilization", size(small))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("Number (in 1000s)",size(small)) saving("trends_utilization_admin1_${country}", replace) legend(size(vsmall))
*
*lab var cov_anc1_admin1_plb "Coverage ANC-1"
*lab var cov_penta1_admin1_plb "Coverage of Penta-1"
*lab var cov_bcg_admin1_plb "Coverage of BCG"
*
*twoway connected cov_anc1_admin1_plb cov_penta1_admin1_plb cov_bcg_admin1_plb year if admin1_index==1, by(adminlevel_1, title("Coverage trends based on projected population", size(small))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_plb_admin1_${country}", replace) legend(size(vsmall))
*
*
** OUPTUT RESULTS INTO A LOG FILE
*log on
**************************************************************
**************************************************************
*sort national_index
*
**replace totpreg_national=totpreg_national/1000
**replace totinft_national=totinft_national/1000
*
*list country year totlb_national  totanc1_national totpenta1_national totbcg_national totpreg_national totinft_national cov_anc1_plb cov_penta1_plb cov_bcg_plb if national_index==1,  table noobs
*
*bysort adminlevel_1: list adminlevel_1 year totlb_admin1 totanc1_admin1 totpenta1_admin1 totbcg_admin1 totpreg_admin1 totinft_admin1 cov_anc1_admin1_plb cov_penta1_admin1_plb cov_bcg_admin1_plb if admin1_index==1,  table noobs
*
************************************************************
** Save results to Excel file 
*save tmp3, replace
*
** National coverage estiamte 
*keep if national_index
*collapse (max) totlb_national  totanc1_national totpenta1_national totbcg_national totpreg_national totinft_national cov_anc1_plb cov_penta1_plb cov_bcg_plb, by(country year)
*
*rename (totlb_national  totanc1_national totpenta1_national totbcg_national totpreg_national totinft_national cov_anc1_plb cov_penta1_plb cov_bcg_plb) (totlb  totanc1 totpenta1 totbcg totpreg totinft cov_anc1 cov_penta1 cov_bcg)
*gen area=0
*order country year 
*save ${country}_coverage_plb, replace 
*
*use tmp3, clear
*keep if admin1_index
*collapse (max) totlb_admin1 totanc1_admin1 totpenta1_admin1 totbcg_admin1 totpreg_admin1 totinft_admin1 cov_anc1_admin1_plb cov_penta1_admin1_plb cov_bcg_admin1_plb, by(country adminlevel_1 year)
*rename (totlb_admin1 totanc1_admin1 totpenta1_admin1 totbcg_admin1 totpreg_admin1 totinft_admin1 cov_anc1_admin1_plb cov_penta1_admin1_plb cov_bcg_admin1_plb) (totlb  totanc1 totpenta1 totbcg totpreg totinft cov_anc1 cov_penta1 cov_bcg)
*gen area=adminlevel_1
*lab val area first_admin_level
*order country area year 
*save ${country}_coverage_plb_admin1, replace
*
*append using ${country}_coverage_plb
*lab def first_admin_level 0"National", add
*lab val area first_admin_level
*lab val adminlevel_1 first_admin_level
*replace adminlevel_1=0 if adminlevel_1==.
*
*sort country area year
*save ${country}_coverage_plb_national_admin1, replace 
*
*export excel using "${country}_coverage_plb_national_admin1.xls", firstrow(variables) replace
*
************************************************************************************
** Check the following Excel files for the outputs of your work 
** "denominators_tables_${country}.xls"
** "denominators_tables_${country}_admin1.xls"
** "${country}_coverage_plb_national_admin1.xls
************************************************************************************
/*
*erase tmp0.dta
*erase tmp1.dta
*erase tmp2.dta 
*erase tmp3.dta
*/
*
*
** TO USE EXCEL FILE VERSION, YOU MUST RUN THIS PORTION
*use "${country}_master_adjusted_dataset", clear
*order country adminlevel_1 district urban_rural year month date anc1 anc4 ipt2 idelv sba bcg penta1 penta3 measles1 live_births total_births women15_49 total_pop under5_pop under1_pop
*
*keep country adminlevel_1 district urban_rural year month date anc1 anc4 ipt2 idelv sba bcg penta1 penta3 measles1 live_births total_births women15_49 total_pop under5_pop under1_pop
*
*export excel using "Adjusted data-Niger (Exported)", firstrow(variables)






*-----------------------------------------------------------------------------------------------------------------------
* Appendix 2: Base script (2) sourced from Countdown (4b_Code_RHIS_DenominatorAssessment-FINAL.do) ####
*-----------------------------------------------------------------------------------------------------------------------
***** HEALTH FACILITY DATA DERIVED DENOMINATORS 
*
** EXAMPLE USES NIGER DATASET
*
** Change Working directory
/* CHANGE TO YOUR WORKING DIRECTORY */
*cd "C:\Users\Agbessi\Dropbox\IIP\COUNTDOWN2030\HealthFAcilityDataAnalysis\Workshop-June2022\Analysis\NIGER"
*
** Declare your country
*global country="Niger"
*
** SET YOUR PARAMETERS
*global pregloss=0.03 /* Pregnancy loss - default value 0.03 */
*global sbr=0.02 /* Stillbirth rate: Default value 0.02 */
*global twin=0.035 /* Twin rate -- Obtain from DHS for NIGER; Default value: 0.015 */
*global nmr=0.024  /* neonatal mortality rate; Default value=0.03 */
*global pnmr=0.0216 /* Post neonatal mortality rate; Default value 0.02 */
*
***** USING ANC-1 DERIVED DENOMINATORS ****************************
*******************************************************************
** INPUT VALUE OF ANC-1 FROM SURVEY
*global anc1_survey=0.83    /* ANC-1 Coverage from latest household survey: PLEASE CHANGE TO YOUR SPECIFIC COUNTRY VALUE */
*
*use "${country}_master_adjusted_dataset", clear
*
*
** Compute utilization numbers
** ANC-1
*sort country adminlevel_1 district year
*bysort year: egen tot_anc1=total(anc1)
*bysort adminlevel_1 year: egen reg_anc1=total(anc1)
*
** ANC4
*sort country adminlevel_1 district year
*bysort year: egen tot_anc4=total(anc4)
*bysort adminlevel_1 year: egen reg_anc4=total(anc4)
*
** IPT2
*bysort year: egen tot_ipt2=total(ipt2)
*bysort adminlevel_1 year: egen reg_ipt2=total(ipt2)
*
** Institutional Deliveries
*bysort year: egen tot_idelv=total(idelv)
*bysort adminlevel_1 year: egen reg_idelv=total(idelv)
*
** BCG
*bysort year: egen tot_bcg=total(bcg)
*bysort adminlevel_1 year: egen reg_bcg=total(bcg)
*
** DPT1
*bysort year: egen tot_penta1=total(penta1)
*bysort adminlevel_1 year: egen reg_penta1=total(penta1)
*
** DPT3 
*bysort year: egen tot_penta3=total(penta3)
*bysort adminlevel_1 year: egen reg_penta3=total(penta3)
*
** Measles vaccination
*bysort year: egen tot_measles1=total(measles1)
*bysort adminlevel_1 year: egen reg_measles1=total(measles1)
*
*************************************
** Generate total pregnancies
*gen preg=anc1/${anc1_survey}
*sort country adminlevel_1 district year
*bysort year: egen tot_preg=total(preg)
*bysort adminlevel_1 year: egen reg_preg=total(preg)
*
** Generate total deliveries
*gen deliveries=preg*(1-${pregloss})
*sort country adminlevel_1 district year
*bysort year: egen tot_deliveries=total(deliveries)
*bysort adminlevel_1 year: egen reg_deliveries=total(deliveries)
*
** Generate total births
*gen births=deliveries*(1+${twin})
*sort country adminlevel_1 district year
*bysort year: egen tot_births=total(births)
*bysort adminlevel_1 year: egen reg_births=total(births)
*
** Generate live births
*gen lbirths=births*(1-${sbr})
*sort country adminlevel_1 district year
*bysort year: egen tot_lbirths=total(lbirths)
*bysort adminlevel_1 year: egen reg_lbirths=total(lbirths)
*
** Generate total infants eligible for DPT1
*gen inftpenta1=lbirths*(1-${nmr})
*sort country adminlevel_1 district year
*bysort year: egen tot_inftpenta1=total(inftpenta1)
*bysort adminlevel_1 year: egen reg_inftpenta1=total(inftpenta1)
*
** Generate total infants eligible for measles vaccination
*gen inftmeasle=inftpenta1*(1-${pnmr})
*sort country adminlevel_1 district year
*bysort year: egen tot_inftmeasle=total(inftmeasle)
*bysort adminlevel_1 year: egen reg_inftmeasle=total(inftmeasle)
*
************************************************
** Generate Coverage based on ANC-1 Coverage
** Coverage of ANC-4 
*gen tot_cov_anc4=100*tot_anc4/tot_preg
*gen reg_cov_anc4=100*reg_anc4/reg_preg
*lab var tot_cov_anc4 "Coverage ANC-4"
*lab var reg_cov_anc4 "Coverage ANC-4"
*
** Coverage IPT2 
*gen tot_cov_ipt2=100*tot_ipt2/tot_preg
*gen reg_cov_ipt2=100*reg_ipt2/reg_preg
*lab var tot_cov_ipt2 "Coverage IPT2"
*lab var reg_cov_ipt2 "Coverage IPT2"
*
** Coverage Institutional deliveries
*gen tot_cov_idelv=100*tot_idelv/tot_deliveries
*gen reg_cov_idelv=100*reg_idelv/reg_deliveries 
*lab var tot_cov_idelv "Coverage Institutional Deliveries"
*lab var reg_cov_idelv "Coverage Institutional Deliveries"
*
** Coverage of BCG 
*gen tot_cov_bcg=100*tot_bcg/tot_lbirths
*gen reg_cov_bcg=100*reg_bcg/reg_lbirths 
*lab var tot_cov_bcg "BCG coverage"
*lab var reg_cov_bcg "BCG coverage"
*
** Coverage of DPT1
*gen tot_cov_penta1=100*tot_penta1/tot_inftpenta1
*gen reg_cov_penta1=100*reg_penta1/reg_inftpenta1 
*lab var tot_cov_penta1 "Penta-1 coverage"
*lab var reg_cov_penta1 "Penta-1 coverage"
*
** Coverage of penta3 
*gen tot_cov_penta3=100*tot_penta3/tot_inftpenta1
*gen reg_cov_penta3=100*reg_penta3/reg_inftpenta1 
*lab var tot_cov_penta3 "Penta 3 coverage"
*lab var reg_cov_penta3 "Penta 3 coverage"
*
** Coverage of measles vaccination
*gen tot_cov_measles1=100*tot_measles1/tot_inftmeasle
*gen reg_cov_measles1=100*reg_measles1/reg_inftmeasle
*lab var tot_cov_measles1 "Measles coverage"
*lab var reg_cov_measles1 "Measles coverage"
*
** Graph coverage trends
**** National 
*twoway connected tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on ANC1 derived denominators, National", size(medium)) saving("trends_coverage_anc1denom_1_${country}", replace) sort
*
*twoway connected tot_cov_bcg tot_cov_penta1 tot_cov_penta3 tot_cov_measles1 year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on ANC1 derived denominators, National", size(medium)) saving("trends_coverage_anc1denom_2_${country}", replace) sort
*
**** By admin 1
*twoway connected reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv year, by(adminlevel_1, title("Coverage based on ANC1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_anc1denom_admin1_1_${country}", replace) legend(size(vsmall))
*
*twoway connected  reg_cov_bcg reg_cov_penta1 reg_cov_penta3 reg_cov_measles1 year, by(adminlevel_1, title("Coverage based on ANC1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_anc1denom_admin1_${country}", replace) legend(size(vsmall))
*
** Export coverage output to Excel file
*
*save tmp, replace
*
*collapse (max) tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta1 tot_cov_penta3 tot_cov_measles1, by(country year)
*rename (tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta1 tot_cov_penta3 tot_cov_measles1) (cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta1 cov_penta3 cov_measles1)
*gen area=0
*save tmpcov, replace
*
*use tmp, clear 
*collapse (max) reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta1 reg_cov_penta3 reg_cov_measles1, by(country adminlevel_1 year)
*rename (reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta1 reg_cov_penta3 reg_cov_measles1) (cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta1 cov_penta3 cov_measles1)
*
*rename adminlevel_1 area
*append using tmpcov
*
*lab def first_admin_level 0"National", add
*lab val area first_admin_level
*
*sort country area year
*save Coverage_based_on_ANC1, replace
*export excel Coverage_based_on_ANC1.xls, firstrow(variables) replace
*
*
***************************************************************************
***************************************************************************
*
***** USING DPT-1 DERIVED DENOMINATORS ****************************
******************************************************************
** INPUT VALUE OF ANC-1 FROM SURVEY
*global dpt1_survey=0.84    /* ANC-1 Coverage from latest household survey: PLEASE CHANGE TO YOUR SPECIFIC COUNTRY VALUE */
*
*use "${country}_master_adjusted_dataset", clear
*
** Compute utilization numbers
** ANC-1
*sort country adminlevel_1 district year
*bysort year: egen tot_anc1=total(anc1)
*bysort adminlevel_1 year: egen reg_anc1=total(anc1)
*
** ANC4
*sort country adminlevel_1 district year
*bysort year: egen tot_anc4=total(anc4)
*bysort adminlevel_1 year: egen reg_anc4=total(anc4)
*
** IPT2
*bysort year: egen tot_ipt2=total(ipt2)
*bysort adminlevel_1 year: egen reg_ipt2=total(ipt2)
*
** Institutional Deliveries
*bysort year: egen tot_idelv=total(idelv)
*bysort adminlevel_1 year: egen reg_idelv=total(idelv)
*
** BCG
*bysort year: egen tot_bcg=total(bcg)
*bysort adminlevel_1 year: egen reg_bcg=total(bcg)
*
** DPT1
*bysort year: egen tot_penta1=total(penta1)
*bysort adminlevel_1 year: egen reg_penta1=total(penta1)
*
** DPT3 
*bysort year: egen tot_penta3=total(penta3)
*bysort adminlevel_1 year: egen reg_penta3=total(penta3)
*
** Measles vaccination
*bysort year: egen tot_measles1=total(measles1)
*bysort adminlevel_1 year: egen reg_measles1=total(measles1)
*
*************************************
** Generate total infants eligible for DPT1
*gen inftpenta1=penta1/${dpt1_survey}
*sort country adminlevel_1 district year
*bysort year: egen tot_inftpenta1=total(inftpenta1)
*bysort adminlevel_1 year: egen reg_inftpenta1=total(inftpenta1)
*
** Generate total infants eligible for measles vaccination
*gen inftmeasle=inftpenta1*(1-${pnmr})
*sort country adminlevel_1 district year
*bysort year: egen tot_inftmeasle=total(inftmeasle)
*bysort adminlevel_1 year: egen reg_inftmeasle=total(inftmeasle)
*
** Generate live births
*gen lbirths=inftpenta1/(1-${nmr})
*sort country adminlevel_1 district year
*bysort year: egen tot_lbirths=total(lbirths)
*bysort adminlevel_1 year: egen reg_lbirths=total(lbirths)
*
** Generate total births
*gen births=lbirths/(1-${sbr})
*sort country adminlevel_1 district year
*bysort year: egen tot_births=total(births)
*bysort adminlevel_1 year: egen reg_births=total(births)
*
** Generate total deliveries
*gen deliveries=births/(1+${twin})
*sort country adminlevel_1 district year
*bysort year: egen tot_deliveries=total(deliveries)
*bysort adminlevel_1 year: egen reg_deliveries=total(deliveries)
*
** Generate total pregnancies
*gen preg=deliveries/(1-${pregloss})
*sort country adminlevel_1 district year
*bysort year: egen tot_preg=total(preg)
*bysort adminlevel_1 year: egen reg_preg=total(preg)
*
************************************************
** Generate Coverage based on DPT1 Coverage
** Coverage of ANC-1
*gen tot_cov_anc1=100*tot_anc1/tot_preg
*gen reg_cov_anc1=100*reg_anc1/reg_preg
*lab var tot_cov_anc1 "Coverage ANC-1"
*lab var reg_cov_anc1 "Coverage ANC-1"
*
** Coverage of ANC-4 
*gen tot_cov_anc4=100*tot_anc4/tot_preg
*gen reg_cov_anc4=100*reg_anc4/reg_preg
*lab var tot_cov_anc4 "Coverage ANC-4"
*lab var reg_cov_anc4 "Coverage ANC-4"
*
** Coverage IPT2 
*gen tot_cov_ipt2=100*tot_ipt2/tot_preg
*gen reg_cov_ipt2=100*reg_ipt2/reg_preg
*lab var tot_cov_ipt2 "Coverage IPT2"
*lab var reg_cov_ipt2 "Coverage IPT2"
*
** Coverage Institutional deliveries
*gen tot_cov_idelv=100*tot_idelv/tot_deliveries
*gen reg_cov_idelv=100*reg_idelv/reg_deliveries 
*lab var tot_cov_idelv "Coverage Institutional Deliveries"
*lab var reg_cov_idelv "Coverage Institutional Deliveries"
*
** Coverage of BCG 
*gen tot_cov_bcg=100*tot_bcg/tot_lbirths
*gen reg_cov_bcg=100*reg_bcg/reg_lbirths 
*lab var tot_cov_bcg "BCG coverage"
*lab var reg_cov_bcg "BCG coverage"
*
*
** Coverage of penta3 
*gen tot_cov_penta1=100*tot_penta1/tot_inftpenta1
*gen reg_cov_penta1=100*reg_penta1/reg_inftpenta1 
*lab var tot_cov_penta1 "Penta 1 coverage"
*lab var reg_cov_penta1 "Penta 1 coverage"
*
*
** Coverage of penta3 
*gen tot_cov_penta3=100*tot_penta3/tot_inftpenta1
*gen reg_cov_penta3=100*reg_penta3/reg_inftpenta1 
*lab var tot_cov_penta3 "Penta 3 coverage"
*lab var reg_cov_penta3 "Penta 3 coverage"
*
** Coverage of measles vaccination
*gen tot_cov_measles1=100*tot_measles1/tot_inftmeasle
*gen reg_cov_measles1=100*reg_measles1/reg_inftmeasle
*lab var tot_cov_measles1 "Measles coverage"
*lab var reg_cov_measles1 "Measles coverage"
*
** Graph coverage trends
**** National 
*twoway connected tot_cov_anc1 tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on DPT1 derived denominators, National", size(medium)) saving("trends_coverage_dpt1denom_1_${country}", replace) sort
*
*twoway connected tot_cov_bcg tot_cov_penta3 tot_cov_measles1 year, ylab(, labsize(small)) xlabel(,labsize(small)) scheme(s1color) ytitle("%", size(small)) title("Coverage based on DPT1 derived denominators, National", size(medium)) saving("trends_coverage_dpt1denom_2_${country}", replace) sort
*
**** By admin 1
*twoway connected tot_cov_anc1 reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv year, by(adminlevel_1, title("Coverage based on DPT-1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_dpt1denom_admin1_1_${country}", replace) legend(size(vsmall))
*
*twoway connected  reg_cov_bcg reg_cov_penta3 reg_cov_measles1 year, by(adminlevel_1, title("Coverage based on DPT1 derived denominators, by region", size(medium))) ylab(, labsize(tiny)) xlabel(,labsize(vsmall)) scheme(s1color) ytitle("%") saving("trends_coverage_dpt1denom_admin1_2_${country}", replace) legend(size(vsmall))
*
** Export coverage output to Excel file
*
*save tmp, replace
*
*collapse (max) tot_cov_anc1 tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta3 tot_cov_measles1, by(country year)
*rename (tot_cov_anc1 tot_cov_anc4 tot_cov_ipt2 tot_cov_idelv tot_cov_bcg tot_cov_penta3 tot_cov_measles1) (cov_anc1 cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta3 cov_measles1)
*gen area=0
*save tmpcov, replace
*
*use tmp, clear 
*collapse (max) reg_cov_anc1 reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta3 reg_cov_measles1, by(country adminlevel_1 year)
*
*rename (reg_cov_anc1 reg_cov_anc4 reg_cov_ipt2 reg_cov_idelv reg_cov_bcg reg_cov_penta3 reg_cov_measles1) (cov_anc1 cov_anc4 cov_ipt2 cov_idelv cov_bcg cov_penta3 cov_measles1)
*
*rename adminlevel_1 area
*append using tmpcov
*
*lab def first_admin_level 0"National", add
*lab val area first_admin_level
*
*sort country area year
*save Coverage_based_on_DPT1, replace
*export excel Coverage_based_on_DPT1.xls, firstrow(variables) replace
*
*************************************************************************
**** END
**** Look for the following Excel files for the output of coverage estimates
**** based on ANC1 derived denominators: "Coverage_based_on_ANC1.xls"
**** based on DPT1 derived denominators: "Coverage_based_on_DPT1.xls"

