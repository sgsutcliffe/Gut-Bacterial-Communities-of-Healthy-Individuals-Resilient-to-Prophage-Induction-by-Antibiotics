#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=bacterial_assembly
#SBATCH --output=%x-%j.out

#SBATCH --time=7:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=12

module load StdEnv/2020 megahit/1.2.9

#QC reads directory in relation to the script
input_directory=../1_QCReads/3_Decontaminated_DNA/
#Output directory in relation to the script
output_directory=1_Assembled_Contigs

#Individual Code
ind=B
#Sequence list
pe1=$(for i in {1..6}; do echo -n "${input_directory}Res2_DNA_${ind}${i}_paired_decontaminated.fastq.1.gz,"; done)
pe2=$(for i in {1..6}; do echo -n "${input_directory}Res2_DNA_${ind}${i}_paired_decontaminated.fastq.2.gz,"; done)
#Notes: megahit hates spaces and needs commas between each sample

# megahit [options] {-1 <pe1> -2 <pe2> | --12 <pe12> | -r <se>} [-o <out_dir>]

run=$(megahit -t 12 -1 ${pe1::-1} -2 ${pe2::-1} --out-prefix Ind${ind} --min-contig-len 1500 -o ${ind}_megahit_output)




#Couldn't get it to put output in my 1_Assembled_Contigs so I will do it myself
mv ${ind}_megahit_output ${output_directory}
