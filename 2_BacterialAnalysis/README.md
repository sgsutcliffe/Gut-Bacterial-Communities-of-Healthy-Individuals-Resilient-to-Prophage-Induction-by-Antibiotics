# Bacterial Analysis

## Note
For now this process is assembling bacterial contigs that will be the scaffolds for binning as I am mostly interested in bacterial bins for prophage detection.
Decontaminated/Trimmed sequences are in 1_QC_Reads/3_Decontaminated_DNA
  
## Files

*

## Directories

*  0_Stored_Standard_Outputs : Each script generates a standard output. To declutter I am moving them here after the step is complete.
*  1_Assembled_Contigs : Output of all the megahit assembly per individual [Once again the fasta files are too large to upload to Github]
*  2_Bacterial_Binning : Parent directory for subdirectories of each binning tool

## Scripts + Batch Jobs

*  bacterial_assembly[A-J].sh : Using megahit to assemble reads into contigs per individual 

## Tools Used

*  megahit v.1.2.9(https://github.com/voutcn/megahit)
*  metabat2 v.2.14(https://bitbucket.org/berkeleylab/metabat/src/master/)
*  bowtie2 v.2.4.2(http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)

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

Full script
```shell
module load StdEnv/2020 gcc/9.3.0 quast/5.0.2
#Note CC has python 3.7 preloaded when I ran this script

#Also the location of the script is outside of the directory so I will run this
#Also metaquast is also installed within module of quast
quast=$(which metaquast.py)

#QC reads directory in relation to the script
input_directory=1_Assembled_Contigs/

#MEGAHIT Contig lists
contigs=$(for i in {A..J}; do echo -n "${input_directory}${i}_megahit_output/Ind${i}.contigs.fa "; done)

python3 $quast $contigs -t 4
```

### 2 Binning Bacterial Assembled Contigs

I will use the approach of using multiple binners Metabat2, Maxbin2 and CONCOCT with DAS-Tool and then QC control with CheckM (combined with DAS-Tool)
Note: Binners operate using coverage maps so Bowtie2 will be generated as a preliminary step for binning

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

