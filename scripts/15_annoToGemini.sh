#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script performs add pass flag
##and fixes ploidy

cmd_dir=${variant_recal}/cmds

vcf_in=${variant_recal}/allSamples.snp.indel.addPASS.fixPloidy.vcf.gz


echo "

" > ${cmd_dir}/annoToGemini.cmd

if [ $exe = 'true' ]; then
  bash ${cmd_dir}/annoToGemini.cmd 2> ${cmd_dir}/annoToGemini.cmd 1> ${cmd_dir}/annoToGemini.cmd
fi
