#!/usr/bin/env bash
# generates a file for importing typing results and ORF sequences into LIMS (casebook)
# $1= dir containg orf sequences (orfipy)
# $2= dir containing insaflu typing results (insaflu)
# $3= csvfile with sample name and data location (makecsv)

mkdir normalised_orf
while read lines
	do 
		sample=$(echo $lines|cut -f 1 -d ',')
		seqkit seq -w 100 $1/${sample}_ORF.fasta > normalised_orf/${sample}_ORF.fasta
		seqkit fx2tab $1/${sample}_ORF.fasta > ${sample}_ORF.csv
		sed -i '1i SEQ HEADER\tSEQUENCE' ${sample}_ORF.csv
		paste $2/${sample}_insaflu_typing.csv ${sample}_ORF.csv > ${sample}_LIMS.csv
done < $3
	
awk 'FNR==1 && NR!=1 { while (/^#F/) getline; } 1 {print}' *LIMS.csv > InfA_LIMS_file.csv