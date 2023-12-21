#!/usr/bin/env bash
# make headerless csvfile with samplename in the first column and fastq location of the sample in the second column
# $1 = directory containing fastq directories

# get list of all directories
ls -1 $1 > sample.csv
#get path of each fastq directory
realpath $1/* > paths.csv
#concatenate samplename and paths
paste sample.csv paths.csv > samplelist.csv
#replace tab with comma
sed -i 's/	/,/g' "samplelist.csv"