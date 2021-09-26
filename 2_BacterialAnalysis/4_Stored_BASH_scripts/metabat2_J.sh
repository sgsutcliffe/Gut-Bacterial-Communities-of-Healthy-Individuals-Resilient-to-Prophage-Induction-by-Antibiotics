#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=metabat2
#SBATCH --output=%x-%j.out

#SBATCH --time=1:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4

#Individual
ind=J

module load StdEnv/2020 gcc/9.3.0 metabat/2.14

#megahit contigs
megahit_contigs=1_Assembled_Contigs/${ind}_megahit_output/Ind${ind}.contigs.fa
#sorted bam file for coverage
sorted_bam=2_Bacterial_Binning/bowtie2/Ind${ind}/Ind${ind}_megahit_contig_sorted_coverage.bam
#Output file
output=2_Bacterial_Binning/Metabat2/Ind${ind}_metabat_bins

#Step 1 make the depth file
jgi_summarize_bam_contig_depths --outputDepth ${output}/Ind_${ind}_depth.txt $sorted_bam

metabat -m 1500 -t 4 -i $megahit_contigs -a ${output}/Ind_${ind}_depth.txt -o ${output}


