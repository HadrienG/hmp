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
        file("prokka/*")
    when:
        !params.skip_annotation
    script:
        """
        string="${bin}"
        suffix=".fa"
        prokka --cpus "${task.cpus}" --metagenome \
            --outdir prokka --prefix \${string%\$suffix} "${bin}"
        """
}

process eggnog {
    tag "bin annotation"
    publishDir "${params.output}/eggnog", mode: "copy"

    input:
        file(bins)
    output:

    when:
        !params.skip_annotation
    script:
        """
        emapper.py
        """
}
