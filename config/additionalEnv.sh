#!/usr/bin/env bash
#!
## setPipelineEnv.sh
## Author: Alba Sanchis alba.sanchis@uv.es
## Updated last: 24 Apr 2019
## Description: setting up additional environment


# MANUAL STEP

## Export your reference files

export ref='/path/to/hs37d5.fa'
export bed_sureselect='/path/to/sureselectxt_human_allexon_v5_utr.nochr.100pb.collapsed.bed'
export bed_nextera='/path/to/nextera_rapid--20130804.nochr.100pb.collapsed.bed'

## Export additional relative paths

export fastq_trimmed_dir=${output_dir}/fastq_trimmed
export alignment_dir=${output_dir}/alignment
export alignment_merged_rel=${output_dir}/alignment_merged_rel
export alignment_merged=${output_dir}/alignment_merged
export vcalling_dir=${output_dir}/variant_calling
export gatk_bundle=/media/scratch/ata/ref/gatk_bundle
export variant_calling_rel=${output_dir}/variant_calling_rel
export variant_recal=${output_dir}/variant_recalibration
