#!/bin/bash

# bash WS_filtering.sh c_elegans known_pathogens

# performed awk '($7 == "G" || $7 == "S") && $9 != "Caenorhabditis" {print $0}' C_tropicalis_Kraken2classification_10perc.txt > non_CaenGenera_10percKraken2class_Ct.txt
# to filter out Caenorhabditis from being classified and only keep genera

if [[ $1 == "c_elegans" ]]; then
    concat_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/non_CaenGenera_10percKraken2class_Ce.txt"
elif [[ $1 == "c_tropicalis" ]]; then
    concat_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_tropicalis/Kraken2/wild_strains/analysis/non_CaenGenera_10percKraken2class_Ct.txt"
elif [[ $1 == "c_briggsae" ]]; then
    concat_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_briggsae/Kraken2/wild_strains/analysis/non_CaenGenera_10percKraken2class_Cb.txt"
else
    echo "Invalid argument"
    exit 1
fi

if [[ $2 == "known_pathogens" ]]; then
    key="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/pathogens.txt"
    output_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/$1/Kraken2/wild_strains/analysis/filtGenera_10perc_knownPatho_$1.txt"
elif [[ $2 == "VTM_novel" ]]; then
    key="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/VTM_endosymbionts.txt"
    output_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/$1/Kraken2/wild_strains/analysis/filtGenera_10perc_VTMsEndosymb_$1.txt"
elif [[ $2 == "genera_filter" ]]; then
    key_genera="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/genera_filter.txt"
    key_species="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/species_filter.txt"
    output_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/$1/Kraken2/wild_strains/analysis/nonMiscGeneraSpecies_10perc_$1.txt"
fi 


> $output_file

if [[ $2 != "genera_filter" ]]; then
    while IFS= read -r genus; do
        awk -v genus="$genus" '$9 == genus {print $0}' "$concat_file" >> "$output_file"
    done < "$key"
else
    temp_file=$(mktemp)

    cp "$concat_file" "$temp_file"
    while IFS= read -r genus; do
        awk -v genus="$genus" '$9 != genus' "$temp_file" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
    done < "$key_genera"

    while IFS= read -r species; do
        awk -v species="$species" '$9 != species' "$temp_file" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
    done < "$key_species"

    mv "$temp_file" "$output_file"
fi

# Sort the output file by the second column from highest to lowest
sort -k2,2nr "$output_file" -o "$output_file"
