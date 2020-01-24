#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

include fastp from './modules/qc' params(output: params.output)
include fastqc as fastqc_raw from './modules/qc' params(output: params.output)
include fastqc as fastqc_trim from './modules/qc' params(output: params.output)
include multiqc from './modules/qc' params(output: params.output)



Channel
    .fromFilePairs(params.reads)
    .dump()
    .set{read_files_raw}

workflow {
    // fastqc - pass 1
    fastqc_raw(read_files_raw)
    fastqc_raw.out.set {fastqc_raw}

    // quality and adapter trimming
    fastp(read_files_raw)
    fastp.out.set {trimmed_reads}

    // fastqc - pass 2
    fastqc_trim(trimmed_reads)
    fastqc_trim.out.set {fastqc_trimmed}

    // multiqc
    fastqc_raw
        .concat(fastqc_trimmed)
        .collect()
        .dump()
        .set{fastqc_for_multiqc}
    multiqc(fastqc_for_multiqc)
}