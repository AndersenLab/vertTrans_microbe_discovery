#!/bin/bash

#SBATCH -J KrakenBracken
#SBATCH -A eande106_bigmem
#SBATCH -p bigmem
#SBATCH -t 12:00:00
#SBATCH -N 1
#SBATCH -n 10
#SBATCH --mail-user=loconn13@jh.edu
#SBATCH --mail-type=END
#SBATCH --output=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/SLURM_output/database_build/customBuild.oe  
#SBATCH --error=/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/SLURM_output/database_build/customBuild.rr 

db_path="/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/databases"

kraken2-build --download-taxonomy --db $db_path/custom
This will download the accession number to taxon maps, as well as the taxonomic name and tree information from NCBI. 
These files can be found in $DBNAME/taxonomy/ 

# in /vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/databases/core_nt, I peformed
if ! wget https://genome-idx.s3.amazonaws.com/kraken/k2_core_nt_20240904.tar.gz; then
    echo "Error downloading core_nt database"
    exit 1
fi
if ! tar --extract --verbose --file="$db_path/core_nt/k2_core_nt_20240904.tar.gz" --directory="$db_path"; then
        echo "Error extracting Kraken2 database content"
        exit 1
fi

# in /vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/databases/EukPath, I peformed
if ! wget https://genome-idx.s3.amazonaws.com/kraken/k2_eupathdb48_20230407.tar.gz; then
    echo "Error downloading EukPath database"
    exit 1
fi
if ! tar --extract --verbose --file="$db_path/EukPath/k2_eupathdb48_20230407.tar.gz" --directory="$db_path"; then
        echo "Error extracting Kraken2 database content"
        exit 1
fi

# do I need to peform this step?
cp $db_path/core_nt/*cnt.k2d $db_path/custom
cp $db_path/EukPath/*eukpath.k2d $db_path/custom

# downloading additional species that we want to add to the custom database in addition to core_nt and eupathdb48
### Sequences must be in a FASTA file (multi-FASTA is allowed)
### Each sequence's ID (the string between the > and the first whitespace character on the header line) must contain either an NCBI accession number to allow Kraken 2 to lookup the correct taxa, 
### or an explicit assignment of the taxonomy ID using kraken:taxid 

cd $db_path/custom

# using the package "ncbi-datasets-cli" to download genome
datasets download genome accession GCA_024243835.1 --include genome --filename enteropsectra_breve_genome.zip # NCBI taxonomy ID: 1912989
datasets download genome accession GCA_001642415.1 --include genome --filename N_ironsii_genome.zip # 1805481
datasets download genome accession GCA_024244115.1 --include genome --filename N_cider_genome.zip # 2670344
datasets download genome accession GCA_024244045.1 --include genome --filename N_botruosus_genome.zip # 2670343
datasets download genome accession GCA_024243985.1 --include genome --filename N_ferruginous_genome.zip # 2670340
I subsequently had to unzip, rename, and move .fna file to $db_path/custom for all 
## Must add "kraken:taxid|XX" to every sequence ID for each organism with the XX being the NCBI taxonomy ID number
sed 's/^>/&kraken:taxid|1912989 /' E_breve.fna > E_breve_w_taxID.fna


adding genomes to libarary
for file in $db_path/custom/*.fna; do
    kraken2-build --add-to-library $file --db $db_path/custom
done


kraken2-build --build --threads 10 --db $db_path/custom


kraken2 --db . --report ./ECA1211.k2report --report-minimizer-data --minimum-hit-groups 1 --output ./ECA1211.kraken /vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/raw_data/c_elegans/unaligned_reads/ctr_microspor_hawaii/notInfected/unaligned_ECA1211.fastq


