## RNA-seq workflow

 <span style="color:blue">**Note: This is work in development, mainly as a template for personal use, and it is provided "as-is", without guarantees of robustness, correctness or optimality. Please use responsibly.**</span>

This RNA-seq workflow consists of a `Snakefile`, a configuration file (`config.yaml`) and a set of R scripts to perform quality control, preprocessing and differential expression analysis of RNA-seq data. The output can be combined with the [`iResViewer`](https://github.com/csoneson/iResViewer) R package to generate a shiny application for browsing and sharing the results.

### Preparation
To use the RNA-seq workflow on your own data, first clone this repository to your local machine and then follow the steps below:

##### Input files

- Put the gzipped fastq files in a `FASTQ` directory. The `Snakefile` assumes that these files are named according to the pattern `<sample-name>.fastq.gz` (or `<sample-name>_R1.fastq.gz` and `<sample-name>_R2.fastq.gz` for paired-end data), if this is not the case you need to rename the files or modify the `Snakefile` accordingly.
-  Create a tab-separated metadata text file. This file should have at least two columns: one named `names`, which contains all the values of `<sample-name>` from the fastq files, and one named `type` which is either SE or PE depending on whether the samples were obtained with a single-end or paired-end protocol. In addition, any number of columns can be included and used later in the analysis. All variables required for the differential expression analysis should be included as columns in the metadata text file. 

##### Include paths to input files in `config.yaml`

- Include the path to the metadata file in `config.yaml` at the requested line (`metatxt := `).
- Add paths to reference files in `config.yaml`. Note that you will also have to add desired paths for indexes etc that will be generated by the workflow. The following reference files are used in the workflow, and can be downloaded from [Ensembl](https://www.ensembl.org/info/data/ftp/index.html) or [Gencode](https://www.gencodegenes.org/releases/current.html):
	- Genome fasta file: Must be uncompressed
	- Corresponding GTF file: Must be uncompressed
	- A single cDNA or ncRNA fasta file: or a fasta file with cDNA and ncRNA combined (`cat cdna.fastq.gz ncrna.fastq.gz > cdna.ncrna.fastq.gz`). Can be compressed.
- Specify the source of your reference files in `config.yaml`. Please be consistent with build and release versions and fill in:
  - annotation: Either `Ensembl` or `Gencode`
  - organism: Species name separated by an underscore `_` (e.g. `Homo_sapiens`)
  - build: Genome build (e.g. `GRCh38`)
  - release: Release number (e.g. `93`)
-  Add the readlength for your RNA-seq reads to `config.yaml`.
-  Add a "group variable" to `config.yaml`. This will be used to color the samples in downstream visualizations, and should correspond to one of the column names in the metadata text file.
-  Set the maximal number of cores to use for the tools that support multi-threading.

##### Include paths to software in `envs/environment.yaml`

- The workflow assumes that all the necessary software is in your path. Alternatively, you can set up a `conda` environment, which will contain all necessary software. First, ensure that `conda` is available and, if necessary, add the channels `r`, `conda-forge` and `bioconda` (see e.g. [here](https://bioconda.github.io/)). Then, to create an environment named `rnaseqworkflow`, do

	```conda env create -n rnaseqworkflow --file envs/environment.yaml``` 

	Note that after the environment has been created, it can be updated after editing `envs/environment.yaml`, in the case where new versions are needed, using 

	```conda env update -n rnaseqworkflow --file envs/environment.yaml```

	Before running the workflow, activate the environment with 

	```source activate rnaseqworkflow``` 

- If you don't want to use `conda`, make sure that all necessary software is installed. The following software is used by the workflow:
	- [R](https://www.r-project.org/)
	- [Salmon](https://combine-lab.github.io/salmon/)
	- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
	- [TrimGalore!](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
	- [Cutadapt](http://cutadapt.readthedocs.io/en/stable/guide.html)
	- [STAR](https://github.com/alexdobin/STAR)
	- [samtools](http://www.htslib.org/)
	- [MultiQC](http://multiqc.info/)
	- [bedtools](http://bedtools.readthedocs.io/en/latest/)
	- bedGraphToBigWig (select your operating system from [this page](http://hgdownload.soe.ucsc.edu/admin/exe/) and download the executable)
- Make sure that all necessary R packages are installed. The workflow uses the following packages:
	- [Biostrings](https://bioconductor.org/packages/release/bioc/html/Biostrings.html)
	- [tximport](http://bioconductor.org/packages/release/bioc/html/tximport.html)
	- [tximeta](https://github.com/mikelove/tximeta)
	- [limma](http://bioconductor.org/packages/release/bioc/html/limma.html)
	- [edgeR](https://bioconductor.org/packages/release/bioc/html/edgeR.html)
	- [reshape2](https://cran.r-project.org/web/packages/reshape2/index.html)
	- [tibble](https://cran.r-project.org/web/packages/tibble/index.html)
	- [dplyr](https://cran.r-project.org/web/packages/dplyr/index.html)
	- [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html)
	- [tidyr](https://cran.r-project.org/web/packages/tidyr/index.html)
	- [rtracklayer](http://bioconductor.org/packages/release/bioc/html/rtracklayer.html)
	- [DRIMSeq](http://bioconductor.org/packages/release/bioc/html/DRIMSeq.html) (optional)

##### Set up the correct differential expression analysis
- The `scripts/run_dge_edgeR.R` script contains the basic code to perform differential expression analysis with [edgeR](https://bioconductor.org/packages/release/bioc/html/edgeR.html). However, you need to modify it in order to perform the proper analysis for your data. As a minimum, define the design and the contrast(s) you would like to use, based on the variables defined in the metadata text file. If you make additional modifications, make sure that the output of the script follows the requirements outlined in `scripts/run_dge_edgeR.R`. 

### Running the workflow

If all the instructions above have been followed, the workflow can be run from the command line by simply typing 

```snakemake```

This will generate all necessary output directories and run the analysis for the indicated samples. If you want to use multiple cores, just do

```snakemake --cores 12```

### Checking software versions

The workflow contains two rules to check the versions of the software that has been used. To check the versions of R packages, running `snakemake listpackages` will parse the output files generated by `R CMD BATCH` and extract all used R packages. The results will be written to a text file. To check the versions of other software, running `snakemake softwareversions` will check the versions of the software. Finally, the `log` directory contains log files, which should state the version of all software that was used. 

### Visualization

#### Visualizing results with `iResViewer`

The output file of the workflow (`output/shiny_results_list.rds`) can be directly used as input to the [`iResViewer`](https://github.com/csoneson/iResViewer) package in order to generate a shiny application where the results can be viewed. After installing `iResViewer`, make sure that the bigWig files listed in the `bwFiles` slot of `output/shiny_results.rds` are reachable (they will be streamed into the shiny application for coverage visualizations). The following code will start a shiny application where you can browse the results:

```
library(iResViewer)
res <- readRDS("output/shiny_results_list.rds")
do.call(iResViewer, res)
```

The title of the shiny application can also be specified:

```
do.call(iResViewer, c(res, list(appTitle = "myTitle")))
```

#### Visualizing results with `iSEE`

The output file of the workflow (`output/shiny_results_sce.rds`) can be directly used as input to the [`iSEE`](https://bioconductor.org/packages/release/bioc/html/iSEE.html) package in order to generate a shiny application where the results can be viewed. After installing `iSEE`, the following code will start a shiny application where you can browse the results:

```
library(iSEE)
sce <- readRDS("output/shiny_results_sce.rds")
app <- iSEE(sce)
shiny::runApp(app)
```


