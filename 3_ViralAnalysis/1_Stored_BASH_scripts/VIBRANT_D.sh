#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=VIBRANT
#SBATCH --output=%x-%j.out

#SBATCH --time=10:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=5


source ~/Tool_Box/VIBRANT/bin/activate

module load StdEnv/2020 prodigal/2.6.3 hmmer/3.2.1

ind=D

echo "Running VIBRANT on individual ${ind}"

#Location of bins
bin_location=../2_BacterialAnalysis/5_Final_bins/Ind${ind}

#Output folder
output_bin=2_Prophages/VIBRANT/Ind${ind}

#Database location (I will point to database I share with Galaxy users)

database=/project/def-corinnem/databases/vibrant-database/

#To avoid having a hundred different VIBRANT folders I will concatenate all the bins into a temporary fasta file.
cat $bin_location/Ind${ind}* >> Ind${ind}_vibrant.fa

python ~/Tool_Box/VIBRANT/VIBRANT_run.py -i Ind${ind}_vibrant.fa -t 5 -folder ${output_bin} -d ${database} -no_plot

#Remove temporary fasta file
rm Ind${ind}_vibrant.fa

