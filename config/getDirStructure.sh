#!/usr/bin/env bash
#!
## getDirStructure.sh
## Author: Alba Sanchis alba.sanchis@uv.es
## Updated last: 24 Apr 2019
## Description: get directory structure 

mkdir -p $output_dir/qc/relatedness/cmds
mkdir -p $output_dir/qc/sex/cmds
mkdir -p $output_dir/qc/fastqc/cmds
mkdir -p $output_dir/qc/read_qc_length/cmds
mkdir -p $output_dir/qc/coverage/cmds
mkdir -p $output_dir/alignment/cmds
mkdir -p $output_dir/alignment_merged/cmds
mkdir -p $output_dir/fastq_trimmed/cmds
mkdir -p $output_dir/variant_calling/cmds
mkdir -p $output_dir/annotation/cmds
mkdir -p $output_dir/relatedness/pre
mkdir -p $output_dir/relatedness/post
mkdir -p $output_dir/alignment_merged_rel/cmds
mkdir -p $output_dir/variant_calling_rel/cmds
mkdir -p $output_dir/variant_recalibration/cmds
