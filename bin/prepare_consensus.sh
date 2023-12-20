#!/usr/bin/env bash
#take samplelist.csv file with sample name and data location and checks if both HA and NA sequences are there. 
# If they are absent then headers with info is added

mkdir cons
	
while read lines
do 
		sample=$(echo $lines|cut -f 1 -d ',')
        # count no. of sequences in the consensus folder
		count=$(ls -1 ${sample}/consensus/*.fa 2>/dev/null | wc -l)

       
		if [[ "${count}" != "0" ]]
		then
            # conctaenate fasta sequences
			cat ${sample}/consensus/*.fa > "cons"/${sample}_InfA.fasta
            # if HA seq is not present then add a header mentioning no Ha consensus
			HA_count=$(cat "cons"/${sample}_InfA.fasta|grep HA|wc -l)
			if [[ "${HA_count}" == "0" ]]
			then
				echo -e ">HA_No_consensus/${sample}" >> "cons"/${sample}_InfA.fasta
			fi
            # if HA seq is not present then add a header mentioning no Ha consensus
			NA_count=$(cat "cons"/${sample}_InfA.fasta|grep NA|wc -l)
			if [[ "${NA_count}" == "0" ]]
			then
				echo -e ">NA_No_consensus/${sample}" >> "cons"/${sample}_InfA.fasta
			fi
        # if no consensus is available fasta file is created saying fasta headers mentioning no consensus
		else
			echo -e ">HA_No_consensus/${sample}" >> "cons"/${sample}_InfA.fasta
			echo -e ">NA_No_consensus/${sample}" >> "cons"/${sample}_InfA.fasta
		fi	
done < samplelist.csv