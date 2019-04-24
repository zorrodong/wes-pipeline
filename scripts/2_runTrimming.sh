#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs Nextera adapter trimming

cmd_dir=${fastq_trimmed_dir}/cmds
n_cores=20

fastq_fof=`awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["path"]) }' $manifest | awk 'NR>1'`

for i in $fastq_fof;
  do n=`awk -v p="$i" 'NR==1 { \
	for (i=1; i<=NF; i++) { \
		f[$i] = i \
	}}{ \
	if ( $(f["path"]) == p ) print $(f["seq_id_read"]) \
	}' $manifest`;
  echo "$cutadapt -q 10 -a CTGTCTCTTATA -o ${fastq_trimmed_dir}/${n}.fastq.gz $i";
done > ${cmd_dir}/fastqTrimming.cmd

#CTCTTCCGATCT - truseq?
#AGATGTGTATAAGAGACAG - nextera?

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/fastqTrimming.cmd | parallel -j $n_cores --joblog ${cmd_dir}/fastqTrimming.log
fi
