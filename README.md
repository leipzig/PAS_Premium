# PAS_Premium

See the report at http://leipzig.github.io/PAS_Premium/

The generation of this report is fully reproducible. To run from scatch on linux-64:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh Miniconda3-latest-Linux-x86_64.sh
# type "yes"
# allow this to install into your home
conda create -y -n catchmentenv python==3.5
source activate catchmentenv
conda install -y -c bioconda snakemake
conda install -y -c ccordoba12 pandoc
conda install -y -c ruby-lang ruby
conda install -y -c r r-leaflet r-dplyr r-stringr r-lubridate r-rmarkdown r-devtools
conda install -y -c osgeo gdal rgdal
conda install -y -c trent phantomjs

echo 'devtools::install_github("wch/webshot");' | R --no-save --quiet

wget https://github.com/caseypt/phl-opa/archive/master.zip
cd phl-opa-master/
gem install bundle
bundle
gem install phl-opa
cd ..

snakemake clean
snakemake
````
