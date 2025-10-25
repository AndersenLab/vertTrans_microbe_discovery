library(dplyr)
library(ggplot2)
# install.packages("ggtext")
library(ggtext)
library(stringr)
library(cowplot)
library(ggplotify)

genera <- c("Nematocida", "Pseudomonas","Brucella") # Escherichia is not in the 15 highest % minimizers for any species

control_ni <- readr::read_tsv("/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/notInfected/EukPath/all_strains.tsv", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::distinct(strain) %>%
  dplyr::mutate(perc = 0, genus = NA, species = "C.e. control (not-infected)") 

control_ni <- tidyr::expand_grid(
  strain = control_ni$strain,
  genus  = genera
) %>%
  mutate(perc = 0, species = "C.e. control (not-infected)")

control_i <- readr::read_tsv("/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/microsporidia_ctr/infected/EukPath/all_strains.tsv", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::mutate(perc = ifelse(perc >= 10, perc, 0)) %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  distinct() %>%
  dplyr::mutate(species = "C.e. control (infected)")  %>%
  dplyr::arrange(desc(perc)) 


ce <- readr::read_tsv("/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_elegans/Kraken2/wild_strains/analysis/c_elegans_Kraken2classification_10perc.fixed.tsv", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C. elegans") %>%
  dplyr::arrange(desc(perc))
  
ce_top15strains <- ce %>% dplyr::slice_head(n=15) %>% dplyr::pull(strain)

ce <- ce %>% dplyr::filter(strain %in% ce_top15strains)
  
            
cb <- readr::read_tsv("/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_briggsae/Kraken2/wild_strains/analysis/c_briggsae_Kraken2classification_10perc.fixed.txt", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C. briggsae")  %>%
  dplyr::arrange(desc(perc))

cb_top15strains <- cb %>% dplyr::slice_head(n=15) %>% dplyr::pull(strain)

cb <- cb %>% dplyr::filter(strain %in% cb_top15strains)

ct <- readr::read_tsv("/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/processed_data/c_tropicalis/Kraken2/wild_strains/analysis/c_tropicalis_Kraken2classification_10perc.fixed.txt", col_names = c("strain","perc","x1","x2","x3","x4","x5","x6","genus")) %>%
  dplyr::filter(x5 == "G") %>%
  dplyr::filter(genus %in% genera) %>%
  dplyr::select(strain,perc,genus) %>%
  dplyr::distinct() %>%
  dplyr::mutate(species = "C. tropicalis")  %>%
  dplyr::arrange(desc(perc))

ct_top15strains <- ct %>% dplyr::slice_head(n=15) %>% dplyr::pull(strain)

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

space <- "\u00A0" 

ctr_plot <- all %>%
  dplyr::filter(grepl("<i>C.e.",species_lab)) %>%
  dplyr::mutate(species_lab = ifelse(species_lab == "<i>C.e.</i>", paste0("<i>C.e.</i>", "         "," control"), paste0("<i>C.e.</i>", "     ", " control"))) %>%
  dplyr::mutate(control = ifelse(species == "C.e. control (infected)", "(infected)", "(not-infected)")) 

species_plot <- all %>%
  dplyr::filter(!grepl("<i>C.e.", species_lab)) %>%
  dplyr::mutate(species_lab = factor(species_lab, levels = c("<i>C. elegans</i>","<i>C. briggsae</i>","<i>C. tropicalis</i>")))

heatmap1 <- ggplot(ctr_plot, aes(x = strain, y = genus, fill = perc)) +
  geom_tile(color = "white", linewidth = 0.15) +
  facet_wrap(~ species_lab+control, scales = "free_x", nrow = 1) +
  scale_fill_gradient(low = "skyblue", high = "red", name = "Percent minimizers", limits = c(0, 100)) +
  labs(x = NULL, y = NULL) +
  scale_y_discrete(expand = c(0,0)) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_rect(fill = NA, color = 'black'),
    # legend.title = element_text(size = 16, color = 'black'), 
    # legend.text  = element_text(size = 14),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, color = 'black', size = 7),
    # strip.text = element_text(face = "bold.italic", size = 16),
    strip.text = ggtext::element_markdown(face = "bold", size = 10),
    strip.text.x = element_text(margin = margin(0.155,0,0.155,0, "cm")),
    panel.spacing.x = unit(0.2, "lines"),
    axis.text.y = element_text(size = 11, face = 'bold.italic', color = 'black'),
    plot.margin = margin(l = 20), #b = 64, t = 5.5),
    legend.position = "none")
heatmap1


heatmap2 <- ggplot(species_plot, aes(x = strain, y = genus, fill = perc)) +
  geom_tile(color = "white", linewidth = 0.15) +
  facet_wrap(~ species_lab, scales = "free_x", nrow = 1) +
  scale_fill_gradient(low = "skyblue", high = "red", name = "Percent minimizers     ", limits = c(0, 100)) +
  labs(x = NULL, y = NULL) +
  scale_y_discrete(expand = c(0,0)) +
  theme(
    panel.grid = element_blank(),
    axis.text.y = element_blank(),
    panel.border = element_rect(fill = NA, color = 'black'),
    legend.title = element_text(size = 9, color = 'black'), 
    legend.text  = element_text(size = 8),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, color = 'black', size = 7),
    strip.text = ggtext::element_markdown(face = "bold", size = 10),
    panel.spacing.x = unit(0.2, "lines"),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(margin = margin(0.5,0,0.5,0, "cm")),
    legend.position = 'bottom', 
    legend.justification.bottom = "left")
heatmap2

# p1 <- as.ggplot(ggplotGrob(heatmap1))

final_plot <- cowplot::plot_grid(
  heatmap1, heatmap2,                  
  ncol = 2,
  rel_widths = c(0.667, 1),
  align = "h"
)
final_plot


# ggsave("/vast/eande106/projects/Lance/THESIS_WORK/pathogen_unalignedBAM_SDSU/pathogenDiscovery-sh/plots/heatmap.png",final_plot, dpi = 600, width = 7.5, height = 5)



no_cow <- ctr_plot %>% dplyr::bind_rows(species_plot) %>% 
  dplyr::mutate(species_lab = dplyr::recode(species,
                                            "C. elegans"   = "<i>C. elegans</i>",
                                            "C. briggsae"  = "<i>C. briggsae</i>",
                                            "C. tropicalis"= "<i>C. tropicalis</i>",
                                            "C.e. control (infected)"     = "<i>C.e.</i> control (infected)",
                                            "C.e. control (not-infected)" = "<i>C.e.</i> control (not-infected)")) %>%
  dplyr::mutate(species_lab = factor(species_lab, levels = c("<i>C.e.</i> control (infected)","<i>C.e.</i> control (not-infected)","<i>C. elegans</i>","<i>C. briggsae</i>","<i>C. tropicalis</i>")))

no_cow_plt <- ggplot(no_cow, aes(x = strain, y = genus, fill = perc)) +
  geom_tile(color = "white", linewidth = 0.15) +
  facet_wrap(~ species_lab, scales = "free_x", nrow = 1) +
  scale_fill_gradient(low = "skyblue", high = "red", name = "Percent minimizers", limits = c(0, 100)) +
  labs(x = NULL, y = NULL) +
  scale_y_discrete(expand = c(0,0)) +
  theme(
    panel.grid = element_blank(),
    panel.border = element_rect(fill = NA, color = 'black'),
    legend.title = element_text(size = 14, color = 'black'),
    legend.text  = element_text(size = 11),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, color = 'black', size = 12),
    # strip.text = element_text(face = "bold.italic", size = 16),
    strip.text = ggtext::element_markdown(face = "bold", size = 14),
    # strip.text.x = element_text(margin = margin(0.155,0,0.155,0, "cm")),
    panel.spacing.x = unit(0.2, "lines"),
    axis.text.y = element_text(size = 12, face = 'bold.italic', color = 'black'),
    plot.margin = margin(l = 20), #b = 64, t = 5.5),
    legend.position = 'bottom')
    # legend.justification.bottom = "middle")
no_cow_plt

