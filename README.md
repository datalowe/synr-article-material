# synr article: accompanying material

This repository holds accompanying material for the article:

> Wilsson, L., van Leeuwen, T.M. & Neufeld, J. synr: An R package for handling synesthesia consistency test data. Behav Res 55, 4086–4098 (2023). https://doi.org/10.3758/s13428-022-02007-y

## KIND data

The [synr](https://cran.r-project.org/web/packages/synr/index.html) article's second example application section uses data from [KIND](https://ki.se/en/kind/center-of-neurodevelopmental-disorders-at-karolinska-institutet-kind) at Karolinska Institute, Sweden. These were collected in 2019-2021, in a study led by Janina Neufeld. Unfortunately, the real data currently cannot be shared, due to missing ethics board approval for sharing anonymized individual-level participant data. Instead, this repository includes a small set of mock raw data ('data/raw_data.csv'), which are used to demonstrate how the actual analyses were performed.

## Data directory

- _raw_data.csv_: Mock raw synesthesia consistency test data in tidy data format. Each row represents a single experiment trial. The data simulate responses from 7 participants (ID's 3, 4, 5, 6, 7, 8 and 31).
- _humanrater1_validation_results.csv / humanrater2_validation_results.csv_: Human ratings of mock participant's data validity, where ratings are made separately for letter and digit trial data, respectively. Ratings were made with the help of the plots in the 'validation_plots' directory.
  - For these mock data, the human raters' evaluations are identical for all participants; this was not the case for the original data, as described in the article.
- _synr_validation_results.csv_: Results of validation of participant data, as produced by running the script 'scripts/1_validate_participant_data_synr.R'. Note that only the 'dig_valid' and 'lett_valid' columns are relevant/used for comparison with human rater evaluations.

## Scripts directory

- _0_generate_rating_plots.R_: Script for producing the plots in 'validation_plots'.
- _1_validate_participant_data_synr.R_: Script for applying automated data set validation with synr, producing 'data/synr_validation_results.csv'.
- _2_compare_synr_human_validation.Rmd_: R Markdown document where comparison of human rater/synr validation of data is performed and briefly discussed.
- _3_dingemanse_validation_ciexyz.R_: R script giving example of applying data validation with CIE XYZ color space in addition to the CIELUV-based validation example discussed in article.

## synr raw vignettes directory

- _synr-validate-data-vignette.Rmd_: R Markdown document, holding 'raw' version of synr vignette 'Validating participant color response data'. Above all, this document may be relevant for researchers who wish to produce 3D plots describing results of applying DBSCAN clustering to data. Be aware though that this is an advanced topic, and the vignette does not include that much code documentation. It is strongly recommended to first go through an introductory tutorial (e.g. on YouTube) about the R package plotly before looking at the vignette.

## Validation plots directory

Contains plots which summarize participants' color responses, for use by human raters.
