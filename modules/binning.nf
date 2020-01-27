process bowtie {
    tag "mapping: ${name}"
    publishDir "${params.output}/bowtie", mode: "copy"

    input:
        tuple val(name), file(assembly), file(reads)

    output:
        tuple val(name), file(assembly),
              file("${name}.bam"), file("${name}.bam.bai")

    script:
        """
        bowtie2-build --threads "${task.cpus}" "${assembly}" ref
        bowtie2 -p "${task.cpus}" -x ref -1 "${reads[0]}" -2 "${reads[1]}" | \
            samtools view -@ "${task.cpus}" -bS | \
            samtools sort -@ "${task.cpus}" -o "${name}.bam"
        samtools index "${name}.bam"
        """

}


process metabat {
    tag "binning: ${name}"
    publishDir "${params.output}/metabat", mode: "copy"

    input:
        tuple val(name), file(assembly), file(mapping), file(index)

    output:
        tuple val(name), file("${name}.*.fa")

    script:
        """
        jgi_summarize_bam_contig_depths --outputDepth depth.txt "${mapping}"
        metabat2 -t "${task.cpus}" -i "${assembly}" -a depth.txt \
            -o "${name}" -m 1500
        
        # if bin folder is empty
        if ls "${name}".*.fa
            then 
                cp "${assembly}" "${name}.1.fa"
        fi
        """
}