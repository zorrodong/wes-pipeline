#!/usr/bin/env bash
#!
## setPipelineEnv.sh
## Author: Alba Sanchis alba.sanchis@uv.es
## Updated last: 24 Apr 2019
## Description: setting up environment


# Step 1: Activate the conda environment
conda env create --force --file config/envPipeline.yml
source activate wes-pipeline

# Step 2: Register GATK
# MANUAL STEP: Download Gatk3.8-0 and move to `modules` directory
# Download from: https://software.broadinstitute.org/gatk/download/
gatk3-register modules/GenomeAnalysisTK-3.8-0.tar.bz2

# NOTE: Once this script is run once, to recreate the computational environment, simply run:
# source activate wes-pipeline

# Step 3: Export additional environment
. config/additionalEnv.sh
