#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=metaQUAST
#SBATCH --output=%x-%j.out

#SBATCH --time=12:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8

module load StdEnv/2020 gcc/9.3.0 quast/5.0.2
#Note CC has python 3.7 preloaded when I ran this script

#Also the location of the script is outside of the directory so I will run this
#Also metaquast is also installed within module of quast
quast=$(which metaquast.py)

#QC reads directory in relation to the script
input_directory=1_Assembled_Contigs/

#MEGAHIT Contig lists
contigs=$(for i in {A..J}; do echo -n "${input_directory}${i}_megahit_output/Ind${i}.contigs.fa "; done)
python3 $quast $contigs -t 8
