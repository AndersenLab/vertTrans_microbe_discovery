library(dplyr)
library(ggplot2)
library(ggtext)
library(stringr)
library(cowplot)
library(ggplotify)

genera <- c("Nematocida", "Achromobacter","Brevundimonas", "Pseudochrobactrum", "Cupriavidus", "Myroides", "Kocuria", "Streptomyces") # Genera that are mentioned in the paper 

# Reading in Ce negative control info
control_ni <- readr::read_tsv("../../processed_data/Kraken2/c_elegans/microsporidia_ctr/notInfected/all_strain_class.tsv", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::distinct(strain) %>%
  dplyr::mutate(perc = 0, genus = NA, species = "C.e. control (not-infected)") 

control_ni <- tidyr::expand_grid(
  strain = control_ni$strain,
  genus  = genera) %>%
  mutate(perc = 0, species = "C.e. control (not-infected)")

# Reading in Ce positive control info
control_i <- readr::read_tsv("../../processed_data/Kraken2/c_elegans/microsporidia_ctr/infected/all_strain_class.tsv", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::mutate(perc = ifelse(perc >= 10, perc, 0)) %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C.e. control (infected)")  %>%
  dplyr::arrange(desc(perc)) 

# Reading in Ce Kraken2 filtered results
ce <- readr::read_tsv("../../processed_data/Kraken2/c_elegans/nonMiscGeneraSpecies_10perc_c_elegans.txt", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C. elegans", force_top = strain %in% c("NIC2011", "ECA1191", "NIC1781", "QG2833", "ECA1297")) %>%
  dplyr::arrange(desc(force_top), desc(perc)) %>%
  dplyr::select(-force_top)
  
ce_top15strains <- ce %>% dplyr::distinct(strain) %>% dplyr::slice_head(n=9) %>% dplyr::pull(strain)

ce <- ce %>% dplyr::filter(strain %in% ce_top15strains)
  
# Reading in Cb Kraken2 filtered results
cb <- readr::read_tsv("../../processed_data/Kraken2/c_briggsae/nonMiscGeneraSpecies_10perc_c_briggsae.txt", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C. briggsae", force_top = strain %in% c("NIC1204", "ED3032")) %>%
  dplyr::arrange(desc(force_top), desc(perc)) %>%
  dplyr::select(-force_top)

cb_top15strains <- cb %>% dplyr::distinct(strain) %>% dplyr::slice_head(n=9) %>% dplyr::pull(strain)

cb <- cb %>% dplyr::filter(strain %in% cb_top15strains)

# Reading in Ct Kraken2 filtered results
ct <- readr::read_tsv("../../processed_data/Kraken2/c_tropicalis/nonMiscGeneraSpecies_10perc_c_tropicalis.txt", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C. tropicalis")  %>%
  dplyr::arrange(desc(perc))

ct_top15strains <- ct %>% dplyr::distinct(strain) %>% dplyr::slice_head(n=9) %>% dplyr::pull(strain)

ct <- ct %>% dplyr::filter(strain %in% ct_top15strains)

all <- bind_rows(control_ni, control_i, ce, cb, ct) %>%
  dplyr::group_by(species, strain) %>%
  tidyr::complete(genus = genera, fill = list(perc = 0)) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(genus = factor(genus, levels = rev(genera))) %>%
  dplyr::mutate(species_lab = dplyr::recode(species,
      "C. elegans"   = "<i>C. elegans</i>",
      "C. briggsae"  = "<i>C. briggsae</i>",
      "C. tropicalis"= "<i>C. tropicalis</i>",
      "C.e. control (infected)"     = "<i>C.e.</i>",
      "C.e. control (not-infected)" = "<i>C.e.</i>")) 

ctr_plot <- all %>%
  dplyr::filter(grepl("<i>C.e.",species_lab)) %>%
  dplyr::mutate(species_lab = ifelse(species_lab == "<i>C.e.</i>", paste0("<i>C.e.</i>", "         "," control"), paste0("<i>C.e.</i>", "     ", " control"))) %>%
  dplyr::mutate(control = ifelse(species == "C.e. control (infected)", "(infected)", "(not-infected)")) 

species_plot <- all %>%
  dplyr::filter(!grepl("<i>C.e.", species_lab)) %>%
  dplyr::mutate(species_lab = factor(species_lab, levels = c("<i>C. elegans</i>","<i>C. briggsae</i>","<i>C. tropicalis</i>")))



plt_data <- ctr_plot %>% dplyr::bind_rows(species_plot) %>% 
  dplyr::mutate(species_lab = dplyr::recode(species,
                                            "C. elegans"   = "<i>C. elegans</i>",
                                            "C. briggsae"  = "<i>C. briggsae</i>",
                                            "C. tropicalis"= "<i>C. tropicalis</i>",
                                            "C.e. control (infected)"     = "<i>C. elegans</i><br>Nematocide-infected",
                                            "C.e. control (not-infected)" = "<i>C. elegans</i><br>Uninfected")) %>%
  dplyr::mutate(species_lab = factor(species_lab, levels = c("<i>C. elegans</i><br>Nematocide-infected","<i>C. elegans</i><br>Uninfected","<i>C. elegans</i>","<i>C. briggsae</i>","<i>C. tropicalis</i>")))

fig_main <- ggplot(plt_data, aes(x = strain, y = genus, fill = perc)) +
  geom_tile(color = "white", linewidth = 0.15) +
  facet_wrap(~ species_lab, scales = "free_x", nrow = 1) +
  scale_fill_gradient(low = "skyblue", high = "red", name = "Percent minimizers", limits = c(0, 100)) +
  labs(x = NULL, y = NULL) +
  scale_y_discrete(expand = c(0,0), labels = c("Pseudochrobactrum" = "Pseudo-\nchrobactrum")) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_rect(fill = NA, color = 'black'),
    legend.title = element_text(size = 10, color = 'black'),
    legend.text  = element_text(size = 8),
    axis.text.x = element_text(angle = 75, vjust = 1, hjust = 1, color = 'black', size = 10),
    strip.text = ggtext::element_markdown(face = "bold", size = 7.3),
    panel.spacing.x = unit(0.2, "lines"),
    axis.text.y = element_text(size = 10, face = 'bold.italic', color = 'black'),
    plot.margin = margin(l = 0.01, b = -1, t = 2, r = 2),
    legend.position = 'bottom')
fig_main

ggsave("../../plots/heatmap_final.png", no_cow_plt, width = 7.5, height = 5.5, dpi = 600)

