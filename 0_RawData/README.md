# Raw sequences downloaded

## Files

 * filereport_read_run_PRJNA588313.txt (ENA file locations for downloading)
 * Kang_Sampling_Info.txt (Sample lable information)

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

Res2_<Type>_<a-z><d>

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

They have very nicely uploaded a file for their analysis:
[http://sbb.hku.hk/Resistome/](http://sbb.hku.hk/Resistome/)

The file sample.RData has the sample information.
I converted that into a tsv as Kang_Sampling_Info.txt

filereport_read_run_PRJNA588313.txt
This file has ftp location as well as the md5 sum for the file, so that I can check tne files.

```shell
$ head -n1 filereport_read_run_PRJNA588313.txt 
```
study_accession	sample_accession	experiment_accession	run_accession	tax_id	scientific_name	library_name	library_strategy	fastq_md5	fastq_ftp	submitted_ftp	sra_ftp

