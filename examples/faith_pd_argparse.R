## needed libraries
library(ggpubr)
library(ggplot2)
library(magrittr)
library(tidyverse)
library(broom)
library(argparse)

## implimenting argparse
parser <- ArgumentParser()
parser$add_argument("-m",
                    "--metadata",
                    dest = "metadata_FP",
                    help = "Filepath to metadata file in .tsv format.")
parser$add_argument("-f",
                    "--faith_pd",
                    dest = "faith_pd_FP",
                    help = "Filepath to Faith's PD file in .tsv format.")
parser$add_argument("-fp",
                    "--faith_plot",
                    dest = "faith_plot_FP",
                    help = "Filepath to Faith's PD plot in .pdf format.")
parser$add_argument("-fs",
                    "--faith_stats",
                    dest = "faith_stats_FP",
                    help = "Filepath to Faith's PD statistical results in .tsv format.")

args <- parser$parse_args()


## reading in metadata and faith's pd .tsvs
metadata <- read_tsv(args$metadata_FP)
faith_pd <- read_tsv(args$faith_pd_FP)

metadata %>%
    left_join(faith_pd, by = 'sampleid') -> combined_faith_table

## creating plot
combined_faith_table %>%
    ggplot(aes(x = sample_date, y = faith_pd)) +
        geom_boxplot(aes(group = sample_date)) +
        geom_jitter(width = 0.1, height = 0, alpha = 0.6) +
        geom_smooth(se = FALSE) +
        labs(x = 'Day',
            y = "Faith's PD",
            title = "Faith's PD Over Time") -> faith_pd_plot

## running stats on my faith's pd results by sample date
combined_faith_table %>%
    do(tidy(kruskal.test(faith_pd ~ sample_date,
                         data = .))) -> kruskal_test

combined_faith_table %>%
    dunn_test(faith_pd ~ sample_date,
              p.adjust.method = 'BH',
              data = .) -> dunn_test

## saving my outputs
ggsave(args$faith_plot_FP,
       plot = faith_pd_plot,
       width = 7,
       height = 5)

write_tsv(dunn_test,
          args$faith_stats_FP)