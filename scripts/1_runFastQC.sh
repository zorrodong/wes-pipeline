#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script runs fastQC for all the fastq files in the manifest


fastqc_dir=${output_dir}/qc/fastqc
cmd_dir=${fastqc_dir}/cmds
n_cores=13

fastq_fof=`awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["path"]) }' $manifest | awk 'NR>1'`

for i in $fastq_fof;
  do n=`awk -v p="$i" 'NR==1 { \
	  for (i=1; i<=NF; i++) { \
		  f[$i] = i \
	  }}{ \
	  if ( $(f["path"]) == p ) print $(f["seq_id_read"]) \
	  }' $manifest`;
  echo "mkdir -p ${fastqc_dir}/${n}; $fastqc --outdir ${fastqc_dir}/${n} $i";
done > ${cmd_dir}/fastQC.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/fastQC.cmd | parallel -j $n_cores --joblog ${cmd_dir}/fastQC.log
fi
