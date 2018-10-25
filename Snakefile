from snakemake.utils import R

def get_head_hash():
    return os.popen('git rev-parse --verify HEAD 2>&1').read().strip()

rule default:
    input: "index.html"

rule makeprops:
    input: blocks="data/properties/blocks.txt",
           addr="data/properties/addresses.txt"
    output: "intermediates/results_extended.txt"
    shell:
        """
        ruby prepare.rb > {output}
        """

rule analyze:
    input: prep="intermediates/results_extended.txt",
           shp="data/shapefiles/Parcels_UniversityCity.shp"
    output: "intermediates/properties.RData"
    run:
        R("""
        inputfile<-"{input.prep}"
        source("analysis.R")
        """)

rule report:
    input: prop="intermediates/properties.RData",
           report="catchment.Rpres"
    output: "{report}.html"
    params: githash= get_head_hash()
    run:
        R("""
        githash<-"{params.githash}"
        rmarkdown::render("{input.report}",output_file="{output}")
        """)

rule clean:
    shell:
        """
        rm -f *.html
        rm -f intermediates/properties.RData
        """
