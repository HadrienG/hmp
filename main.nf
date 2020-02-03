#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

params.skip_qc = false
params.skip_annotation = true
params.skip_taxonomy = true

include fastp from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastqc as fastqc_raw from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastqc as fastqc_trim from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include multiqc from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include quast from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)

include kraken from './modules/taxonomy' params(output: params.output, skip_taxonomy: params.skip_taxonomy)

include megahit from './modules/assembly' params(output: params.output)

include bowtie from './modules/binning' params(output: params.output)
include metabat from './modules/binning' params(output: params.output)
include checkm from './modules/binning' params(output: params.output)

include gtdbtk from './modules/annotation' params(output: params.output, skip_annotation: params.skip_annotation)
include prokka from './modules/annotation' params(output: params.output, skip_annotation: params.skip_annotation)
include eggnog from './modules/annotation' params(output: params.output, skip_annotation: params.skip_annotation)


Channel
    .fromFilePairs(params.reads)
    .dump()
    .set{read_files_raw}

kraken_db = file(params.kraken_db)

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
    if(params.skip_qc) {
        read_files_raw.set{trimmed_reads}
    }
    megahit(trimmed_reads)
    megahit.out.set{dna_assemblies}
    // quast
    quast(dna_assemblies)
    quast.out.set{quast_dna_assemblies}

    // taxonomy classification
    kraken(kraken_db, trimmed_reads)

    //binning
    dna_assemblies
        .join(trimmed_reads, by:0)
        .dump(tag: "reads and assemblies")
        .set{reads_and_assemblies}
    bowtie(reads_and_assemblies)
    bowtie.out.set{metabat_input}
    metabat(metabat_input)
    metabat.out.set{bins_per_sample}
    bins_per_sample
        .collect()
        .dump(tag: "bins_per_sample")
        .set{genome_bins_set}
    checkm(genome_bins_set)

    //bin phylogeny and annotation
    genome_bins_set
        .flatten()
        .dump(tag: "bins flattened")
        .set{genome_bins}
    gtdbtk(genome_bins_set)
    prokka(genome_bins)
    prokka.out.set{bin_annotations}
    eggnog(bin_annotations)

    // multiqc
    fastqc_raw
        .concat(fastqc_trimmed)
        .collect()
        .dump(tag: "fastqc_for_multiqc")
        .set{fastqc_for_multiqc}
    quast_dna_assemblies
        .collect()
        .dump(tag: "quast_for_multiqc")
        .set{quast_dna_assemblies_for_multiqc}
    multiqc(fastqc_for_multiqc, quast_dna_assemblies_for_multiqc)
}