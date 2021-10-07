# Viral Analysis

## Notes

I will include the prophage-finding work here as part of the viral analysis.
Bacterial bins were made for each individual (including data from all time points)

## Files

## Directories

*  0_Stored_Standard_Outputs : Each script generates a standard output. To declutter I am moving them here after the step is complete.
*  1_Stored_BASH_scripts : After a step is done I moved the BASH script for the job here to be more organized.
*  2_Prophages : Storage of VIBRANT prophages detected

## Scripts + Batch Jobs


## Tools Used

*  VIBRANT v1.2.1 [Galaxy install](https://github.com/AnantharamanLab/VIBRANT)

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

My previous work has shown that using multiple tools to detect prophages. For now I will focus on VIBRANT as it is developed by the same person who developed PropagAte, the tool I plan to use for determining active prophages.

I will run on VIBRANT on each bin assembled per individual

I know that VIBRANT makes a lot of files per run. All I want is A) fasta files of prophages B) location of prophages on scaffolds
Because I have labelled each scaffold with a bin ID and Individual ID I can always use that to reconnect them.

I had trouble getting my local install to work (specifically problems recognizing numpy dependency) I will try and trouble-shoot this and report what I did.
Until then I ran it on Galaxy
Minimum Scaffold Length: 1000
Min #ORF: 4
Virome mode: no

I will transfer the files back to here when I am done.

