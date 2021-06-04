FROM continuumio/miniconda3:4.9.2

# filled by wfpm
LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/wfpm-demo

# add ps (required by nextflow)
RUN apt-get -y update  && \
    apt-get install -y procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# install snp-pileup
RUN /opt/conda/bin/conda install --yes -c bioconda -c conda-forge snp-pileup=0.6.1

# RUN mkdir -p /tools
# ENV PATH="/tools:${PATH}"

# COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
