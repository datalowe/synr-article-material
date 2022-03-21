# This script applies synr's automated validation procedure on
# mock data, simulating study data from KIND at Karolinska Institutet
# (collected in 2019-2021, in a study led by Janina Neufeld),
# resulting in the CSV file 'synr_validation_results.csv'.
# Validation is executed with data in the following categories:
# * all data (no filter)
# * data from trials where a single letter served as inducer (A-Z)
# * data from trials where a single digit served as inducer (0-9)
# * data from trials where the (Swedish) name of a weekday served as inducer
# * data from trials where the (Swedish) name of a month served as inducer
# Note that only data from letter and digit trials are used for comparisons
# with human raters - the other validations are executed for the sake of
# completeness.

# Load libraries ----
# (remember to install the required packages if you don't have them)
library(synr)
library(dplyr)
library(tibble)

# Load data ----
INPUT_FILE_PATH <- '../data/raw_data.csv'
OUTPUT_FILE_PATH <- '../data/synr_validation_results.csv'

raw_df <- read.csv(
  INPUT_FILE_PATH,
  stringsAsFactors = FALSE,
  na.strings = c("NA", "", "nocolor")
)

pg <- create_participantgroup(
  raw_df,
  n_trials_per_grapheme = 3,
  id_col_name = 'participant_id',
  symbol_col_name = 'trial_symbol',
  color_col_name = 'response_color',
  color_space_spec = 'Luv'
)

# Constants ----
# specify common validation function-related settings (see synr's 
# documentation for details about what these mean) that will be used
# for all validation
MIN_COMPLETE_GRAPHEMES <- 4
DBSCAN_EPS <-  20
DBSCAN_MIN_PTS <- 1
MAX_VAR_TIGHT_CLUSTER <-  180
MAX_PROP_SINGLE_TIGHT_CLUSTER <-  0.6
SAFE_NUM_CLUSTERS <- 3
SAFE_TWCV <-  250


# Apply validation procedure for each data category ----
## all trials (no filter)
val_df_all <- pg$check_valid_get_twcv_scores(
  min_complete_graphemes = MIN_COMPLETE_GRAPHEMES,
  dbscan_eps = DBSCAN_EPS,
  dbscan_min_pts = DBSCAN_MIN_PTS,
  max_var_tight_cluster = MAX_VAR_TIGHT_CLUSTER,
  max_prop_single_tight_cluster = MAX_PROP_SINGLE_TIGHT_CLUSTER,
  safe_num_clusters = SAFE_NUM_CLUSTERS,
  safe_twcv = SAFE_TWCV,
  symbol_filter = NULL
)

## single letter inducer trials
letter_filter <- LETTERS
val_df_lett <- pg$check_valid_get_twcv_scores(
  min_complete_graphemes = MIN_COMPLETE_GRAPHEMES,
  dbscan_eps = DBSCAN_EPS,
  dbscan_min_pts = DBSCAN_MIN_PTS,
  max_var_tight_cluster = MAX_VAR_TIGHT_CLUSTER,
  max_prop_single_tight_cluster = MAX_PROP_SINGLE_TIGHT_CLUSTER,
  safe_num_clusters = SAFE_NUM_CLUSTERS,
  safe_twcv = SAFE_TWCV,
  symbol_filter = letter_filter
)

## digit inducer trials
digit_filter <- 0:9
val_df_dig <- pg$check_valid_get_twcv_scores(
  min_complete_graphemes = MIN_COMPLETE_GRAPHEMES,
  dbscan_eps = DBSCAN_EPS,
  dbscan_min_pts = DBSCAN_MIN_PTS,
  max_var_tight_cluster = MAX_VAR_TIGHT_CLUSTER,
  max_prop_single_tight_cluster = MAX_PROP_SINGLE_TIGHT_CLUSTER,
  safe_num_clusters = SAFE_NUM_CLUSTERS,
  safe_twcv = SAFE_TWCV,
  symbol_filter = digit_filter
)

## weekday inducer trials
weekday_filter <- c(
  "Måndag",
  "Tisdag",
  "Onsdag",
  "Torsdag",
  "Fredag",
  "Lördag",
  "Söndag"
)
val_df_wkd <- pg$check_valid_get_twcv_scores(
  min_complete_graphemes = MIN_COMPLETE_GRAPHEMES,
  dbscan_eps = DBSCAN_EPS,
  dbscan_min_pts = DBSCAN_MIN_PTS,
  max_var_tight_cluster = MAX_VAR_TIGHT_CLUSTER,
  max_prop_single_tight_cluster = MAX_PROP_SINGLE_TIGHT_CLUSTER,
  safe_num_clusters = SAFE_NUM_CLUSTERS,
  safe_twcv = SAFE_TWCV,
  symbol_filter = weekday_filter
)

## month inducer trials
month_filter <- c(
  "Januari", "Februari", "Mars",
  "April", "Maj", "Juni",
  "Juli", "Augusti", "September",
  "Oktober", "November", "December"
)
val_df_mon <- pg$check_valid_get_twcv_scores(
  min_complete_graphemes = MIN_COMPLETE_GRAPHEMES,
  dbscan_eps = DBSCAN_EPS,
  dbscan_min_pts = DBSCAN_MIN_PTS,
  max_var_tight_cluster = MAX_VAR_TIGHT_CLUSTER,
  max_prop_single_tight_cluster = MAX_PROP_SINGLE_TIGHT_CLUSTER,
  safe_num_clusters = SAFE_NUM_CLUSTERS,
  safe_twcv = SAFE_TWCV,
  symbol_filter = month_filter
)

# Summarize classifications ----
## add prefix for each individual data frame's columns to make columns
## discernible from each other after merging them
names(val_df_all) <- paste0('all_', names(val_df_all))
names(val_df_dig) <- paste0('dig_', names(val_df_dig))
names(val_df_lett) <- paste0('lett_', names(val_df_lett))
names(val_df_wkd) <- paste0('wkd_', names(val_df_wkd))
names(val_df_mon) <- paste0('mon_', names(val_df_mon))

## Combine all resulting classifications in a single data frame
## and add an ID column
val_df <- bind_cols(
  participant_id = pg$get_ids(),
  val_df_all,
  val_df_dig,
  val_df_lett,
  val_df_wkd,
  val_df_mon
)

write.csv(val_df, OUTPUT_FILE_PATH, row.names=FALSE)
