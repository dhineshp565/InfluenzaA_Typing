#!/usr/bin/env bash

# Generates influenza HA and NA results file using abricate and insaflu database
# $1 -cons folder containing consensus from influenza_nano process
# $2 -csv file with samplename and location from influenza_nano process

mkdir typing_results
	while read lines
	do 
		sample=$(echo $lines|cut -f 1 -d ',')
		# run abricate image with insaflu database
		abricate --db insaflu -minid 70 -mincov 60 --quiet $1/${sample}_InfA.fasta > typing_results/${sample}_insaflu_typing.csv
		# count HA or NA is in the typing results
		HA_count=$(cat "typing_results"/${sample}_insaflu_typing.csv|grep HA|wc -l)
		NA_count=$(cat "typing_results"/${sample}_insaflu_typing.csv|grep NA|wc -l)
		# if HA count is 0 then  add a line to say no HA consensus available
		if [[ "${HA_count}" == "0" ]]
		then
				echo -e "cons/${sample}_InfA.fasta	HA_No_consensus/${sample}	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	No_HA_consensus" >> typing_results/${sample}_insaflu_typing.csv
				
		fi
		# if NA count is 0 add a line to say no HA consensus available
		if [[ "${NA_count}" == "0" ]]
		then
				echo -e "cons/${sample}_InfA.fasta	NA_No_consensus/${sample}	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	n/a	No_NA_consensus" >> typing_results/${sample}_insaflu_typing.csv
				
		fi
	
	done < $2
# summary of results
awk 'FNR==1 && NR!=1 { while (/^#F/) getline; } 1 {print}' typing_results/*typing.csv > typing_summary.csv