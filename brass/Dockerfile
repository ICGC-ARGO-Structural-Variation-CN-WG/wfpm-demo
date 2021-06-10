FROM quay.io/wtsicgp/brass:v6.3.4

LABEL org.opencontainers.image.source https://github.com/icgc-argo-structural-variation-cn-wg/wfpm-demo

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
