process salmon {
    tag "quantification: ${name}"
    publishDir "${params.output}/salmon", mode: "copy"
    input:
        tuple val(name), file(reads)
        tuple file(transcriptome), file(index)
    output:
        file("${name}")
    script:
        """
        salmon quant -i index -l IU -1 "${reads[0]}" -2 "${reads[1]}" \
            --validateMappings -o "${name}" -p "${task.cpus}"
        """
}