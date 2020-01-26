process megahit {
    tag "assembly: ${name}"
    publishDir "${params.output}/", mode: "copy"

    input:
        tuple val(name), file(reads)

    output:
        tuple val(name), file("megahit/${name}.contigs.fa")

    script:
        """
        megahit -t "${task.cpus}" --k-min 27 --k-max 147 --k-step 10 \
            -1 "${reads[0]}" -2 "${reads[1]}" \
            -o megahit --out-prefix "${name}"
        """
}