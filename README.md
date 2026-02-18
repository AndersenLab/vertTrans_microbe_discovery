## Vertically transmitted microbe detection from unaligned sequencing reads
This repository contains scripts for detecting potentially vertically transmitted microbes in wild strains of *C. elegans, C. tropicalis,* and *C. briggsae* using Kraken2 to taxonomically classify DNA from unaligned sequencing reads.

### The scripts to perform each analysis

#### Build Kraken2 database:
	scripts/kraken/databaseBuild.sh

#### Control analysis with microsporidia-infected strains (positive control) and non-infected strains (negative control):
	scripts/kraken/kraken_control_analysis.sh

#### Kraken2 analysis on wild strains of self-fertilizing *Caenorhabditis* species:
	scripts/kraken/kraken_wild_strains.sh

#### Filtering Kraken2 output
	scripts/kraken/wild_strain_kraken_filtering.sh


