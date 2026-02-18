#!/bin/bash

####################################### INSERT CODE FOR REMOVING MISC WHITE SPACE IN THE LAST COLUMN 

# performed awk '($7 == "G" || $7 == "S") && $9 != "Caenorhabditis" {print $0}' C_tropicalis_Kraken2classification_10perc.txt > non_CaenGenera_10percKraken2class_Ct.txt
# to filter out Caenorhabditis from being classified and only keep genera

if [[ $1 == "c_elegans" ]]; then
    concat_file="../../processed_data/Kraken2/c_elegans/c_elegans_Kraken2classification_10perc.txt"
    key_genera="../../raw_data/genera_filter.txt"
    key_species="../../raw_data/species_filter.txt"
    output_file="../../processed_data/Kraken2/c_elegans/nonMiscGeneraSpecies_10perc_c_elegans.txt"
elif [[ $1 == "c_tropicalis" ]]; then
    concat_file="../../processed_data/Kraken2/c_tropicalis/c_tropicalis_Kraken2classification_10perc.txt"
    key_genera="../../raw_data/genera_filter.txt"
    key_species="../../raw_data/species_filter.txt"
    output_file="../../processed_data/Kraken2/c_tropicalis/nonMiscGeneraSpecies_10perc_c_tropicalis.txt"
elif [[ $1 == "c_briggsae" ]]; then
    concat_file="../../processed_data/Kraken2/c_briggsae/c_briggsae_Kraken2classification_10perc.txt"
    key_genera="../../raw_data/genera_filter.txt"
    key_species="../../raw_data/species_filter.txt"
    output_file="../../processed_data/Kraken2/c_briggsae/nonMiscGeneraSpecies_10perc_c_briggsae.txt"
else
    echo "Invalid argument"
    exit 1
fi


awk '
  FNR==NR { dropG[$1]=1; next } 
  FILENAME==ARGV[2] { dropS[$1]=1; next }
  {
    if ($7 == "G" && ($9 in dropG || $9 in dropS)) next
    if ($7 == "S" && ($9 in dropS || $9 in dropG)) next
    if ($7 == "NA") next
    if ($7 == "F") next
    print
  }
' $key_genera $key_species $concat_file > $output_file

