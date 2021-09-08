# Raw sequences downloaded

## Note

Right now I do not have a plan to use the RNA-seq data. So I will not quality control it.

## Files

 * DNA_IDs.txt : List of all the DNA sample IDs
 * Phage_IDs.txt : List of all the Phage sample IDs
 * DNA_IDS_missed.txt " List of all DNA sample IDs that were missed during first trimmomatic run on "DNA_IDs.txt" due to timeout
 * DNA_IDS_missed[1-4].txt : Four files compose the missed files in first round of trimmomatic split into four

## Directories

 * 0_Trimmed_DNA : trimmed metagenomic sequence
 * 1_Trimmed_RNA : trimmed metatranscriptomics
 * 2_Trimmed_Phage : trimmed virome metagenomics
 * 3_Decontaminated_DNA : removed human decontamination metagenomic sequence
 * 4_Decontaminated_RNA : removed human decontamination metatranscriptomics
 * 5_Decontaminated_Phage : removed human decontamination virome metagenomics
 * 6_PreQC_FASTQC : Output of QC reports before trimming
 * 7_PostQC_FASTQC : Output of QC reports after trimming
 

## Scripts + Batch Jobs

 * pre_fastq_DNA.sh
 * pre_fastq_RNA.sh
 * pre_fastq_Phage.sh
 * pre_fastqc_multiqc.sh
 * trimmomatic_viral.sh
 * trimmomatic_bacteria.sh 
 * post_fastq_DNA_trimmomatic.sh
 * post_fastq_Phage_trimmomatic.sh
 * human_decon_bacteria[1-5].sh
 * human_decon_viral.sh

## Tools Used
 
 * FastQC v.0.11.9 (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) 
 * MultiQC v.1.11 (https://multiqc.info/)
 * Trimmomatic v.0.39 (http://www.usadellab.org/cms/?page=trimmomatic)
 * bowtie2 v.2.4.2 (http://bowtie-bio.sourceforge.net/index.shtml)

### Sample naming

Samples appear to be distinguished by 'library_name'

`Res2_<Type>_<a-z><d>`

* Type
  * Phage : Virome samples
  * RNA : Metatranscriptomics
  * DNA : Micorbial Sequencing
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

Note: Sample J5 does not exist for any of the samples. So there are 58 paired sequences per 'omic'

## Decontaminating and Trimming Reads

### Information about the reads
DNA library preparation and sequencing:  
Illumina HiSeq 2000 PE125 using TrueSeq Nano 550 bp kits (Illumina)
Phage DNA : MiSeq PE300  

### Step 1 : FASTQC sequences before QC for comparison
This step will help us see how well the QC steps did and if there are any initial issues

I ran each DNA, RNA and Phage seperately as SBATCH jobs
```shell
sbatch pre_fastq_DNA.sh
sbatch pre_fastq_RNA.sh
sbatch pre_fastq_Phage.sh
```
The results were stored in 6_PreQC_FastQC in their respective folders (DNA, RNA, Phage)

FASTQC makes a file per sample which is annoying to check them all simultaneously
so I will run multiqc per DNA, RNA and Phage which pools samples together

I will run it using:
pre_fastqc_multiqc.sh

```shell
sbatch pre_fastqc_multiqc.sh
```

This will take all .html files from FASTQC and make
<type>_multiqc_report_data (directory)
<type>_multiqc_report.html (file)
<type>_multiqc_report_plots (directory)

These files are stored 
```shell
1_QCReads/6_PreQC_FASTQC/<type>
```
I would recommend looking at multiqc_report.html files as they are easy to digest in the browser.
I will go over all the issues that reported and compare them before and after using Trimmomatic.

Trimmomatic will help me remove adapters left over from the sequence length, trim near ends of sequence where quality drops off, and remove low quality reads.

Bacterial sequences quality pre-trimming  
![bacterial_quality_pre_trim](6_PreQC_FASTQC/DNA/DNA_multiqc_report_plots/png/mqc_fastqc_per_base_sequence_quality_plot_1.jpg "FastQC: Mean Quality Scores of Pre-Trimmed Bacterial Sequences")
Phage sequences quality pre-trimming, there seems to be more issues as the length of sequences are longer
![phage_quality_pre_trim](6_PreQC_FASTQC/Phage/Phage_multiqc_report_plots/png/mqc_fastqc_per_base_sequence_quality_plot_1.jpg "FastQC: Mean Quality Scores of Pre-Trimmed Phage Sequences")

There doesn't seem to be an issue with adapters with the bacteria or phage but like low-quality position it appears to slightly increase near end of read, which makes sense
Bacteria sequences adapter contamination
![bacterial_adaptors_pre_trim](6_PreQC_FASTQC/DNA/DNA_multiqc_report_plots/png/mqc_fastqc_adapter_content_plot_1.jpg "Adaptors of Pre-Trimmed Bacterial Sequences")
Phage sequences adapter contamination
![phage_adaptors_pre_trim](6_PreQC_FASTQC/Phage/Phage_multiqc_report_plots/png/mqc_fastqc_adapter_content_plot_1.jpg "Adaptors of Pre-Trimmed Phage Sequences")

I would also look at the MultiQC file, as it has a status checks for each category. Which is a nice summary. So now I will run Trimmomatic

### Step 2 : Trimmomatic
For the adaptors I will use the default Trimmomatic::TruSeq2-PE, 
the universal adapter sequence of TruSeq kit as:
Illumina HiSeq 2000 PE125 using TrueSeq Nano 550 bp kits (Illumina)
Phage DNA : MiSeq PE300

I will use 'palindrome mode' which is aimed at detecting 'adapter read-through' which is is prevelant in the long read length of MiSeq which we see in the Phage DNA samples.
I will run similar analysis as previously used on this dataset (re:Kang et al 2021) 
Removing low quality bases (<Q20); reads shorter than 75bp
1) remove adapters ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:8:keepBothReads
2) remove reads below a Phred score of 20 with a sliding window of 4 SLIDINGWINDOW:4:20
3) I will set a minimum length for MINLEN:75
4) I will also run it on four CPUs

I will need to run trimmomatic on each sample individually, so I will make a file that has all the DNA and Phage ID names:

```shell
$ cut -f7 ../0_RawData/filereport_read_run_PRJNA588313.txt | grep 'DNA' > DNA_IDs.txt
$ head DNA_IDs.txt
Res2_DNA_B6
Res2_DNA_B5
Res2_DNA_A2
Res2_DNA_A1
Res2_DNA_B4
Res2_DNA_B3
Res2_DNA_B2
Res2_DNA_B1
Res2_DNA_J6
Res2_DNA_J5
$ cut -f7 ../0_RawData/filereport_read_run_PRJNA588313.txt | grep 'Phage' > Phage_IDs.txt
$ head Phage_IDs.txt
Res2_Phage_B4
Res2_Phage_B3
Res2_Phage_B2
Res2_Phage_B1
Res2_Phage_J6
Res2_Phage_J5
Res2_Phage_J4
Res2_Phage_J2
Res2_Phage_J1
Res2_Phage_I6
```

I will use these files to run trimmomatic on each of the samples.
I will run DNA and Phage in two different batch jobs
viral_trimmomatic.sh
bacteria_trimmomatic.sh
The final script will look like this:
```shell
#Raw reads directory in relation to the script
input_directory=../0_RawData/2_Phage/
#Output directory in relation to the script
output_directory=2_Trimmed_Phage/

#Each line of Phage_IDs.txt is a sample
cat Phage_IDs.txt | while read id

do

java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 8 ${input_directory}${id}_1.fastq.gz ${input_directory}${id}_2.fastq.gz   ${output_directory}trimmed_${id}_1_paired.fastq.gz \
${output_directory}trimmed_${id}_1_unpaired.fastq.gz ${output_directory}trimmed_${id}_2_paired.fastq.gz \
${output_directory}trimmed_${id}_2_unpaired.fastq.gz \
ILLUMINACLIP:$EBROOTTRIMMOMATIC/adapters/TruSeq3-PE.fa:2:30:10:8:keepBothReads SLIDINGWINDOW:4:20 MINLEN:75

done
```
I will do the bacteria version in batch script trimmomatic_bacteria.sh

NOTE: When I ran the trimmomatic_bacteria.sh the run timed out at Res2_DNA_A6, so I will re-run this sample and all missed samples. So there will be two outputs for this batch command.
I put the missing files into DNA_IDs_missed.txt but also it takes a long time to run, so I will split this file.
So I will split the missed files into four sets and run them each in a different batch job.

```shell
$ awk 'FNR>=1 && FNR<=11' DNA_IDs_missed.txt > DNA_IDs_missed1.txt
$ awk 'FNR>=12 && FNR<=23' DNA_IDs_missed.txt > DNA_IDs_missed2.txt
$ awk 'FNR>=24 && FNR<=35' DNA_IDs_missed.txt > DNA_IDs_missed3.txt
$ awk 'FNR>=36 && FNR<=42' DNA_IDs_missed.txt > DNA_IDs_missed4.txt
```
I will make four new trimmomatic bacteria jobs for each list of missed samples.

Now I have completed trimmomatic for both bacteria and phage sequence data. For each sample trimmomatic produces an unpaired set of sequences and paired. For example for Phage_A1 we have
```shell
trimmed_Res2_Phage_A1_1_paired.fastq.gz
trimmed_Res2_Phage_A1_1_unpaired.fastq.gz
trimmed_Res2_Phage_A1_2_paired.fastq.gz
trimmed_Res2_Phage_A1_2_unpaired.fastq.gz
```
We will do all further analysis on the paired reads; as both mate-pairs survived the trimming. Once again the files are too large to upload but they are stored in
0_Trimmed_DNA
2_Trimmed_Phage

I will do two other quality control steps (human decontamination and duplicate removal if needed) but I will re-run FastQC to compare results to see if they did a good job of trimming results 
before the next steps.

### Step 2b : Trimmomatic Check
In 7_PostQC_FASTQC I will make a sub-directory 0_Post_Trimmomatic; so I can store the FASTQC results in
I will run
post_fastq_DNA_trimmomatic.sh
post_fastq_Phage_trimmomatic.sh

Note: This generated FASTQC files for the unpaired files as well. Which is tossed sequence reads so I will delete them.
```shell
$ rm 7_PostQC_FASTQC/0_Post_Trimmomatic/DNA/*unpaired_fastqc*
$ rm 7_PostQC_FASTQC/0_Post_Trimmomatic/Phage/*unpaired_fastqc*
```
It appears that the Trimmomatic step worked well. No more detectable adapter sequences in either or N calls. MultiQC doesn't produce images when they are bellow the range of detection.
 Bacterial sequences quality post-trimming
![bacterial_quality_prost_trim](7_PostQC_FASTQC/0_Post_Trimmomatic/DNA/DNA_multiqc_report_plots/bacteria_mqc_fastqc_per_base_sequence_quality_plot_1.jpg "FastQC: Mean Quality)
 Phage sequences quality post-trimming
![phage_quality_post_trim](7_PostQC_FASTQC/0_Post_Trimmomatic/Phage/Phage_multiqc_report_plots/phage_mqc_fastqc_per_base_sequence_quality_plot_1.jpg "FastQC: Mean Quality)

MultiQC produces a nice summary table at the of the html file. Shows that the Trimmomatic step did its job. Onto contamination!

### Step 3 : Remove Human Contaminates
Human contamination always finds its way into samples. I don't remove bacterial deconaminates from viral samples as that causes more harm then benefit. But I will align the reads to the human genome and remove those reads.

We will use the homo sapien bowtie index GRCh38 which is already available on Compute Canada. I have already installed it for another project:
```shell
export MUGQIC_INSTALL_HOME=/cvmfs/soft.mugqic/CentOS6

```

I will use --un option of bowtie 1.3.0 which takes all the reads that do no align to human genome and puts them in a new fastq.gz file
Using the scripts
human_decon_bacteria1.sh
human_decon_bacteria2.sh
human_decon_bacteria3.sh
human_decon_bacteria4.sh
human_decon_bacteria5.sh

NOTE: Again the bacterial sequence runs were too much for each bowtie2 decontamination to run successfully. I will divide the whole list of DNA_IDs.txt into five files

```shell
$ awk 'FNR>=1 && FNR<=12' DNA_IDs.txt > DNA_IDs1.txt
$ awk 'FNR>=13 && FNR<=25' DNA_IDs.txt > DNA_IDs2.txt
$ awk 'FNR>=26 && FNR<=38' DNA_IDs.txt > DNA_IDs3.txt
$ awk 'FNR>=39 && FNR<=49' DNA_IDs.txt > DNA_IDs4.txt
$ awk 'FNR>=50 && FNR<=59' DNA_IDs.txt > DNA_IDs5.txt
```
Despite splitting two of the runs failed
Slurm Job_id=13324410
Slurm Job_id=13324413

```shell
$ tail -n 2 human_decon_bacteria-13324410.out 
Sample Res2_DNA_I1
slurmstepd: error: *** JOB 13324410 ON cdr798 CANCELLED AT 2021-09-07T15:44:06 DUE TO TIME LIMIT ***

$ tail -n 2  human_decon_bacteria-13324413.out   
Sample Res2_DNA_F2
slurmstepd: error: *** JOB 13324413 ON cdr849 CANCELLED AT 2021-09-07T15:44:06 DUE TO TIME LIMIT ***

```
So I will remove Res2_DNA_I1 and Res2_DNA_F2 then make another 'missed ID list'

```shell
$ rm 3_Decontaminated_DNA/Res2_DNA_F2*
$ rm 3_Decontaminated_DNA/Res2_DNA_I1*
```
Res2_DNA_F2 is the last line of DNA_IDs3.txt and Res2_DNA_12 is the 6th last of DNA_IDs3.txt
```shell
$ tail -n 6 DNA_IDs2.txt
Res2_DNA_I1
Res2_DNA_H6
Res2_DNA_H5
Res2_DNA_H4
Res2_DNA_H3
Res2_DNA_H2

$ tail -n 1 DNA_IDs3.txt
Res2_DNA_F2

```
So I will modify the script to run on these
human_decon_bacteria_missed.sh

