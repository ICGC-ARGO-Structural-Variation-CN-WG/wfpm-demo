This folder contains tiny data files for testing.

## normal and tumor BAM downloaded from sanger variant calling test dataset
# normal
wget https://github.com/icgc-argo/sanger-wgs-variant-calling/blob/main/sanger-wgs-variant-calling/tests/data/HCC1143_BL-mini-N/cfa409d0-3236-5f07-8634-a2c0de74c8f2.5.20190927.wgs.grch38.bam?raw=true
# tumor
wget https://github.com/icgc-argo/sanger-wgs-variant-calling/blob/main/sanger-wgs-variant-calling/tests/data/HCC1143-mini-T/8f879c15-14da-593d-bb76-db866f81ab3a.6.20190927.wgs.grch38.bam?raw=true


## reference files
# File "grch38-chr11-530001-537000_gc50.wig.gz" was prepared with sequenza-utils v3.0.0 using the following command:
sequenza-utils gc_wiggle --fasta tiny-grch38-chr11-530001-537000.fa  -w 50 -o grch38-chr11-530001-537000_gc50.wig.gz
# File "tiny-grch38-chr11-530001-537000.fa" downloaded from sanger variant calling test dataset
wget https://raw.githubusercontent.com/icgc-argo/sanger-wgs-variant-calling/main/sanger-wgs-variant-calling/tests/reference/tiny-grch38-chr11-530001-537000.fa