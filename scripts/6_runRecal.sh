#!/bin/bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: BAM files are recalibrated at this stage

cmd_dir=${alignment_merged}/cmds
n_cores=12

sample_ids=$(awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["sample_id_ref"]) }' $manifest | awk 'NR>1' | sort | uniq)

for i in $sample_ids; do
  	kit=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id_ref"]) == s ) \
	  print $(f["kit"])\
          }' $manifest | sort | uniq);
  	if [ $kit = "sureselect" ]; then 
	  bed=$bed_sureselect
  	elif [ $kit = "nextera" ]; then
	  bed=$bed_nextera
	fi;
	echo "
	mkdir -p ${alignment_merged}/${i}/intermediate; \
	mkdir -p ${alignment_merged}/${i}/plots; \
	$gatk --java-options '-Xmx4g' \
	  BaseRecalibrator \
	  -R $ref \
	  -I ${alignment_merged}/${i}/${i}.rgmod.rmdup.bam \
	  -known-sites ${gatk_bundle}/Mills_and_1000G_gold_standard.indels.b37.vcf.gz \
	  -known-sites ${gatk_bundle}/dbsnp_138.b37.vcf.gz \
	  -L $bed \
	  -O ${alignment_merged}/${i}/intermediate/${i}_recal_data.table \
	  2> ${alignment_merged}/${i}/logs/${i}.baseRecal.err 1> ${alignment_merged}/${i}/logs/${i}.baseRecal.out; \
	$gatk --java-options '-Xmx4g' \
	  ApplyBQSR \
	  -R $ref \
	  -I ${alignment_merged}/${i}/${i}.rgmod.rmdup.bam \
	  --bqsr-recal-file ${alignment_merged}/${i}/intermediate/${i}_recal_data.table \
	  -L $bed \
	  -O ${alignment_merged}/${i}/${i}.rgmod.rmdup.recal.bam \
	  2> ${alignment_merged}/${i}/logs/${i}.applyBaseRecal.err 1> ${alignment_merged}/${i}/logs/${i}.applyBaseRecal.out; \
	$gatk --java-options '-Xmx4g' \
          BaseRecalibrator \
          -R $ref \
          -I ${alignment_merged}/${i}/${i}.rgmod.rmdup.recal.bam \
          -known-sites ${gatk_bundle}/Mills_and_1000G_gold_standard.indels.b37.vcf.gz \
          -known-sites ${gatk_bundle}/dbsnp_138.b37.vcf.gz \
          -L $bed \
          -O ${alignment_merged}/${i}/intermediate/${i}_recal_data_post.table \
          2> ${alignment_merged}/${i}/logs/${i}.baseRecalPost.err 1> ${alignment_merged}/${i}/logs/${i}.baseRecalPost.out; \
	$gatk --java-options '-Xmx4g' \
          AnalyzeCovariates \
	  -before ${alignment_merged}/${i}/intermediate/${i}_recal_data.table \
	  -after ${alignment_merged}/${i}/intermediate/${i}_recal_data_post.table \
	  -plots ${alignment_merged}/${i}/plots/${i}_recal_plots.pdf \
	  2> ${alignment_merged}/${i}/logs/${i}.plots.err 1> ${alignment_merged}/${i}/logs/${i}.plots.out
	"; 
	done > ${cmd_dir}/recalibration.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/recalibration.cmd | parallel -j $n_cores --joblog ${cmd_dir}/recalibration.log
  #rm -f ${alignment_merged}/*/*.rmdup.ba*
fi


