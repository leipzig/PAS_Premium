rule default:
    input
rule makeprops:
    input: "blocks.txt", "addresses.txt"
    output: "results_extended.txt"
    shell:
        """
        ruby prepare.rb > {output}
        """

rule analyze:
    input: "results_extended.txt"
    output: "properties.RData"
    run:
        R("""
        source("analysis.R")
        """)