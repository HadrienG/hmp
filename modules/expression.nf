process index {
    tag "transciptome index"
    publishDir "${params.output}/salmon", mode: "copy"
    input:
        file(transcriptome_clusters)
    output:
        file("trinity_index")
    script:
        """
        salmon index -t trinity_cluster90 -i trinity_index -k 31
        """
}

process salmon {
    tag "quantification: ${name}"
    publishDir "${params.output}/salmon", mode: "copy"
    input:
        tuple val(name), file(reads)
        file(index)
    output:
        file("${name}")
    script:
        """
        salmon quant -i "${index}" -l IU -1 "${reads[0]}" -2 "${reads[1]}" \
            --validateMappings -o "${name}" -p "${task.cpus}"
        """
}