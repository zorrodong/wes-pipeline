#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: Read groups are replaced and libraries
##are defined for MarkDuplicates step

cmd_dir=${alignment_merged_rel}/cmds
n_cores=8

seq_ids=`cat  ${cmd_dir}/alignment_merged_rel_samples.txt`

for i in $seq_ids;
    do  b=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id_ref_rel"]) == s ) print $(f["batch"]) \
          }' $manifest | sort | uniq | xargs | tr ' ' '-');
	f=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id_ref_rel"]) == s ) print $(f["flowcell"]) \
          }' $manifest | sort | uniq | xargs | tr ' ' '-');
        l=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id_ref_rel"]) == s ) print $(f["lane"]) \
          }' $manifest | sort | uniq | xargs | tr ' ' '-');
	sr=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id_ref_rel"]) == s ) print $(f["sample_id_ref"]) \
          }' $manifest | sort | uniq | xargs | tr ' ' '-');
	echo "
	java -Xmx4g -jar $picard AddOrReplaceReadGroups \
	  INPUT=${alignment_merged_rel}/${i}/${i}.rgmod.rmdup.recal.bam \
	  OUTPUT=${alignment_merged_rel}/${i}/${i}.rgmod.rmdup.recal.rgmod.bam \
	  RGID=${i} \
	  RGPL=ILLUMINA \
	  RGLB=${sr}-${f}\
	  RGPU=${sr}-${f}-${l}\
	  RGSM=$sr \
	  RGDS=ref=1KG\;pfx=$ref\
	  RGCN=$b \
	  SORT_ORDER=coordinate \
	  CREATE_INDEX=true \
	  VALIDATION_STRINGENCY=SILENT \
	  2> ${alignment_merged_rel}/${i}/${i}.addReplaceRG.err 1> ${alignment_merged_rel}/${i}/${i}.addReplaceRG.out
	"; 
	done > ${cmd_dir}/addReplaceRG.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/addReplaceRG.cmd | parallel -j $n_cores --joblog ${cmd_dir}/addReplaceRG.log
  #rm -f ${alignment_dir}/*/*.sorted.bam
fi
