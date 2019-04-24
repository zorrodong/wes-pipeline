#!/usr/bin/env bash
#!
## runPipeline.sh
## Author: Alba Sanchis alba.sanchis@uv.es
## Updated last: 24 Apr 2019
## Description: pipeline for variant discovery from
## whole-exome sequencing data

set -e
set -a


OPTIND=1

## Usage info
show_help() {
cat << EOF
#Usage: ${0##*/} [-hv] [-o OUTPUT_DIR] [-e ENV] [-m MANIFEST] [-p PED] [-s STEPS] 
WES pipeline
    -h            display this help and exit
    -v            verbose mode. Can be used multiple times for increased
                  verbosity.
    -o output_dir 
    -m manifest
    -p pedigree_file
    -x execute
    -s steps
EOF
}

# Initialize variables:
verbose=0
output_dir=''
exe=''

while getopts "h?vo:m:p:e:x:s:" opt; do
    case $opt in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    o)  output_dir=$OPTARG
        ;;
    m)  manifest=$OPTARG
        ;;
    p)  ped=$OPTARG
        ;;
    x)  exe=$OPTARG
	;;
    s)  IFS=, steps=($OPTARG)
	;;
    esac
done

shift $((OPTIND-1))   # Discard the options and sentinel --

#Everything that's left in "$@" is a non-option.
[ "$1" = "--" ] && shift

echo "verbose=$verbose, \
	output_dir='$output_dir', \
	manifest='$manifest', \
	ped='$ped', \
	environment='config/setEnvPipeline.sh', \
	execute='$exe', \
	steps='$(IFS=, ; echo "${steps[*]}")', \
	Leftovers: $@"

##Get directory structure
echo "Preparing directory structure"
bash setup/getDirStructure.sh 

##Load env file
echo "Loading env"
bash config/setEnvPipeline.sh

##Run fastQC for all the fastq in the manifest file
if [[ " ${steps[*]} "  =~ " 1 " ]]; then
  echo "Running fastQC"
  bash snvs_indels/1_runFastQC.sh;
  echo "FastQC done";
fi

##Run fastq trimming
if [[ " ${steps[*]} "  =~ " 2 " ]]; then
  echo "Trimming fastq files";
  bash snvs_indels/2_runTrimming.sh;
  echo "Trimming done";
fi

##Run alignment 
if [[ " ${steps[*]} "  =~ " 3 " ]]; then
  echo "Running alignment";
  bash snvs_indels/3_runAlignment.sh;
  echo "Alignment done";
fi

##Add or replace RG
if [[ " ${steps[*]} "  =~ " 4 " ]]; then
  echo "Running addOrReplaceRG";
  bash snvs_indels/4_runAddOrReplaceRG.sh;
  echo "addOrReplaceRG done";
fi

##Markdup
if [[ " ${steps[*]} "  =~ " 5 " ]]; then
  echo "Removing duplicates"
  bash snvs_indels/5_runMarkDup.sh
  echo "Remove duplicates done"
fi

##RealignRecal
if [[ " ${steps[*]} "  =~ " 6 " ]]; then
  echo "Running realignment and recalibration";
  bash snvs_indels/6_runRecal.sh;
  echo "Realignment and recalibration done";
fi

#Call SNVs/indels with GATK
if [[ " ${steps[*]} "  =~ " 7 " ]]; then
  echo "Running variant calling";
  bash snvs_indels/7_runVariantCallingGATK.sh;
  echo "Variant calling done";
fi

#Run relatedness test
if [[ " ${steps[*]} "  =~ " 8 " ]]; then
  echo "Running relatedness";
  bash snvs_indels/8_runRelatedness.sh;
  echo "Relatedness done";
fi

#Mod RGs
if [[ " ${steps[*]} "  =~ " 9 " ]]; then
  echo "Mod RG";
  bash snvs_indels/9_runAddOrReplaceRGrel.sh
  echo "Mod RG done";
fi

#Mark duplicates post relatedness analysisK
if [[ " ${steps[*]} "  =~ " 10 " ]]; then
  echo "Running mark duplicates post relatedness analysis";
  bash snvs_indels/10_runMarkDupPostRel.sh 
  echo "Mark duplicates done";
fi

#Recal bam after relatedness
if [[ " ${steps[*]} "  =~ " 11 " ]]; then
  echo "Running bam recalibration analysis";
  bash snvs_indels/11_runRecalPostRel.sh
  echo "Recalibration done";
fi

#Run gvcalling
if [[ " ${steps[*]} "  =~ " 12 " ]]; then
  echo "Running g variant calling";
  bash snvs_indels/12_runGVariantCallingGATK.sh
  echo "GVariant Calling done";
fi

#Run Genotype gatk
if [[ " ${steps[*]} "  =~ " 13 " ]]; then
  echo "Mod RG";
  bash snvs_indels/13_runGenotypeGVCFsGATK.sh
  echo "Mod RG done";
fi



##Pending - CNV analysis

##Pending - HLA typing

