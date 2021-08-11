#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=pre_fastq_Phage
#SBATCH --output=%x-%j.out

#SBATCH --time=4:00:00
#SBATCH --mem=1500MB
#SBATCH --cpus-per-task=8

module load fastqc/0.11.9

seqfile_directory=../0_RawData/2_Phage
output_directory=6_PreQC_FASTQC/Phage

fastqc -threads 6 $seqfile_directory/* -o $output_directory


