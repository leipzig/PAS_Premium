FROM debian:buster-20181011-slim
#debian:experimental had screwed up sslconf
#debian-stretch is missing the latest ncurses
MAINTAINER Jeremy Leipzig <leipzig@gmail.com>
ADD . /tmp/repo
WORKDIR /tmp/repo
ENV PATH /opt/conda/bin:${PATH}
ENV LANG C.UTF-8
ENV SHELL /bin/bash
RUN apt-get update && apt-get install -y wget bzip2 unzip git ruby libncurses-dev libproj-dev libgdal-dev libssl-dev build-essential && \
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    conda update -n base conda && conda env update --name root --file /tmp/repo/environment.yml && conda clean --all -y

RUN wget https://github.com/caseypt/phl-opa/archive/master.zip
RUN unzip master.zip && \
    cd phl-opa-master/ && \
    gem install bundle && \
    bundle && \
    gem install phl-opa

CMD snakemake clean && snakemake