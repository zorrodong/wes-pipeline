#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs the variant calling
##with GATK 

cmd_dir=${variant_calling_rel}/cmds
n_cores=10

sample_ids=`awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["sample_id_ref_rel"]) }' $manifest | awk 'NR>1' | sort | uniq`

for i in $sample_ids;
	do bam=`grep $i /media/scratch/ata/pipeline/output/20171111/variant_calling_rel/cmds/bam.fof`;
		echo "mkdir -p ${variant_calling_rel}/${i}/gatk/logs; \
		$gatk --java-options '-Xmx4g' \
			HaplotypeCaller \
			-R $ref -I $bam -O ${variant_calling_rel}/${i}/gatk/${i}.raw.snps.indels.g.vcf \
			-ERC GVCF -G StandardAnnotation -G AS_StandardAnnotation \
			2> ${variant_calling_rel}/${i}/gatk/logs/${i}_variant_calling_gvcf.err \
		       	1> ${variant_calling_rel}/${i}/gatk/logs/${i}_variant_calling_gvcf.out"
	done > ${cmd_dir}/runGVCgatk.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/runGVCgatk.cmd | parallel -j $n_cores --joblog ${cmd_dir}/runGVCgatk.log
fi
