#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs add pass flag
##and fixes ploidy

cmd_dir=${variant_recal}/cmds

vcf_in=${variant_recal}/allSamples.snp.indel.vcf
vcf_out1=${variant_recal}/allSamples.snp.indel.addPASS.vcf.gz
vcf_out2=${variant_recal}/allSamples.snp.indel.addPASS.fixPloidy.vcf.gz
genders=PENDING!!!

echo "

bcftools annotate -x FILTER -Ou $vcf_in | bcftools +fill-AN-AC | bcftools filter -e 'AN<(1*N_SAMPLES)' -s 'LOWCALL' -m + | bcftools filter -e 'PF==0' -s 'LOWPF' -m + -Oz > $vcf_out1;

bcftools index $vcf_out1;

bcftools +fixploidy $vcf_out1 -- -s $genders | bcftools view - -Oz -o $vcf_out2

" > ${cmd_dir}/addPASSfixPloidy.cmd

if [ $exe = 'true' ]; then
  bash ${cmd_dir}/addPASSfixPloidy.cmd 2> ${cmd_dir}/addPASSfixPloidy.cmd 1> ${cmd_dir}/addPASSfixPloidy.cmd
fi
