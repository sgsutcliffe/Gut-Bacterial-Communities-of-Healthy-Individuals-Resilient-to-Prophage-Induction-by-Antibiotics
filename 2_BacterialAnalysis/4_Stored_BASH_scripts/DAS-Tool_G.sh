#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=DAS-Tool
#SBATCH --output=%x-%j.out

#SBATCH --time=5:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=8

module --force purge
#Load dependencies
module load StdEnv/2020 gcc/9.3.0 r/4.0.2 r-bundle-bioconductor/3.12
module load pullseq/1.0.2 prodigal/2.6.3 blast+/2.11.0 diamond/2.0.4 ruby/2.7.1

#Make a DAS-Tool command
export PATH=$PATH:$HOME/LIBS/DAS_Tool
#Make Fasta_to_Scaffolds2Bin command
Fasta_to_Scaffolds2Bin=~/LIBS/DAS_Tool/src/Fasta_to_Scaffolds2Bin.sh

#Individual
ind=G
echo "Running DAS-Tool on Individual ${ind}"

#Location of the bins
metabat=2_Bacterial_Binning/Metabat2/Ind${ind}_metabat_bins
maxbin=2_Bacterial_Binning/Maxbin2/Ind${ind}
concoct=2_Bacterial_Binning/CONCOCT/Ind${ind}/concoct_output/fasta_bins/

#Contig location
megahit_contigs=1_Assembled_Contigs/${ind}_megahit_output/Ind${ind}.DAS_Tool_contigs.fa

#Output locations
default_location=2_Bacterial_Binning/DAS-Tool/default/Ind${ind}
cutoff_location=2_Bacterial_Binning/DAS-Tool/0_35/Ind${ind}

#Make the input .tsv files for each binner

$Fasta_to_Scaffolds2Bin -i ${metabat} -e fa > ${metabat}/Ind${ind}_metabat.scaffolds2bin.tsv
$Fasta_to_Scaffolds2Bin -i ${maxbin} -e fasta > ${maxbin}/Ind${ind}_maxbin.scaffolds2bin.tsv
perl -pe "s/,/\tconcoct./g;" 2_Bacterial_Binning/CONCOCT/Ind${ind}/concoct_output/clustering_merged.csv | tail -n +2 > ${concoct}/Ind${ind}_concoct.scaffolds2bin.tsv

#Run DAS-Tool on all bins with default and score threshold of 0.35

DAS_Tool --score_threshold 0.35 --write_bin_evals 1 --create_plots 1 --write_bins 1 --search_engine diamond -t 8 -i ${metabat}/Ind${ind}_metabat.scaffolds2bin.tsv,${maxbin}/Ind${ind}_maxbin.scaffolds2bin.tsv,${concoct}/Ind${ind}_concoct.scaffolds2bin.tsv -l metabat,maxbin,concoct -c ${megahit_contigs} -o ${cutoff_location}/Ind${ind}_DASTool

DAS_Tool --write_bin_evals 1 --create_plots 1 --write_bins 1 --search_engine diamond -t 8 -i ${metabat}/Ind${ind}_metabat.scaffolds2bin.tsv,${maxbin}/Ind${ind}_maxbin.scaffolds2bin.tsv,${concoct}/Ind${ind}_concoct.scaffolds2bin.tsv -l metabat,maxbin,concoct -c ${megahit_contigs} -o ${default_location}/Ind${ind}_DASTool
