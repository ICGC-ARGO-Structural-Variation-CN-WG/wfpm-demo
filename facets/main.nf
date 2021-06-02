#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC-ARGO-Structural-Variation-CN-WG

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    Andrej Benjak
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.facets'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = default_container_registry
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir
params.publishDirMode = 'copy'
params.help = null

// tool specific parmas go here, add / change as needed
params.input_file     = ""
params.input          = null
params.snp_pileup     = null
params.genome         = 'hg38'
params.snp_nbhd       = 250
params.minNDepth      = 25
params.maxNDepth      = 1000
params.pre_cval       = 50
params.cval1          = 200
params.cval2          = 'NULL'
params.max_cval       = 5000
params.min_nhet       = 25
params.unmatched      = 'FALSE'
params.minGC          = 0
params.maxGC          = 1
params.q              = 15
params.Q              = 20
params.r              = '25,0'
params.d              = 1000
params.test           = null

def helpMessage() {
    log.info"""

USAGE

The typical command for running the pipeline is as follows:
    nextflow run facets/assets/facets-1.0.1 --input input.txt -profile cluster,singularity

Mandatory arguments:
    --input         Tab delimited file (no header), with paths to following files:
                    tumor_ID    normal_ID    tumor.bam    normal.bam    target.dbsnp

Optional arguments:
    --snp_pileup    Full path to the folder containing the snp_pileup files (you might want to use this when re-running facets)
    --summaryPrefix Prefix for the summary files [${params.summaryPrefix}]
    --q             (snp-pileup) Sets the minimum threshold for mapping quality [${params.q}]
    --Q             (snp-pileup) Sets the minimum threshold for base quality [${params.Q}]
    --r             (snp-pileup) Comma separated list of minimum read counts for a position to be output [${params.r}]
    --d             (snp-pileup) Sets the maximum depth [${params.d}]
    --genome        Genome build (b37, GRCh37, hg19, mm9, mm10, GRCm38, hg38). [${params.genome}]
    --seed          [${params.seed}]
    --snp_nbhd      Window size [${params.snp_nbhd}]
    --minNDepth     Minimum depth in normal to keep the position [${params.minNDepth}]
    --maxNDepth     Maximum depth in normal to keep the position [${params.maxNDepth}]
    --pre_cval      Pre-processing critical value [cval1 - 50]
    --cval1         Critical value for estimating diploid log Ratio [${params.cval1}]
    --cval2         Starting critical value for segmentation (increases by 25 until success) [cval1 - 50]
    --max_cval      Maximum critical value for segmentation (increases by 25 until success) [${params.max_cval}]
    --min_nhet      Minimum number of heterozygote snps in a segment used for bivariate t-statistic during clustering of segment [${params.min_nhet}]
    --unmatched     Is it unmatched? [${params.unmatched}]
    --minGC         Min GC of position [${params.minGC}]
    --maxGC         Max GC of position [${params.maxGC}]
    """.stripIndent()
}

if (params.help) exit 0, helpMessage()

log.info ""
log.info "input=${params.input}"
log.info "genome=${params.genome}"
if(params.snp_pileup != null) { log.info "snp_pileup folder provided: ${params.snp_pileup}" }
log.info ""


// Validate inputs
if(params.input == null & params.test == null) error "Missing mandatory '--input' parameter"


// Parse input parameters and create input channels
if(params.test == null) Channel.fromPath( file(params.input) )
        .splitCsv(sep:'\t')
        .map { row ->
            def tumor_id     = row[0]
            def normal_id    = row[1]
            def tumor_bam    = file(row[2], checkIfExists: true)
            def tumor_bai    = file("${row[2]}.bai", checkIfExists: true)
            def normal_bam   = file(row[3], checkIfExists: true)
            def normal_bai   = file("${row[3]}.bai", checkIfExists: true)
            def target_dbsnp = file(row[4], checkIfExists: true)
            return [ tumor_id, normal_id, tumor_bam, tumor_bai, normal_bam, normal_bai, target_dbsnp ]
        }
        .set { input_ch }

if(params.test != null) input_ch = ""

if(params.test == null) Channel.fromPath( file(params.input) )
        .splitCsv(sep:'\t')
        .map { row ->
            def tumor_id     = row[0]
            def normal_id    = row[1]
            return [ tumor_id, normal_id ]
        }
        .set { ch_id }

if(params.test != null) ch_id = ""

ch_facetsRun        = file("${baseDir}/scripts/facetsRun.R")
ch_runFacets_myplot = file("${baseDir}/scripts/runFacets_myplot.R")

if(params.snp_pileup != null) ch_pileup = file(params.snp_pileup, checkIfExists: true)
if(params.snp_pileup == null) ch_pileup = ""
if(params.test != null) ch_test = "--help"

process copy_pileup {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "facets_out/snp_pileup", mode: params.publishDirMode

  cpus 1
  memory '1 GB'
  time { (1.hour + (1.hour * task.attempt)) }

  errorStrategy 'retry'
  maxRetries 1

  input:
  set val(tumor_id), val(normal_id) from ch_id
  file(pileup) from ch_pileup

  output:
  file "*_q${params.q}_Q${params.Q}_d${params.maxNDepth}_r${params.min_nhet}.bc.gz" into copy_pileup_out
  set val(tumor_id), val(normal_id) into copy_id_ch

  when:
  params.snp_pileup != null && params.test == null

  shell:
	'''
		cp !{pileup}/!{tumor_id}__!{normal_id}__q!{params.q}_Q!{params.Q}_d!{params.maxNDepth}_r!{params.min_nhet}.bc.gz .
	'''
}

process snp_pileup {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "facets_out/snp_pileup", mode: params.publishDirMode

  cpus 1
  memory { 4.GB * task.attempt }
  time { 5.hour * task.attempt }

  errorStrategy 'retry'
  maxRetries 1

  input:
  set val(tumor_id), val(normal_id), file(tumor_bam), file(tumor_bai), file(normal_bam), file(normal_bai), file(target_dbsnp) from input_ch

  output:
  file "*_q${params.q}_Q${params.Q}_d${params.maxNDepth}_r${params.r}.bc.gz" into pileup_out
  set val(tumor_id), val(normal_id) into id_ch

  when:
  params.snp_pileup == null && params.test == null

  shell:
	'''
		snp-pileup -P 100 -A -d !{params.d} -g -q !{params.q} -Q !{params.Q} -r !{params.r} !{target_dbsnp} !{tumor_id}__!{normal_id}__q!{params.q}_Q!{params.Q}_d!{params.maxNDepth}_r!{params.r}.bc.gz !{normal_bam} !{tumor_bam}
	'''
}


process facets {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "facets_out/cval1_${params.cval1}", mode: params.publishDirMode

  cpus 2
  memory '16 GB'
  time { (2.hour * task.attempt) }

  errorStrategy 'retry'
  maxRetries 1

  input:
  file pileup from copy_pileup_out.mix(pileup_out)
  set val(tumor_id), val(normal_id) from copy_id_ch.mix(id_ch)
  file facetsRun from ch_facetsRun
  file runFacets_myplot from ch_runFacets_myplot

  output:
  file "*.Rdata" into ch_facets_rdata
  file "*.out" into ch_facets_out
  file "*.logR.pdf"
  file "*.cncf.txt" into ch_facets_cncf
  file "*.cncf.pdf"

  when:
  params.test == null


  shell:
	'''
		Rscript !{facetsRun} --minNDepth !{params.minNDepth} --maxNDepth !{params.maxNDepth} --snp_nbhd !{params.snp_nbhd} --minGC !{params.minGC} --maxGC !{params.maxGC} --cval1 !{params.cval1} --cval2 !{params.cval2} --pre_cval !{params.pre_cval} --max_cval !{params.max_cval} --genome !{params.genome} --min_nhet !{params.min_nhet} --outPrefix !{tumor_id}__!{normal_id} --tumorName !{tumor_id} --normalName !{normal_id} !{pileup}
	'''
}

process test {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "facets_out", mode: params.publishDirMode

  cpus 1
  memory '0.5 GB'
  time '1m'

  errorStrategy 'terminate'

  input:
  val(help) from ch_test

  output:
  file "test.txt"

  when:
  params.test != null

  shell:
	'''
		snp-pileup !{help} > test.txt
	'''
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  facets(
    file(params.input_file)
  )
}
