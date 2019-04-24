#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs the relatedness analysis 
##with GATK 

relatedness_dir=${output_dir}/relatedness/pre
n_cores=10

if [ $exe = 'true' ]; then
 for i in ${vcalling_dir}/*/gatk/*.vcf; do 
	 echo "bgzip $i; tabix -p vcf ${i}.gz"
 done | parallel -j $n_cores --joblog ${relatedness_dir}/runRelatedness.log
 vcfs=`ls ${vcalling_dir}/*/gatk/*.vcf.gz | xargs`
 vcf-merge $vcfs | bgzip -c > ${vcalling_dir}/all.raw.snps.indels.vcf.gz
 vcftools --gzvcf ${vcalling_dir}/all.raw.snps.indels.vcf.gz --relatedness2 --out ${relatedness_dir}/all.raw.snps.indels
  awk '$1!=$2 && $7>0.35 {print $1"\t"$2}' ${relatedness_dir}/all.raw.snps.indels.relatedness2 > ${relatedness_dir}/self.txt
  Rscript snvs_indels/rmRelDup.R ${relatedness_dir}/self.txt ${relatedness_dir}/self_unique.txt
  date=`date +%Y%m%d`
  Rscript snvs_indels/fixRel.R ${relatedness_dir}/self_unique.txt \
	  $manifest \
	  ${output_dir}/data/${manifest}/manifest-${date}.txt
  rm ${output_dir}/data/${manifest}/latest
  ln -s ${output_dir}/data/${manifest}/manifest-${date}.txt ${output_dir}/data/${manifest}/latest
fi
