# PAS_Premium

See the report at http://leipzig.github.io/PAS_Premium/

The generation of this report is fully reproducible.

To run using Conda on linux-64:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh Miniconda3-latest-Linux-x86_64.sh
# type "yes"
# allow this to install into your home
conda env create --file environment.yml
source activate pas

wget https://github.com/caseypt/phl-opa/archive/master.zip
cd phl-opa-master/
gem install bundle
bundle
gem install phl-opa
cd ..

snakemake clean
snakemake
````

From the Docker image:
```
docker run quay.io/leipzig/pas
```
