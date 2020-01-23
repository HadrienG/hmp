#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

include fastp from './modules/qc' params(output: params.output)
include fastqc from './modules/qc' params(output: params.output)


Channel
    .fromFilePairs(params.reads)
    .dump()
    .set{read_files_raw}

workflow {
    // fastqc - pass 1
    fastqc(read_files_raw)
    fastqc.out.set {fastqc_raw}

    // quality and adapter trimming
    fastp(read_files_raw)
    fastp.out.set {trimmed_reads}

    // fastqc - pass 2
}