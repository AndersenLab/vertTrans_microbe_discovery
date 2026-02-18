#!/bin/bash

cd $db_path

# Downlaoding Kraken core_nt database
if ! wget https://genome-idx.s3.amazonaws.com/kraken/k2_core_nt_20240904.tar.gz; then
    echo "Error downloading core_nt database"
    exit 1
fi

# Extracting contents of database
if ! tar --extract --verbose --file="$db_path/k2_core_nt_20240904.tar.gz" --directory="$db_path"; then
        echo "Error extracting Kraken2 database content"
        exit 1
fi
