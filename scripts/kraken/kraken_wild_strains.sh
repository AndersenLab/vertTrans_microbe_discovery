#!/bin/bash

# This script is meant to be run by iterating over a list of BAMs to extract unaligned reads and run Kraken2 on. 
# An example of how this script should be run:
# while read -r bam; do bash kraken_wild_strains.sh c_elegans $bam; done < <$c_elegans_bam_dir/bam_list>
# Download BAMs from CaeNDR

bam=$2

unaligned_dir="/<path/to/store_unaligned_FASTQs/$1/unaligned_reads"
output="/<path/to/store/Kraken2Output>/$1/Kraken2"

strain_name=$(basename $bam .bam)

# Extract unaligned reads from BAM files and convert to FASTQ
output_fastq="$unaligned_dir/${strain_name}_unaligned.fastq"
if [[ ! -f $output_fastq ]]; then
    if ! samtools view --output-fmt BAM --include-flags 4 $bam | samtools fastq - > $output_fastq; then
        echo "Error processing $bam"
        exit 1
    fi
fi

# Run Kraken2 on the unaligned FASTQ files
output_k2="$output/${strain_name}.k2report"
if [[ ! -f $output_k2 ]]; then
    if ! kraken2 --db $database_path --report $output_k2 --report-minimizer-data --minimum-hit-groups 1 --output $output/${strain_name}.kraken $output_fastq; then 
        echo "Error running Kraken2 on $bam"
        exit 1
    fi
fi
