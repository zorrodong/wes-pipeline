#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs the variant calling
##with GATK 

cmd_dir=${vcalling_dir}/cmds
n_cores=10

sample_ids=`awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["sample_id_ref"]) }' $manifest | awk 'NR>1' | sort | uniq`

for i in $sample_ids;
	do echo "mkdir -p ${vcalling_dir}/${i}/gatk/logs; \
		$gatk --java-options '-Xmx4g' \
			HaplotypeCaller \
			-R $ref \
			-I ${alignment_merged}/${i}/${i}.rgmod.rmdup.recal.bam \
			-O ${vcalling_dir}/${i}/gatk/${i}.raw.snps.indels.vcf \
			2> ${vcalling_dir}/${i}/gatk/logs/${i}_variant_calling_vcf.err \
		       	1> ${vcalling_dir}/${i}/gatk/logs/${i}_variant_calling_vcf.out
		"; 
	done > ${cmd_dir}/runVCgatk.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/runVCgatk.cmd | parallel -j $n_cores --joblog ${cmd_dir}/runVCgatk.log
fi
