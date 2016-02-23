#! bin/usr/env bash

## Question 1
#Use BEDtools intersect to identify the size of the largest overlap between
#CTCF and H3K4me3 locations.

datasets='/Users/mandyricher/Desktop/Classes/GenomicsWorkshop/data-sets'

H3K4="$datasets/bed/encode.h3k4me3.hela.chr22.bed.gz"
TFBS="$datasets/bed/encode.tfbs.chr22.bed.gz"

gzcat $TFBS | awk '$4 == "CTCF"' \
    | bedtools sort -i - > data/CTCF.bed

answer1=$(gzcat $H3K4 \
   | bedtools sort -i - \
   | bedtools intersect -a data/CTCF.bed -b - -wo \
   | awk '{print $NF}' \
   | sort -nr \
   | head -n1)


echo  "answer-1: $answer1"

## Question 2
#Use BEDtools to calculate the GC content of nucleotides 19,000,000 to
#19,000,500 on chr22 of `hg19` genome build. Report the GC content
#as a fraction (e.g., 0.50).

#Use bedtools nuc -fi <fasta> -bed <bed> contains ranges to extract
#You want column 2 - %GC content, but may need to change it to a fraction

HG19="$datasets/fasta/hg19.chr22.fa"
GC="/Users/mandyricher/Desktop/Classes/GenomicsWorkshop/problem-set-2/data/GC.bed"

echo -e "chr22\t19000000\t19000500" > $GC

answer2=$(bedtools nuc -fi $HG19 -bed $GC \
    | cut -f5 \
    | tail -n1)

echo "answer-2: $answer2"

## Question 3
#Use BEDtools to identify the length of the CTCF ChIP-seq peak (i.e.,
#interval) that has the largest mean signal in `ctcf.hela.chr22.bg.gz`.

#map, mean

#gunzip $datasets/bedtools/ctcf.hela.chr22.bg

CTCF="$datasets/bedtools/ctcf.hela.chr22.bg"

answer3=$(bedtools map -a data/CTCF.bed -b $CTCF -c 4 -o mean \
    | sort -k5n \
    | tail -n1 \
    | awk '{print $3 - $2}')

echo "answer-3: $answer3"


## Question 4
#Use BEDtools to identify the gene promoter (defined as 1000 bp upstream of
#a TSS) with the highest median signal in `ctcf.hela.chr22.bg.gz`.  Report
#the gene name (e.g., 'ABC123')

#promotors == 1000 bp upstream 
#bedtools flank -l(left) -s(strand)
#map median

TSS="$datasets/bed/tss.hg19.chr22.bed.gz"
GENOME="$datasets/genome/hg19.genome"
answer4=$(gzcat $TSS \
    | bedtools flank -s -i - -g $GENOME -l 1000 -r 0 \
    | bedtools sort -i - \
    | bedtools map -a - -b $CTCF -c 4 -o median \
    | sort -k7n \
    | tail -n1\
    | cut -f4)


echo "answer-4: $answer4"


## Question 5
#Use BEDtools to identify the longest interval on `chr22` that is not
#covered by `genes.hg19.bed.gz`. Report the interval like `chr1:100-500`.

#complement, given input intervals, it will give you back all the
#intervals not covered by the input
#Must also give it a genome file

GENES="$datasets/bed/genes.hg19.bed.gz"

awk '$1 == "chr22"' $GENOME > data/chr22.genome


answer5=$(gzcat $GENES \
    | awk '$1 == "chr22"' \
    | bedtools sort -i - \
    | bedtools complement -i - -g data/chr22.genome \
    | awk '{print $1, $2, $3, $3 - $2}'\
    | sort -k4n \
    | tail -n1 \
    | awk '{print $1":"$2"-"$3}')

echo "answer-5: $answer5"

## Question 6 (extra credit)
#Use one or more BEDtools that we haven't covered in class. Be creative.

#This uses bedtools reldist to find the relative distance between
#transcription factor binding sites and transcription start sites or genes

#I will make a plot of the information. 

gzcat $TSS > data/TSS.bed

gzcat $TFBS \
    | bedtools reldist -a - -b $TSS \
    > TSS_TFBS_reldist.tsv

gzcat $GENES \
    | awk '$1 == "chr22"' \
    | bedtools sort -i - \
    | bedtools reldist -a $TFBS -b - \
    > GENES_TFBS_reldist.tsv

echo "answer-6: see R plot"

