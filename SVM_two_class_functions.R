# EXAMPLE USAGE:
#    microbenchmark::microbenchmark(
#         (results <- update( './disc05/cells4_bins6/' ))
#       , times=1L
#     )

# --- Configuration
DATA_PATH <- '/path/to/Projects/Video-Captioning/'

# --- Deeper Configuration --- less likely to change

# Standard naming for files: train, test, pos, neg
CFG <- dplyr::tribble(
    ~filename      , ~y
  , 'test_pos.csv' , 1
  , 'test_neg.csv' , 0
  , 'train_pos.csv', 1
  , 'train_neg.csv', 0
)

# Adapted by Karl Edwards on March 28, 2018 from http://uc-r.github.io/svm

# -----------------------------------------------
#     F U N C T I O N S
# -----------------------------------------------

# Load and label the data for one row of CFG
load_and_label <- function( y, fname ){
  data <- read.csv( file=fname, header=FALSE, sep=',', as.is=TRUE, row.names=1 )
  data$y <- y
  data
}

# Optimize cost parameter, C,
# by training an SVM classifier using each of the
# C-values given in input, range_lists
optimize_cost <- function( range_lists, test_data ){
  cat( sprintf( 'Finding optimal cost...\n' ))
  e1071::tune(
      e1071::svm
    , y~.
    , data   = test_data
    , kernel = 'linear'
    , ranges = range_lists
  )
}

# Create a confusion matrix
get_confusion <- function( thefit, thedata, y ){
  predictions <- ifelse( predict( thefit, thedata ) > 0.50, 1, 0 )
  confusion_matrix <- table( predict = predictions, truth = y )
}

# Calculate the effectiveness of the classifier
evaluate_fit <- function( confusion_matrix ){
  TN <- confusion_matrix[ 1, 1 ]
  FN <- confusion_matrix[ 1, 2 ]
  FP <- confusion_matrix[ 2, 1 ]
  TP <- confusion_matrix[ 2, 2 ]
  Accuracy  <- ( TP + TN ) / ( TP + FP + FN + TN )
  Precision <-   TP / ( TP + FP )
  Recall    <-   TP / ( TP + FN )
  F1        <-  2 * ( Recall * Precision ) / ( Recall + Precision )
  list(
      TN=TN, FN=FN, FP=FP, TP=TP
    , Accuracy=Accuracy, Precision=Precision
    , Recall=Recall, F1=F1
  )
}

# Save some stuff, someplace
save_as <- function( data, fname, path = BASE_PATH ){
  df <- data.frame( data )
  names( df ) <- NULL
  write.csv(
      df
    , file = paste0( path, fname )
    , quote = FALSE, row.names = FALSE
  )
}

# Add a row of inforation to an existing data frame,
# populating descr[iption] and value in the first two columns
add_row <- function( df, descr, value ){
  new_index <- 1 + nrow( df )
  df[ new_index, 1 ] <- descr
  df[ new_index, 2 ] <- value
  df
}
