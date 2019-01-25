# Fastq2uBam
Scripts for converting FASTQ files into unaligned BAM files, and viceversa, conserving all information in the @SEQ_ID field. Every other software we have considered have some deficiencies, either by loosing tags after whitespaces in the @SEQ_ID file, or requiring dependencies and/or compiling libraries not available in an "stable" OS like CentOS 6. For this reason, we have created these scripts to transform files from and to Fastq and uBam formats without loosing any information and using only a picard.jar java ejecutable as dependency.

# Installation
In order to use these scripts, you need to have an updated version of [picard tools](https://broadinstitute.github.io/picard/) in your system and to save and export the path to the picard.jar file in the variable $PICARD:
```
export PICARD="/path/to/picard-tools-X.Y.Z/picard.jar"
```

That's it. Now you can download the scripts and exeture them. We recommend cloning the repository, so they can be easily updated if a new version is released.
```
git clone https://github.com/BU-ISCIII/Fastq2uBam.git
```

# Usage

## Fastq2uBam.sh

This script takes FASTQ files (either one single-end or two paired-end files) and transforms them in an unaligned BAM 
file.

IMPORTANT: `$PICARD` must be declared in your environment and pointing to the picard.jar file you want to use.

One FASTQ file must be inputed as argument for single-end mode and two (R1 and R2, in that order) for paired-end mode. For single-end mode, a second parameter "single-end" must be included.

Input FASTQ files can be compressed in gzip format. In this case the must be named with the file extension ".fastq.gz".

If not specified, the resulting BAM file will be named as the first FASTQ file inputed in the program, removing everything after "_R1" and changing the file extension for ".bam". The file will be written in the same folder where the first FASTQ file is.

Lack of necessary input or not found FASTQ file will lead to end of execution and display of the help message.

Example of usage:
```
Fastq2uBam.sh myreads_R1.fastq.gz myreads_R2.fastq.gz myreads.bam --PLATFORM=ILLUMINA --SEQUENCING_CENTER=ISCIII
Fastq2uBam.sh myreads.fastq single-end myreads.bam
```
Optional arguments: Any other optional arguments for piccard can be added, just need to be written in format `--ARGUMENT=VALUE` or `-ARG=VALUE`.

Full list of available optional argumentes here: https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.5.1/picard_sam_FastqToSam.php

## uBam2Fastq.sh

This script takes an unaligned BAM file and transforms it to FASTQ format (either one single-end or two paired-end files)

IMPORTANT: `$PICARD` must be declared in your environment and pointing to the picard.jar file you want to use.

One BAM file must be inputed as argument as long as the output for single-end mode and two (R1 and R2, in that order) for paired-end mode. For single-end mode, a second parameter "single-end" must be included.

Output files will be compressed with gzip if specified in their file extension with ".fastq.gz".

If not specified, tha BAM file will be considered paired-end and the resulting FASTQ files will be named as the BAM file inputed in the program, without the file extension ".bam". The files will be written in the same folder where the input BAM file is.

Lack of necessary input or not found BAM file will lead to end of execution and display of the help message.

Example of usage:
```
uBam2Fastq.sh myreads.bam myreads_R1.fastq.gz myreads_R2.fastq.gz
uBam2Fastq.sh myreads.bam single-end myreads.fastq
```
Optional arguments: Any other optional arguments for piccard can be added, just need to be written in format `--ARGUMENT=VALUE` or `-ARG=VALUE`.

Full list of available optional argumentes here: https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.5.1/picard_sam_FastqToSam.php

## benchmark.sh

This script is designed to benchmark the compression rate and computing time of the methods used in `Fastq2uBam.sh` and `uBam2Fastq.sh`.

To execute it just pass as argument a folder with some paired-end Fastq files. All the computation will take place in the same folder, creating new files but without modifying the original ones.

Output will be printed to stout. You can easily redirect to a file with ">".

Example of usage:
```
benchmark.sh /path/to/my/folder/with/fastqgzfiles/ > report.txt
```
