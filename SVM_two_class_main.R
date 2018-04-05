BATCH <- 'disc40/cells9_bins9/'

# ----- Load the functions to use for this analysis -----
require( purrr )
libraries <- list( 'SVM_two_class_functions', 'SVM_two_class_script' )
LIBRARY_PATH <- '~/Dropbox/Projects/Video-Captioning/'
DATA_PATH    <- LIBRARY_PATH
libraries %>%
  map_chr( .f= ~paste0( LIBRARY_PATH, .x, '.R' )) %>%
  walk( source )
# -------------------------------------------------------

classify_these( DATA_PATH, batch = BATCH )

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
map2( DATA_PATH, BATCHES, ~classify_these( .x, .y ))
