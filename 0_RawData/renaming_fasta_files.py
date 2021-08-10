#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 10 11:09:34 2021

@author: steven
"""

#The goal of this script is to use the file-meta-data file I have downloaded from ENA "Project-ID Download Report"
#Then to use those to rename the FASTQ files by their sample name Res2_Type_a-z0-6

import csv
import os
from os import path
import argparse


parser = argparse.ArgumentParser(description='Takes the filereport and renames the SRR names to their library scheme name')
parser.add_argument("-f", help="File report.")


args = parser.parse_args()
input_path = args.f

# make an empty dictionary which will hold the keys
keys = {}

#open file
with open(input_path,'r') as tsvfile:
        reader = csv.reader(tsvfile, delimiter = '\t', quotechar='"')
        next(reader, None)
        for rowDict in reader:
              keys[ rowDict[3]+ "_1.fastq.gz" ] = rowDict[6]+ "_1.fastq.gz"
              keys[ rowDict[3]+ "_2.fastq.gz" ] = rowDict[6]+ "_2.fastq.gz"


# renaming the files based on their library_scheme 


for key, value in keys.items():
    
    if not path.exists(key):
        open(key, 'a').close()
        
    if path.exists(key):
        os.rename(key, value)