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

process plass {
    tag "protein assembly: ${name}"
    publishDir "${params.output}/plass", mode: "copy"
    input:
        tuple val(name), file(reads)
    output:
        tuple val(name), file("${name}.fasta")
    when:
        !params.skip_protein_assembly
    script:
        """
        plass assemble --threads "${task.cpus}" --translation-table 11 \
            "${reads[0]}" "${reads[1]}" "${name}.tmp.fasta" tmp
        # rename the sequences
        awk '/^>/{print ">${name}" ++i; next}{print}' < "${name}.tmp.fasta" \
            > "${name}.fasta"
        """
}

process cdhit {
    tag "clustering: ${name}"
    publishDir "${params.output}/plass", mode: "copy"
    input:
        tuple val(name), file(protein_assembly)
    output:
        tuple val(name), file("${name}_ cluster90*")
    when:
        !params.skip_protein_assembly
    script:
        """
        cd-hit -i "${protein_assembly}" -o "${name}_cluster90" -T "${task.cpus}"
        """
}