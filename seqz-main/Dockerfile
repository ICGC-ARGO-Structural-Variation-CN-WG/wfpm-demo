FROM continuumio/miniconda3:4.8.2
# newer version results in conflicts.

RUN apt-get update \
    && apt-get install -y procps \
    && /opt/conda/bin/conda install --yes -c bioconda r-sequenza=3.0.0 r-optparse \
    && git clone https://github.com/aroneklund/copynumber.git \
    && /opt/conda/bin/R CMD INSTALL copynumber

ENV PATH="/home/sequenza:${PATH}"

COPY /scripts/runSequenza.R /home/sequenza/

USER sequenza
WORKDIR /home/sequenza

CMD ["/bin/bash"]
