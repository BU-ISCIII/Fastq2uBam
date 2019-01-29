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
# uBam2Fastq.sh -i myreads.bam -1 myreads_R1.fastq.gz -2 myreads_R2.fastq.gz
# uBam2Fastq.sh -i myreads.bam -1 single-end -2 myreads.fastq
#
# Optional arguments: Any other optional arguments for piccard can
# be added, just need to be written in format
#     "--ARGUMENT VALUE" or "-ARG VALUE"
#
# Full list of available optional argumentes here:
# https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.5.1/picard_sam_FastqToSam.php
#
###################################################################

# Help
function help {
    cat << EOF
    
    This script takes an unaligned BAM file and transforms it to FASTQ format (either one single-end or two paired-end files)
    
    IMPORTANT: \$PICARD must be declared in your environment and pointing to the picard.jar file you want to use.
    
    One BAM file must be inputed as argument as long as the output for single-end mode and two (R1 and R2, in that order) for paired-end mode. For single-end mode, a second parameter "single-end" must be included.
    
    Output files will be compressed with gzip if specified in their file extension with ".fastq.gz".
    
    If not specified, tha BAM file will be considered paired-end and the resulting FASTQ files will be named as the BAM file inputed in the program, without the file extension ".bam". The files will be written in the same folder where the input BAM file is.
    
    Lack of necessary input or not found BAM file will lead to end of execution and display of the help message.
    
    Example of usage:
    uBam2Fastq.sh -i myreads.bam -1 myreads_R1.fastq.gz -2 myreads_R2.fastq.gz
    uBam2Fastq.sh -i myreads.bam -1 single-end -2 myreads.fastq
    
    Optional arguments: Any other optional arguments for piccard can be added, just need to be written in format
        "--ARGUMENT VALUE" or "-ARG VALUE"
    depending it you want to use the log or short name of the parameter.
    
    Full list of available optional argumentes here:
    https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.5.1/picard_sam_FastqToSam.php
    
EOF
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

# Paramenters
if [ $# = 0 ]; then
	echo "NO ARGUMENTS SUPPLIED"
	help >&2
	exit 1
fi

# translate long options to short
reset=true
for arg in "$@"
do
    if [ -n "$reset" ]; then
      unset reset
      set --      # this resets the "$@" array so we can rebuild it
    fi
    case "$arg" in
        # MANDATORY MINIMAL OPTIONS
    	--INPUT)	set -- "$@"	-I ;;
        # OPTIONAL ARGUMENTS
        --FASTQ)	set -- "$@"	-F ;;
        --SECOND_END_FASTQ)	set -- "$@"	-F2 ;;
        # PICARD
        --CLIPPING_ACTION)	set -- "$@"	-CLIP_ACT ;;
        --CLIPPING_ATTRIBUTE)	set -- "$@"	-CLIP_ATTR ;;
        --CLIPPING_MIN_LENGTH)	set -- "$@"	-CLIP_MIN ;;
        --INCLUDE_NON_PF_READS)	set -- "$@"	-NON_PF ;;
        --INCLUDE_NON_PRIMARY_ALIGNMENTS)	set -- "$@"	--INCLUDE_NON_PRIMARY_ALIGNMENTS ;;
        --INTERLEAVE)	set -- "$@"	 -INTER ;;
        --OUTPUT_PER_RG)	set -- "$@"	-OPRG ;;
        --QUALITY)	set -- "$@"	-Q ;;
        --RE_REVERSE)	set -- "$@"	-RC ;;
        --READ1_MAX_BASES_TO_WRITE)	set -- "$@"	-R1_MAX_BASES ;;
        --READ1_TRIM)	set -- "$@"	-R1_TRIM ;;
        --READ2_MAX_BASES_TO_WRITE)	set -- "$@"	-R2_MAX_BASES ;;
        --READ2_TRIM)	set -- "$@"	-R2_TRIM ;;
        --RG_TAG)	set -- "$@"	-RGT ;;
        --UNPAIRED_FASTQ)	set -- "$@"	-FU ;;
        # pass through anything else
        *)  set -- "$@" "$arg" ;;
    esac
done

# translate short to POSIX
reset=true
for arg in "$@"
do
    if [ -n "$reset" ]; then
      unset reset
      set --      # this resets the "$@" array so we can rebuild it
    fi
    case "$arg" in
        # MANDATORY MINIMAL OPTIONS
        -I) set -- "$@"	-i ;;
        # OPTIONAL ARGUMENTS
    	-F)	set -- "$@"	-1 ;;
		-F2)	set -- "$@"	-2 ;;
        # PICARD
        -CLIP_ACT)	set -- "$@"	-c ;;
        -CLIP_ATTR)	set -- "$@"	-a ;;
        -CLIP_MIN)	set -- "$@"	-m ;;
        -NON_PF)	set -- "$@"	-n ;;
        --INCLUDE_NON_PRIMARY_ALIGNMENTS)	set -- "$@"	-N ;;
        -INTER)	set -- "$@"	-I ;;
        -OPRG)	set -- "$@"	-r ;;
        -Q)	set -- "$@"	-q ;;
        -RC)	set -- "$@"	-R ;;
        -R1_MAX_BASES)	set -- "$@"	-b ;;
        -R1_TRIM)	set -- "$@"	-t ;;
        -R2_MAX_BASES)	set -- "$@"	-B ;;
        -R2_TRIM)	set -- "$@"	-T ;;
        -RGT)	set -- "$@"	-g ;;
        -FU)	set -- "$@"	-u ;;
        # pass through anything else
        *)  set -- "$@" "$arg" ;;
    esac
done

#PARSE VARIABLE ARGUMENTS WITH getops
options=":i:1:2:o:s:c:a:m:n:N:I:r:q:R:b:t:B:T:g:u"
picard_args=""
while getopts $options opt; do
	case $opt in
        i )
            file_bam=$OPTARG
            ;;
		1 )
			file_R1=$OPTARG
			;;
		2 )
			file_R2=$OPTARG
			;;
        c )
            clipping_action=$OPTARG
            picard_args="${picard} CLIP_ACT=${clipping_action}"
            ;;
        a )
            clipping_atribute=$OPTARG
            picard_args="${picard} CLIP_ATTR=${clipping_atribute}"
            ;;
        m )
            clipping_min_length=$OPTARG
            picard_args="${picard} CLIP_MIN=${clipping_min_length}"
            ;;
        n )
            include_non_pf_reads=$OPTARG
            picard_args="${picard} NON_PF=${include_non_pf_reads}"
            ;;
        N )
            include_non_primary_alignments=$OPTARG
            picard_args="${picard} INCLUDE_NON_PRIMARY_ALIGNMENTS=${include_non_primary_alignments}"
            ;;
        I )
            interleave=$OPTARG
            picard_args="${picard} INTER=${interleave}"
            ;;
        r )
            output_per_rg=$OPTARG
            picard_args="${picard} OPRG=${output_per_rg}"
            ;;
        q )
            quality=$OPTARG
            picard_args="${picard} Q=${quality}"
            ;;
        R )
            re_reverse=$OPTARG
            picard_args="${picard} RC=${re_reverse}"
            ;;
        b )
            r1_max_bases=$OPTARG
            picard_args="${picard} R1_MAX_BASES=${r1_max_bases}"
            ;;
        t )
            r1_trim=$OPTARG
            picard_args="${picard} R1_TRIM=${r1_trim}"
            ;;
        B )
            r2_max_bases=$OPTARG
            picard_args="${picard} R2_MAX_BASES=${r2_max_bases}"
            ;;
        T )
            r2_trim=$OPTARG
            picard_args="${picard} R2_TRIM=${r2_trim}"
            ;;
        g )
            rg_tag=$OPTARG
            picard_args="${picard} RGT=${rg_tag}"
            ;;
        u )
            unpaired_fastq=$OPTARG
            picard_args="${picard} FU=${unpaired_fastq}"
            ;;
        * )
			echo "Unimplemented option: -$OPTARG" >&2;
			exit 1
			;;
	esac
done
shift "$((OPTIND-1))"


# Variables
if [ ! -f "$file_bam" ]; then
    help
fi

sample="${file_bam%.bam}"

if [ "$file_R1" == "single-end" ]; then
    SE=true
elif [ ! -z "file_R1" ]; then
    SE=false
else
    path_bam="${file_bam%/*}"
    file_R1="${path_bam}/${sample}_R1.fastq.gz"
    SE=false
fi

if [ -z "$file_R2" ]; then
    if echo "$file_bam" | grep -q "/"; then
        path_bam="${file_bam%/*}/"
    else
        path_bam="/"
    fi
    if [ "$SE" = true ]; then
        file_R2="${path_bam}${sample}.fastq.gz"
    else
        if [ ! -z "$file_R1" ]; then
            file_R2="${file_R1/R1/R2}"
        else
            file_R2="${path_bam}/${sample}_R2.fastq.gz"
        fi
    fi
fi

if echo "$file_R2" | grep -q ".gz"; then
    compressed=true
    file_R2="${file_R2%.gz}"
    if [ ! "$SE" = true ]; then
        file_R1="${file_R1%.gz}"
    fi
else
    compressed=false
fi

if [ "$SE" = true ]; then
    picard_args="I=$file_bam F=$file_R2 ${picard_args}"
else
    picard_args="I=$file_bam F=$file_R1 F2=$file_R2 ${picard_args}"
fi

# Transform to FASTQ
java -jar "$PICARD" SamToFastq $picard_args || exit 1

# Modify @SEQ_ID lines so no info is lost
if [ -x "$( command -v perl )" ] ; then
    # Perl is faster than sed and awk
    if [ ! "$SE" = true ]; then
        perl -i -pe '/^@/ && s/;/\ 1/g && s/\/\d$//g' "$file_R1" || exit 1
        perl -i -pe '/^@/ && s/;/\ 2/g && s/\/\d$//g' "$file_R2" || exit 1
    else
        perl -i -pe '/^@/ && s/;/\ /g && s/\/\d$//g' "$file_R2" || exit 1
    fi
else
    # Use sed if perl is not in $PATH
    if [ ! "$SE" = true ]; then
        sed -i 's/;/\ 1/g' | sed 's/\/.$//g' "$file_R1" || exit 1
        sed -i 's/;/\ 2/g' | sed 's/\/.$//g' "$file_R2" || exit 1
    else
        sed -i 's/;/\ /g' | sed 's/\/.$//g' "$file_R2" || exit 1
    fi
fi

# Compress
if [ "$compressed" = true ]; then
    gzip "$file_R2" || exit 1
    if [ ! "$SE" = true ]; then
        gzip "$file_R1" || exit 1
    fi
fi
