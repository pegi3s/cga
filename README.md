# CGA [![license](https://img.shields.io/badge/license-MIT-brightgreen)](https://github.com/pegi3s/cga) [![dockerhub](https://img.shields.io/badge/hub-docker-blue)](https://hub.docker.com/r/pegi3s/cga) [![compihub](https://img.shields.io/badge/hub-compi-blue)](https://www.sing-group.org/compihub/explore/62b2ee1dcc1507001943ab83)
> **CGA** (Conserved Genome Annotation) is a [Compi](https://www.sing-group.org/compi/) pipeline to efficiently perform CDS annotations by automating the steps that researchers usually follow when performing manual annotations. A Docker image is available for this pipeline in [this Docker Hub repository](https://hub.docker.com/r/pegi3s/cga).

## CGA repositories

- [GitHub](https://github.com/pegi3s/cga)
- [DockerHub](https://hub.docker.com/r/pegi3s/cga)
- [CompiHub](https://www.sing-group.org/compihub/explore/62b2ee1dcc1507001943ab83)

# What does CGA do?

**CGA** (Conserved Genome Annotation) is a [Compi](https://www.sing-group.org/compi/) pipeline to efficiently perform CDS annotations by automating the steps that researchers usually follow when performing manual annotations.
 
Given a protein reference sequence, CGA applies the following procedure to each nucleic input sequence in a given FASTA file with the genome regions of interest:

1. *get-orf*: Obtain all between STOP codons open reading frames (ORF) longer than 30 bp using EMBOSS getorf. Intron splice sites (GT and AG) may be either located within these ORF regions or immediately before (if the 5’ stop codon of the identified ORF is TAG, it may contribute with the AG to the splice site) or after (if the last nucleotide of the identified ORF is G, both TAA, TAG or TGA could contribute with the T to a putative GT splice site). Therefore, for these cases, the STOP codon sequence is added to the ORF sequence. Then, the sequences are translated in frame +1 using EMBOSS transeq. The main output files of this step are `*01_*_orfs.prot.fasta` and `01_*_orfs.nuc.fasta` (where `*` is just the sequence number from the previous split).
   
2. *blast*: Create a protein BLAST database for each `01_*_orfs.prot.fasta` produced in the previous step. Using this database, and the reference protein sequence provided by the user, a blastp analysis is performed. All ORFs from the `01_*_orfs.nuc.fasta` that, when translated, have significant similarity (e-value below 0.05) with the reference sequence, are retrieved and stored in the `02_*.ini` file.

3. *sort*: This step sorts the `02_*.ini` files to ensure that exons are ordered according to their relative location in the genome, using the information that the EMBOSS getorf program outputs in the sequence headers. The sorted files are named `03_*.ini.sorted`.

4. *join-exons*: This step comprises six main sub-steps to process the `03_*.ini.sorted` from the previous step. These sub-steps are run iteratively until all exons have been successfully joined (see *4.6 get_sequences*) and the main output file `04_*.join_exons_results` is created.
    
    4.1. *prepare_and_select*: This sub-step takes the first two consecutive sequences from the file containing the ordered ORFs and then checks whether they come from the same genome region and whether the distance between the two sequences is not greater than the one specified by the user in the max_dist parameter (see below). If these criteria are met, the headers and sequences are merged but a mark is left at the place of the junction of the two sequences. The degree of overlap (if any) is calculated based on sequence headers and whether the STOP codon was added to the ORF (see the get-orf step).

    4.2. *find_splicing_sites*: Then, since all ORF are in frame +1 and the size of the mark that is left around the sequence junction is of size two, all words starting with GT and ending in AG, that are multiple of three, and that include the mark, are extracted from the file resulting from the prepare_and_select script and saved, as long as the intron splice sites are located in the region specified by the user in the intron_bp parameter. 

    4.3. *translate*: If the previous sub-step produces an output (i.e. sequences have been joined), then those sequences are translated in frame +1 using the EMBOSS transeq program before proceeding with the subsequent sub-steps.

    4.4. *remove_stops*: If a sequence from the previous steps starts with a stop codon, that codon is removed. Moreover, sequences that have in frame stop codons (the last codon is ignored) that were created by the extraction of a given subsequence, are removed.

    4.5. *final_selection*: Each of the sequences obtained from the previous sub-steps are aligned with the reference protein using the EMBOSS stretcher program, which allows the rapid global alignment of two sequences using the Needleman-Wunsch algorithm. Three options (models) for choosing one sequence over another can be configured with the selection_criterion parameter, namely: 

    - Citerion 1: sequences are chosen based on similarity, and only when two sequences show the same similarity level the one with the smallest percentage of gaps is kept.
    - Citerion 2: sequences are chosen based on gap frequency, and only when two sequences show the same gap frequency the one with higher similarity is kept.
    - Citerion 3: in this mixed mode sequences are chosen based on the similarity level, but if the challenging sequence has fewer gaps than the current best sequence, a bonus (specified by the user in the *selection_correction* parameter) is given to the similarity level, when deciding which sequence to keep.

    4.6. *get_sequences*: The DNA sequences corresponding to the selected protein sequences (see *4.5 final_selection*) are obtained. If exons are successfully joined, the resulting sequence is added to the top of the file that is given to the *prepare_and_select step* and the cycle is repeated from that point onwards until the input file is empty. If exons are not successfully joined, then the second sequence is added to the top of the file that is given to the *prepare_and_select* step and the cycle is repeated from that point onwards until the input file is empty. 

5. *predict*: Once all exons have been joined successfully, the `04_*.join_exons_results` file is processed in this step using a combination of the EMBOSS getorf and transeq programs to obtain the predicted CDS and protein sequences (only those in frame +1 are considered) only if they are longer than the minimum size specified by the user in the *min_full_nucleotide_size* parameter. This could be, for instance, the minimum size of a likely complete CDS. A blastp search is also performed using the reference protein as the query and the annotated protein as the database.
    
    At the end of the execution of this step, four output files are produced for each input sequence, namely:

   - The `05_*.join_exons_results` file containing the DNA sequences being considered before the predict step. This file is useful for manual sequence refinement when there are reasons to believe that a complete annotation was not achieved. There are a number of situations in which this could happen. For instance, the first coding exon could be smaller than 30 bp (the minimum size for an ORF to be reported by getorf). It should, however, be noted that in such cases it would be equally difficult to annotate the gene manually.
    - The `05_*.nuc` and `05_*.pep` files containing the predicted CDS sequence and its translation, respectively.
    - The `05_*.pep.blast` file showing the result of the blastp search when using the reference protein as query and the `05_*.pep` file as the database. This is a fast and simple way of checking how different the annotated sequences are from the reference protein.

After doing this, the results from each input sequence analysed are joined to generate the aggregated output files under `results`, namely: `nuc`, `pep`, `blast`, and `results`.

## CGA parameters

Here is a brief description of the CGA parameters related with the annotation process described above:

- *max_dist*: Maximum distance between exons (in this case sequences identified by getorf) from the same gene. It only applies to large genome sequences where there is some chance that two genes with similar features are present.
- *intron_bp*: Distance around the junction point between two sequences where to look for splicing signals.
- *selection_criterion*: The selection model to be used (1, 2, or 3): 1) similarity with reference sequence first, in case of a tie, percentage of gaps relative to reference sequence; 2) percentage of gaps relative to reference sequence first, in case of a tie, similarity with reference sequence; 3) a mixed model with similarity with reference sequence first, but if fewer gaps relative to reference sequence, similarity gets a bonus defined by the user.
- *selection_correction*: A bonus percentage times 10. For instance, 20 means 2% bonus. Something with 18% similarity acts as having 20% similarity. Applied when *selection_criterion=3*.
- *min_full_nucleotide_size*: Minimum size for CDS to be reported.

# Using the CGA image in Linux

In order to use the CGA image, create first a directory in your local file system (`cga_working_dir` in the example) with the following structure: 

```bash
cga_working_dir/
├── cga.params
├── input.fasta
└── ref.fasta
```

- `cga.params` is the Compi parameters file with the pipeline configuration (see below).
- `input.fasta` is the FASTA file containing the nucleic sequences of the genome regions of interest.
- `ref.fasta` is the FASTA file containing the reference protein sequence.

You can populate the CGA working directory, including sample Compi parameter files with default values, running the following command (here, you only need to set `CGA_WORKING_DIR` to the right path in your local file system):

```bash
CGA_WORKING_DIR=/path/to/cga_working_dir

mkdir -p ${CGA_WORKING_DIR}

docker run --user "$(id -u):$(id -g)" --rm -v ${CGA_WORKING_DIR}:/working_dir pegi3s/cga init_working_dir.sh /working_dir
```

Now, you should:

1. Edit the `cga.params` file to set the appropriate pipeline parameters. It is mandatory to update the `host_working_dir` path.
2. Copy your input files to `input.fasta` and `ref.fasta`. You can use different names for these two input files. If so, update their names in the `cga.params` file

After doing this, you can run the pipeline with the `run.sh` that has been generated:
```
./run.sh /path/to/cga_working_dir "-n 1"
```
    
Where `-n 1` indicates that 1 is the maximum number of parallel tasks that can be executed. The `run.sh` script executes the neccessary `docker run` command to run the Compi-Docker image of CGA. After running the pipeline, three folders are created:
- `cga_working_dir` contains the results of analyzing each input sequence separately.
- `logs` contains all execution logs.
- `results` contains the aggregated results.

# Test data

The sample data is available [here](https://github.com/pegi3s/cga/raw/master/resources/test-data/cga-test-data.zip). Download and uncompress it, and move the directory named `cga-test-data`, where you will find:

- The `cga.params` file with the appropriate pipeline parameters already set. You must only update the `host_working_dir` parameter.
- A `README.txt` file with the instructions to run the pipeline with the sample data provided using the `run.sh` script included.

After running the pipeline, three folders are created:
- `cga_working_dir` contains the results of analyzing each input sequence separately.
- `logs` contains all execution logs.
- `results` contains the aggregated results.

## Running times

- ≈ 21 minutes - 4 parallel tasks - Ubuntu 18.04.6 LTS, 8 CPUs (Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz), 16GB of RAM and SSD disk.

# Using CGA through SEDA

[SEDA](https://www.sing-group.org/seda/) (SEquence DAtaset builder) is an open-source, multiplatform application for processing FASTA files containing DNA and protein sequences developed by us. In SEDA v1.5.0 (or higher), CGA can be executed through SEDA, being available in the *Gene Annotation* group. The [online SEDA manual](https://www.sing-group.org/seda/manual/operations.html#conserved-genome-annotation-cga-pipeline) provides more details about this option. Note that a [Docker image](https://hub.docker.com/r/pegi3s/seda/) is also available for SEDA.

# For Developers

## Building the Docker image

To build the Docker image, [`compi-dk`](https://www.sing-group.org/compi/#downloads) is required. Once you have it installed, simply run `compi-dk build -tv -drd` from the project directory to build the Docker image. The image will be created with the name specified in the `compi.project` file (i.e. `pegi3s/cga:latest`). This file also specifies the version of Compi that goes into the Docker image.
