#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=post_fastq_DNA_trimmomatic
#SBATCH --output=%x-%j.out

#SBATCH --time=4:00:00
#SBATCH --mem=1500MB
#SBATCH --cpus-per-task=8

module load fastqc/0.11.9

seqfile_directory=0_Trimmed_DNA
output_directory=7_PostQC_FASTQC/0_Post_Trimmomatic/DNA

fastqc -threads 6 $seqfile_directory/*paired.fastq.gz -o ${output_directory}

