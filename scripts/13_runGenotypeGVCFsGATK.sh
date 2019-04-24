#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs GenotypeGVCFs
##and variant recalibaration for snps and infels - GATK 

cmd_dir=${variant_recal}/cmds
#n_cores=5

hapmap_sites=${gatk_bundle}/hapmap_3.3.b37.vcf.gz
omni_sites=${gatk_bundle}/1000G_omni2.5.b37.vcf.gz
training_1000G_sites=${gatk_bundle}/1000G_phase3_v4_20130502.sites.vcf.gz
dbSNP_129=${gatk_bundle}/dbsnp_138.b37.excluding_sites_after_129.vcf.gz
indelGoldStandardCallset=${gatk_bundle}/Mills_and_1000G_gold_standard.indels.b37.vcf.gz

vcf_fof=${variant_calling_rel}/cmds/gvcf.fof

vars=`awk '{print " --variant",$1}' $vcf_fof | xargs`

echo "
#Setp 1: Combine gVCFs
$gatk --java-options '-Xmx4g' \
   CombineGVCFs \
   -R $ref \
   $vars \
   -O ${variant_recal}/allSamples.g.vcf.gz

#Step 2: GenotypeGVCFs
$gatk --java-options '-Xmx4g' \
  GenotypeGVCFs \
  -R $ref \
  -V ${variant_recal}/allSamples.g.vcf.gz \
  -O ${variant_recal}/allSamples.vcf \
  -G StandardAnnotation -G AS_StandardAnnotation;

#Step 3: VariantRecalibrator
##SNP modeling pass
$gatk --java-options '-Xmx4g' \
  VariantRecalibrator \
  -R $ref -mode SNP \
  -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \ 
  --variant ${variant_recal}/allSamples.vcf \
  --resource hapmap,known=false,training=true,truth=true,prior=15.0:$hapmap_sites \
  --resource omni,known=false,training=true,truth=true,prior=12.0:$omni_sites \
  --resource 1000G,known=false,training=true,truth=false,prior=10.0:$training_1000G_sites \
  --resource dbsnp,known=true,training=false,truth=false,prior=2.0:$dbSNP_129 \
  --output ${variant_recal}/allSamples.snps.recal \
  --tranches-file ${variant_recal}/allSamples.snps.tranches \
  --rscript-file ${variant_recal}/allSamples.snps.R

#Step 4: Apply SNP Recalibration
$gatk --java-options '-Xmx4g' \
   ApplyVQSR \
   -R $ref \ 
   --variant ${variant_recal}/allSamples.vcf \
   --output ${variant_recal}/allSamples.snp.vcf \
   --tranches-file ${variant_recal}/allSamples.snps.tranches \ 
   --recal-file ${variant_recal}/allSamples.snps.recal \
   -mode SNP \
   -ts-filter-level 99.0

#Step 5: VariantRecalibrator
##INDEL modeling pass
$gatk --java-options '-Xmx4g' \
  VariantRecalibrator \
  -R $ref -mode INDEL \
  -an QD -an DP -an FS -an SOR -an ReadPosRankSum -an MQRankSum -an InbreedingCoeff \
  --variant ${variant_recal}/allSamples.snp.vcf \
  --resource 1000G,known=false,training=true,truth=true,prior=12.0:$indelGoldStandardCallset \
  --resource dbsnp,known=true,training=false,truth=false,prior=2.0:$dbSNP_129 \
  --max-gaussians 4 \
  --output ${variant_recal}/allSamples.indels.recal \
  --tranches-file ${variant_recal}/allSamples.indels.tranches \
  --rscript-file ${variant_recal}/allSamples.indels.R

#Step 6: Apply INDEL Recalibration
$gatk --java-options '-Xmx4g' \
   ApplyVQSR \
   -R $ref \
   --variant ${variant_recal}/allSamples.snp.vcf \
   --output ${variant_recal}/allSamples.snp.indel.vcf \
   --tranches-file ${variant_recal}/allSamples.indels.tranches \
   --recal-file ${variant_recal}/allSamples.indels.recal \
   -mode INDEL \
   -ts-filter-level 99.0

bcftools view ${variant_recal}/allSamples.snp.indel.vcf -Oz -o ${variant_recal}/allSamples.snp.indel.vcf.gz

bcftoos index ${variant_recal}/allSamples.snp.indel.vcf.gz

" > ${cmd_dir}/combineGenotypeGVRecal.cmd

if [ $exe = 'true' ]; then
  bash ${cmd_dir}/combineGenotypeGVRecal.cmd 2> ${cmd_dir}/combineGenotypeGVRecal.err 1> ${cmd_dir}/combineGenotypeGVRecal.out  
fi

