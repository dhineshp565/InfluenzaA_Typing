#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process influenza_nano {
	label "high"
	publishDir "${params.out_dir}/infa",mode:"copy"
	input:
	path(fastq_input)
	output:
	path(".")
	path("cons"),emit:cons
	path("samplelist.csv"),emit:csv
	val("sample"),emit:sample
	script:
	"""
	#make csv
	makecsv.sh ${fastq_input}
	# run influenza pipeline
	influenza_consensus.sh -t 8 -s 4,6 -i "samplelist.csv" -o . --mode dynamic --notrim -m r1041_e82_400bps_sup_v4.2.0	
	# move consensus for orfipy process
	prepare_consensus.sh
	"""
}
process orfipy {
	label "low"
	publishDir "${params.out_dir}/orf",mode:"copy"
	input:
	path(cons)
	path(csv)
	output:
	path ("orfipy_res")
	script:
	"""
	orfy.sh ${cons} ${csv}
	"""

}

process insaflu {
	label "low"
	publishDir "${params.out_dir}/insaflu",mode:"copy"
	input:
	path (cons)
	path (csv)
	output:
	path("typing_results"),emit:type
	path("typing_summary.csv"),emit:summary
	script:
	"""
	insaflu.sh ${cons} ${csv}
	
	"""
}

process make_report {
	label "low"
	publishDir "${params.out_dir}/",mode:"copy"
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
	cp ${cons}/*_ORF.fasta ./
	cp ${samplelist} sample.csv
	Rscript -e 'rmarkdown::render(input="rmdfile_copy.Rmd",params=list(csv="sample.csv"),output_file="InfA_report.html")'

	"""

}

process make_limsfile {
	label "low"
	publishDir "${params.out_dir}/LIMS",mode:"copy"
	input:
	path (typing_results)
	path (orf)
	path (csv)
	output:
	path("LIMS_file.csv")

	script:
	"""
	make_lims.sh ${orf} ${typing_results} ${csv}
	"""


}

workflow {
	
	data=Channel
	.fromPath(params.input)
	influenza_nano(data)
	insaflu(influenza_nano.out.cons,influenza_nano.out.csv)
	orfipy(influenza_nano.out.cons,influenza_nano.out.csv)
	rmdfile=file("${baseDir}/InfA_report.Rmd")
	make_report(rmdfile,insaflu.out.type,orfipy.out,influenza_nano.out.csv)
	make_limsfile (insaflu.out.type,orfipy.out,influenza_nano.out.csv)
}

	