# Repository: Child health service coverage estimation using routine health data from Ghana’s Eastern Region

Standard Stata scripts for district level implementation of Maina and colleagues' coverage estimation approach are openly available from the Countdown to 2030 Collaboration at https://www.countdown2030.org/tools-for-analysis/health-facility-data-and-analysis

This repository contains Stata scripts adapted for the present study to generate estimates for region, district, sub-district and health facility levels using routinely collected health data from Ghana

## Author

Matthew Johnson, University of Southampton

## Citation

If you use this code, please cite the associated publication:

Johnson, M., et al. (2026). DOI: xx.xxxx/xxxxx [to be added]

The code repository is provided to support reproducibility of the published research.

## Software

The scripts were developed using using Stata SE Version 16.0 (Stata-Corp, College Station, TX, USA)

## Workflow

File names include a two-character prefix indicating the order in which they should be run. Run in ascending alphanumeric order

The digit denotes the administrative level for which estimates are produced
- scripts prefixed by '1' are used for regions and districts
- scripts prefixed by '2' are used for sub-districts
- scripts prefixed by '3' are used for health facilities

The letter denotes the purpose of the script
- 'a' prepares the data
- 'b' assesses reporting completeness
- 'c' assesses the internal consistency of indicators
- 'e' produces denominators and coverage/utilisation estimates

## Notes

The routinely collected health data analysed for this study are not included in this repository due to confidentiality and data licensing restrictions from the Ghana Health Service. This repository contains code only
