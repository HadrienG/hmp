// needs db to test
process gtdbtk {
    tag "bin phylogeny"
    publishDir "${params.output}/gtdb", mode: "copy"

    input:
        file(bins)
    output:
        file(gtdb)
    when:
        !params.skip_annotation
    script:
        """
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
        file("${string}")
    when:
        !params.skip_annotation
    script:
        def string = "${bin}".replaceAll(/.fa/, "")
        """
        prokka --cpus "${task.cpus}" --metagenome \
            --outdir "${string}" --prefix "${string}" "${bin}"
        """
}

process eggnog {
    tag "bin annotation"
    publishDir "${params.output}/eggnog", mode: "copy"

    input:
        file(prokka_annotation)
    output:
        file("output_eggnog")
    when:
        !params.skip_annotation
    script:
        def string = prokka_annotation
        """
        mkdir output_eggnog
        emapper.py -o "${string}" --output_dir output_eggnog -m diamond \
            -i "${prokka_annotation}/"*.faa --cpu "${task.cpus}"
        """
}
