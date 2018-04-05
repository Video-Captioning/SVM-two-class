require( ggplot2 )

SCORES <- '/path/to/scores'
x <- read.csv( file = SCORES, header=TRUE,sep='|' )
x$recs <- sum(x[,c(2:5)])
x$rate <- x$recs/x$Sec
#x[order(x$rate),]
#x[order(x$AUC),]
x$A_per_sec <- round( 1000 * x$AUC/x$Sec, 0 )
#x[order(x$A_per_sec),]

pattern <- '([a-z][a-z]*)([0-9]{1,2})\\/(cells)([0-9]{1,2})_(bins)([0-9]{1,2})\\/'
x <- transform(
    x
  , Frac = gsub(
        pattern
      , '\\2'
      , Batch
    )
  , Bins = gsub(
        pattern
      , '\\6'
      , Batch
    )
  , Cells = gsub(
        pattern
      , '\\4'
      , Batch
    )
  , Accu  = round( 100 * (TP + TN ) / ( TP + FP + FN + TN ), 2 )
  , Prec = round( 100 *  TP        / ( TP + FP           ), 2 )
  , Recl    = round( 100 *  TP        / ( TP   +    FN      ), 2 )
)
x$Batch <- NULL
x <- transform(
  x, F1 = round( 2 *  Recl * Prec / ( Recl + Prec ), 2 )
)
x$Cells <- sprintf( '%02d', as.numeric( as.character( x$Cells )))
x


# -----
# For each combination of cells, training fraction...
# 
qplot(
    AUC
  , data=x
  , geom='density'
  , fill=as.factor(Cells)
  , alpha=I(0.5)
  , main='Distribution of AUC by number of cells'
  , xlab="AUC"
  , ylab="Density"
)

qplot(
    AUC
  , Sec/60
  , data=x
  , shape=Bins, color=Frac
  , facets=Cells~Bins, size=I(3)
  , main='Accuracy vs. Time to Classify'
  , xlab="AUC"
  , xlim=c(0,1)
  , ylab="Time [Minutes]"
)


# https://www.mathworks.com/help/vision/ref/extracthogfeatures.html?requestedDomain = true
# To capture large-scale spatial information, increase the cell size. When you increase the cell size, you may lose small-scale detail.
# To encode finer orientation details, increase the number of bins. Increasing this value increases the size of the feature vector, which requires more time to process.
