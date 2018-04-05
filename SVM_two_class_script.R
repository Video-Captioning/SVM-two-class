# Usage: classify( batch = BATCH )
classify_these <- function( path=DATA_PATH, batch=BATCH ){

  # ----- Get the data ------------------------------------
  cat( sprintf( 'Getting data...\n' ))
  BASE_PATH <- paste0( DATA_PATH, batch )

  # ToDo [] Handle file-not-found error
  data <- purrr::map2(
           CFG[[ 'filename' ]] # .x
         , CFG[[ 'y' ]]        # .y
         , ~load_and_label( y=.y, fname=paste0( BASE_PATH, .x ) )
       )
  train.data <- rbind( data[[ 3 ]], data[[ 4 ]])
  test.data  <- rbind( data[[ 1 ]], data[[ 2 ]])

  # ----- Optimize cost parameter, C ----------------------
  benchmark <- microbenchmark::microbenchmark(
      models <- optimize_cost(
        range_lists = list(
          cost = c( 0.001, 0.01, 0.1, 1 )
        )
        , test_data = test.data
      )
    , times = 1L
  )

  # ----- Evaluate the results ----------------------------
  best_model  <- models$best.model
  ( best_fit  <- get_confusion( best_model, test.data, test.data$y ) )
  scores      <- evaluate_fit( best_fit )
  predictions <- ifelse( predict( best_model, test.data ) > 0.50, 1, 0 )

  # ----- Summarize the best fit -------------------------
  fit_summary <- data.frame( best_fit )
  fit_summary$Descr <- paste0( fit_summary[ , 1 ], fit_summary[ , 2 ] )
  fit_summary$Value <- fit_summary$Freq
  fit_summary <- fit_summary[ , c('Descr', 'Value' )]

  rocr_data   <- ROCR::prediction( predictions, test.data$y )
  auc.tmp     <- ROCR::performance( rocr_data, 'auc' );
  fit_summary <- add_row(
      fit_summary, descr='AUC', value=as.numeric( auc.tmp@y.values )
  )
  fit_summary <- add_row(
      fit_summary, descr='Time-to-optimize, seconds'
    , value=round(benchmark$time/1e9,0)
  )
  fit_summary$Value <- round( fit_summary$Value, 3 )

  # ----- Save key information ---------------------------
  save_as(
      data  = names( predictions) [ !test.data$y == predictions & predictions == 1 ]
    , fname = 'false_detection.csv', path = BASE_PATH
  )

  save_as(
     data  = names( predictions )[ !test.data$y == predictions & predictions == 0 ]
   , fname = 'not_detected.csv', path = BASE_PATH
  )

  save_as( data = fit_summary, fname = 'summary.csv', path = BASE_PATH )
  paste0( BASE_PATH, fname )
}
