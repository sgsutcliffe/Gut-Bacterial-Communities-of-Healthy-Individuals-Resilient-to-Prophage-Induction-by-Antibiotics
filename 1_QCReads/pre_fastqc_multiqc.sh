#!/bin/sh

#SBATCH --mail-user=steven.sutcliffe@mail.mcgill.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=REQUEUE
#SBATCH --mail-type=ALL
#SBATCH --job-name=pre_fastqc_multiqc
#SBATCH --output=%x-%j.out

#SBATCH --time=4:00:00
#SBATCH --mem=1500MB
#SBATCH --cpus-per-task=8

module load python
module load scipy-stack
pip install multiqc

multiqc 6_PreQC_FASTQC/DNA/ -n DNA_multiqc_report.html -o 6_PreQC_FASTQC/DNA/

multiqc 6_PreQC_FASTQC/RNA/ -n RNA_multiqc_report.html -o 6_PreQC_FASTQC/RNA/

multiqc 6_PreQC_FASTQC/Phage/ -n Phage_multiqc_report.html -o 6_PreQC_FASTQC/Phage/
