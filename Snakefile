rule all:
    input: "output/tRNA_scan_result.txt",
           "output/G_intestinalis.tRNA",
            expand("output/{sp}.tRNA",sp =["G_muris","S_salmonicida"]),
            expand("output/blastn/G_intestinalis/{sp}.blastn", sp =["G_muris", "S_salmonicida"])


rule tRNAscan:
    input: "resource/genomes/G_intestinalis.fasta"
    output: "output/tRNAscan/tRNA_scan_result.txt"
    shell: """tRNAscan-SE {input} -o {output}"""


rule tRNAscan_stats:
    input:
        genome = "resource/genomes/G_intestinalis.fasta"
    output:
        tRNA = "output/tRNAscan/G_intestinalis.tRNA",
        stats = "output/tRNAscan/G_intestinalis.stats"
    params:
        threads = 2
    conda:
        "env/env.yaml"
    script:
        "scripts/tRNAscan_stats.py"


rule tRNAScan_stats_wildcard:
    input:
        genome = "resource/genomes/{genome}.fasta"
    output:
        tRNA = "output/tRNAscan/{genome}.tRNA",
        stats = "output/tRNAscan/{genome}.stats"
    params:
        threads = 2
    conda:
        "env/env.yaml"
    script:
        "scripts/tRNAscan_stats.py"


rule makeblastdb:
    input:
        "resource/{type}/db/{db}.fasta"
    output:
        "output/{type}/db/{db}.ndb",
        "output/{type}/db/{db}.nhr",
        "output/{type}/db/{db}.nin",
        "output/{type}/db/{db}.not",
        "output/{type}/db/{db}.nsq",
        "output/{type}/db/{db}.ntf",
        "output/{type}/db/{db}.nto"
    params:
        outname="output/{type}/db/{db}"
    #conda:
    #     "/Users/mehmettevfikkara/anaconda3/envs/blast"
    shell:
        'makeblastdb -dbtype nucl -in {input} -out {params.outname}'


rule blastn:
    input:
        query = "resource/{type}/query/{query}.fasta",
        db = "output/{type}/db/{db}.ndb"
    output:
          'output/{type}/{db}/{query}.blastn'
    params:
          perc_identity=95,
          outfmt=6,
          num_threads=2,
          max_target_seqs=1,
          max_hsps=1,
          db_prefix="output/{type}/db/{db}"
    #conda:
    #     "/Users/mehmettevfikkara/anaconda3/envs/blast"
    script:
          "scripts/blastn.py"


rule orthofinder:
    input:
        fasta = "resource/orthofinder",
    output:
        directory("output/orthofinder"),
    conda:
        "env/env.yaml"
    script:
        "scripts/2_BioinformaticTools/orthofinder.py"


