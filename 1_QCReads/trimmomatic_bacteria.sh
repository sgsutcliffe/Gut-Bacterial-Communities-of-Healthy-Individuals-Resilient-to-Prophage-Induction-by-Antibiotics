#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=trimmomatic_bacteria
#SBATCH --output=%x-%j.out

#SBATCH --time=10:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8

module load StdEnv/2020 trimmomatic/0.39

#Raw reads directory in relation to the script
input_directory=../0_RawData/0_DNA/
#Output directory in relation to the script
output_directory=0_Trimmed_DNA/

#Each line of Phage_IDs.txt is a sample
cat DNA_IDs.txt | while read id

do

java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 8 ${input_directory}${id}_1.fastq.gz ${input_directory}${id}_2.fastq.gz   ${output_directory}trimmed_${id}_1_paired.fastq.gz \
${output_directory}trimmed_${id}_1_unpaired.fastq.gz ${output_directory}trimmed_${id}_2_paired.fastq.gz \
${output_directory}trimmed_${id}_2_unpaired.fastq.gz \
ILLUMINACLIP:$EBROOTTRIMMOMATIC/adapters/TruSeq3-PE.fa:2:30:10:8:keepBothReads SLIDINGWINDOW:4:20 MINLEN:75

done

