#!/usr/bin/env nextflow
nextflow.preview.dsl = 2

include fastp from 'modules/qc'

workflow {
 fastp(ARGS).set{output}
}