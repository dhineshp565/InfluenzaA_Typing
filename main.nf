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
	val("sample"),emit:sample
	script:
	"""
	# make csvfile
	ls -1 ${fastq_input} > sample.csv
	realpath ${fastq_input}/* > paths.csv
	paste sample.csv paths.csv > samplelist.csv
	sed -i 's/	/,/g' "samplelist.csv"
	# run influenza pipeline
	influenza_consensus.sh -t 10 -s 4,6 -i "samplelist.csv" -o . --mode dynamic --notrim
	# move consensus for orfipy process
	mkdir cons
	while read lines;do sample=\$(echo \$lines|cut -f 1 -d ',');cat \${sample}/consensus/*.fa > "cons"/\${sample}_InfA.fasta;done < "samplelist.csv"
	"""
}
process orfipy {
	label "low"
	publishDir "${params.outdir}/orf",mode:"copy"
	input:
	path(cons)
	path(csv)
	output:
	path ("orfipy_res")
	script:
	"""
	# Uses orfipy to make consensus with ATG as a start codon
	while read lines
	do 
		sample=\$(echo \$lines|cut -f 1 -d ',')
		orfipy ${cons}/\${sample}_InfA.fasta --dna \${sample}_ORF.fasta --min 540 --outdir orfipy_res --start ATG
	done < ${csv}
	"""

}

process insaflu {
	label "high"
	publishDir "${params.outdir}/insaflu",mode:"copy"
	input:
	path (cons)
	path (csv)
	output:
	path("typing_results"),emit:type
	path("typing_summary.csv"),emit:summary
	script:
	"""
	mkdir typing_results
	while read lines
	do 
		sample=\$(echo \$lines|cut -f 1 -d ',')
		abricate --db insaflu -minid 70 -mincov 60 --quiet ${cons}/\${sample}_InfA.fasta > typing_results/\${sample}_insaflu_typing.csv
	done < ${csv}
	awk 'FNR==1 && NR!=1 { while (/^#F/) getline; } 1 {print}' typing_results/*typing.csv > typing_summary.csv
	
	"""
}

process make_report {
	label "high"
	publishDir "${params.outdir}/reports",mode:"copy"
	input:
	path(rmdfile)
	path(typing_results)
	path(cons)
	path(samplelist)
	
	output:
	path("InfA_report.html")

	script:

	"""
	cp ${rmdfile} rmdfile_copy.Rmd
	cp ${typing_results}/* ./
	cp ${cons}/* ./
	cp ${samplelist} sample.csv
	Rscript -e 'rmarkdown::render(input="rmdfile_copy.Rmd",params=list(csv="sample.csv"),output_file="InfA_report.html")'

	"""

}

workflow {
	
	data=Channel
	.fromPath(params.input)
	influenza_nano(data)
	insaflu(influenza_nano.out.cons,influenza_nano.out.csv)
	orfipy(influenza_nano.out.cons,influenza_nano.out.csv)
	rmdfile=file("${baseDir}/InfA_report.Rmd")
	make_report(rmdfile,insaflu.out.type,influenza_nano.out.cons,influenza_nano.out.csv)
}

	