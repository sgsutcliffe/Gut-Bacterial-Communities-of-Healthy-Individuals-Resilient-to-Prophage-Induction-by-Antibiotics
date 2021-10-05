#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=post_trimmmomatic_fastqc_multiqc
#SBATCH --output=%x-%j.out

#SBATCH --time=0:30:00
#SBATCH --mem=1200MB
#SBATCH --cpus-per-task=1

module load python
module load scipy-stack
pip install multiqc

multiqc 7_PostQC_FASTQC/0_Post_Trimmomatic/DNA  -n DNA_multiqc_report.html -o 7_PostQC_FASTQC/0_Post_Trimmomatic/DNA -p

multiqc 7_PostQC_FASTQC/0_Post_Trimmomatic/Phage -n Phage_multiqc_report.html -o 7_PostQC_FASTQC/0_Post_Trimmomatic/Phage -p
