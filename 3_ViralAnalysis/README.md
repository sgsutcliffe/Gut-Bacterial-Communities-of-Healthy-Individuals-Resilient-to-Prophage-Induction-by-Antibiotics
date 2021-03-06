# Viral Analysis

## Notes

I will include the prophage-finding work here as part of the viral analysis.
Bacterial bins were made for each individual (including data from all time points)
In the past, I used multiple prophage tools to detect prophages from MAGs. Talking with Simon Roux he mentioned that viral contigs are not reliably binned, and can sometimes lead to misleading prophage detection.
See (https://www.nature.com/articles/s41587-020-0718-6; supplementary section :Benchmarking host-prediction methods for more info). So I will begin with relying on VIBRANTs fragment category.

My intial process of QC of viral contigs didn't work. So this README.md is in progress. I will clean it up when I finish the QC so that I am satisfied with the outcome.

## Files
*  VIBRANT_requirements.txt : This the output of Python dependencies I used for running VIBRANT.
*  propagAte_requirements.txt : Output of python dependencies for propagAte

## Directories

*  0_Stored_Standard_Outputs : Each script generates a standard output. To declutter I am moving them here after the step is complete.
*  1_Stored_BASH_scripts : After a step is done I moved the BASH script for the job here to be more organized.
*  2_Prophages : Storage of VIBRANT prophages detected
*  3_Viral_Assembly : Outputs of metaSpades assemblies for both Pooled or Seperate
*  4_QC_Viral_Contigs : I will store output of Galaxy loaded tools here (for future comparison)

## Scripts + Batch Jobs

*  VIBRANT_{A..J}.sh : Running VIBRANT on bacterial bins
*  propagate_{A..J}.sh : Running propagAte on prophages detected from VIBRANT
*  viral_assembly_{A..J}.sh : This the 'Pooled' assembly I did first with metaSpades
*  viral_seperate_assembly_{A..J}.sh : This the 'Seperate' assembly I did second.
*  blastn_5kb_viral_contigs_vs_GVD_{A..J}.sh : BLASTn against GVD to find shortest contig with 80% overlap
*  viral_QC_on_pooled_5kb_{A..J}.sh : Aligns viral reads to the 5kb or greater contigs, to see how much viral reads align before selecting phage contigs
*  viral_QC_on_pooled_{A..J}.sh : This gives me my pre-QC viral read alignment on pooled assembly.  
*  prodigal_ORF_prediction_{A..J}.sh : This predicts protein-coding genes on my viral contigs for searching against HMM profiles  
*  HMMSearch_pVOG_{A..J}.sh : This searches my ORFs against PVOG HMM profiles
*  pvog_summary_script.sh : Collects the contigs that have 3 or more PVOG matches, and makes a contig list
*  bamtool_converted_samtools.sh : This makes a human readable summary of alignment from final step for analysis
*  bacphlip_{A..J}.sh : runs bacphlip to predict temperate/lytic replication style on checkv contigs

## Tools Used

*  VIBRANT v1.2.1(https://github.com/AnantharamanLab/VIBRANT) (see notes on install)
*  PropagAte v1.0.0(https://github.com/AnantharamanLab/PropagAtE)
*  Spades v.3.15.1(https://github.com/ablab/spades)
*  CD-HIT-EST (Galaxy Version 1.2) (http://weizhong-lab.ucsd.edu/cd-hit/)
*  VIRSorter (Galaxy Version 1.0.6)
*  blast+ v2.12.0 (https://blast.ncbi.nlm.nih.gov/)
*  prodigal v2.6.3 (https://github.com/hyattpd/Prodigal)
*  HMMER v3.2.1 (http://hmmer.org/)
*  CheckV Galaxy (Version 0.7.0)
*  Samtools v.1.12 (using htslib 1.12) (http://www.htslib.org/)
*  BACPHLIP v.0.9.6 (https://github.com/adamhockenberry/bacphlip)

### Sample Naming

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

### Step 1A: Prophage Detection : VIBRANT

My previous work has shown that using multiple tools to detect prophages. For now I will focus on VIBRANT as it is developed by the same person who developed PropagAte, the tool I plan to use for determining active prophages. In addition, there is a section for prophages that have flanking host sequence. So they would be properly binnned according to Simon Roux.

I also had issues with my install of VIBRANT, so here is what I use for Python dependencies. Most are available on CC pre-installed wheels.
```shell
$ pip freeze --local
appdirs==1.4.3
biopython==1.79+computecanada
click==8.0.1+computecanada
colorama==0.4.4+computecanada
coloredlogs==15.0.1+computecanada
colormath==3.0.0+computecanada
commonmark==0.9.1+computecanada
cycler==0.10.0+computecanada
Cython==0.29.24+computecanada
distlib==0.3.0
filelock==3.0.12
future==0.18.2+computecanada
humanfriendly==9.2+computecanada
joblib==1.0.1+computecanada
kiwisolver==1.3.1+computecanada
lzstring==1.0.4+computecanada
Markdown==3.3.4+computecanada
matplotlib==3.4.2+computecanada
more-itertools==8.2.0
multiqc==1.11+computecanada
networkx==2.6.2+computecanada
numpy==1.21.0+computecanada
pandas==1.3.0+computecanada
Pillow==8.3.1+computecanada
pyfasta==0.5.2
pyparsing==2.4.7
python-dateutil==2.8.2+computecanada
pytz==2021.3+computecanada
PyYAML==5.4.1+computecanada
rich==10.7.0+computecanada
scikit-learn==0.21.3
scipy==1.7.1+computecanada
seaborn==0.11.2+computecanada
setuptools-scm==3.5.0
simplejson==3.17.3+computecanada
six==1.14.0
spectra==0.0.11+computecanada
threadpoolctl==3.0.0+computecanada
virtualenv==20.0.18
```
I put this list into a file VIBRANT_requirements.txt
I will run on VIBRANT on each bin assembled per individual

I know that VIBRANT makes a lot of files per run. All I want is A) fasta files of prophages B) location of prophages on scaffolds
Because I have labelled each scaffold with a bin ID and Individual ID I can always use that to reconnect them.

The coordinate files with prophages that have flanking regions is found here:
```shell
2_Prophages/VIBRANT/Ind{A..J}/VIBRANT_Ind{A..J}_vibrant/VIBRANT_results_Ind{A..J}_vibrant/VIBRANT_integrated_prophage_coordinates_Ind{A..J}_vibrant.tsv
```
This the file used to run PropagAte.
Similar to VIBRANT propagAte need specific python modules to run, so I will put them in a file as well
```shell
 pip freeze --local > propagAte_requirements.txt
```
The phage genomes in fasta format are located here
```shell
2_Prophages/VIBRANT/Ind{A..J}/VIBRANT_Ind{A..J}_vibrant/VIBRANT_Ind{A..J}_vibrant/VIBRANT_phages_Ind{A..J}_vibrant/Ind{A..J}_vibrant.phages_lysogenic.fna
```

I ran with default settings.

### Step 2: PropagAte - determine which prophages are active


I will run it with -sb input because we have sorted bam files for each day.
(this is bacterial reads aligned to the bins) see bacterial section.

This will run for each sorted bacterial bam file per day (6 times) so the script might take a while. I'm running it on -clean mode so that it deletes all the temporary files generated.

propagate_{A..J}.sh

```shell
source ~/Tool_Box/propagAtE/bin/activate
module load StdEnv/2020
module load bowtie2/2.4.1 samtools/1.11 scipy-stack

#Label of individual involved
ind=A

#Python script for propagate
propagate=~/Tool_Box/propagAtE/PropagAtE/PropagAtE_run.py

#Prophage coordinate file (I'm using the default one generated by VIBRANT)
prophage_coordinates=2_Prophages/VIBRANT/Ind${ind}/VIBRANT_Ind${ind}_vibrant/VIBRANT_results_Ind${ind}_vibrant/VIBRANT_integrated_prophage_coordinates_Ind${ind}_vibrant.tsv

#Output folder for each day
output_folder=2_Prophages/PropagAte/Ind${ind}

#Run propahate 6 times, once per sampling day, to see when active prophages appear
for i in {1..6}

do

#Sorted bam file for input for each day
output_bam=../2_BacterialAnalysis/7_Relative_Abundance/bowtie2/Ind${ind}/Ind${ind}_${i}_bin_sorted_coverage.bam


python3 $propagate -sb ${output_bam} -v ${prophage_coordinates} -t 4 -o ${output_folder}/Ind${ind}_${i}_propagate_result.tsv -i day_${i} -clean


done
```
The results are stored in 
2_Prophages/PropagAte/Ind{A..J}/Ind{A..J}_2_propagate_result.tsv

However, when I look at 'active prophages' I see only a few 1-11 ish. This number is very low considering we have 55-177 bins per individual.  

PropagAte also outputs the sorted bam file the tool produces (even in clean mode). So I will delete these, as well as the .log file which is just a summary. The results are stored in a .tsv file.

```shell
for i in {A..J}; do rm 2_Prophages/PropagAte/Ind${i}/Ind${i}_*_bin_sorted_coverage.gap-1_mm-3.sorted.bam; done
for i in {A..J}; do rm 2_Prophages/PropagAte/Ind${i}/Ind${i}_*_propagate_result.log; done
```
I'm also going to move these results to a new sub-directory of PropagAte named "VIBRANT-fragements" - this just means it is the VIBRANT results with fragments.

```shell
mkdir 2_Prophages/PropagAte/VIBRANT-fragments
mv 2_Prophages/PropagAte/Ind{A..J} 2_Prophages/PropagAte/VIBRANT-fragments
```
I will upload these onto Github account.
Note Propagate uses the cutoffs (default)
Cohen d test: 0.75 
Minimum prophage:host coverage ratio: 1.65
Mann-Whitney statistical test: 0.05

I don't know if these cut-offs are hard rule. I think passing all three is pretty strict cut-off. When I modified the script I didn't use Cohen d test (as it broke).
I recommend looking at these outputs manually. To see where these statitistics lead to prophages being called non-active. So far I operate under the impression these are pretty conservative.

For example Individual A:
```shell
$ grep -c 'yes' 2_Prophages/PropagAte/VIBRANT-fragments/IndA/*.tsv
2_Prophages/PropagAte/VIBRANT-fragments/IndA/IndA_1_propagate_result.tsv:2
2_Prophages/PropagAte/VIBRANT-fragments/IndA/IndA_2_propagate_result.tsv:1
2_Prophages/PropagAte/VIBRANT-fragments/IndA/IndA_3_propagate_result.tsv:1
2_Prophages/PropagAte/VIBRANT-fragments/IndA/IndA_4_propagate_result.tsv:1
2_Prophages/PropagAte/VIBRANT-fragments/IndA/IndA_5_propagate_result.tsv:0
2_Prophages/PropagAte/VIBRANT-fragments/IndA/IndA_6_propagate_result.tsv:0
```
So for individual A at time point there is only 2 active prophages out of 56 prophages.
They have MW pvalue: of 4.87E-23 and 6.27E-24, CohenD 0.8 and 0.77, and prophage-host ratio of 1.66 and 1.7
46 of 56 have pvalue < 0.05
4 of 56 have dtest > 0.75
2 of 56 have mean coverage > 1.65

So it looks like mean coverage is the big limiting factor. 31 of 57 increased in coverage. If I drop the cut-off down to 1.3 it would be 10 of 57 active prophages.

Timepoint 2:
1 out of 56
31 of of 56 have pvlaue < 0.05
4 of 56 have dtest > 0.75
5 of 56 have mean cov > 1.65 ; 13 > 1.3 and 25 > 1.0

Timepoint 3:
1 out of 56
24 of 56; p value
3 of 56; d value
4 of 56; cov> 1.65 ; 6 > 1.3 ; 23 > 1

Timepoint 4:
25 of 56; pvalue
5 of 57; dtest
2 of 56; cov > 1.65; 8 > 1.3; 29 > 1

Timepoint 5:
31 of of 56; pvalue
4 of 56; dtest
1 of 56 > cov1.65; 9 > 1.3; 28 > 1

So, as I had suspected Cohen D-test really cuts the number of active prophages down. I also think if coverage increased and is significantly more (pvalue) than that should be enough  
So I will try presenting a loose-cut off comparison.
So cov > 1 and pvalue < 0.05 (my rational is weak but I am curious to see if patterns change). I will do this in R as it'll be faster.

Note: I made a directory called "Reduced_Cutoff"
```r
for (i in LETTERS[1:9]){
  for (n in 1:6){
  ind = (paste("Ind",i, sep = ""))
  
  propagate_table <- read_delim(paste(ind,'/', ind, '_', as.character(n), '_propagate_result.tsv', sep = ""), delim = '\t')
  propagate_table$MW_pvalue <- as.integer(propagate_table$MW_pvalue)
  propagate_table %>% filter(MW_pvalue <= 0.05, `prophage-host_ratio` > 1) -> reduced_cuttoff_table
  write_delim(reduced_cuttoff_table, paste("Reduced_Cutoff/", ind, "_", as.character(n), ".tsv", sep = ""), delim = '\t')
  }
}

for (i in LETTERS[10:10]){
  for (n in c(1, 2, 4, 5, 6)){
    ind = (paste("Ind",i, sep = ""))
    
    propagate_table <- read_delim(paste(ind,'/', ind, '_', as.character(n), '_propagate_result.tsv', sep = ""), delim = '\t')
    propagate_table$MW_pvalue <- as.integer(propagate_table$MW_pvalue)
    propagate_table %>% filter(MW_pvalue <= 0.05, `prophage-host_ratio` > 1) -> reduced_cuttoff_table
    write_delim(reduced_cuttoff_table, paste("Reduced_Cutoff/", ind, "_", as.character(n), ".tsv", sep = ""), delim = '\t')
  }
}
```
All the contigs in the files are the active prophages, ignore the 'active' column.

### Step 3: Assembly of phages from viral sequences
At one point I was worried that pooling viral reads before assembly was leading to miss-assemblies. After completing my first assembly I decided to run assemblies seperately.
Now I don't think it is the issue. 
Until I finish QC I will keep them around. So folders will have 
1) Pooled
2) Seperate
To indicate where each came from.

I will try this again but assemble each sample per individual seperately. This will also require a 'remove redundent contig step' in the QC.
I made two directories in 3_Viral_Assembly/Pooled & 3_Viral_Assembly/Seperate; Pooled will be when each sample was assembled together.
This will break the orginal scripts (BEWARE)
Also, because my viral_seperate_assembly{A..J}.sh required output from each day. I made subfolders for each sample.
Unlike bacterial assembly I will use metaSPades as it has been published that it is better at viral assembly (Simon Roux's benchmarking paper).  

Like with bacterial assembly, I will assembled all the samples for each individual together.
Note: spades doesn't like how I named my fastq files (fastq.1.gz) so I add a renaming step in this script.

Also, note this program takes a lot of resources:
default 16 cores, 250 GB. It is not fast either for this work. So 30hrs is not crazy. I will run seff after to help out if you need to rerun it on similar samples.
I ran 4 samples A-D; it actually only used 7-33 GB 32-cores (60-70%) for 30min-2h30min. SO I cancled the other jobs before they ran and altered their specs.

### Step 4: QC of Phage Contigs
Note: I tried to just do steps 1 and 2 initially but only kept a small amount of viral reads.
I will use three methods for detecting phage contigs from my assembled contigs.
1.  Size-select, remove smaller than 5kb contigs
2.  Tool-based (VIRSorter)
3.  Presence of viral protien homologs
4.  Match to phage-databases (e.g. GVD, from Sullivan Lab)

Seperately assembled contigs also have the extra step of removing redundant contigs.

The results was that I didn't find that many more contigs by running all three.  
I have decided to proceed with using VIRSorter w/ custom GVD database* which is loaded on Galaxy right now by Michel.

*GVD (https://doi.org/10.1016/j.chom.2020.08.003) Gut-Virome-Database.

This time, I will also save some time by only proceeding with 5kb > contigs from the get-go  which is lower than has has been recommended. If only a few contigs are below this or I get a lot of reads aligning to these contigs I might tighten the cutoff to 10kb.

My approach is 1) to move more efficiently 2) I will be looking for general trends in temperate phages (there is no need to look at incomplete phages for temperate analysis)

The output from metaSpades put all contigs in a file 'contigs.fasta' for each individual

Also, the name of the contigs are something like: >NODE_1_length_170994_cov_402.280182

Therefore, before proceeding, I will rename the contig.fasta file and add an individual identifier to contigs.
NOTE: This is for pooled assembly, I will run a slightly different approach for seperate contigs, as they then need to be catenated together.
NOTE: This one-liner needs to be modified as I have created a parent directory for pooled-assembly.
```shell
#Rename contig fasta file
#Add "Ind{A..J}_" to the start of each contig, just in case we need to identify them downstream later
for i in {A..J}; do sed "s/^>/>Ind${i}_/" 3_Viral_Assembly/Ind${i}/contigs.fasta >> 3_Viral_Assembly/Ind${i}/Ind${i}_contigs.fasta; done
```

For the unpooled, seperate assemblies:
```shell
for i in {A..I}; do sed "s/^>/>Ind${i}_/" 3_Viral_Assembly/Seperate/Ind${i}/sample{1..5}/contigs.fasta >> 3_Viral_Assembly/Seperate/Ind${i}/Ind${i}_seperate_assemb_contigs.fasta; done
for i in {1,2,4,5,6}; do sed "s/^>/>IndJ_/" 3_Viral_Assembly/Seperate/IndJ/sample${i}/contigs.fasta >> 3_Viral_Assembly/Seperate/IndJ/IndJ_seperate_assemb_contigs.fasta; done
```


I will then move them to Galaxy, and remove contigs redundant contigs (seperate assembled contigs), smaller than 5kb, then run VIRSorter with GVD database

1. Remove Redundant Samples with CD-HIT-EST (For seperately assembled contigs)
	Settings: Similarity 0.9 / Word Size 8 / Length difference 0.9
2. Size-cut off 5kb
	I used Michels Galaxy script. But I will then rename the files to
	Ind{A..J}_5kb_contigs.fasta
3. VIRSORTER
	Settings: Viromes + Gut Virome Database (v1, 2020), No virome decontamination, diamond
	Including all categories of output. Moved the FASTA files, and renamed Ind{A..J}_cat{1..4}_VIRSorter.fasta (for whicher categories were output)
	Then I combined them all into one file for Step 4: Ind{A..J}_VIRSORTER.fasta
4. Align viral reads back to these contigs to see what % of phages we are capturing.
	viral_abundance_pooled_{A..J}.sh : Align all the reads for pooled assembly  

It looks like I am loosing %reads by the final stage of the process.
So I aligned the reads to all the contigs. viral_QC_on_pooled_{A..J}.sh
We got 85-95% of reads aligning. Next I will check the 5kb contigs to see if that is what lost the biggest amount
I put the outputs of aligning reads to original contigs in
3_ViralAnalysis/3_Viral_Assembly/Pooled/QC/all_contigs

I will put the 5kb contings QC results in a directory 5kb_contigs
I will also run a check to see the % of reads that align to contigs >= 5kB
viral_QC_on_pooled_5kb_{A..J}.sh
For individual A, for example I still see 85%,82%,86%,79%,94%,92%. So it is not the losing of the smaller than 5kb contigs.

I will therefore proceed with pooled, 5kb (or longer) contigs. Since VIRSorter, does not seem to be capturig all the viral contigs. I will use an approach from my other project.
Keep contigs that meet of the three criteria:
1) VIRSorter +
2) Match to GVD 
3) Have 3 or more CDS with homology to pVOG database

### Step 4b: QC of Phage Contigs Match GVD

The Gut Virome Database was used in the previous aim from Sullivan lab (https://doi.org/10.1016/j.chom.2020.08.003)  
I have stored the orginal database:
/home/ssutclif/scratch/collab_project_storage/viral/GVD/GVDv1_viralpopulations.fna
It is 33242 uncultivated viral genomes from the gut. So I wont redownload it.

Basically what I will do is BLASTn my contigs for each individual (twice switching which is the query or subject)  
Then I take all the contigs that have coverage > 80, so the shortest contig.
I also use an evalue cutoff of 1e-10

blastn_5kb_viral_contigs_vs_GVD_{A..J}.sh

This will output two files, each with a different query/subject. Because some of the GVD genomes are shortter than my assembled genomes.
I just want the shortest contig to be 80% covered.

So I will select those with a quick one liner
```shell
$ awk '-F\t' '$3>79' IndAblastn_80x_cov_1 | cut -f2 | sort | uniq >> temp
$ awk '-F\t' '$3>79' IndAblastn_80x_cov_2 | cut -f2 | sort | uniq >> temp
$ sort temp | uniq > IndA_80x_coverage_blast_hits
```
To check to see how many contigs fit this criteria:
```shell
$ for i in {A..J}; do grep -c 'NODE' Ind${i}/Ind${i}_80x_coverage_blast_hits; done
41
45
64
64
68
84
38
83
48
30
```
So like VIRSorter it seems low. 
The next step will be to predict CDS with prodigal, and see if these match pVOG database for phage-proteins.

### Step 4C: QC of Phage Contigs: Match CDS of phages to pVOG

First I need to predict coding sequences
I will use Prodigal "Fast, reliable protein-coding gene preductuib for prokaryotic genomes"  
From these genes I can think check them against pVOG.
We have Prodigal v.2.6.3 installed on CC.

prodigal_ORF_prediction_{A..J}.sh

I have already downloaded pVOG database:
Database is VOG HMM profiles downloaded on December 1, 2020 from
http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads.html
I will also include ViPhOGs V2 in the future, especially if PVOG does not predict a lot of viral contigs as phage
https://osf.io/zd287/

I will begin with pVOG for now.
Using the ORFs from prodigal I will run
HMMSearch_pVOG_{A..J}.sh

Next, I will look to see which contigs had >3 matches to PVOG proteins. I will run a little script.

Based on this code:
```shell
$ grep '>' ../../1_Size_Cutoff/IndA_5kb_contigs.fasta | sed 's/>//' | cut -d" " -f1 >> contig_list
$ grep '>' ../../5_Prodigal/IndA/IndA_5kb_representatives.proteins.faa | sed 's/>//' | cut -d ' ' -f1 | head >> ORF_list
$ cat ORF_list | while read in; do grep -wo ${in} IndA_PVOG_tblout >> ORF_hits; done
$ cat ORF_hits | sort | uniq >> ORF_hits_no_dups
$ cat contig_list | while read in; do k=($(grep -c ${in} ORF_hits_no_dups)); echo -e "${in}\t${k}" >> PVOG_counts_viral_contigs; done
$ cat PVOG_counts_viral_contigs  | awk '-F\t' '{if($2>2)print$1}' | sort | uniq >> PVOG_contig_List
```
Which I made into a script as read/writting on project space is not great to do, so I will do it in the $SLURM_TMPDIR
pvog_summary_script.sh

### Step 4D:QC of Phage Contigs: Combining All the steps together

Now that I have the results from 1) VirSorter + contigs 2) GVD matches 3) PVOG + contigs. I will need to combine them all together
In the previous step I made a directory:
4_QC_Viral_Contigs/Pooled/7_Phage_Contigs/

I can use seqtk to select only 'phage contigs' from all the contigs.

The files: contig_list_{A..J} is the ALL the 5kb contigs
For the previous step I have: PVOG_phage_list_{A..J} for all the step 3 + contigs. 

I will then make a similar list of contigs for the other steps. I have already done this for the step 2 as well. So I ill move those files into this folder Ind{A..J}_80x_coverage_blast_hits
```shell
for i in {A..J}; do cp 4_QC_Viral_Contigs/Pooled/4_GVD/Ind${i}/Ind${i}_80x_coverage_blast_hits 4_QC_Viral_Contigs/Pooled/7_Phage_Contigs/; done
```

The next step is trickier as while step 2 and 3 maintain the orginal contig names
```shell
$ head -n 2 IndA_80x_coverage_blast_hits
IndA_NODE_10_length_48840_cov_73.575382
IndA_NODE_121_length_8995_cov_9.212304

$ head -n 2 PVOG_phage_list_A
IndA_NODE_100_length_11259_cov_30.066583
IndA_NODE_101_length_10963_cov_7.230840
```
VirSorter modifies the names of contigs in the fasta files. Now this is how I did in my last project but I do not think this is the best way. But you can pull the names from the FASTA files of VirSorter to get the original names with a SED command
Using D as an example as it has each category of VirSorter phages I will show what I mean.
```shell
for i in {1..6}; do grep '>' IndD/Ind_cat${i}_VIRSorter.fasta | head -n 2; done
>VIRSorter_IndD_NODE_282_length_5705_cov_27_770088-circular-cat_1
>VIRSorter_IndD_NODE_45_length_36485_cov_28_586961-circular-cat_2
>VIRSorter_IndD_NODE_5_length_126458_cov_100_338070-circular-cat_2
>VIRSorter_IndD_NODE_7_length_100781_cov_480_574291-circular-cat_3
>VIRSorter_IndD_NODE_27_length_58283_cov_105_013619-circular-cat_3
>VIRSorter_IndD_NODE_1_length_199819_cov_27_973764_gene_66_gene_165-49746-147548-cat_4
>VIRSorter_IndD_NODE_43_length_37987_cov_13_672941_gene_1_gene_53-0-32868-cat_5
>VIRSorter_IndD_NODE_67_length_24805_cov_107_831717_gene_7_gene_18-3696-18590-cat_5
>VIRSorter_IndD_NODE_2_length_171645_cov_532_328492-circular_gene_1_gene_199-75-123392-cat_6
>VIRSorter_IndD_NODE_4_length_126566_cov_41_931769_gene_95_gene_194-49877-126566-cat_6
```
So it
adds >VIRSorter_  
turns the . into a _ 
and taks on -circular- for cat 1,2 and 3, and _gene_ for cat 4,5, or -circular_gene

So I to say I am not a regex genuis is an understatement. So I use pipes to string it all together to remove what I want
I put it all in small bash script called; renaming_virsorter_contigs.sh
The bones of it look like this, where orginal fasta file combines all the .fasta file outputs together
```shell
grep '>' IndD_VIRSORTER.fasta > IndD_VirSorter_contig_list
#This replaces the endings after what I need, then uses cut command to take everything before space
sed 's/-circular/ /' IndD_VirSorter_contig_list | sed 's/-cat/ /' | sed 's/_gene/ /' | cut -d " " -f 1 > temp
#Next I will remove the start bit which is easy
sed 's/>VIRSorter_//' temp > temp2
#Then change the last instance of the _ to a . 
sed 's/\(.*\)_/\1./' temp2 > IndD_VirSorter_contig_list
#This last one will replace the orginal contig list with the right naming scheme, now I will delete the temp files
rm temp*
```

Now I have three sets of contigs:
*  IndA_80x_coverage_blast_hits
*  IndA_VirSorter_contig_list
*  PVOG_phage_list_A

So I will combine them together, and remove all those that are found through all the different methods
```shell
for i in {A..J}; do cat Ind${i}_80x_coverage_blast_hits Ind${i}_VirSorter_contig_list PVOG_phage_list_${i} | sort | uniq > Ind${i}_Phage_Contig_List; done
```
Now I have all the final phage contigs that I want to use.

```shell
wc -l *_Phage_Contig_List
   61 IndA_Phage_Contig_List
   53 IndB_Phage_Contig_List
   91 IndC_Phage_Contig_List
   85 IndD_Phage_Contig_List
  125 IndE_Phage_Contig_List
  142 IndF_Phage_Contig_List
   53 IndG_Phage_Contig_List
  125 IndH_Phage_Contig_List
   63 IndI_Phage_Contig_List
   42 IndJ_Phage_Contig_List
```
Now for each I can take the orginal 5kb fasta files
Combines (1,2,3): 840 phage contigs
PVOG (Step 3): 8 phage contigs
VirSorter(Step 1): 487 phage contigs
GVD match (Step 2): 565 phage contigs
Combine (1,2): 840 phage contigs

So looking for PVOG protiens is useless.
Now I will use seqtk to pull the fasta files for all the contigs that I have determined as phage. Then I will take a look at % of reads that align to these contigs.
Seqtk is a pretty efficient step (https://github.com/lh3/seqtk) so I will run it without submitting a batch job.
```shell
module load seqtk/1.3
for i in {A..J}; do seqtk subseq ../1_Size_Cutoff/Ind${i}_5kb_contigs.fasta Ind${i}_Phage_Contig_List > Ind${i}_Phage_Contigs.fasta; done
```
So now I have my phage contigs.
Ind{A..J}_Phage_Contigs.fasta

While the next step of QC is aligning the viral reads to these contigs, this is what I will be doing for abundance as well. So I can't think of what I would do differently if it doesn't work.
So I will add my 'active prophages' to this and proceed with the next step of analysis. So I will put it all in 5_Viral_Analysis.

I will do a similar thing for the list of active prophages from the reduced cutoff criteria
```shell
for i in {A..J}
do
for x in {1..6}
do
tail -n +2 ../../../2_Prophages/PropagAte/VIBRANT-fragments/Reduced_Cutoff/Ind${i}_${x}_reduced_cutoff_propagate_result.tsv | cut -f 1 >> temp
done
sort temp | uniq > Ind${i}_Prophage_List
rm temp
done
```
It was noted in the R script, but for some reason Individual B, doesn't have the 'IndB' at the start. Just to note.
I will make a prophage fasta list too:
```shell
module load seqtk/1.3
for i in {A..J}; do seqtk subseq ../../../2_Prophages/VIBRANT/Ind${i}/VIBRANT_Ind${i}_vibrant/VIBRANT_phages_Ind${i}_vibrant/Ind${i}_vibrant.phages_lysogenic.fna Ind${i}_Prophage_List > Ind${i}_Active_Prophages.fasta; done
```

### Step 4E: QC on Phage Contigs: CheckV
This step was done on Galaxy, as the program is installed already there.
Storing the results in 5_Viral_Analysis/3_CheckV (not finished, still on Galaxy Server)

### Step 5 Viral Analysis : Align Viral Reads

So I need to combine both the prophages and viral assembled phage contigs.
```shell
for i in {A..J}
do
cat 3_ViralAnalysis/4_QC_Viral_Contigs/Pooled/7_Phage_Contigs/Ind${i}_Phage_Contigs.fasta 3_ViralAnalysis/4_QC_Viral_Contigs/Pooled/7_Phage_Contigs/Ind${i}_Active_Prophages.fasta >> /home/ssutclif/projects/def-corinnem/ssutclif/temp_storage/Third_Aim/3_ViralAnalysis/5_Viral_Analysis/Ind${i}/Ind${i}_All_Phage_Contigs.fasta
done
```

Now I the final set of contigs (viral assembled and active prophages).
5_Viral_Analysis/Ind${A..J}}/Ind${A..J}_All_Phage_Contigs.fasta

I will align the viral decontaminated reads to these contigs.
viral_abundance_final_contigs_A.sh

I will use samtools coverage command to make a summary sheet of reads-aligning that I can deal with in R
I made a BASH script to do this in temp-directory

```shell
module load samtools
for i in {A..I}

do

for x in {1..5}

do

samtools coverage Ind${i}_${x}_contig_sorted_coverage.bam -o Ind${i}_${x}_samtool_coverage; done

done

done
```

### Step 6 Viral Analysis : CheckV phage contigs
I want to differentiate between temperate and lytic phages for relative abundance
Before I can run Bacphlip, I want to only look at 5kb> medium-complete phages (Via CheckV)

I ran CheckV via Galaxy, then collected the phage-contig names of those more than or equal 50% complete and greater than 5kb

I did this in R on my desktop using the checkv_quality files.
(The orginal files will be stored in my viral analysis coverage data folder.
I will store the list of contigs in 
5_Viral_Analysis/3_CheckV

```shell
module load seqtk/1.3
for i in {A..J}; do seqtk subseq ../1_Final_Contigs/Ind${i}_All_Phage_Contigs.fasta Ind${i}CheckV_Contigs > Ind${i}_CheckV_contigs.fasta;done
```

### Step 7 Bacphlip on medium-high quality contigs
Bacphlip is installed in a virtual environment using:
#Note I loaded in dependencies first to use CC wheels but a straight install would have worked
```shell
module load python/3.8.10
module load scipy-stack/2021a
virtualenv --no-download ~/Tool_Box/BACPHLIP
source ~/Tool_Box/BACPHLIP/bin/activate
pip install --no-index --upgrade pip
pip install  biopython --no-index
pip install joblib  --no-index
pip install scikit-learn --no-index
pip freeze --local > ~/Tool_Box/BACPHLIP/bin/installed_dependecies
#-no-index means it will be a CC wheel
#Also scipy-stack loads pandas already
pip install bacphlip
```

After the install I will run it on all the checkv (medium+ contigs)
NOTE: This could did not mv correctly, as the output files are put in 3_CheckV folder instead, so unless corrected will generate an error code but actually work.
```shell
source ~/Tool_Box/BACPHLIP/bin/activate
module load hmmer/3.2.1

for i in {A..J}

do

echo "Running Bacphlip on Individual ${i}"

#Location of viral contigs file
contig_dir=5_Viral_Analysis/3_CheckV/Ind${i}_CheckV_contigs.fasta

bacphlip -i $contig_dir
#Output file plops into the location the script is run, so I will move it myself
mv Ind${i}_CheckV_contigs.fasta.bacphlip 5_Viral_Analysis/4_BACPHLIP/

done
```
