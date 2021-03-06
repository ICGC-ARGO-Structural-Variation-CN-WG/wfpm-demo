#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC ARGO

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
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/wfpm-demo.snp-pileup'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = "outdir"  // set to empty string will disable publishDir
params.help = null

// tool specific parmas go here, add / change as needed
params.tumor_bam      = ""
params.normal_bam     = ""
params.dbsnp          = "${baseDir}/resources/dbsnp_151.common.hg38.vcf.gz"
params.q              = 15
params.Q              = 20
params.r              = '5,0'
params.d              = 1000
params.P              = 100
params.output_pattern = "*.bc.gz"  // output file name pattern



def helpMessage() {
    log.info"""

USAGE

The typical command for running the pipeline is as follows:
    nextflow run snp-pileup/main.nf --tumor_bam <tumor BAM> --normal_bam <normal BAM> --dbsnp <dbsnp vcf>

Mandatory arguments:
    --tumor_bam     Path to the tumor BAM.
    --normal_bam    Path to the normal BAM.
    --dbsnp         Path to the germline resource VCF.
                    Default is 'snp-pileup/resources/dbsnp_151.common.hg38.vcf.gz'.
                    You need to execute 'snp-pileup/scripts/fetch_resources.sh' to fetch this file before you can run this module.

Optional arguments:
    --r             Minimum tumor and normal read counts for a position, in that order. [${params.r}]
    --q             Sets the minimum threshold for mapping quality [${params.q}]
    --Q             Sets the minimum threshold for base quality [${params.Q}]
    --d             Sets the maximum depth [${params.d}]
    --P             Insert a pseudo SNP every [${params.P}] positions, with the total count at that position.
                    This is used to reduce large gaps between consecutive SNPs and still get consistent read counts across the genome.
    """.stripIndent()
}

if (params.help) exit 0, helpMessage()

log.info ""
log.info "tumor_bam=${params.tumor_bam}"
log.info "normal_bam=${params.normal_bam}"
log.info ""


// Validate inputs
if(params.tumor_bam == null) error "Missing mandatory '--tumor_bam' parameter"
if(params.normal_bam == null) error "Missing mandatory '--normal_bam' parameter"



process snpPileup {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path tumor_bam
    path normal_bam
    path dbsnp

  output:  // output, make update as needed
    path "output_dir/${params.output_pattern}", emit: output_file

  shell:
    // add and initialize variables here as needed

    '''
    mkdir -p output_dir
    
    snp-pileup -P !{params.P} -A -d !{params.d} -g -q !{params.q} -Q !{params.Q} -r !{params.r} !{dbsnp} output_dir/$(basename !{tumor_bam} .bam).bc.gz !{normal_bam} !{tumor_bam}

    '''
}


// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  snpPileup(
    file(params.tumor_bam),
    file(params.normal_bam),
    file(params.dbsnp)
  )
}
