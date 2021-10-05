# Experimental bacterial binning

## Note

As mentioned in the README of the parent directory I was curious if the coverage or depth file used in binning would be impacted by aligning reads to  
the assembled contigs of each individual per sample OR if it is better to use all reads of the all the samples of the individual.

The only difference will be in the pre-binning step with bowtie. I will generate 6 different sorted bam files. I will keep the structure the same  
as the other approach in case I need to merge them or at least so I need to do minimal modification of the scripts.

There will be less explaining here as it is just repeating the same steps.

## Scripts + Batch Jobs

*  pre_binning_bowtie2_per_sample_[A-J].sh : Same as previous coverage generating script but loops over each sample making a bam file per sample  


## Directories

*  2_Bacterial_Binning

## Prebinning

For this step I will create a for loop per individual, and make a bam file per sample.

```shell
#Label of individual involved
Ind=A
#QC reads directory in relation to the script
input_directory=../../1_QCReads/3_Decontaminated_DNA/

#For loop for each sample, note for J it is not 1..6

for i in  {1..6}

do

    #Read lists
    pe1=${input_directory}Res2_DNA_${Ind}${i}_paired_decontaminated.fastq.1.gz
    pe2=${input_directory}Res2_DNA_${Ind}${i}_paired_decontaminated.fastq.2.gz

    #Output index
    index_name=../2_Bacterial_Binning/bowtie2/Ind${Ind}/Ind${Ind}_megahit_contig_index
    
    #Output sam-file
    output_sam=2_Bacterial_Binning/bowtie2/Ind${Ind}/Ind${Ind}_${i}_megahit_contig_coverage.sam

    bowtie2 -p 8 -x ${index_name} -1 ${pe1} -2 ${pe2} -S ${output_sam}
    
    #Output bam-file
    output_bam=2_Bacterial_Binning/bowtie2/Ind${Ind}/Ind${Ind}_${i}_megahit_contig_sorted_coverage.bam


    samtools sort ${output_sam} -O bam -o ${output_bam}


done

```
