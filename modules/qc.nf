process fastp {
    tag "trimming: $name"
    publishDir "${params.output}/fastp/", mode: "copy"

    input:
        tuple val(name), file(reads)
    output:
        tuple val(name), file("${name}_trimmed*.fastq.gz")
    when:
        !params.skip_qc
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
    when:
        !params.skip_qc
    script:
        """
        fastqc -t "${task.cpus}" ${reads}
        """
}

process quast {
    tag "assembly qc: $name"
    publishDir "${params.output}/quast/", mode: "copy"

    input:
        tuple val(name), file(assembly)
    output:
        file("${name}/")
    when:
        !params.skip_qc
    script:
        """
        metaquast.py --threads "${task.cpus}" \
            --rna-finding --max-ref-number 0 -l "${name}" -o "${name}" \
            "${assembly}"
        """
}

process multiqc {
    tag "multiqc"
    publishDir "${params.output}/", mode: "copy"

    input:
        file (fastqc_reports)
        file (quast_reports)
    output:
        file "*multiqc_report.html"
    when:
        !params.skip_qc
    script:
        """
        multiqc .
        """
}