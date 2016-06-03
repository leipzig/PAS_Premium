from snakemake.utils import R

rule default:
    input: "intermediates/properties.RData"

rule makeprops:
    input: "data/properties/blocks.txt", "data/properties/addresses.txt"
    output: "intermediates/results_extended.txt"
    shell:
        """
        ruby prepare.rb > {output}
        """

rule analyze:
    input: "intermediates/results_extended.txt"
    output: "intermediates/properties.RData"
    run:
        R("""
        inputfile<-"{input}"
        source("analysis.R")
        """)

rule report:
    input: "intermediates/properties.RData"
    output: "catchment.html"
    run:
        R("""
        rmarkdown::render("catchment.Rpres")
        """)

rule clean:
    shell:
        """
        rm intermediates/properties.RData
        """