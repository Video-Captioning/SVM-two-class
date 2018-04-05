# ----- Load the functions to use for this analysis -----
require( purrr )
libraries <- list( 'SVM_functions', 'SVM_classify_one_set' )
LIBRARY_PATH <- '~/Dropbox/Projects/Video-Captioning/'
DATA_PATH    <- LIBRARY_PATH
libraries %>%
  map_chr( .f= ~paste0( LIBRARY_PATH, .x, '.R' )) %>%
  walk( source )
# -------------------------------------------------------

# ----- Describe which data sets to process -------------
BATCHES <- list(
    'disc40/cells4_bins9/'
  , 'disc40/cells5_bins9/'
  , 'disc40/cells6_bins9/'
  , 'disc40/cells7_bins9/'
  , 'disc40/cells8_bins9/'
  , 'disc40/cells9_bins9/'
  , 'disc50/cells4_bins9/'
  , 'disc50/cells5_bins9/'
  , 'disc50/cells6_bins9/'
  , 'disc50/cells7_bins9/'
  , 'disc50/cells8_bins9/'
  , 'disc50/cells9_bins9/'
)

# ----- Process the data sets ----------------------------
map2( DATA_PATH, BATCHES, ~SVM_classify_one_set( .x, .y ))
