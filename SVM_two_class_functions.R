
# EXAMPLE USAGE:
#    microbenchmark::microbenchmark( (results <- update( './disc05/cells4_bins6/' )), times=1L )

# --- Configuration
DATA_PATH <- '/Users/Karl/Dropbox/Projects/Video-Captioning/'

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

# Load and label the data
load_and_label <- function( y, fname ){
  data <- read.csv( file=fname, header=FALSE, sep=',', as.is=TRUE, row.names=1 )
  data$y <- y
  data
}

optimize_cost <- function( range_lists, test_data ){
  cat( sprintf( 'Finding optimal cost...\n' ))
  # find optimal cost of confusion_matrixification
  e1071::tune(
      e1071::svm
    , y~.
    , data = test_data
    , kernel = 'linear'
    , ranges = range_lists
  )
}

get_confusion <- function( thefit, thedata, y ){
  # Create a table of mis-classified observations
  predictions <- ifelse( predict( thefit, thedata ) > 0.50, 1, 0 )
  confusion_matrix <- table( predict = predictions, truth = y )
}

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

save_as <- function( data, fname, path = BASE_PATH ){
  X <- data.frame( data )
  names( X ) <- NULL
  write.csv(
      X
    , file = paste0( path, fname )
    , quote = FALSE, row.names = FALSE
  )
}

add_row <- function( X, descr, value ){
  new_index <- 1 + nrow( X )
  X[ new_index, 'Descr' ] <- descr
  X[ new_index, 'Value' ] <- value
  X
}
