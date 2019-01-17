#!/bin/bash

###################################################################
#
# This script is designed to benchmark the compression rate and
# computing time of the methods used in Fastq2uBam.sh and 
# uBam2Fastq.sh.
#
# To execute it just pass as argument a folder with some paired-end
# Fastq files. All the computation will take place in the same 
# folder, creating new files but without modifying the original 
# ones.
#
# Output will be printed to stout. You can easily redirect to a 
# file with ">".
#
# Example of usage:
# benchmark.sh /path/to/my/folder/with/fastqgzfiles/ > report.txt
#
###################################################################

# Help
function help {
	echo ""
	echo "This script is designed to benchmark the compression rate and computing time of the methods used in Fastq2uBam.sh and  uBam2Fastq.sh."
	echo ""
	echo "To execute it just pass as argument a folder with some paired-end Fastq files. All the computation will take place in the same folder, creating new files but without modifying the original ones."
	echo ""
	echo "Output will be printed to stout. You can easily redirect to a file with \">\"."
	echo ""
	echo "Example of usage:"
	echo "benchmark.sh /path/to/my/folder/with/fastqgzfiles/ > report.txt"
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

# Move to working directory
if [ -d "$1" ]; then
	cd "$1"
	echo "Benchmarking compression rate and time for pair end \"_R?.fastq.gz\" files inside $1."
else
	echo "ERROR: $1 does not exist."
	help
fi

# RAW size
echo "RAW fastq file sizes in bytes:";
for file in *.fastq.gz; do du -k "$file"; done

# Uncompress computation time
echo;
echo "Uncompress time requirement:";
for file in *.fastq.gz; do 
	start=`date +%s`
	gzip -d "$file"
	end=`date +%s`
	runtime_compression=$((end-start))
	echo "$file $runtime_compression";
done

# Edit computation time
echo;
echo "Edit time requirement:";
for file in *.fastq; do 
	sample=${file%.fastq}
	start=`date +%s`
	cat "$file" | perl -pe 's/\ /;/g' > ${sample}.fastq.perl_full
	end=`date +%s`
	runtime_perl_replacement_full=$((end-start))
	start=`date +%s`
	cat "$file" | perl -pe '/^@/ && s/\ /;/g' > ${sample}.fastq.perl
	end=`date +%s`
	runtime_perl_replacement=$((end-start))
	start=`date +%s`
	cat "$file" | perl -pe sed 's/\ /;/g' > ${sample}.fastq.sed
	end=`date +%s`
	runtime_sed_replacement=$((end-start))
	echo "$sample perl_replacement_full $runtime_perl_replacement_full perl_replacement $runtime_perl_replacement sed_replacement $runtime_sed_replacement";
done

# Fastq2Bam computation time
echo;
echo "Mapping time requirement:";
for file_R1 in *_R1.fastq.perl; do
	file_R1=${file_R1%.perl}
	start=`date +%s`
	file_R2=${file_R1%_R2.fastq}_R2.fastq
	file_bam=${file_R1%_R1.fastq}_picard.bam
	sample=${file_R1%_R1.fastq}
	java -jar "$PICARD" FastqToSam \
		F1="$file_R1" \
		F2="$file_R2" \
	 	O="$file_bam" \
		SM="$sample" 
	end=`date +%s`
	runtime=$((end-start))
	echo "$sample $runtime";
done

# BAM size
echo;
echo "BAM file sizes in bytes:";
for file in *.bam; do du -k "$file"; done

# Bam2Fastq computation time
echo;
echo "BAM2FQ time requirement:";
for file_bam in *picard.bam; do
	start=`date +%s`
	file_R1=${file_bam%.bam}_R1.fastq
	file_R2=${file_bam%.bam}_R2.fastq
	sample=${file_R1%picard_R1.fastq}
	java -jar "$PICARD" SamToFastq \
		I=$file_bam \
		FASTQ=$file_R1 \
		F2=$file_R2
	end=`date +%s`
	runtime=$((end-start))
	echo "$sample $runtime";
done

# Edit computation time
echo;
echo "Edit time requirement:";
for file in *picard_R?.fastq; do 
	sample=${file%.fastq}
	start=`date +%s`
	cat "$file" | perl -pe 's/;/\ /g' > ${sample}.fastq.perl_full
	end=`date +%s`
	runtime_perl_replacement_full=$((end-start))
	start=`date +%s`
	cat "$file" | perl -pe '/^@/ && s/;/\ /g' > ${sample}.fastq.perl
	end=`date +%s`
	runtime_perl_replacement=$((end-start))
	start=`date +%s`
	cat "$file" | perl -pe sed 's/;/\ /g' > ${sample}.fastq.sed
	end=`date +%s`
	runtime_sed_replacement=$((end-start))
	echo "$sample perl_replacement_full $runtime_perl_replacement_full perl_replacement $runtime_perl_replacement sed_replacement $runtime_sed_replacement";
done

# Compress computation time
echo;
echo "Compress time requirement:";
for file in *picard_R?.fastq.perl; do 
	start=`date +%s`
	gzip "$file"
	end=`date +%s`
	runtime_compression=$((end-start))
	echo "$file $runtime_compression";
done
