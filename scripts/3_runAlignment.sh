#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script aligns fastq against genome of reference
##using BWA, sorts and index the output

cmd_dir=${alignment_dir}/cmds
n_cores=5

seq_ids=`awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["seq_id"]) }' $manifest | awk 'NR>1' | sort | uniq`

for i in $seq_ids;
  #do rs=`awk -v var="$i" -v fastq_dir="$fastq_trimmed_dir" '$5 == var {print fastq_dir"/"$6".fastq.gz"}' $manifest | xargs`;	
  do rs=`awk -v var="$i" -v fastq_dir="$fastq_trimmed_dir" 'NR==1 { \
        for (i=1; i<=NF; i++) { \
                f[$i] = i \
        }}{ \
        if ( $(f["seq_id"]) == var ) print fastq_dir"/"$(f["seq_id_read"])".fastq.gz" \
        }' $manifest`;
  echo "mkdir -p ${alignment_dir}/${i}; $bwa mem -M $ref $rs 2> ${alignment_dir}/${i}/${i}.log | $samtools sort - | $samtools view -bS - > ${alignment_dir}/${i}/${i}.bam; $samtools index $alignment_dir/${i}/${i}.bam"
done > ${cmd_dir}/alignment.cmd 

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/alignment.cmd | parallel -j $n_cores --joblog ${cmd_dir}/runAlignment.log
fi
