#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=CONCOCT
#SBATCH --output=%x-%j.out

#SBATCH --time=8:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=8

#Individual
ind=H
echo "Running on Individual $ind"
output=2_Bacterial_Binning/CONCOCT/Ind${ind}

#Tools for indexing bam files
module load samtools/1.12
#Dependencies for CONCOCT
module add python gsl
#Load local install of CONCOCT
source /home/ssutclif/projects/def-corinnem/ssutclif/temp_storage/collab_project_storage/binning/third_round/CONCOCT/concoct_env/bin/activate

#Make an index of the sorted bam files
bam_file=2_Bacterial_Binning/bowtie2/Ind${ind}/Ind${ind}_megahit_contig_sorted_coverage.bam

samtools index $bam_file -@ 8

echo "Completed indexing bam file"

#Cut contigs into smaller parts
megahit_contigs=1_Assembled_Contigs/${ind}_megahit_output/Ind${ind}.contigs.fa

cut_up_fasta.py ${megahit_contigs} -c 10000 -o 0 --merge_last -b ${output}/Ind${ind}_contigs_10K.bed > ${output}/Ind${ind}_contigs_10K.fa

#Using their suggested defaults
echo "Completed the cutting of contigs"

#Generate table with coverage depth information per sample per subcontig

concoct_coverage_table.py ${output}/Ind${ind}_contigs_10K.bed ${bam_file} > ${output}/Ind${ind}_coverage_table.tsv

echo "Completed coverage table step"

#Run concoct

concoct --composition_file ${output}/Ind${ind}_contigs_10K.fa --coverage_file ${output}/Ind${ind}_coverage_table.tsv -b ${output}/concoct_output/ -t 8

echo "Completed CONCOCT"

#Merge subcontig clustering into orginal contig clustering:

merge_cutup_clustering.py ${output}/concoct_output/clustering_gt1000.csv > ${output}/concoct_output/clustering_merged.csv

echo "Completed merge"

#Extract bins as individual FASTA

mkdir ${output}/concoct_output/fasta_bins
extract_fasta_bins.py ${megahit_contigs} ${output}/concoct_output/clustering_merged.csv --output_path ${output}/concoct_output/fasta_bins



