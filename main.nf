#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

include fastp from './modules/qc' params(output: params.output)

Channel
    .fromFilePairs(params.reads)
    .dump()
    .set{read_files_for_fastp}

workflow {
    fastp(read_files_for_fastp)
    fastp.out.set {trimmed_reads}
}