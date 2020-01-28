FROM nfcore/base:1.7

LABEL authors="Hadrien Gourlé <hadrien.gourle@slu.se>" \
    description="Docker image containing for hmp"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
RUN mkdir -p /checkm_data && \
    cd /checkm_data && \
    curl -O https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz && \
    tar xzf checkm_data_2015_01_16.tar.gz && \
    rm checkm_data_2015_01_16.tar.gz && \
    /opt/conda/envs/hmp/bin/checkm data setRoot /checkm_data
ENV PATH /opt/conda/envs/hmp/bin:$PATH