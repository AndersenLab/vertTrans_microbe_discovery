#!/bin/bash
#SBATCH -J KrakenBracken
#SBATCH -A mschatz1
#SBATCH -p parallel
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --output=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/stats_analysis/extractCoverage.oe  
#SBATCH --error=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/stats_analysis/extractCoverage.rr 

if [[ $1 == "c_elegans" ]]; then
    cov_file="/data/eande106/eande106/analysis/alignment-nf/20231203-CE/20240213_c_elegans_gatk_ss.tsv" #1618 strains - 13 short
    output_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis"
elif [[ $1 == "c_tropicalis" ]]; then
    cov_file="/data/eande106/eande106/analysis/alignment-nf/20231203-CT/20231206_c_tropicalis_gatk_ss.tsv" #690 strains - exact amount
    output_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_tropicalis/Kraken2/wild_strains/analysis"
elif [[ $1 = "c_briggsae" ]]; then
    cov_file="/data/eande106/eande106/analysis/alignment-nf/20231203-CB/20231208_c_briggsae_gatk_ss.tsv" #1786 strains - 4 short
    output_dir="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_briggsae/Kraken2/wild_strains/analysis"
fi

if [[ $2 == "NA" ]]; then

    ### Isolating strains that have no classification for any genera
    # awk '$2 == "NA" {print $1}' "$output_dir/${1}_Kraken2classification_10perc.txt" | sort > "$output_dir/${1}_NA_10perc_strainList.txt"
    
    ### Calculating mean coverage for each sample
    output_csv="$output_dir/seqCoverage/${1}_NA_10perc_strainList_aveCoverage.csv"
    echo "strain_name,coverage" > $output_csv
    while IFS= read -r strain; do 
        if [[ -f $cov_file ]]; then
            coverage=$(awk -v strain="$strain" '$1 == strain {print $4}' $cov_file)
            if [[ -n "$coverage" ]]; then
                echo "$strain,$coverage" >> "$output_csv"
            fi        
        else
            echo "coverage file not found"
        fi
    done < "$output_dir/${1}_NA_10perc_strainList.txt"
fi

if [[ $2 == "fluff_gen" ]]; then
    ### Isolating strains that have any genera classification 
    # awk '$2 != "NA" {print $1}' "$output_dir/${1}_Kraken2classification_10perc.txt" | sort | uniq > "$output_dir/${1}_allGenera_10perc_strainList.txt"
    
    ### Calculating mean coverage for each sample
    output_csv="$output_dir/seqCoverage/${1}_allGenera_10perc_strainList_aveCoverage.csv"
    echo "strain_name,coverage" > $output_csv
    while IFS= read -r strain; do 
        if [[ -f $cov_file ]]; then
            coverage=$(awk -v strain="$strain" '$1 == strain {print $4}' $cov_file)
            if [[ -n "$coverage" ]]; then
                echo "$strain,$coverage" >> "$output_csv"
            fi   
        else
            echo "coverage file not found"
        fi
    done < "$output_dir/${1}_allGenera_10perc_strainList.txt"
fi

if [[ $2 == "no_fluff_gen" ]]; then
    ### Isolating strains that have genera of interst ("no fluff" = (Caenorhabditis, Mus, Danio, Homo, Escherichia, Sphingomonas, Acinetobacter, Microbacterium, Pseudomonas))
    # awk '$7 == "G" {print $1}' "$output_dir/nonMiscGeneraSpecies_10perc_${1}.txt" | sort | uniq > "$output_dir/${1}_restrictedGenera_10perc_strainList.txt"
    
    ### Calculating mean coverage for each sample
    output_csv="$output_dir/seqCoverage/${1}_restrictedGenera_10perc_strainList_aveCoverage.csv"
    echo "strain_name,coverage" > $output_csv
    while IFS= read -r strain; do 
        if [[ -f $cov_file ]]; then
            coverage=$(awk -v strain="$strain" '$1 == strain {print $4}' $cov_file)
            if [[ -n "$coverage" ]]; then
                echo "$strain,$coverage" >> "$output_csv"
            fi
        else
            echo "coverage file not found"
        fi
    done < "$output_dir/${1}_restrictedGenera_10perc_strainList.txt"
fi

