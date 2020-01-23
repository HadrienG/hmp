process fastp {
    tag "trimming: $name"
    publishDir "${params.output}/fastp/", mode: "copy"

    input:
        tuple val(name), file(reads)
    output:
        tuple val(name), file("${name}_trimmed*.fastq.gz")
    script:
        """
        fastp -w ${task.cpus} -q 5 -l 50 -3 -M 5 \
            --detect_adapter_for_pe \
            -i "${reads[0]}" -I "${reads[1]}" \
            -o "${name}_trimmed_R1.fastq.gz" -O "${name}_trimmed_R2.fastq.gz"
        """
}

process fastqc {
    tag "read qc: $name"
    publishDir "${params.output}/fastqc/", mode: "copy"

    input:
        tuple val(name), file(reads)

    output:
        file "*_fastqc.{zip,html}"

    script:
        """
        fastqc -t "${task.cpus}" ${reads}
        """
}