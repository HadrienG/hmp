process kraken {
    tag "taxonomy: ${name}"
    publishDir "${params.output}/kraken", mode: "copy"
    input:
        file(kraken_database)
        tuple val(name), file(reads)
    output:
        tuple val(name), file("*.txt")
    when:
        !params.skip_taxonomy
    script:
        """
        kraken2 --db "${kraken_database}" --threads "${task.cpus}" \
            --output "${name}.txt" --report "${name}_report.txt" \
            --paired --gzip-compressed "${reads[0]}" "${reads[1]}"
        """
}


process bracken {
    tag "taxonomy: ${name}"
    publishDir "${params.output}/kraken", mode: "copy"
    input:
        file(kraken_database)
        tuple val(name), file(kraken_results)
    output:
        file("*_bracken.txt")
    when:
        !params.skip_taxonomy
    script:
        """
        bracken -d "${kraken_database}" -i "${name}_report.txt" \
            -o "${name}_bracken.txt" -r 150 -l S
        """
}