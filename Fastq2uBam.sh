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
# Fastq2uBam.sh -1 myreads_R1.fastq.gz -2 myreads_R2.fastq.gz -o myreads.bam --PLATFORM ILLUMINA --SEQUENCING_CENTER ISCIII
# Fastq2uBam.sh -1 myreads.fastq -2 single-end -o myreads.bam
#
# Optional arguments: Any other optional arguments for piccard can
# be added, just need to be written in format
#     "--ARGUMENT=VALUE" or "-ARG=VALUE"
#
# Full list of available optional argumentes here:
# https://software.broadinstitute.org/gatk/documentation/tooldocs/4.0.5.1/picard_sam_FastqToSam.php
#
###################################################################

# Help
function help {
    cat << EOF
    
    This script takes FASTQ files (either one single-end or two paired-end files) and transforms them in an unaligned BAM file.
    
    IMPORTANT: \$PICARD must be declared in your environment and pointing to the picard.jar file you want to use.
    
    One FASTQ file must be inputed as argument for single-end mode and two (R1 and R2, in that order) for paired-end mode. For single-end mode, a second parameter "single-end" must be included.
    
    Input FASTQ files can be compressed in gzip format. In this case the must be named with the file extension ".fastq.gz".
    
    If not specified, the resulting BAM file will be named as the first FASTQ file inputed in the program, removing everything after "_R1" and changing the file extension for ".bam". The file will be written in the same folder where the first FASTQ file is.
    
    Lack of necessary input or not found FASTQ file will lead to end of execution and display of the help message.
    
    Example of usage:
    Fastq2uBam.sh -1 myreads_R1.fastq.gz -2 myreads_R2.fastq.gz -o myreads.bam --PLATFORM ILLUMINA --SEQUENCING_CENTER ISCIII
    Fastq2uBam.sh -1 myreads.fastq -2 single-end -o myreads.bam
    
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
    	--FASTQ)	set -- "$@"	-F1 ;;
		--FASTQ2)	set -- "$@"	-F2 ;;
        # OPTIONAL
		--OUTPUT)	set -- "$@"	-O ;;
        # PICARD
        --SAMPLE_NAME)	set -- "$@"	-S ;;
        --DESCRIPTION)	set -- "$@"	-DS ;;
        --LIBRARY_NAME)	set -- "$@"	-LB ;;
        --PLATFORM)	set -- "$@"	-PL ;;
        --PLATFORM_MODEL)	set -- "$@"	-PM ;;
        --PLATFORM_UNIT)	set -- "$@"	-PU ;;
        --PREDICTED_INSERT_SIZE)	set -- "$@"	-PI ;;
        --PROGRAM_GROUP)	set -- "$@"	-PG ;;
        --QUALITY_FORMAT)	set -- "$@"	-V ;;
        --READ_GROUP_NAME)	set -- "$@"	-RG ;;
        --RUN_DATE)	set -- "$@"	-DT ;;
        --SEQUENCING_CENTER)	set -- "$@"	-CN ;;
        --SORT_ORDER)	set -- "$@"	-SO ;;
        --MAX_Q)	set -- "$@"	--MAX_Q ;;
        --MIN_Q)	set -- "$@"	--MIN_Q ;;
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
    	-F1)	set -- "$@"	-1 ;;
		-F2)	set -- "$@"	-2 ;;
        # OPTIONAL
		-O) set -- "$@"	-o ;;
        # PICARD
        -S)	set -- "$@"	-s ;;
        -DS)	set -- "$@"	-d ;;
        -LB)	set -- "$@"	-l ;;
        -PL)	set -- "$@"	-p ;;
        -PM)	set -- "$@"	-m ;;
        -PU)	set -- "$@"	-u ;;
        -PI)	set -- "$@"	-i ;;
        -PG)	set -- "$@"	-g ;;
        -V)	set -- "$@"	-V ;;
        -RG)	set -- "$@"	-r ;;
        -DT)	set -- "$@"	-D ;;
        -CN)	set -- "$@"	-c ;;
        -SO)	set -- "$@"	-O ;;
        --MAX_Q)	set -- "$@"	-Q ;;
        --MIN_Q)	set -- "$@"	-q ;;
        # pass through anything else
        *)  set -- "$@" "$arg" ;;
    esac
done

#PARSE VARIABLE ARGUMENTS WITH getops
options=":1:2:o:s:d:l:p:m:u:i:g:V:r:D:c:O:Q:q"
picard_args=""
while getopts $options opt; do
	case $opt in
		1 )
			file_R1=$OPTARG
			;;
		2 )
			file_R2=$OPTARG
			;;
        o )
            file_bam=$OPTARG
            ;;
        s )
            sample=$OPTARG
            ;;
        d )
            description=$OPTARG
            picard_args="${picard} DS=${description}"
            ;;
        l )
            library_name=$OPTARG
            picard_args="${picard} LB=${libary_name}"
            ;;
        p )
            platform=$OPTARG
            picard_args="${picard} PL=${platform}"
            ;;
        m )
            platform_model=$OPTARG
            picard_args="${picard} PM=${platform_model}"
            ;;
        u )
            platform_unit=$OPTARG
            picard_args="${picard} PU=${platform_unit}"
            ;;
        i )
            predicted_insert_size=$OPTARG
            picard_args="${picard} PI=${predicted_insert_size}"
            ;;
        g )
            program_group=$OPTARG
            picard_args="${picard} PG=${program_group}"
            ;;
        V )
            quality_format=$OPTARG
            picard_args="${picard} V=${quality_format}"
            ;;
        r )
            read_group_name=$OPTARG
            picard_args="${picard} RG=${read_group_name}"
            ;;
        D )
            run_date=$OPTARG
            picard_args="${picard} DT=${run_date}"
            ;;
        c )
            sequencing_center=$OPTARG
            picard_args="${picard} CN=${sequencing_center}"
            ;;
        O )
            sort_order=$OPTARG
            picard_args="${picard} SO=${sort_order}"
            ;;
        Q )
            max_q=$OPTARG
            picard_args="${picard} MAX_Q=${max_q}"
            ;;
        q )
            min_q=$OPTARG
            picard_args="${picard} MIN_Q=${min_q}"
            ;;
        * )
			echo "Unimplemented option: -$OPTARG" >&2;
			exit 1
			;;
	esac
done
shift "$((OPTIND-1))"

# Variables
tmp_R1=tmp_${file_R1%.gz}
tmp_R2=tmp_${file_R2%.gz}

if [ ! -f "$file_R1" ]; then
    echo "ERROR: file $file_R1 does not exist." >&2
    help
fi

if [ "$file_R2" == "single-end" ]; then
    SE=true
elif [ -f "$file_R2" ]; then
    SE=false
else
    echo "ERROR: file $file_R2 does not exist." >&2
    help
fi

if echo "$file_R1" | grep -q ".gz"; then
    compressed=true
else
    compressed=false
fi

if [ -z "$sample" ]; then
    if [ "$compressed" = true ]; then
        sample="${file_R1%.gz}"
    else
        sample="${file_R1}"
    fi
    sample="${file_R1%.fastq}"
    sample="${file_R1%_R1*}"
fi

if [ -z "$file_bam" ]; then
    if echo "$file_R1" | grep -q "/"; then
        path_bam="${file_R1%/*}/"
    else
        path_bam="/"
    fi
    file_bam="${path_bam}${sample}.bam"
fi

if [ "$SE" = true ]; then
    picard_args="FASTQ=$tmp_R1 O=$file_bam SM=$sample ${picard_args}"
else
    picard_args="F1=$tmp_R1 F2=$tmp_R2 O=$file_bam SM=$sample ${picard_args}"
fi

# Modify @SEQ_ID lines so no info is lost
if [ -x "$( command -v perl )" ] ; then
    # Perl is faster under some cirumstances and, in this case, preciser than sed and awk
    if [ "$compressed" = true ]; then
        if [ ! "$SE" = true ]; then
            zcat "$file_R1" | perl -pe '/^@/ && s/\ 1/;/g' > "$tmp_R1" || exit 1
            zcat "$file_R2" | perl -pe '/^@/ && s/\ 2/;/g' > "$tmp_R2" || exit 1
        else
            zcat "$file_R1" | perl -pe '/^@/ && s/\ /;/g' > "$tmp_R1" || exit 1
        fi
    else
        if [ ! "$SE" = true ]; then
            cat "$file_R1" | perl -pe '/^@/ && s/\ 1/;/g' > "$tmp_R1" || exit 1
            cat "$file_R2" | perl -pe '/^@/ && s/\ 2/;/g' > "$tmp_R2" || exit 1
        else
            cat "$file_R1" | perl -pe '/^@/ && s/\ /;/g' > "$tmp_R1" || exit 1
        fi
    fi
else
    # Use sed if perl is not in $PATH
    if [ "$compressed" = true ]; then
        if [ ! "$SE" = true ]; then
            zcat "$file_R1" | sed 's/\ 1/;/g' > "$tmp_R1" || exit 1
            zcat "$file_R2" | sed 's/\ 2/;/g' > "$tmp_R2" || exit 1
        else
            zcat "$file_R1" | sed 's/\ /;/g' > "$tmp_R1" || exit 1
        fi
    else
        if [ ! "$SE" = true ]; then
            cat "$file_R1" | sed 's/\ 1/;/g' > "$tmp_R1" || exit 1
            cat "$file_R2" | sed 's/\ 2/;/g' > "$tmp_R2" || exit 1
        else
            cat "$file_R1" | sed 's/\ /;/g' > "$tmp_R1" || exit 1
        fi
    fi
fi

# Transform to BAM
java -jar "$PICARD" FastqToSam $picard_args || exit 1

# Clean tmp files
rm -rf "$tmp_R1" "$tmp_R2"  || exit 1
