#!/bin/bash

#SBATCH -J KrakenRun
#SBATCH -A eande106_bigmem
#SBATCH -p bigmem
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=loconn13@jh.edu
#SBATCH --mail-type=END
#SBATCH --output=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/SLURM_output/initial_krakenBracken_run/core_ntRun.oe  
#SBATCH --error=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/SLURM_output/initial_krakenBracken_run/core_ntRun.rr 

if [[ $1 == "infected" ]]; then
    read_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/BAM"
    samples="ECA1388,ECA2679,ECA2680,ECA2681,ECA2682,ECA2683,ECA2684,ECA2685,ECA2686"
    unaligned_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/unaligned_reads/ctr_microspor_hawaii/infected"
    raw_data="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans"
    outdirKraken="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/infected/core_nt"
    Kraken_class_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/infected/core_nt/classification.txt"
    outdirBracken="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Bracken/microsporidia_ctr/infected/core_nt"
    Bracken_class_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Bracken/microsporidia_ctr/infected/core_nt/classification.txt"
elif [[ $1 == "control" ]]; then
    read_dir="/vast/eande106/data/c_elegans/WI/alignments"
    samples="ECA1389,ECA1211,ECA1214,ECA1228,ECA1269,ECA1281,ECA1282,ECA1287,ECA2803"
    unaligned_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/unaligned_reads/ctr_microspor_hawaii/notInfected"
    raw_data="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans"
    outdirKraken="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/notInfected/core_nt"
    Kraken_class_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/notInfected/core_nt/classification.txt"
    outdirBracken="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Bracken/microsporidia_ctr/notInfected/core_nt"
    Bracken_class_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Bracken/microsporidia_ctr/notInfected/core_nt/classification.txt"
else
    echo "Invalid argument"
    exit 1
fi


IFS=',' read -a sample_array <<< "$samples"

for sample in "${sample_array[@]}"; do
    input_bam="$read_dir/${sample}.bam"
    output_fastq="$unaligned_dir/unaligned_${sample}.fastq"
    if ! samtools view --output-fmt BAM --include-flags 4 "$input_bam" | samtools fastq - > "$output_fastq"; then
        echo "Error processing $input_bam"
        exit 1
    fi
done

echo "FASTQ for unaligned reads have been deposited to $unaligned_dir"

mkdir -p "$raw_data/databases/core_nt"

if [ ! -s "$raw_data/databases/core_nt/taxo.k2d" ]; then
    if ! wget --quiet --no-clobber -O "$raw_data/databases/core_nt/kraken/k2_core_nt_20240904.tar.gz" https://genome-idx.s3.amazonaws.com/kraken/k2_core_nt_20240904.tar.gz; then
        echo "Error downloading database"
        exit 1
    fi
    if ! tar --extract --verbose --file="$raw_data/databases/core_nt/k2_core_nt_20240904.tar.gz" --directory="$raw_data/databases/core_nt"; then
        echo "Error extracting Kraken2 database content"
        exit 1
    fi
fi

for sample in "${sample_array[@]}"; do
    input_fastq="$unaligned_dir/unaligned_${sample}.fastq"
    if ! kraken2 --db "$raw_data/databases/core_nt" --report "$outdirKraken/${sample}.k2report" --report-minimizer-data --minimum-hit-groups 1 --output "$outdirKraken/${sample}.kraken" "$input_fastq"; then 
            #Kraken2 automoatically determines optimal k-mer length based on database used
            #can change --minimun-hit-groups to optimize specificity - higher the value, higher the specificity
        echo "Error running Kraken2 on $input_fastq"
        exit 1
    fi
    if ! bracken -d "$raw_data/databases/core_nt" -i "$outdirKraken/${sample}.k2report" -o "$outdirBracken/${sample}.bracken" -w "$outdirBracken/${sample}.breport" -r 150 -l S; then
            #abundance for the "S" species level
        echo "Error running Bracken on $outdirKraken/${sample}.k2report"
        exit 1
    fi
done

#Extracting classification data for Kraken2
echo "Classificaiton of unaligned reads for: " > "$Kraken_class_file"
for sample in "${sample_array[@]}"; do 
    input_file="$outdirKraken/${sample}.k2report"
    echo "$sample: " >> "$Kraken_class_file"
    awk '$6 == "D" {print $0; exit}' "$input_file" >> "$Kraken_class_file"
    awk '$6 == "F" {print $0; exit}' "$input_file" >> "$Kraken_class_file"
    awk '$6 == "S" {print $0; exit}' "$input_file" >> "$Kraken_class_file"
done






