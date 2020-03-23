#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

params.skip_qc = false
params.skip_annotation = true
params.skip_taxonomy = true
params.skip_protein_assembly = true

include fastp as fastp_dna from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastp as fastp_rna from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastqc as fastqc_dna_raw from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastqc as fastqc_dna_trim from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastqc as fastqc_rna_raw from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include fastqc as fastqc_rna_trim from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include multiqc from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)
include quast from './modules/qc' params(output: params.output, skip_qc: params.skip_qc)

include kraken from './modules/taxonomy' params(output: params.output, skip_taxonomy: params.skip_taxonomy)
include bracken from './modules/taxonomy' params(output: params.output, skip_taxonomy: params.skip_taxonomy)

include megahit from './modules/assembly' params(output: params.output)
include trinity from './modules/assembly' params(output: params.output)
include plass from './modules/assembly' params(output: params.output, skip_protein_assembly: params.skip_protein_assembly)
include cdhit from './modules/assembly' params(output: params.output, skip_protein_assembly: params.skip_protein_assembly)

include bowtie from './modules/binning' params(output: params.output)
include metabat from './modules/binning' params(output: params.output)
include checkm from './modules/binning' params(output: params.output)

include gtdbtk from './modules/annotation' params(output: params.output, skip_annotation: params.skip_annotation)
include prokka from './modules/annotation' params(output: params.output, skip_annotation: params.skip_annotation)
include eggnog_bins from './modules/annotation' params(output: params.output, skip_annotation: params.skip_annotation)
include eggnog_proteins from './modules/annotation' params(output: params.output, skip_protein_assembly: params.skip_protein_assembly)


Channel
    .fromFilePairs(params.dna_reads)
    .dump()
    .set{read_files_dna_raw}

Channel
    .fromFilePairs(params.rna_reads)
    .dump()
    .set{read_files_rna_raw}

kraken_db = file(params.kraken_db)

workflow {
    // fastqc - pass 1
    fastqc_dna_raw(read_files_dna_raw)
    fastqc_dna_raw.out.set{fastqc_dna_raw}
    fastqc_rna_raw(read_files_rna_raw)
    fastqc_rna_raw.out.set{fastqc_rna_raw}
    // quality and adapter trimming
    fastp_dna(read_files_dna_raw)
    fastp_dna.out.set{trimmed_dna_reads}
    fastp_rna(read_files_rna_raw)
    fastp_rna.out.set{trimmed_rna_reads}
    // fastqc - pass 2
    fastqc_dna_trim(trimmed_dna_reads)
    fastqc_dna_trim.out.set{fastqc_dna_trimmed}
    fastqc_rna_trim(trimmed_rna_reads)
    fastqc_rna_trim.out.set{fastqc_rna_trimmed}

    // DNA assembly
    if(params.skip_qc) {
        read_files_dna_raw.set{trimmed_dna_reads}
        read_files_rna_raw.set{trimmed_rna_reads}
    }
    megahit(trimmed_dna_reads)
    megahit.out.set{dna_assemblies}
    // quast
    quast(dna_assemblies)
    quast.out.set{quast_dna_assemblies}

    // taxonomy classification
    kraken(kraken_db, trimmed_dna_reads)
    kraken.out.set{taxonomy_reports}
    bracken(kraken_db, taxonomy_reports)

    // protein assembly
    plass(trimmed_dna_reads)
    plass.out.set{protein_assemblies}
    cdhit(protein_assemblies)
    cdhit.out.set{clusters}
    eggnog_proteins(clusters)

    // RNA assembly
    trimmed_rna_reads
        .collect()
        .flatten()
        .toList()
        .dump(tag: "reads for trinity")
        .set{reads_for_trinity}
    trinity(reads_for_trinity, file(params.rna_manifest))

    //binning
    dna_assemblies
        .join(trimmed_dna_reads, by:0)
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
    eggnog_bins(bin_annotations)

    // multiqc
    fastqc_dna_raw
        // .concat(fastqc_dna_trimmed, fastqc_rna_raw, fastqc_rna_trimmed)
        .concat(fastqc_dna_trimmed)
        .collect()
        .dump(tag: "fastqc_for_multiqc")
        .set{fastqc_for_multiqc}
    quast_dna_assemblies
        .collect()
        .dump(tag: "quast_for_multiqc")
        .set{quast_dna_assemblies_for_multiqc}
    multiqc(fastqc_for_multiqc, quast_dna_assemblies_for_multiqc)
}