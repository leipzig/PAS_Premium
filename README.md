# PAS_Premium

See the report at http://leipzig.github.io/PAS_Premium/

To run from scatch on linux-64:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh Miniconda3-latest-Linux-x86_64.sh
# type "yes"
# allow this to install into your home
conda config --add channels bioconda
conda config --add channels r
conda config --add channels ruby-lang
conda config --add channels asmeurer
conda create -y -n catchmentenv python==3.5
source activate catchmentenv
conda install -y -c ruby-lang ruby=2.2.3
conda install -y -c r r-leaflet r-dplyr r-stringr r-lubridate
conda install -y -c osgeo gdal rgdal
conda install -y -c trent phantomjs=1.9.7


echo 'options(repos = c(CRAN = "http://cran.rstudio.com"));install.packages("devtools");library("devtools");devtools::install_github("wch/webshot");' | R --no-save --quiet

wget https://github.com/caseypt/phl-opa/archive/master.zip
cd phl-opa-master/
gem install bundle
bundle
gem install phl-opa
cd ..

snakemake
````
