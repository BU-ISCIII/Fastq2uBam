#!/bin/bash

###################################################################
#
# This script takes an unaligned BAM file and transforms it to
# FASTQ format (either one single-end or two paired-end files).
#
# IMPORTANT: $PICARD must be declared in your environment and
# pointing to the picard.jar file you want to use.
#
# One BAM file must be inputed as argument as long as the output 
# for single-end mode and two (R1 and R2, in that order) for 
# paired-end mode. For single-end mode, a second parameter 
# "single-end" must be included.
#
# Output files will be compressed with gzip if specified in their 
# file extension with ".fastq.gz".
#
# If not specified, tha BAM file will be considered paired-end and
# the resulting FASTQ files will be named as the BAM file inputed 
# in the program, without the file extension ".bam". The files 
# will be written in the same folder where the input BAM file is.
#
# Lack of necessary input or not found BAM file will lead to end
# of execution and display of the help message.
#
# Example of usage:
# uBam2Fastq.sh myreads.bam myreads_R1.fastq.gz myreads_R2.fastq.gz
# uBam2Fastq.sh myreads.bam myreads.fastq single-end 
#
###################################################################

# Help
function help {
	echo ""
	echo "This script takes an unaligned BAM file and transforms it to FASTQ format (either one single-end or two paired-end files)"
	echo ""
	echo "IMPORTANT: \$PICARD must be declared in your environment and pointing to the picard.jar file you want to use."
	echo ""
	echo "One BAM file must be inputed as argument as long as the output for single-end mode and two (R1 and R2, in that order) for paired-end mode. For single-end mode, a second parameter \"single-end\" must be included."
	echo ""
	echo "Output files will be compressed with gzip if specified in their file extension with \".fastq.gz\"."
	echo ""
	echo "If not specified, tha BAM file will be considered paired-end and the resulting FASTQ files will be named as the BAM file inputed in the program, without the file extension \".bam\". The files will be written in the same folder where the input BAM file is."
	echo ""
	echo "Lack of necessary input or not found BAM file will lead to end of execution and display of the help message."
	echo ""
	echo "Example of usage:"
	echo "uBam2Fastq.sh myreads.bam myreads_R1.fastq.gz myreads_R2.fastq.gz"
	echo "uBam2Fastq.sh myreads.bam single-end myreads.fastq"
	echo ""
	exit 1
}

# picard.jar location
if [ -z "$PICARD" ]; then
	echo "ERROR: \$PICARD was not declared. Please set \$PICARD to yout picard.jar file and export the variable."
	exit 1
elif [ ! -f "$PICARD" ]; then
	echo "ERROR: \$PICARD = $PICARD does not exist."
	exit 1
fi

# Variables
if [ -f "$1" ]; then
	file_bam="$1"
else
	help
fi

sample="${file_bam%.bam}"

if [ "$2" == "single-end" ]; then
	SE=true
elif [ -z "$2" ]; then
	path_bam="${file_bam%/*}"
	file_R1="${path_bam}/${sample}_R1.fastq.gz"
	SE=false
elif [ -f "$2" ]; then
	file_R1="$2"
	SE=false
else
	help
fi

if [ -z "$3" ]; then
	path_bam="${file_bam%/*}"
	if [ "$SE" = true ]; then
		file_R2="${path_bam}/${sample}.fastq.gz"
	else
		file_R2="${path_bam}/${sample}_R2.fastq.gz"
	fi
elif [ -f "$3" ]; then
	file_R2="$3"
else
	help
fi

if echo "$file_R2" | grep -q ".gz"; then
	compressed=true
else
	compressed=false
fi

# Transform to FASTQ
if [ "$SE" = true ]; then
	java -jar "$PICARD" SamToFastq \
		I="$file_bam" \
		FASTQ="$file_R2"
else
	java -jar "$PICARD" SamToFastq \
     	I="$file_bam" \
     	F1="$file_R1" \
     	F2="$file_R2"
fi

# Modify @SEQ_ID lines so no info is lost
if [ -x "$( command -v perl )" ] ; then
	# Perl is faster than sed and awk
	perl -i -pe '/^@/ && s/;/\ /g' "$file_R2"
	if [ ! "$SE" = true ]; then
		perl -i -pe '/^@/ && s/;/\ /g' "$file_R1"
	fi
else
	# Use sed if perl is not in $PATH
	sed -i 's/;/\ /g' > "$file_R2"
	if [ ! "$SE" = true ]; then
		sed -i 's/;/\ /g' "$file_R1"
	fi
fi

# Compress
if [ "$compressed" = true ]; then
	mv $file_R2 ${file_R2%.gz}
	gzip ${file_R2%.gz}
	if [ ! "$SE" = true ]; then
		mv $file_R1 ${file_R1%.gz}
		gzip ${file_R1%.gz}
	fi
fi