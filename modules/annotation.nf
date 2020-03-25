// needs db to test
process gtdbtk {
    tag "bin phylogeny"
    publishDir "${params.output}/gtdb", mode: "copy"

    input:
        file(gtdbtk_db)
        file(bins)
    output:
        file(gtdb)
    when:
        !params.skip_annotation
    script:
        """
        export GTDBTK_DATA_PATH="./release89"
        gtdbtk classify_wf -x fa --genome_dir . \
            --out_dir gtdb --cpus "${task.cpus}"
        """
}

process prokka {
    tag "bin annotation"
    publishDir "${params.output}/prokka", mode: "copy"

    input:
        file(bin)
    output:
        file("prokka_*")
    when:
        !params.skip_annotation
    script:
        def string = "${bin}".replaceAll(/.fa/, "")
        """
        prokka --cpus "${task.cpus}" --metagenome \
            --outdir "prokka_${string}" --prefix "${string}" "${bin}"
        """
}

process eggnog_bins {
    tag "bin annotation"
    publishDir "${params.output}/", mode: "copy"

    input:
        file(eggnog_db)
        file(prokka_annotation)
    output:
        file("eggnog/*emapper*")
    when:
        !params.skip_annotation
    script:
        def string = prokka_annotation
        """
        mkdir eggnog
        emapper.py -o "${string}" --output_dir eggnog -m diamond \
            -i "${prokka_annotation}/"*.faa --cpu "${task.cpus}" \
            --data_dir "${eggnog_db}"
        """
}

process eggnog_proteins {
    tag "protein annotation"
    publishDir "${params.output}/plass", mode: "copy"

    input:
        file(eggnog_db)
        tuple val(name), file(proteins_clusters)
    output:
        file("*emapper*")
    when:
        !params.skip_protein_assembly
    script:
        """
        emapper.py -o "${name}" -m diamond \
            -i "${name}_cluster90" --cpu "${task.cpus}" \
            --data_dir "${eggnog_db}"
        """
}
