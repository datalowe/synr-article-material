# This script generates plots describing participants' color responses,
# for use by human raters.
# Uses mock data. (the real data unfortunately currently cannot 
# be shared, due to missing ethics board approval)

# Load libraries ----
# (remember to install the required packages if you don't have them)
library(synr)

# Load data ----
INPUT_FILE_PATH <- '../data/raw_data.csv'
MAIN_OUTPUT_DIR_PATH <- '../validation_plots/'
LETTER_DIR_NAME <- 'letters'
DIGITS_DIR_NAME <- 'digits'


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

pg$save_plots(
  save_dir = file.path(OUTPUT_DIR_PATH, LETTER_DIR_NAME),
  grapheme_size = 3,
  symbol_filter = LETTERS
)

pg$save_plots(
  save_dir = file.path(OUTPUT_DIR_PATH, DIGITS_DIR_NAME),
  grapheme_size = 3,
  symbol_filter = 0:9
)

write.csv(val_df, OUTPUT_FILE_PATH, row.names=FALSE)
