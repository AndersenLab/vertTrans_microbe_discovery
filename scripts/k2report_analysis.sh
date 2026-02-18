#!/bin/bash

#SBATCH -J KrakenBracken
#SBATCH -A mschatz1
#SBATCH -p parallel
#SBATCH -t 1:00:00
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --mail-user=loconn13@jh.edu
#SBATCH --mail-type=END
#SBATCH --output=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/initial_krakenBracken_run/initialRun.oe  
#SBATCH --error=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/SLURM_output/initial_krakenBracken_run/initialRun.rr 

if [[ $1 == "c_elegans" ]]; then
    k2reports="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/c_elegans_Kraken2classification_10perc.txt"
    biasedfile="$k2reports/analysis/c_elegans_allWS_2perc_Rickettsiales.txt"
elif [[ $1 == "c_tropicalis" ]]; then
    k2reports="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_tropicalis/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/c_tropicalis_Kraken2classification_10perc.txt"
    biasedfile="$k2reports/analysis/c_tropicalis_allWS_2perc_Rickettsiales.txt"
elif [[ $1 == "c_briggsae" ]]; then
    k2reports="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_briggsae/Kraken2/wild_strains"
    Kraken_class_file="$k2reports/analysis/c_briggsae_Kraken2classification_10perc.txt"
    biasedfile="$k2reports/analysis/c_briggsae_allWS_2perc_Rickettsiales.txt"
elif [[ $1 == "control" ]]; then
    infected="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/infected/core_nt"
    not_infected="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/notInfected/core_nt"
    Kraken_class_file="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/analysis/microsporCtrKraken2classification_11perc.txt"
else
    echo "Invalid argument"
    exit 1
fi

# Initialize a blank file
# echo -e "NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" > "$Kraken_class_file"

# for strain in "$k2reports"/*.k2report; do 
#     strain_name=$(basename "$strain" .k2report)
#     hits_found=0
#     awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
#     awk -v strain_name="$strain_name" '$1 >= 10.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
#     awk -v strain_name="$strain_name" '
#         BEGIN {found_genus=0}
#         $1 >= 10.0 && $6 == "G" {found_genus=1}
#         $1 >= 10.0 && $6 == "S" && found_genus {
#             print strain_name, $0
#             found_genus=0
#         }s
#     ' $strain >> $Kraken_class_file
#     if grep -qw "$strain_name" "$Kraken_class_file"; then
#             hits_found=1
#     fi
#     if [[ $hits_found -eq 0 ]]; then
#         echo -e "$strain_name\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" >> "$Kraken_class_file"
#     fi
# done

if [[ $2 == "control" ]]; then 
    for strain in "$infected"/*.k2report; do 
        strain_name=$(basename $strain .k2report)
        hits_found=0
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 11.0 && $6 == "G" {found_genus=1}
            $1 >= 11.0 && $6 == "S" && found_genus {
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
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "F" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '$1 >= 11.0 && $6 == "G" {print strain_name, $0}' $strain >> $Kraken_class_file
        awk -v strain_name="$strain_name" '
            BEGIN {found_genus=0}
            $1 >= 11.0 && $6 == "G" {found_genus=1}
            $1 >= 11.0 && $6 == "S" && found_genus {
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



# Biased search for Robert - 4% cutoff and everything in Rickettsiales order
echo -e "NA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA" > $biasedfile

elif [[ $2 == "biased" ]]; then
    for strain in "$k2reports"/*.k2report; do 
        strain_name=$(basename "$strain" .k2report)
        hits_found=0
        
        awk -v strain_name="$strain_name" '
            BEGIN {found_rickettsiales=0}
            # If we find "Rickettsiales" at Order level (column 6 == "O") and >= 4.0% (column 1)
            $1 >= 2.0 && $6 == "O" && $8 == "Rickettsiales" {
                print strain_name, $0
                found_rickettsiales=1  
                next  # Continue processing the file
            }
            # Append subsequent families/genera/species until next order 
            found_rickettsiales && $1 >= 2.0 && $6 != "O" {
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


# sed -i '1d' $biasedfile

# sed -i '1d' $Kraken_class_file

