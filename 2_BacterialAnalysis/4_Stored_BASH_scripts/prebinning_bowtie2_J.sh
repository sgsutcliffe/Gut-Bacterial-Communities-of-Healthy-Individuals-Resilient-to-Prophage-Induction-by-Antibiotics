#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=prebinning_bowtie2
#SBATCH --output=%x-%j.out

#SBATCH --time=12:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=12

module load bowtie2/2.4.2

#Label of individual involved
Ind=J
#QC reads directory in relation to the script
input_directory=../1_QCReads/3_Decontaminated_DNA/

#Read lists
pe1=$(for i in {1..6}; do echo -n " ${input_directory}Res2_DNA_${Ind}${i}_paired_decontaminated.fastq.1.gz,"; done)
pe2=$(for i in {1..6}; do echo -n " ${input_directory}Res2_DNA_${Ind}${i}_paired_decontaminated.fastq.2.gz,"; done)

#Megahit contigs
contigs=1_Assembled_Contigs/${Ind}_megahit_output/Ind${Ind}.contigs.fa
#Output index
index_name=2_Bacterial_Binning/bowtie2/Ind${Ind}/Ind${Ind}_megahit_contig_index
#Output sam-file
output_sam=2_Bacterial_Binning/bowtie2/Ind${Ind}/Ind${Ind}_megahit_contig_coverage.sam
output_bam=2_Bacterial_Binning/bowtie2/Ind${Ind}/Ind${Ind}_megahit_contig_sorted_coverage.bam
#Make bowtie2 index for contigs

bowtie2-build -f $contigs $index_name

echo "Index made for Ind ${Ind}"

#Align QC reads used in megahit assembly to measure coverage

bowtie2 -p 12 -x ${index_name} -1 ${pe1} -2 ${pe2} -S ${output_sam}

echo "Finished aligning Sample Ind${Ind}"

#metabat2 requires a sorted bam file

module --force purge
module load StdEnv/2020 samtools/1.12

samtools sort ${output_sam} -O bam -o ${output_bam}

