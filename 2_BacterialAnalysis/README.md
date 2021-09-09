# Bacterial Analysis

## Note
For now this process is assembling bacterial contigs that will be the scaffolds for binning as I am mostly interested in bacterial bins for prophage detection.
Decontaminated/Trimmed sequences are in 1_QC_Reads/3_Decontaminated_DNA
  
## Files

*

## Directories

*  1_Assembled_Contigs

## Scripts + Batch Jobs

## Tools Used

*  megahit v.1.2.9(https://github.com/voutcn/megahit)
### Sample naming

* [A-J]
  * A : Doxycycline
  * B : Ciprofloxacin
  * C : Control
  * D : Azithromycin
  * E : Control
  * F : Cefuroxime
  * G : Azithromycin
  * H : Ciprofloxacin
  * I : Doxycycline
  * J : Cefuroxime
* [1-6]
  * 1 : Baseline (Day -15)
  * 2 : Treatment1 (Day 3)
  * 3 : Treatment2 (Day 5)
  * 4 : Post-treatment (Day 15)
  * 5 : Post-treatment (Day 30)
  * 6 : Post-treatment (Day 90)

Note: Sample J5 does not exist for any of the samples. So there are 59 paired sequences per 'omic'

### Bacterial Assembly

Reads will be assembled per individual in the study at time points [1-6]
Individuals are [A-J]
Samples are named:
Res2_DNA_A1_paired_decontaminated.fastq.1.gz
Res2_DNA_A1_paired_decontaminated.fastq.2.gz
For Individual A time point 1

I need to iterate over 1-6 (except for individual J) then run the command on all reads for each individual. The script looks like this:

```shell
#QC reads directory in relation to the script
input_directory=../1_QCReads/3_Decontaminated_DNA/
#Output directory in relation to the script
output_directory=1_Assembled_Contigs

#Individual Code
ind=A
#Sequence list
pe1=$(for i in {1..6}; do echo " ${input_directory}Res2_DNA_${ind}${i}_paired_decontaminated.fastq.1.gz"; done)
pe2=$(for i in {1..6}; do echo " ${input_directory}Res2_DNA_${ind}${i}_paired_decontaminated.fastq.2.gz"; done)

# megahit [options] {-1 <pe1> -2 <pe2> | --12 <pe12> | -r <se>} [-o <out_dir>]

megahit -t 12 -1 ${pe1} -2 ${pe2} -o ${output_directory} -out-prefix Ind${ind} -min-contig-len 1500
```
Then I will just make a script for each individual so I can run them faster. Also, modify Individual J so that it runs {1,2,3,4,6} instead.
