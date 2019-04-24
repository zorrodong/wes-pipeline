#!/usr/bin/env bash
##Author: Alba Sanchis-Juan (as2635@cam.ac.uk)
##Description: Read groups are replaced and libraries
##are defined for MarkDuplicates step

cmd_dir=${alignment_dir}/cmds
n_cores=5

seq_ids=`awk 'NR==1 {for (i=1; i<=NF; i++) {f[$i] = i}}{ print $(f["seq_id"]) }' $manifest | awk 'NR>1' | sort | uniq`

for i in $seq_ids;
    do  b=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["seq_id"]) == s ) print $(f["batch"]) \
          }' $manifest | sort | uniq);
	f=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["seq_id"]) == s ) print $(f["flowcell"]) \
          }' $manifest | sort | uniq);
        l=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["seq_id"]) == s ) print $(f["lane"]) \
          }' $manifest | sort | uniq);
	s=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["seq_id"]) == s ) print $(f["sample_id"]) \
          }' $manifest | sort | uniq);
	sr=$(awk -v s="$i" 'NR==1 { \
          for (i=1; i<=NF; i++) { \
                  f[$i] = i \
          }}{ \
          if ( $(f["seq_id"]) == s ) print $(f["sample_id_ref"]) \
          }' $manifest | sort | uniq);
	echo "
	java -Xmx4g -jar $picard AddOrReplaceReadGroups \
	  INPUT=${alignment_dir}/${i}/${i}.sorted.bam \
	  OUTPUT=${alignment_dir}/${i}/${i}.rgmod.bam \
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
	  2> ${alignment_dir}/${i}/${i}.addReplaceRG.err 1> ${alignment_dir}/${i}/${i}.addReplaceRG.out
	"; 
	done > ${cmd_dir}/addReplaceRG.cmd

if [ $exe = 'true' ]; then
  cat ${cmd_dir}/addReplaceRG.cmd | parallel -j $n_cores --joblog ${cmd_dir}/addReplaceRG.log
  #rm -f ${alignment_dir}/*/*.sorted.bam
fi
