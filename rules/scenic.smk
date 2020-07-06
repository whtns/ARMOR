

rule seu_to_anndata:
	input:
		seu_file = outputdir + "seurat/unfiltered_seu.rds",
		script = "scripts/seu_to_loom.R"
	output:
		loom_file = outputdir + "scenic/unfiltered.loom"
	log:
		outputdir + "Rout/scenic.Rout"
	benchmark:
		outputdir + "benchmarks/scenic.txt"
	conda:
		"../envs/environment_R.yaml"
	shell:
		'''{Rbin} CMD BATCH --no-restore --no-save "--args seu_file='{input.seu_file}' loom_file='{output.loom_file}'" {input.script} {log}'''

rule runscenic:
	input:
		loom_file = outputdir + "scenic/unfiltered.loom"
	output:
		final_loom = outputdir + "scenic/unfiltered-final.loom"
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
	  "--loom_input {input.loom_file} --loom_output {output.final_loom} "
	  "--TFs {params.TFs} --motifs {params.motifs} --db {params.feather_db} "
	  "--thr_min_genes 1"
