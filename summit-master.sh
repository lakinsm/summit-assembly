#!/bin/bash

# purge all existing modules
module purge

# load required modules
module load jdk/1.8.0
module load singularity/2.5.2

# The directory where you want the job to run
cd /projects/$USER/meg-assembly/summit-assembly
../../nextflow run summit-assembly.nf -w /scratch/summit/lakinsm\@colostate.edu/work --output /projects/$USER/meg-assembly/project4 --reads "/scratch/summit/$USER/*_R{1,2}.fastq.gz" 


