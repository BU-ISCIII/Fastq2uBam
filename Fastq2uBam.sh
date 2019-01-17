#!/bin/bash

###################################################################
#
# This script takes FASTQ files (either one single-end or two
# paired-end files) and transforms them in an unaligned BAM file.
#
# IMPORTANT: $PICARD must be declared in your environment and
# pointing to the picard.jar file you want to use.
#
# One FASTQ file must be inputed as argument for single-end mode
# and two (R1 and R2, in that order) for paired-end mode. For
# single-end mode, a second parameter "single-end" must be included.
#
# Input FASTQ files can be compressed in gzip format. In this case
# the must be named with the file extension ".fastq.gz".
#
# If not specified, the resulting BAM file will be named as the
# first FASTQ file inputed in the program, removing everything after
# "_R1" and changing the file extension for ".bam". The file will be
# written in the same folder where the first FASTQ file is.
#
# Lack of necessary input or not found FASTQ file will lead to
# end of execution and display of the help message.
#
# Example of usage:
# Fastq2uBam.sh myreads_R1.fastq.gz myreads_R2.fastq.gz myreads.bam
# Fastq2uBam.sh myreads.fastq single-end myreads.bam
#
###################################################################

# Help
function help {
	echo "This script takes FASTQ files (either one single-end or two paired-end files) and transforms them in an unaligned BAM file."
	echo ""
	echo "IMPORTANT: \$PICARD must be declared in your environment and pointing to the picard.jar file you want to use."
	echo ""
	echo "One FASTQ file must be inputed as argument for single-end mode and two (R1 and R2, in that order) for paired-end mode. For single-end mode, a second parameter \"single-end\" must be included."
	echo ""
	echo "Input FASTQ files can be compressed in gzip format. In this case the must be named with the file extension \".fastq.gz\"."
	echo ""
	echo "If not specified, the resulting BAM file will be named as the first FASTQ file inputed in the program, removing everything after \"_R1\" and changing the file extension for \".bam\". The file will be written in the same folder where the first FASTQ file is."
	echo ""
	echo "Lack of necessary input or not found FASTQ file will lead to end of execution and display of the help message."
	echo ""
	echo "Example of usage:"
	echo "Fastq2uBam.sh myreads_R1.fastq.gz myreads_R2.fastq.gz myreads.bam"
	echo "Fastq2uBam.sh myreads.fastq single-end myreads.bam"
	echo ""
	exit 1
}

# picard.jar location
if [ -z "$PICARD" ]; then
	echo "ERROR: \$PICARD was not declared. Please set \$PICARD to yout picard.jar file."
	exit 1
elif [ ! -f "$PICARD" ]; then
	echo "ERROR: \$PICARD = $PICARD does not exist."
	exit 1
fi

# Variables
if [ -f "$1" ]; then
	file_R1="$1"
else
	help
fi

if [ "$2" == "single-end" ]; then
	SE=true
elif [ -f "$2" ]; then
	file_R2="$2"
	SE=false
else
	help
fi

if echo "$file_R1" | grep -q ".gz"; then
	compressed=true
	sample="${file_R1%.gz}"
else
	compressed=false
fi

sample="${file_R1%.fastq}"

sample="${file_R1%_R1*}"

if [ -z "$3" ]; then
	file_bam="$3"
else
	path_bam="${file_R1%/*}"
	file_bam="${path_bam}/${sample}.bam"
fi

# Modify @SEQ_ID lines so no info is lost
if [ -x "$( command -v perl )" ] ; then
	# Perl is faster than sed and awk
	if [ "$compressd" = true ]; then
		zcat "$file_R1" | perl -pe '/^@/ && s/\ /;/g' > tmp_R1
		if [ ! "$SE" = true ]; then
			zcat "$file_R2" | perl -pe '/^@/ && s/\ /;/g' > tmp_R2
		fi
	else
		cat "$file_R1" | perl -pe '/^@/ && s/\ /;/g' > tmp_R1
		if [ ! "$SE" = true ]; then
			cat "$file_R2" | perl -pe '/^@/ && s/\ /;/g' > tmp_R2
		fi
	fi
else
	# Use sed if perl is not in $PATH
	if [ "$compressd" = true ]; then
		zcat "$file_R1" | sed 's/\ /;/g' > tmp_R1
		if [ ! "$SE" = true ]; then
			zcat "$file_R2" | sed 's/\ /;/g' > tmp_R2
		fi
	else
		cat "$file_R1" | sed 's/\ /;/g' > tmp_R1
		if [ ! "$SE" = true ]; then
			cat "$file_R2" | sed 's/\ /;/g' > tmp_R2
		fi
	fi
fi

# Transform to BAM
if [ "$SE" = true ]; then
	java -jar "$PICARD" FastqToSam \
		FASTQ=tmp_R1 \
		O="$file_bam" \
		SM="$sample"
else
	java -jar "$PICARD" FastqToSam \
		F1=tmp_R1 \
		F2=tmp_R2 \
		O="$file_bam" \
		SM="$sample"
fi

# Clean tmp files
rm -rf tmp_R1 tmp_R2
