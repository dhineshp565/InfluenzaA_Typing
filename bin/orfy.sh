#!/usr/bin/env bash


# Uses orfipy to make consensus with ATG as a start codon
# $1 -cons folder containing consensus from influenza_nano process
# $2 -csv file with samplename and location from influenza_nano process

while read lines
do 
		sample=$(echo $lines|cut -f 1 -d ',')
        #using orfipy extract orf from consensus generated in influenza nano process with ATG as start codon with a minim length of 400 in nucleotide format
		orfipy $1/${sample}_InfA.fasta --dna ${sample}_ORF.fasta --min 400 --outdir orfipy_res --start ATG
        #if no ORF sequence found - create a orf file with no consensus headers
		if [ $(wc -l < orfipy_res/"${sample}_ORF.fasta") == "0" ]
		then 
			echo -e ">HA_No_consensus/${sample}_ORF" >> orfipy_res/${sample}_ORF.fasta
			echo -e ">NA_No_consensus/${sample}_ORF" >> orfipy_res/${sample}_ORF.fasta
		
		
		else
        #remove traling characters from default orfipy sequence headers
			sed -i '/>/ s/ORF.1.*/ORF/g' orfipy_res/${sample}_ORF.fasta
        # count HA and NA in the ORF file
			HA_count=$(cat "orfipy_res"/${sample}_ORF.fasta|grep HA|wc -l)
			NA_count=$(cat "orfipy_res"/${sample}_ORF.fasta|grep NA|wc -l)
        # add no consensus sequence header if HA count is 0
			if [[ "${HA_count}" == "0" ]]
			then
				echo -e ">HA_No_consensus/${sample}_ORF" >> "orfipy_res"/${sample}_ORF.fasta
			fi
        # add no consensus sequence header if NA count is 0
			if [[ "${NA_count}" == "0" ]]
			then
				echo -e ">NA_No_consensus/${sample}_ORF" >> "orfipy_res"/${sample}_ORF.fasta
			fi

		fi
done < $2