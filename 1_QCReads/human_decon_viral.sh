#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=human_decon_viral
#SBATCH --output=%x-%j.out

#SBATCH --time=4:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=8

module load bowtie2/2.4.2

#Bowtie index for human genome GRCh38 is already available, see README.md
human_genome_index=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.GRCh38/genome/bowtie2_index/Homo_sapiens.GRCh38

#Trimmed reads directory in relation to the script
input_directory=2_Trimmed_Phage
#Output directory in relation to the script
output_directory=5_Decontaminated_Phage

#Each line of Phage_IDs.txt is a sample
cat Phage_IDs.txt | while read id

do

echo "Sample ${id}"

bowtie2 --un-conc-gz ${output_directory}/${id}_paired_decontaminated.fastq.gz -p 8 -q -x ${human_genome_index} -1 ${input_directory}/trimmed_${id}_1_paired.fastq.gz -2 ${input_directory}/trimmed_${id}_2_paired.fastq.gz -S ${output_directory}/${id}_decontaminated.sam

done

