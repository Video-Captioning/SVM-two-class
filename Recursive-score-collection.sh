#!/usr/bin/env bash

# --- Configuration
datafile=summary.csv # Name of input data file to visit in each subdirectory

# --- Verify command-line parameters, giving usage instructions when warranted
if (( $# != 1 ))
then
  echo 
  echo "Usage:"
  echo "  sh $0 keyword"
  echo "Example:"
  echo "  sh $0 disc"
  exit 1
fi

# --- Get the keyword from the command-line
keyword=$1

# --- Find all partitions on keyword
for i in `ls -d $keyword[0-9][0-9]/*/`; do
  for j in `ls -d $i* | grep $datafile`; do
    echo Batch='"'$i'"'
    cat $j
  done
done > tmp_scores

# --- Create a Header
echo 'Batch | TP | FP | TN | FN | AUC | Sec' > scores.txt

# --- Append each row of scores
cat tmp_scores | sed -e 's/,/=/g' -e 's/=/ /2' -e 's/^Time-to-optimize= seconds /Seconds=/g' | sed 's/^.*=/|/g' | sed -e :a -e '$!N;s/\n|/ |/;ta' -e 'P;D' | sed 's/|\"/\'$'\n/g' | sed 's/\"//g' >> scores.txt

# --- Show the results
grep . scores.txt

# -----------------------------------------------
# Just in case there is a need to know when
# the feature data were last updated...
#   Get date, time, and filespec
#   by removing the first 36 characters
#   from a detailed directory listing
ls -dlR $keyword*/cel*/* | sed 's/^.\{36\}//g' > tmp_files
