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

process eggnog {
    tag "bin annotation"
    publishDir "${params.output}/", mode: "copy"

    input:
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
            -i "${prokka_annotation}/"*.faa --cpu "${task.cpus}"
        """
}
