# InfluenzaNanopore

## Description
This is the nextflow version of https://github.com/jimmyliu1326/InfluenzaNanopore with few more tools added.

## Usage
```
Required arguments:

-i|--input    Path to directory with fastq directories
-o|--output   Path to output directory
```

Example command line for pipeline execution:
```
nextflow run main.nf --input path_to_fastq_dir/ -profile docker --outdir path_to_output_folder
```

## Dependencies
* nextflow
* docker
* wsl2
