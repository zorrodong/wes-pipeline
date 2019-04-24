#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: This script removes duplicates
##that could have arised from same PCR

cmd_dir=${alignment_merged}/cmds
n_cores=3

sample_ids=$(awk 'NR==1 { \
	for (i=1; i<=NF; i++) { \
		f[$i] = i \
	}}{ \
	print $(f["sample_id"]) \
	}' $manifest | awk 'NR>1' | sort | uniq)

for i in $sample_ids;
    do lanes=$(awk -v s="$i" -v a="$alignment_dir" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id"]) == s ) \
		  print "INPUT="a"/"$(f["seq_id"])"/"$(f["seq_id"])".rgmod.bam" \
          }' $manifest | sort | uniq | xargs);
	sr=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["sample_id"]) == s ) print $(f["sample_id_ref"]) \
          }' $manifest | sort | uniq);
       echo "
	mkdir -p ${alignment_merged}/${sr}/metrics; \
	mkdir -p ${alignment_merged}/${sr}/logs; \
	java -Xmx4g -jar $picard MarkDuplicates \
    	  $lanes\
	  OUTPUT=${alignment_merged}/${sr}/${sr}.rgmod.rmdup.bam \
	  METRICS_FILE=${alignment_merged}/${sr}/metrics/${sr}.metrics.txt \
  	  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true \
	  2> ${alignment_merged}/${sr}/logs/${sr}.err 1> ${alignment_merged}/${sr}/logs/${sr}.out
	"; 
	done > ${cmd_dir}/markDup.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/markDup.cmd | parallel -j $n_cores --joblog ${cmd_dir}/markDup.log
  #rm -rf $alignment_dir
fi
