# InfluenzaNanopore

## Description
Pipeline for generating consensus sequences and typing of HA and NA fragments from Influenza A virus using sequencing data generated from Oxford Nanopore Sequencing platform 
- Consensus is generated using Jimmy Liu's InfluenzaNanopore pipeline (https://github.com/jimmyliu1326/InfluenzaNanopore)
- Consensus sequences are then typed using docker image abricate (https://github.com/tseemann/abricate) with insaflu database (https://github.com/INSaFLU/INSaFLU/)
- ORF sequences are generated using orfipy (https://github.com/urmi-21/orfipy)
- Results report is generated using rmarkdown

## Usage
```
Required arguments:

--input    Path to directory with fastq directories
--out_dir  Path to output directory
```

Example command line for pipeline execution:
```
nextflow run main.nf --input path_to_fastq_dir/ --out_dir path_to_output_folder
```

## Dependencies
* nextflow
* docker
* wsl2
## Docker images 
* orfipy (quay.io/biocontainers/orfipy:0.0.4--py310h0dbaff4_2)
* abricate with insaflu (staphb/abricate:1.0.1-insaflu-220727)
* seqkit (quay.io/biocontainers/seqkit:2.5.1--h9ee0642_0)
* rmarkdown (nanozoo/rmarkdown:2.10--7ba854a)
