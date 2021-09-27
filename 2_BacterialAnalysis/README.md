# Bacterial Analysis

## Note
For now this process is assembling bacterial contigs that will be the scaffolds for binning as I am mostly interested in bacterial bins for prophage detection.
Decontaminated/Trimmed sequences are in 1_QC_Reads/3_Decontaminated_DNA

I have decided to do a little experiment. Initially, I had been planning on aligning all the reads of an individual to their assembled contigs for  
for bacterial binning but after talking to a colleague maybe per sample coverage file might give different bins. I will make a second bacterial binning  
folder for it 3_Experimental_bacterial_binning.
  
## Files

*

## Directories

*  0_Stored_Standard_Outputs : Each script generates a standard output. To declutter I am moving them here after the step is complete.
*  1_Assembled_Contigs : Output of all the megahit assembly per individual [Once again the fasta files are too large to upload to Github]
*  2_Bacterial_Binning : Parent directory for subdirectories of each binning tool
*  3_Experimental_bacterial_binning : This folder I will try using a different coverage approach (aligning reads per sample per individual) 
*  4_Stored_BASH_scripts : After a step is done I moved the BASH script for the job here to be more organized.

## Scripts + Batch Jobs
Finished jobs are found here in 4_Stored_BASH_scripts but should be run from this directory.

*  bacterial_assembly[A-J].sh : Using megahit to assemble reads into contigs per individual 
*  metaQUAST_[A-J].sh : QC summary of Assembly Step
*  prebinning_bowtie2_[A-J].sh : Binning relies on contig coverage I will use this to make the sorted bam files for metabat2
*  assembly_multiqc.sh : amalgamates each individuals quast results for assembly

## Tools Used

*  megahit v.1.2.9(https://github.com/voutcn/megahit)
*  metabat2 v.2.14(https://bitbucket.org/berkeleylab/metabat/src/master/)
*  bowtie2 v.2.4.2(http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
*  quast v.5.0.2(http://bioinf.spbau.ru/quast)

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

### Step 1: Bacterial Assembly

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
pe1=$(for i in {1..6}; do echo -n "${input_directory}Res2_DNA_${ind}${i}_paired_decontaminated.fastq.1.gz,"; done)
pe2=$(for i in {1..6}; do echo -n "${input_directory}Res2_DNA_${ind}${i}_paired_decontaminated.fastq.2.gz,"; done)

#Notes: megahit hates spaces and needs commas between each sample
#This is why echo -n (removes space between sample names)
#${pe1::-1} (gets rid of last comma)

# megahit [options] {-1 <pe1> -2 <pe2> | --12 <pe12> | -r <se>} [-o <out_dir>]

run=$(megahit -t 4 -1 ${pe1::-1} -2 ${pe2::-1} --out-prefix Ind${ind} --min-contig-len 1500 -o ${ind}_megahit_output)

#Couldn't get it to put output in my 1_Assembled_Contigs so I will do it myself
mv ${ind}_megahit_output ${output_directory}
```
Then I will just make a script for each individual so I can run them faster. Also, modify Individual J so that it runs {1,2,3,4,6} instead.
After running it on individual these were the stats:
Assembly is an intensive step but running with MEGAHIT (which is fast an low memory requirement) can parallelized well. Here are the stats for individual A

```shell
Cores per node: 12
CPU Utilized: 1-09:25:29
CPU Efficiency: 84.70% of 1-15:27:48 core-walltime
Job Wall-clock time: 03:17:19
Memory Utilized: 41.23 GB
Memory Efficiency: 32.99% of 125.00 GB
```
A lot of individuals lead to issues with #TIMEOUT error but memory was less of an issue so to run more efficiently I used 64GB of memory

```shell
Job ID: 13578835
Cluster: cedar
User/Group: ssutclif/ssutclif
State: COMPLETED (exit code 0)
Nodes: 1
Cores per node: 12
CPU Utilized: 1-11:53:16
CPU Efficiency: 84.18% of 1-18:37:48 core-walltime
Job Wall-clock time: 03:33:09
Memory Utilized: 41.17 GB
Memory Efficiency: 64.33% of 64.00 GB
```
### Step 1A: Quality Control on Assembled Contigs
Before binning the assembled bacterial contigs, I will run a quick QC check on them. There is not much different I could do except possibly try Spades assembly (which is slower and more memory intensive but creates slightly better genomes). 
This is not just my opinion but also published.
See [van der Walt et al. 2017](doi.org/10.1186/s12864-017-3918-9)

I will use QUAST v.5.0.2 (available on CC)
Specifically MetaQUAST, the extension for metagenomic datasets.

Notes: I am running the pre-installed version on Compute Canada. It's a python script so after loading it I ran
```shell
which quast.py
```
This gives me the location of the script. I will put this line in my script

```shell
quast=$(which metaquast.py)
```
So when I run the commands they will look slightly different than that which is on the github.
Put the output in 1_Assembled_Contigs/quast_results/results_Ind[A-J]

Note: I kept having trouble getting database option to work due to internet not working on cluster. So an option is to run it with
--max-ref-number 0
So It will still complete
Full script

Like with FastQC results, MultiQC handles QUAST results. So I will run it on all the Individuals so I can see if assembly worked well on my samples
assembly_multiqc.sh

They will be output into 1_Assembled_Contigs/quast_results/
I knew I did not want contigs shorter than 1kb so I didn't keep them but the stats look quite good for what I got.   
![assembly_stats](1_Assembled_Contigs/quast_results/quast_num_contigs-1.jpg "Here we see that each individual has about the same amount of good length contigs. I will move on with binning.")  

### 2 Binning Bacterial Assembled Contigs

I will use the approach of using multiple binners Metabat2, Maxbin2 and CONCOCT with DAS-Tool and then QC control with CheckM (combined with DAS-Tool)
Note: Binners operate using coverage maps so Bowtie2 will be generated as a preliminary step for binning
Note: I will run QC after each binner is run and on the DAS-Tool refinement

All this work will be put in parent directory 2_Bacterial_Binning/

Subdirectories for each step
2_Bacterial_Binning/bowtie2  
2_Bacterial_Binning/Metabat2  
2_Bacterial_Binning/Maxbin2  
2_Bacterial_Binning/CONCOCT  
2_Bacterial_Binning/DAS-Tool  
2_Bacterial_Binning/CheckM  


Like assembly each individual will get binning done per individual.


### 2A Binning Bacterial Assembled Contigs: Coverage mapping per contig with Bowtie2

Bowtie results will be in 2_Bacterial_Binning/bowtie2
```shell
$ mkdir 2_Bacterial_Binning/bowtie2/Ind{A..J}
```
prebinning_bowtie2_[A-J].sh
Thes scripts will 1) make an index of assembled contigs per individual 2) align reads from the individual to the assembled contigs 3) sort the sam output 4) convert sorted sam file to bam file

It looks like it worked, with most reads aligning to the contigs. For bowtie2 the standard output makes a nice summary stat, so you don't need to use another tool to get it.
```shell
$ tail -n3  prebinning_bowtie2*out
==> prebinning_bowtie2-14211848.out <==
96.68% overall alignment rate
Finished aligning Sample IndA
[bam_sort_core] merging from 181 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212017.out <==
94.43% overall alignment rate
Finished aligning Sample IndB
[bam_sort_core] merging from 177 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212019.out <==
94.86% overall alignment rate
Finished aligning Sample IndC
[bam_sort_core] merging from 159 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212059.out <==
92.62% overall alignment rate
Finished aligning Sample IndD
[bam_sort_core] merging from 170 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212064.out <==
92.33% overall alignment rate
Finished aligning Sample IndE
[bam_sort_core] merging from 170 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212068.out <==
94.25% overall alignment rate
Finished aligning Sample IndF
[bam_sort_core] merging from 184 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212071.out <==
96.13% overall alignment rate
Finished aligning Sample IndG
[bam_sort_core] merging from 180 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212073.out <==
96.19% overall alignment rate
Finished aligning Sample IndH
[bam_sort_core] merging from 204 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212074.out <==
95.55% overall alignment rate
Finished aligning Sample IndI
[bam_sort_core] merging from 182 files and 1 in-memory blocks...

==> prebinning_bowtie2-14212075.out <==
95.05% overall alignment rate
Finished aligning Sample IndJ
[bam_sort_core] merging from 138 files and 1 in-memory blocks..
```
Also I have a sorted bam file now for every sample

```shell
$ ls 2_Bacterial_Binning/bowtie2/Ind[A-J]/*bam
2_Bacterial_Binning/bowtie2/IndA/IndA_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndB/IndB_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndC/IndC_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndD/IndD_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndE/IndE_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndF/IndF_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndG/IndG_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndH/IndH_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndI/IndI_megahit_contig_sorted_coverage.bam
2_Bacterial_Binning/bowtie2/IndJ/IndJ_megahit_contig_sorted_coverage.bam
```
So now I can start binning.

### 2B Binning Bacterial Assembled Contigs: MetaBat2

Note: For this step the depth.txt file for this step is used in other binning steps.
It is jgi_summarize_bam_contig_depths <sorted_bam_file>

```shell
#Individual
ind=A

module load StdEnv/2020 gcc/9.3.0 metabat/2.14

#megahit contigs
megahit_contigs=1_Assembled_Contigs/${ind}_megahit_output/Ind${ind}.contigs.fa
#sorted bam file for coverage
sorted_bam=2_Bacterial_Binning/bowtie2/Ind${ind}/Ind${ind}_megahit_contig_sorted_coverage.bam
#Output file
output=2_Bacterial_Binning/Metabat2/Ind${ind}_metabat_bins

#Step 1 make the depth file
jgi_summarize_bam_contig_depths --outputDepth ${output}/Ind_${ind}_depth.txt $sorted_bam

metabat -m 1500 -t 4 -i $megahit_contigs -a ${output}/Ind_${ind}_depth.txt -o ${output}
```
Note: There is a mistake here the $output should have been
```shell
output=2_Bacterial_Binning/Metabat2/Ind${ind}_metabat_bins/Ind${ind}_metabat_bins
```
So it puts all the files one directory up. However this still works as each bin will still have a unique name.

### 2B Binning Bacterial Assembled Contigs: MaxBin2

Maxbin2 is loaded on Compute Canada cluster.
We will use the MetaBat2 depth file.
Example of script for Individual A:
NOTE: dont end the output with a /
e.g. out/put/path/
As this will make all files and directories hidden with . starting each file
Also a lot of files simply did not work the first time around.
Check out these files:
nano maxbin2-*outcd
To see how they broke. I'm trying it a second time.
Still files broke.
Michael suggested using it as a singularity.
I will keep trying until they all work

```shell
#Individual
ind=A
echo "Running on Individual $ind"

module load StdEnv/2020 gcc/9.3.0 maxbin/2.2.7

#megahit contigs
megahit_contigs=1_Assembled_Contigs/${ind}_megahit_output/Ind${ind}.contigs.fa

#Output file
output=2_Bacterial_Binning/Maxbin2/Ind${ind}

#Metabat2 depth file
depth=2_Bacterial_Binning/Metabat2/Ind${ind}_metabat_bins/Ind_${ind}_depth.txt

run_MaxBin.pl -contig $megahit_contigs -out ${output} -abund ${depth} -thread 4
```
As with Metabat2 I will make a batch script for each individual.

### 2B Binning Bacterial Assembled Contigs: CONCOCT
Note: I have CONCOCT installed in an env located elsewhere in my project space. I had previously used it for a different project. 

CONCOCT; like Metabat2 and Maxbin2 needs and abundance file for the contigs.
It runs more similar to Metabat2 by using the oringal bam file. Except it wants it sorted and indexed. 

I will run it using the basic usage (https://concoct.readthedocs.io/en/latest/usage.html)
You do these steps with a corresponding python script 
1. cut contigs into smaller parts  : cut_up_fasta.py
2. generate coverage table on sorted index file : concoct_coverage_table.py
3. run concoct : concoct
4. merge subcontig clustering : merge_cutup_clustering.py
5. extract bins : extract_fasta_bins.py

It's a little elaborate. Not sure why it is split up this way.
I will run each step in one bash script per individual.

I wont write this one out in full as it is too long:
CONCOCT_A.sh
