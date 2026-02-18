#!/bin/bash

if [[ $1 == "infected" ]]; then
    read_dir="<path/to/BAMs>"
    samples="ECA1388,ECA2679,ECA2680,ECA2681,ECA2682,ECA2683,ECA2684,ECA2685,ECA2686"
    unaligned_dir="<path/to/store/unaligned_reads/infected>"
    outdirKraken="../../processed_data/Kraken2/c_elegans/microsporidia_ctr/infected"
elif [[ $1 == "control" ]]; then
    read_dir="<path/to/BAMS>"
    samples="ECA1389,ECA1211,ECA1214,ECA1228,ECA1269,ECA1281,ECA1282,ECA1287,ECA2803"
    unaligned_dir="<path/to/store/unaligned_reads/notInfected>"
    outdirKraken="../../processed_data/Kraken2/c_elegans/microsporidia_ctr/notInfected/"
else
    echo "Invalid argument"
    exit 1
fi


IFS=',' read -a sample_array <<< "$samples"

# Extracting unaligned reads for control samples
for sample in "${sample_array[@]}"; do
    input_bam="$read_dir/${sample}.bam"
    output_fastq="$unaligned_dir/unaligned_${sample}.fastq"
    if ! samtools view --output-fmt BAM --include-flags 4 "$input_bam" | samtools fastq - > "$output_fastq"; then
        echo "Error processing $input_bam"
        exit 1
    fi
done

# Running Kraken2 on unaligned reads
for sample in "${sample_array[@]}"; do
    input_fastq="$unaligned_dir/unaligned_${sample}.fastq"
    if ! kraken2 --db $database_path --report $outdirKraken/${sample}.k2report --report-minimizer-data --minimum-hit-groups 1 --output $outdirKraken/${sample}.kraken $input_fastq; then 
        echo "Error running Kraken2 on $input_fastq"
        exit 1
    fi
done
