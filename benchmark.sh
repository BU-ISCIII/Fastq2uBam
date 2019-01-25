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
#
# picard.jar location
if [ -z "$PICARD" ]; then
    echo "ERROR: \$PICARD was not declared. Please set \$PICARD to yout picard.jar file and export the variable."
    exit 1
elif [ ! -f "$PICARD" ]; then
    echo "ERROR: \$PICARD = $PICARD does not exist."
    exit 1
fi
#
# Move to working directory
if [ -d "$1" ]; then
    cd "$1"
    echo "Benchmarking compression rate and time for pair end \"_R?.fastq.gz\" files inside $1."
else
    echo "ERROR: $1 does not exist."
    help
fi
#
# RAW size
echo;
echo "RAW fastq file sizes in bytes:";
for file in *.fastq.gz; do du -k "$file" || exit 1; done
#
# Uncompress computation time
echo;
echo "Uncompress time requirement:";
for file in *.fastq.gz; do
    start=`date +%s`
    gzip -d "$file" || exit 1
    end=`date +%s`
    runtime_compression=$((end-start))
    echo "$file $runtime_compression";
done
#
# Edit computation time
echo;
echo "Edit time requirement:";
for file in *.fastq; do
    sample=${file%.fastq}
    start=`date +%s`
    cat "$file" | perl -pe 's/\ \d/;/g' > ${sample}.fastq.perl_full || exit 1
    end=`date +%s`
    runtime_perl_replacement_full=$((end-start))
    start=`date +%s`
    cat "$file" | perl -pe '/^@/ && s/\ \d/;/g' > ${sample}.fastq.perl || exit 1
    end=`date +%s`
    runtime_perl_replacement=$((end-start))
    start=`date +%s`
    cat "$file" | sed 's/\ [0-1]/;/g' > ${sample}.fastq.sed || exit 1
    end=`date +%s`
    runtime_sed_replacement=$((end-start))
    echo "$sample perl_replacement_full $runtime_perl_replacement_full perl_replacement $runtime_perl_replacement sed_replacement $runtime_sed_replacement";
done
rm -rf *.fastq.perl_full *.fastq.sed || exit 1

# Fastq2uBam computation time
echo;
echo "Fastq2uBam time requirement:";
for file_R1 in *_R1.fastq.perl; do
    start=`date +%s`
    file_R2=${file_R1%_R1.fastq.perl}_R2.fastq.perl
    file_bam=${file_R1%_R1.fastq}_picard.bam
    sample=${file_R1%_R1.fastq}
    java -jar "$PICARD" FastqToSam \
        F1="$file_R1" \
        F2="$file_R2" \
        O="$file_bam" \
        SM="$sample" \
        || exit 1
    end=`date +%s`
    runtime=$((end-start))
    echo "$sample $runtime";
    rm -rf "$file_R1" "$file_R2" || exit 1
done

# BAM size
echo;
echo "BAM file sizes in bytes:";
for file in *.bam; do du -k "$file" || exit 1; done

# uBam2Fastq computation time
echo;
echo "uBam2Fastq time requirement:";
for file_bam in *picard.bam; do
    start=`date +%s`
    file_R1=${file_bam%.bam}_R1.fastq
    file_R2=${file_bam%.bam}_R2.fastq
    sample=${file_R1%picard_R1.fastq}
    java -jar "$PICARD" SamToFastq \
        I=$file_bam \
        FASTQ=$file_R1 \
        F2=$file_R2 \
        || exit 1
    end=`date +%s`
    runtime=$((end-start))
    echo "$sample $runtime";
done

# Edit computation time
echo;
echo "Edit time requirement:";
for file_R1 in *picard_R1.fastq; do
    file_R2=${file_R1%_R1.fastq}_R2.fastq
    sample=${file_R1%.fastq}
    start=`date +%s`
    cat "$file_R1" | perl -pe 's/;/\ 1/g && s/\/\d$//g' > ${file_R1}.perl_full || exit 1
    cat "$file_R2" | perl -pe 's/;/\ 2/g && s/\/\d$//g' > ${file_R2}.perl_full || exit 1
    end=`date +%s`
    runtime_perl_replacement_full=$((end-start))
    start=`date +%s`
    cat "$file_R1" | perl -pe '/^@/ && s/;/\ 1/g && s/\/\d$//g' > ${file_R1}.perl || exit 1
    cat "$file_R2" | perl -pe '/^@/ && s/;/\ 2/g && s/\/\d$//g' > ${file_R2}.perl || exit 1
    end=`date +%s`
    runtime_perl_replacement=$((end-start))
    start=`date +%s`
    cat "$file_R1" | sed 's/;/\ 1/g' | sed 's/\/.$//g' > ${file_R1}.sed || exit 1
    cat "$file_R2" | sed 's/;/\ 2/g' | sed 's/\/.$//g' > ${file_R2}.sed || exit 1
    end=`date +%s`
    runtime_sed_replacement=$((end-start))
    echo "$sample perl_replacement_full $runtime_perl_replacement_full perl_replacement $runtime_perl_replacement sed_replacement $runtime_sed_replacement";
done
rm -rf *.fastq.perl_full *.fastq.sed || exit 1

# Compress computation time
echo;
echo "Compress time requirement:";
for file in *picard_R?.fastq.perl; do
    start=`date +%s`
    gzip "$file" || exit 1
    end=`date +%s`
    runtime_compression=$((end-start))
    echo "$file $runtime_compression";
done
