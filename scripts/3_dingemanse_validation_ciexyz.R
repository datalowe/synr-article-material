# This script applies synr's automated validation procedure on
# data from a study by Cuskley, Dingemanse, van Leeuwen & Kirby (2019),
# in a very similar manner to what is described in one of synr's built-in 
# vignettes ('Using synr with real data: Coloured vowels').
# The main difference is that here, after first using the color space CIELUV
# to calculate consistency scores and validating data,
# the color space CIE XYZ and then sRGB are used for
# 'second and third rounds'.
# The motivation for doing this is to give examples of using different
# color spaces with synr, and to see if sRGB and/or CIE XYZ appear to be more
# appropriate than CIELUV when evaluating participant data with all-very-light responses.
# For more information, see synr's official documentation.
# (github.com/datalowe/synr)

# load libraries
library(synr)
library(tidyr)
library(ggplot2)

# define function for calculating z scores (used further below)
calc_z_scores <- function(vals) {
  m_val <- mean(vals, na.rm=TRUE)
  sd_val <- sd(vals, na.rm=TRUE)
  sapply(vals, function(x) {(x - m_val)/sd_val})
}

# download the 'coloured vowels' data
githuburl <- 'https://raw.githubusercontent.com/mdingemanse/colouredvowels/master/BRM_colouredvowels_voweldata.csv'
dingemanse_voweldata <- read.csv(githuburl, sep=' ')

# 'pivot' the data into a long (one row per observation/trial) format,
# using tidyr's pivot_longer function (and the 'pipe' %>% operator)
cvow_long <- dingemanse_voweldata %>% 
  pivot_longer(
    cols=c('color1', 'color2', 'color3',
           'timing1', 'timing2', 'timing3'),
    names_to=c(".value", "trial"),
    names_pattern="(\\w*)(\\d)",
    values_to=c('color', 'timing')
  )





### --------------------------------------------
### CIELUV
# create participantgroup object, specifying CIELUV as color space
luv_pg <- create_participantgroup(
  raw_df=cvow_long,
  n_trials_per_grapheme=3,
  id_col_name="anonid",
  symbol_col_name="item",
  color_col_name="color",
  time_col_name="timing",
  color_space_spec="Luv" # color space is specified here
)

# validate data, with criteria:
# * minimum of 8 complete graphemes
# * dbscan clusters form with epsilon at 20, minimum number of points at 4
# * clusters with total within-cluster variance below 150 are considered 'tight-knit'
# * a maximum of 80% of all colors/points are allowed to be part of a single 'tight-knit'
#   cluster
# * if 2 or more non-noise clusters form, and less than 80% of all colors/points in
#   a single 'tight-knit' cluster, the data are considered valid
# * if aggregated total within-cluster variance is above 300, and less than 80%
#   of all colors/points are in a single 'tight-knit' cluster, the data are considered
#   valid
luv_validation_df <- luv_pg$check_valid_get_twcv_scores(
  min_complete_graphemes = 8,
  dbscan_eps = 20,
  dbscan_min_pts = 4,
  max_var_tight_cluster = 150,
  max_prop_single_tight_cluster = 0.8,
  safe_num_clusters = 2,
  safe_twcv = 300
)

# calculate mean consistency scores, based on CIELUV color space
luv_cons_vec <- luv_pg$get_mean_consistency_scores()

# retrieve participant ID's
luv_ids <- luv_pg$get_ids()

# combine all the results in a single data frame
luv_all_df <- data.frame(id=luv_ids, cons_score=luv_cons_vec)
luv_all_df <- cbind(luv_all_df, luv_validation_df)

# calculate Z scores of consistency scores
luv_all_df["cons_score_z"] <- calc_z_scores(luv_all_df[["cons_score"]])

# calculate Z scores of total within-cluster variance
luv_all_df["twcv_z"] <- calc_z_scores(luv_all_df[["twcv"]])

# retrieve the results for 'problematic' participant data, which dont't work well
# in CIELUV color space due to all responses being very light (making the consistency
# score artificially low)
luv_problematic_p <- luv_all_df[luv_all_df$id == "d47c0e32-e3e2-4acf-84d0-08bf7375308b", ]
print("CIE LUV results:")
print(luv_problematic_p)
# looking at the results, it's clear that the participant's data are regarded as
# invalid, and that they have a very low consistency score considering how much their
# picked hue varies. their Z-score for consistency is at -1.757 (indicating an 'unusually' consistent
# score, just below 10th percentile in sample), and their Z-score for total within-cluster
# variance is -1.325 (~9th percentile)





### --------------------------------------------
### CIE XYZ
# create participantgroup object, specifying CIE XYZ as color space
xyz_pg <- create_participantgroup(
  raw_df=cvow_long,
  n_trials_per_grapheme=3,
  id_col_name="anonid",
  symbol_col_name="item",
  color_col_name="color",
  time_col_name="timing",
  color_space_spec="XYZ" # color space is specified here
)

# see further below for information on how this value was calculated
XYZ_SAFE_TWCV <- 0.0421

# validate data, with criteria:
# * minimum of 8 complete graphemes (based on original article's criteria)
# * dbscan clusters form with epsilon set to 0.0028, minimum number of points set to 4
# * clusters with total within-cluster variance below 0.02105 are considered 'tight-knit'
# * a maximum of 80% of all colors/points are allowed to be part of a single 'tight-knit'
#   cluster
# * if 2 or more non-noise clusters form, and less than 80% of all colors/points are in
#   a single 'tight-knit' cluster, the data are considered valid
# * if aggregated total within-cluster variance is above 0.0421, and less than 80%
#   of all colors/points are in a single 'tight-knit' cluster, the data are considered
#   valid
xyz_validation_df <- xyz_pg$check_valid_get_twcv_scores(
  min_complete_graphemes = 8,
  dbscan_eps = 20/300 * XYZ_SAFE_TWCV,
  dbscan_min_pts = 4,
  max_var_tight_cluster = XYZ_SAFE_TWCV/2,
  max_prop_single_tight_cluster = 0.8,
  safe_num_clusters = 2,
  safe_twcv = XYZ_SAFE_TWCV
)

# calculate mean consistency scores, based on CIE XYZ color space
# (there is no agreed-upon cut-off to use in this color space)
xyz_cons_vec <- xyz_pg$get_mean_consistency_scores()

## command that was originally used to find, for the CIE XYZ color space,
## the 10th percentile with respect to total within-cluster variance values
## calculated for the sample, resulting in the 'safe_twcv' value of 0.0421
## specified above. max_var_tight_cluster was set to half of this, 0.0421/2.
## similarly, epsilon value was set to 20/300 * 0.0421 (to maintain ratio
## between 'dbscan_eps' and 'safe_twcv'). note that this 10th percentile
## value was picked rather arbitrarily, without checking how many false
## positives/negatives there would be
# quantile(xyz_validation_df[["twcv"]], 0.1, na.rm=TRUE)

# retrieve participant ID's
xyz_ids <- xyz_pg$get_ids()

# combine all the results in a single data frame
xyz_all_df <- data.frame(id=xyz_ids, cons_score=xyz_cons_vec)
xyz_all_df <- cbind(xyz_all_df, xyz_validation_df)

# calculate Z scores of consistency scores
xyz_all_df["cons_score_z"] <- calc_z_scores(xyz_all_df[["cons_score"]])

# calculate Z scores of total within-cluster variance
xyz_all_df["twcv_z"] <- calc_z_scores(xyz_all_df[["twcv"]])


# retrieve the results for 'problematic' participant data, which didn't work well
# in CIELUV color space due to all responses being very light
xyz_problematic_p <- xyz_all_df[xyz_all_df$id == "d47c0e32-e3e2-4acf-84d0-08bf7375308b", ]
print("CIE XYZ results:")
print(xyz_problematic_p)
# looking at the results, the participant's data are now regarded as
# valid, and they have a consistency score much closer to the mean.
# their Z-score for consistency is at -0.05, and their Z-score
# for total within-cluster variance is -1.119183 (~13th percentile,
# indicating that they are still not far from being considered invalid)





### --------------------------------------------
### sRGB
# create participantgroup object, specifying sRGB as color space
rgb_pg <- create_participantgroup(
  raw_df=cvow_long,
  n_trials_per_grapheme=3,
  id_col_name="anonid",
  symbol_col_name="item",
  color_col_name="color",
  time_col_name="timing",
  color_space_spec="sRGB" # color space is specified here
)

# see further below for information on how this value was calculated
RGB_SAFE_TWCV <- 0.0909

# validate data, with criteria adjusted for RGB space similar to how
# it was done for CIE XYZ space:
rgb_validation_df <- rgb_pg$check_valid_get_twcv_scores(
  min_complete_graphemes = 8,
  dbscan_eps = 20/300 * RGB_SAFE_TWCV,
  dbscan_min_pts = 4,
  max_var_tight_cluster = RGB_SAFE_TWCV/2,
  max_prop_single_tight_cluster = 0.8,
  safe_num_clusters = 2,
  safe_twcv = RGB_SAFE_TWCV
)

# calculate mean consistency scores, based on CIE RGB color space
# (there is no agreed-upon cut-off to use in this color space)
rgb_cons_vec <- rgb_pg$get_mean_consistency_scores()

## command that was originally used to find, for the CIE RGB color space,
## the 10th percentile with respect to total within-cluster variance values
## calculated for the sample, resulting in the 'safe_twcv' value of 0.0909
## specified above.
# quantile(rgb_validation_df[["twcv"]], 0.1, na.rm=TRUE)

# retrieve participant ID's
rgb_ids <- rgb_pg$get_ids()

# combine all the results in a single data frame
rgb_all_df <- data.frame(id=rgb_ids, cons_score=rgb_cons_vec)
rgb_all_df <- cbind(rgb_all_df, rgb_validation_df)

# calculate Z scores of consistency scores
rgb_all_df["cons_score_z"] <- calc_z_scores(rgb_all_df[["cons_score"]])

# calculate Z scores of total within-cluster variance
rgb_all_df["twcv_z"] <- calc_z_scores(rgb_all_df[["twcv"]])


# retrieve the results for 'problematic' participant data, which didn't work well
# in CIELUV color space due to all responses being very light
rgb_problematic_p <- rgb_all_df[rgb_all_df$id == "d47c0e32-e3e2-4acf-84d0-08bf7375308b", ]
print("CIE RGB results:")
print(rgb_problematic_p)
# looking at the results, they are very similar to what was seen in CIELUV color space.
# it's clear that the participant's data are regarded as
# invalid, and that they have a very low consistency score considering how much their
# picked hue varies. their Z-score for consistency is at -1.434 (indicating an 'unusually' consistent
# score, around 5th percentile in sample), and their Z-score for total within-cluster
# variance is -1.948 (~2nd percentile)
