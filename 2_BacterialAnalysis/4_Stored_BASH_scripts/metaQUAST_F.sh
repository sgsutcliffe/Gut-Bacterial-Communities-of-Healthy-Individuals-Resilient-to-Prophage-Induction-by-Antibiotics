#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=metaQUAST
#SBATCH --output=%x-%j.out

#SBATCH --time=1:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4

#Individual Code
ind=F
echo "Individual ${ind}"
module load StdEnv/2020 gcc/9.3.0 quast/5.0.2
#Note CC has python 3.7 preloaded when I ran this script

#Also the location of the script is outside of the directory so I will run this
#Also metaquast is also installed within module of quast
quast=$(which metaquast.py)

#QC reads directory in relation to the script
input_directory=1_Assembled_Contigs/
#Output
output=1_Assembled_Contigs/quast_results/results_Ind${ind}

#MEGAHIT Contig lists
contigs=${input_directory}${ind}_megahit_output/Ind${ind}.contigs.fa

python3 $quast $contigs -o $output -t 4 --max-ref-num 0
