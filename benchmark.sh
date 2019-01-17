#!/bin/bash

echo "RAW fastq file sizes in bytes:";
for file in *.fastq.gz; do du -k $file; done

echo;
echo "Mapping time requirement:";
for file_R1 in *R1_001.fastq.gz; do
start=`date +%s`
file_R2=${file_R1%R1_001.fastq.gz}R2_001.fastq.gz
file_bam=${file_R1%_R1_001.fastq.gz}_picard.bam
sample=${file_R1%_R1_001.fastq.gz}
java -jar /opt/picard-tools/picard.jar FastqToSam \
       F1=$file_R1 \
       F2=$file_R2 \
       O=$file_bam \
       SM=$sample 
end=`date +%s`
runtime=$((end-start))
echo "$sample $runtime";
done


echo;
echo "BAM file sizes in bytes:";
for file in *.bam; do du -k $file; done

echo;
echo "BAM2FQ time requirement:";
for file_bam in *picard.bam; do
start=`date +%s`
file_R1=${file_bam%.bam}_R1.fastq
file_R2=${file_bam%.bam}_R2.fastq
sample=${file_R1%picard_R1.fastq}
java -jar /opt/picard-tools/picard.jar SamToFastq \
     I=$file_bam \
     FASTQ=$file_R1 \
     F2=$file_R2
end=`date +%s`
runtime=$((end-start))
echo "$sample $runtime";
done

echo;
echo "Compress BAM files:";
for file in *.bam; do
	gzip < $file > ${file}.gz
	du -k ${file}.gz
done
