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



## uBam2Fastq.sh


## benchmark.sh
