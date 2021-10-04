#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=maxbin2
#SBATCH --output=%x-%j.out

#SBATCH --time=4:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4

#Individual
ind=G
echo "Running on Individual $ind"

module load StdEnv/2020 gcc/9.3.0 maxbin/2.2.7

#megahit contigs
megahit_contigs=1_Assembled_Contigs/${ind}_megahit_output/Ind${ind}.contigs.fa

#Output file
output=2_Bacterial_Binning/Maxbin2/Ind${ind}

#Metabat2 depth file
depth=2_Bacterial_Binning/Metabat2/Ind${ind}_metabat_bins/Ind_${ind}_depth.txt

run_MaxBin.pl -contig $megahit_contigs -out ${output} -abund ${depth} -thread 4









