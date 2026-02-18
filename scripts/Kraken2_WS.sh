#!/bin/bash

#SBATCH -J KrakenBracken
#SBATCH -A eande106_bigmem
#SBATCH -p bigmem
#SBATCH -t 1:00:00
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=loconn13@jh.edu
#SBATCH --mail-type=END
#SBATCH --output=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/wild_strains/WS_run_iterativeJobs.oe  # collects what is written to stdout
#SBATCH --error=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/wild_strains/WS_run_iterativeJobs.rr

# while IFS= read -r fastq; do sbatch --export=strain=$fastq Kraken2_WS.sh c_briggsae; done < /vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_briggsae/unaligned_reads/wild_strains/cb_block1.txt
# while IFS= read -r fastq; do sbatch --export=strain=$fastq Kraken2_WS.sh c_elegans; done < /vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_briggsae/unaligned_reads/wild_strains/block1.txt
# while IFS= read -r fastq; do sbatch --export=strain=$fastq Kraken2_WS.sh c_tropicalis; done < /vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_tropicalis/unaligned_reads/wild_strains/need_to_process.txt

bam_dir="/vast/eande106/data/$1/WI/alignments"
unaligned_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/$1/unaligned_reads/wild_strains"
db="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/databases/core_nt"
output="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/$1/Kraken2/wild_strains"


strain_name=$(basename $strain _unaligned.fastq)
output_k2="$output/${strain_name}.k2report"
if [[ ! -f $output_k2 ]]; then
    if ! kraken2 --db $db --report $output_k2 --report-minimizer-data --minimum-hit-groups 1 --output "$output/${strain_name}.kraken" $unaligned_dir/$strain; then 
        echo "Error running Kraken2 on $strain"
        exit 1
    fi
fi


# # Extract unaligned reads from BAM files and convert to FASTQ
# for strain in "$bam_dir"/*.bam; do
#     strain_name=$(basename "$strain" .bam)
#     output_fastq="$unaligned_dir/${strain_name}_unaligned.fastq"
#     if [[ ! -f $output_fastq ]]; then
#         if ! samtools view --output-fmt BAM --include-flags 4 "$strain" | samtools fastq - > $output_fastq; then
#             echo "Error processing $strain"
#             exit 1
#         fi
#     fi
# done

# echo "FASTQ for unaligned reads have been deposited to $unaligned_dir"

# Run Kraken2 on the unaligned FASTQ files
# for strain in "$unaligned_dir"/*_unaligned.fastq; do
#     strain_name=$(basename "$strain" _unaligned.fastq)
#     output_k2="$output/${strain_name}.k2report"
#     if [[ ! -f $output_k2 ]]; then
#         if ! kraken2 --db $db --report $output_k2 --report-minimizer-data --minimum-hit-groups 1 --output "$output/${strain_name}.kraken" $strain; then 
#             # Kraken2 automatically determines optimal k-mer length based on database used
#             # Can change --minimum-hit-groups to optimize specificity - higher the value, higher the specificity
#             echo "Error running Kraken2 on $strain"
#             exit 1
#         fi
#     fi
# done

