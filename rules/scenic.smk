rule seu_to_anndata:
  input:
    seu_file = outputdir + "seurat/unfiltered_seu.rds",
    script = "scripts/seu_to_anndata.R"
  output:
    anndata = outputdir + "scenic/unfiltered.h5ad"
  log:
		outputdir + "Rout/scenic.Rout"
	benchmark:
		outputdir + "benchmarks/scenic.txt"
	conda:
		Renv
	shell:
		'''{Rbin} CMD BATCH --no-restore --no-save {input.script} {log}'''

rule runscenic:
  input:
    anndata = outputdir + "scenic/unfiltered.h5ad"
  output:
    final_loom = outputdir + "scenic/unfiltered.loom"
  log:
		outputdir + "Rout/scenic.Rout"
	benchmark:
		outputdir + "benchmarks/scenic.txt"
	params:
	  TFs = config['TFs'],
	  motifs = config['motifs'],
	  feather_db = config['feather_db']
	shell:
	  "nextflow run aertslab/SCENICprotocol -profile docker "
	  "--anndata_input {input.anndata} --loom_output {output.final_loom} "
	  "--TFs {params.TFs} --motifs {params.motifs} --db {params.feather_db} "
	  "--thr_min_genes 1"
