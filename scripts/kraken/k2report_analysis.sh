#!/bin/bash

if [[ $1 == "c_elegans" ]]; then
    k2reports="../../processed_data/Kraken2/c_elegans"
    Kraken_class_file="$k2reports/c_elegans_Kraken2classification_10perc.txt"
    biasedfile="$k2reports/c_elegans_allWS_2perc_Rickettsiales.txt"
elif [[ $1 == "c_tropicalis" ]]; then
    k2reports="../../processed_data/Kraken2/c_tropicalis"
    Kraken_class_file="$k2reports/c_tropicalis_Kraken2classification_10perc.txt"
    biasedfile="$k2reports/analysis/c_tropicalis_allWS_2perc_Rickettsiales.txt"
elif [[ $1 == "c_briggsae" ]]; then
    k2reports="../../processed_data/c_briggsae/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/c_briggsae_Kraken2classification_10perc.txt"
    biasedfile="$k2reports/c_briggsae_allWS_2perc_Rickettsiales.txt"
elif [[ $1 == "control" ]]; then
    infected="../../processed_data/Kraken2/c_elegans/microsporidia_ctr/infected"
    not_infected="../../processed_data/Kraken2/c_elegans/microsporidia_ctr/notInfected"
    Kraken_class_file="../../processed_data/Kraken2/c_elegans/microsporidia_ctr/analysis/microsporCtrKraken2classification_10perc.txt"
else
    echo "Invalid argument"
    exit 1
fi

# Initialize a blank file
echo -e "NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" > "$Kraken_class_file"

if [[ $1 != "control" ]]; then
    for strain in "$k2reports"/*.k2report; do 
        strain_name=$(basename "$strain" .k2report)
        hits_found=0
        awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 10.0 && $6 == "G" {found_genus=1}
            $1 >= 10.0 && $6 == "S" && found_genus {
                print strain_name, $0
                found_genus=0
            }
        ' $strain >> $Kraken_class_file
        if grep -qw "$strain_name" "$Kraken_class_file"; then
                hits_found=1
        fi
        if [[ $hits_found -eq 0 ]]; then
            echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
        fi
    done
else 
    for strain in "$infected"/*.k2report; do 
        strain_name=$(basename $strain .k2report)
        hits_found=0
        awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 10.0 && $6 == "G" {found_genus=1}
            $1 >= 10.0 && $6 == "S" && found_genus {
                print strain_name, $0
                found_genus=0
            }
        ' $strain >> $Kraken_class_file
        if grep -qw "$strain_name" "$Kraken_class_file"; then
            hits_found=1
        fi
        if [[ $hits_found -eq 0 ]]; then
            echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
        fi
    done
    for strain in "$not_infected"/*.k2report; do 
        strain_name=$(basename $strain .k2report)
        hits_found=0
        awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 10.0 && $6 == "G" {found_genus=1}
            $1 >= 10.0 && $6 == "S" && found_genus {
                print strain_name, $0
                found_genus=0
            }
        ' $strain >> $Kraken_class_file
        if grep -qw "$strain_name" "$Kraken_class_file"; then
            hits_found=1
        fi
        if [[ $hits_found -eq 0 ]]; then
            echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
        fi
    done
fi


# Biased search for Rickettsiales order - 4% cutoff
echo -e "NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" > $biasedfile

if [[ $2 == "biased" && $1 != "control" ]]; then
    echo -e "NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" > $biasedfile

    for strain in "$k2reports"/*.k2report; do 
        strain_name=$(basename "$strain" .k2report)
        hits_found=0
        
        awk -v strain_name="$strain_name" '
            BEGIN {found_rickettsiales=0}
            # If we find "Rickettsiales" at Order level (column 6 == "O") and >= 4.0% (column 1)
            $1 >= 4.0 && $6 == "O" && $8 == "Rickettsiales" {
                print strain_name, $0
                found_rickettsiales=1  
                next  
            }
            # Append subsequent families/genera/species until next order 
            found_rickettsiales && $1 >= 4.0 && $6 != "O" {
                print strain_name, $0
            }
            found_rickettsiales && $6 == "O" && $8 != "Rickettsiales" {
                found_rickettsiales=0
            }
        ' $strain >> $biasedfile

        # Check if the strain was found in the output
        if grep -qw $strain_name $biasedfile; then
            hits_found=1
        fi

        # If no Rickettsiales hits were found, append "NA"
        if [[ $hits_found -eq 0 ]]; then
            echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> $biasedfile
        fi
    done
fi
