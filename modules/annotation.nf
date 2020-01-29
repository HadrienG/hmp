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
        gtdbtk classify_wf --genome_dir . \
            --out_dir gtdb --cpus "${task.cpus}"
        """
}

// // needs a db to test + a separate docker
// process eggnog {
//     tag "bin annotation"
//     publishDir "${params.output}/eggnog", mode: "copy"

//     input:
//         file(bins)

//     output:

//     script:
//         """
//         """
// }