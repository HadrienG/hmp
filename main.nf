#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

include fastp from 'modules/qc'

params.output = "tests/results/"
params.reads = "tests/data/*_R{1,2}.fastq.gz"

Channel
    .fromFilePairs(params.reads)
    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}"}
    .into { read_files_for_fastqc; read_files_for_fastp }

workflow {
 fastp(read_files_for_fastp).set{fastp_output}
}