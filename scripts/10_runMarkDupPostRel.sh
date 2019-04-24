#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script removes duplicates
##that could have arised from same PCR

cmd_dir=${alignment_merged_rel}/cmds
n_cores=4

sample_ids=$(awk 'NR==1 { \
	for (i=1; i<=NF; i++) { \
		f[$i] = i \
	}}{ \
	print $(f["sample_id_ref"]) \
	}' $manifest | awk 'NR>1' | sort | uniq)

for i in $sample_ids;
  do if cut -f1 ${output_dir}/relatedness/pre/self_unique.txt | grep -w $i > /dev/null; then 
    ns=`grep -w $i ${output_dir}/relatedness/pre/self_unique.txt | cut -f2 | uniq`
      lanes=$(awk -v s="$ns" -v a="$alignment_dir" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id_ref_rel"]) == s ) \
		  print "INPUT="a"/"$(f["seq_id"])"/"$(f["seq_id"])".rgmod.bam" \
          }' $manifest | sort | uniq | xargs);
       echo "
	mkdir -p ${alignment_merged_rel}/${ns}/metrics; \
	mkdir -p ${alignment_merged_rel}/${ns}/logs; \
	java -Xmx4g -jar $picard MarkDuplicates \
    	  $lanes\
	  OUTPUT=${alignment_merged_rel}/${ns}/${ns}.rgmod.rmdup.bam \
	  METRICS_FILE=${alignment_merged_rel}/${ns}/metrics/${ns}.metrics.txt \
  	  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true \
	  2> ${alignment_merged_rel}/${ns}/logs/${ns}.err 1> ${alignment_merged_rel}/${ns}/logs/${ns}.out
	"; 
  #else
    #echo "mkdir -p ${alignment_merged_rel}/${i}; ln -s ${alignment_merged}/${i}/${i}.rgmod.rmdup.recal.bam ${alignment_merged_rel}/${i}/${i}.rgmod.rmdup.bam"
  fi
done > ${cmd_dir}/markDupRel.cmd


if [ $exe = 'true' ]; then
  cat ${cmd_dir}/markDupRel.cmd | parallel -j $n_cores --joblog ${cmd_dir}/markDupRel.log
  #rm -rf $alignment_dir
fi
