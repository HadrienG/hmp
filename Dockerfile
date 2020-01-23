FROM nfcore/base:1.7

LABEL authors="Hadrien Gourlé <hadrien.gourle@slu.se>" \
    description="Docker image containing for hmp"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/hmp/bin:$PATH