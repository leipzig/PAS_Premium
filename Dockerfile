FROM bitnami/minideb:stretch
MAINTAINER Jeremy Leipzig <leipzig@gmail.com>
ADD . /tmp/repo
WORKDIR /tmp/repo
ENV PATH /opt/conda/bin:${PATH}
ENV LANG C.UTF-8
ENV SHELL /bin/bash
RUN install_packages wget bzip2 ca-certificates gnupg2 squashfs-tools git && \
    wget -O- http://neuro.debian.net/lists/xenial.us-ca.full > /etc/apt/sources.list.d/neurodebian.sources.list && \
    wget -O- http://neuro.debian.net/_static/neuro.debian.net.asc | apt-key add - && \
    install_packages singularity-container && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    conda update -n base conda && conda env update --name root --file /tmp/repo/environment.yml && conda clean --all -y

RUN wget https://github.com/caseypt/phl-opa/archive/master.zip
RUN cd phl-opa-master/ && \
    gem install bundle && \
    bundle && \
    gem install phl-opa

RUN snakemake clean && snakemake

CMD snakemake