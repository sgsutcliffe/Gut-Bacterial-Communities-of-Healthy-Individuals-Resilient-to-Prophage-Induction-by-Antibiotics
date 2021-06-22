# Raw sequences downloaded

## Files

 * filereport_read_run_PRJNA588313.txt (ENA URLS, metadata, md5sums)
 * Kang_Sampling_Info.txt (Sample lable information)
 * RNA_URLS.txt (ftp locations of metatranscriptomics)
 * DNA_URLS.txt (ftp locations of metagenomics)
 * Phage_URLS.txt (ftp locations of viral metagenomics)
 * phage|rna|dna_downloads_md5sum (This is the md5sums of the files that were downloaded)
 * phage|rna|dna_orginal_md5sum (This is the md5sums listed on the ENA page)

## Directories

 * 0_DNA : metagenomics sequences
 * 1_RNA : metatranscriptomics
 * 2_Phage : virome metagenomics

## Kang dataset:

Raw sequencing data is published at NCBI SAR with the project ID PRJNA588313 and sample category ID SAMN13241759.
Raw data for DNA libraries: SRR10423895 to SRR10423894; [metagenomics]
RNA libraries: SRR10420935 to SRR10420934; [metatranscriptomics]
virome libraries: SRR10417995 to SRR10418053. [virome]

### Description

10 healthy human volun- teers were recruited and randomized to receive one in four different antibiotic courses or to be a control. Before, during, and after 
exposure to antibiotics, they provided a total of six stool samples. Four antibiotics were selected based on their clinical relevance and broad-spectrum activity against 
Gram-positive and/or Gram-negative organisms.

Four antibiotics from different chemical and therapeutic classes were used: ciprofloxacin (quinolone class), cefuroxime (β-lactam class), doxycycline (tetracycline class), 
and azithromycin (macrolide class). As a control, stool samples from two untreated healthy individuals also were processed.

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

They have very nicely uploaded a file for their analysis:
[http://sbb.hku.hk/Resistome/](http://sbb.hku.hk/Resistome/)

The file sample.RData has the sample information.
I converted that into a tsv as Kang_Sampling_Info.txt

filereport_read_run_PRJNA588313.txt ; this the TSV report of all the run accessions of the PRJNA588313 study, and its metadata

Note: By default ENA does not provide all these columns when you select the TSV for the Project-ID Download report. You need to do this in the Show Column Selection.
This file has ftp location as well as the md5 sum for the file, so that I can check tne files.

The columns I selected are:

```shell
$ head -n1 filereport_read_run_PRJNA588313.txt 
```
```shell
study_accession	sample_accession	experiment_accession	run_accession	tax_id	scientific_name	library_name	library_strategy	fastq_md5	fastq_ftp	submitted_ftp	sra_ftp
```

I will make directories for downloading each type and I will continue with their naming scheme **DNA** for whole-metagenomic sequencing of microbes (even though this is where I will focus on 
bacteria.

 * 0_DNA
 * 1_RNA
 * 2_Phage

Each URL (for forward/reverse) reads are in the filereport_read_run_PRJNA588313.txt. I also don't know why but they're also in the same column. I will make a file for each (DNA,RNA,Phage) URL.

```shell
grep 'RNA' filereport_read_run_PRJNA588313.txt | cut -f10 | sed 's/\;/\n/' >> RNA_URLS.txt
grep 'DNA' filereport_read_run_PRJNA588313.txt | cut -f10 | sed 's/\;/\n/' >> DNA_URLS.txt
grep 'Phage' filereport_read_run_PRJNA588313.txt | cut -f10 | sed 's/\;/\n/' >> Phage_URLS.txt
```
From their respective directories I will run 

```shell
cat ../DNA_URLS.txt | while read in; do wget ftp://${in}; done
```

Next I will check the md5sum for each file 

```shell
$ md5sum 2_Phage/* | cut -d' ' -f1 >> phage_downloads_md5sum
$ md5sum 1_RNA/* | cut -d' ' -f1 >> rna_downloads_md5sum
$ 
```
From the directory of the sequences I will run this one-liner which takes the md5sum from the filereport
```shell
$ ls *_1.fastq.gz | while read in; do grep "${in}" ../filereport_read_run_PRJNA588313.txt | cut -f9 | sed 's/\;/\n/' >> ../phage_original_md5sum; done
$ ls *_1.fastq.gz | while read in; do grep "${in}" ../filereport_read_run_PRJNA588313.txt | cut -f9 | sed 's/\;/\n/' >> ../rna_original_md5sum; done
$
```
I will check the files to see the md5sum's are the same

```shell
$ diff rna_downloads_md5sum rna_original_md5sum
$ diff phage_original_md5sum phage_downloads_md5sum
$
```
Looks good! I can proceed!
