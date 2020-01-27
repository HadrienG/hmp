#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

include fastp from './modules/qc' params(output: params.output)
include fastqc as fastqc_raw from './modules/qc' params(output: params.output)
include fastqc as fastqc_trim from './modules/qc' params(output: params.output)
include multiqc from './modules/qc' params(output: params.output)
include quast from './modules/qc' params(output: params.output)

include megahit from './modules/assembly' params(output: params.output)

include bowtie from './modules/binning' params(output: params.output)
include metabat from './modules/binning' params(output: params.output)


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
    fastp.out.set{trimmed_reads}

    // fastqc - pass 2
    fastqc_trim(trimmed_reads)
    fastqc_trim.out.set{fastqc_trimmed}

    // DNA assembly
    megahit(trimmed_reads)
    megahit.out.set{dna_assemblies}

    // quast
    quast(dna_assemblies)
    quast.out.set{quast_dna_assemblies}

    //binning
    dna_assemblies
        .join(trimmed_reads, by:0)
        .dump()
        .set{reads_and_assemblies}
    bowtie(reads_and_assemblies)
    bowtie.out.set{metabat_input}
    metabat(metabat_input)

    // multiqc
    fastqc_raw
        .concat(fastqc_trimmed)
        .collect()
        .dump()
        .set{fastqc_for_multiqc}
    quast_dna_assemblies
        .collect()
        .dump()
        .set{quast_dna_assemblies_for_multiqc}
    multiqc(fastqc_for_multiqc, quast_dna_assemblies_for_multiqc)
}