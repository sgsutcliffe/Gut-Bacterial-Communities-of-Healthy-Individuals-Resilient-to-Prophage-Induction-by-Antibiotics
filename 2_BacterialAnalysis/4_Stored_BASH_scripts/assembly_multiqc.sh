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

multiqc 1_Assembled_Contigs/quast_results/results_Ind*  -n assembly_multiqc_report.html -o 1_Assembled_Contigs/quast_results/ -p


