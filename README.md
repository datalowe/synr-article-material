# synr article: accompanying material
This repository holds accompanying material for the planned article "synr: An R package for handling synesthesia consistency test data", about the [R package synr](https://github.com/datalowe/synr).

The synr article's second example application section uses data from [KIND](https://ki.se/en/kind/center-of-neurodevelopmental-disorders-at-karolinska-institutet-kind) at Karolinska Institute, Sweden. These were collected in 2019-2021, in a study led by Janina Neufeld. Unfortunately, the real data currently cannot be shared, due to missing ethics board approval for sharing anonymized individual-level participant data. Instead, this repository includes a small set of mock raw data ('data/raw_data.csv'), which are used to demonstrate how the actual analyses were performed.

## Data directory
* *raw_data.csv*: Mock raw synesthesia consistency test data in tidy data format. Each row represents a single experiment trial. The data simulate responses from 7 participants (ID's 3, 4, 5, 6, 7, 8 and 31).
* *humanrater1_validation_results.csv / humanrater2_validation_results.csv*: Human ratings of mock participant's data validity, where ratings are made separately for letter and digit trial data, respectively. Ratings were made with the help of the plots in the 'validation_plots' directory.
    - For these mock data, the human raters' evaluations are identical for all participants; this was not the case for the original data, as described in the article.
* *synr_validation_results.csv*: Results of validation of participant data, as produced by running the script 'scripts/1_validate_participant_data_synr.R'. Note that only the 'dig_valid' and 'lett_valid' columns are relevant/used for comparison with human rater evaluations.

## Scripts directory
* *0_generate_rating_plots.R*: Script for producing the plots in 'validation_plots'.
* *1_validate_participant_data_synr.R*: Script for applying automated data set validation with synr, producing 'data/synr_validation_results.csv'.
* *2_compare_synr_human_validation.Rmd*: R Markdown document where comparison of human rater/synr validation of data is performed and briefly discussed.
* *3_dingemanse_validation_ciexyz.R*: R script giving example of applying data validation with CIE XYZ color space in addition to the CIELUV-based validation example discussed in article.

## Validation plots directory
Contains plots which summarize participants' color responses, for use by human raters.
