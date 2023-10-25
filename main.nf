#!/usr/bin/env nextflow

process influenza_nano {
	label "high"
	publishDir "${params.outdir}/infa",mode:"copy"
	input:
	path(fastq_input)
	output:
	path(".")
	path("cons"),emit:cons
	path("samplelist.csv"),emit:csv
	script:
	"""
	# make csvfile
	ls -1 ${fastq_input} > sample.csv
	realpath ${fastq_input}/* > paths.csv
	paste sample.csv paths.csv > samplelist.csv
	sed -i 's/	/,/g' "samplelist.csv"
	# run influennza pipeline
	influenza_consensus.sh -t 10 -s 4 -i "samplelist.csv" -o . --mode dynamic --notrim
	# move consensus for orfipy process
	mkdir cons
	while read lines;do sample=\$(echo \$lines|cut -f 1 -d ',');cp \${sample}/consensus/*.fa "cons"/\${sample}_HA.fasta;done < "samplelist.csv"
	"""
}
process orfipy {
	label "low"
	publishDir "${params.outdir}/orf",mode:"copy"
	input:
	path(cons)
	path(csv)
	output:
	path ("orfipy")
	script:
	"""
	# Uses orfipy to make consensus with ATG as a start codon
	while read lines;do sample=\$(echo \$lines|cut -f 1 -d ',');orfipy ${cons}/\${sample}_HA.fasta --dna \${sample}_HA_ORF.fasta --min 500 --outdir orfipy --start ATG;done < ${csv}
	"""
}


workflow {
	
	data=Channel
	.fromPath(params.input)
	influenza_nano(data)
	orfipy(influenza_nano.out.cons,influenza_nano.out.csv)
	
}
