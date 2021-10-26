#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=viral_assembly
#SBATCH --output=%x-%j.out

#SBATCH --time=6:00:00
#SBATCH --mem=60G
#SBATCH --cpus-per-task=32

module load StdEnv/2020 spades/3.15.1

#Individual Code
ind=G

#Note: spades does not like how I have named my fastq files
# Right now the extension is e.g. .fastq.1.gz but it only accepts .1.fastq.gz
# So I will rename them for the use of this tool

#QC reads directory in relation to the script
input_directory=../1_QCReads/5_Decontaminated_Phage/
#Output directory in relation to the script
output_directory=3_Viral_Assembly/Ind${ind}

#Rename them into temp directory for the job $SLURM_TMPDIR; tmpdir gets created at start of job and then deleted
for i in {1..6}; do zcat ${input_directory}Res2_Phage_${ind}${i}_paired_decontaminated.fastq.1.gz >> ${SLURM_TMPDIR}/Res2_Phage_${ind}_paired_decontaminated.1.fastq; done
for i in {1..6}; do zcat ${input_directory}Res2_Phage_${ind}${i}_paired_decontaminated.fastq.2.gz >> ${SLURM_TMPDIR}/Res2_Phage_${ind}_paired_decontaminated.2.fastq; done

#Sequence list
#pe1=$(for i in {1..6}; do echo -n "--pe${i}-1 ${SLURM_TMPDIR}/Res2_Phage_${ind}${i}_paired_decontaminated.1.fastq.gz "; done)
#pe2=$(for i in {1..6}; do echo -n "--pe${i}-2 ${SLURM_TMPDIR}/Res2_Phage_${ind}${i}_paired_decontaminated.2.fastq.gz "; done)

#Running the spades command

#SPAdes genome assembler v3.15.1

#Usage: spades.py [options] -o <output_dir>
spades.py -t 32 --meta -1 ${SLURM_TMPDIR}/Res2_Phage_${ind}_paired_decontaminated.1.fastq -2 ${SLURM_TMPDIR}/Res2_Phage_${ind}_paired_decontaminated.2.fastq -o ${output_directory}



