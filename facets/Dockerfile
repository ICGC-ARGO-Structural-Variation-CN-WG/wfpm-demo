FROM abenjak/facets:2.0.0

LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/wfpm-demo

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
