rule all:
    input:
        "faith_plot.pdf",
        "faith_stats.tsv" 


rule running_r_script:
    input:
        metadata = "metadata_file.tsv",
        faith_pd = "faith_pd.tsv"
    output:
        faith_plot = "faith_plot.pdf",
        faith_stats = "faith_stats.tsv"
    conda:
        "r_env"
    shell:
        """
        Rscript faith_pd.R --metadata {input.metadata} \
                           --faith_pd {input.faith_pd} \
                           --faith_plot {output.faith_plot} \
                           --faith_stats {output.faith_stats}
        """