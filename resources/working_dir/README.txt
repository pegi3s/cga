|---------------------------------------------------------------------
|
|   1. Initialize the CGA working directory
|
|---------------------------------------------------------------------

- Use the pegi3s/cga Docker image to initialize the working directory with the following commands:

    mkdir $(pwd)/cga_working_dir && docker run --user "$(id -u):$(id -g)" --rm -v $(pwd)/cga_working_dir:/working_dir pegi3s/cga init_working_dir.sh /working_dir
    
- These commands will create "cga_working_dir" in the current directory of your host and then populates it with initial files: "cga.params", "input.fasta" (empty), "ref.fasta" (empty), and "run.sh".

|---------------------------------------------------------------------
|
|   2. Running the full pipeline
|
|---------------------------------------------------------------------

- Edit the "cga.params" file to set the appropriate pipeline parameters. It is mandatory to update the "host_working_dir" path.

- Copy your input files to "input.fasta" and "ref.fasta". You can use different names for this two input files. If so, update their names in the "cga.params" file:
    
    input_fasta=input.fasta
    reference_fasta=ref.fasta

- Then run:

    ./run.sh /path/to/project-directory "-n 1"
    
Where "-n 1" indicates that 1 is the maximum number of parallel tasks that can be executed.

The "run.sh" script executes the neccessary "docker run" command to run the Compi-Docker image.

|---------------------------------------------------------------------
|
|   3. Running parts of the pipeline
|
|---------------------------------------------------------------------

- As described in the manual (https://www.sing-group.org/compi/docs/partial_execution.html#partial-execution) or in the help command (docker run --rm pegi3s/s-locus-finder help), Compi provides many parameters to run specific parts of the pipeline.

- For instance, to run a single task:

    ./run.sh /path/to/project-directory "--single-task split-reference"
    
- For instance, to run all tasks from beginning until the "sort" task (included):
    
    ./run.sh /path/to/project-directory "--until sort"
    
|---------------------------------------------------------------------
|
|   4. Look for errors or warnings in the logs of the tasks
|
|---------------------------------------------------------------------

- Each run of the pipeline saves the output logs in a separated folder at "logs/<timestamp>". This folder contains the log of Compi ("compi.log") and the logs of each task at "tasks".

Even when the pipeline run completely, it is encouraged to look for errors o warnings in the logs of the tasks with the "process_logs.sh" included in the image:
    
    docker run --rm -v $(pwd):/working_dir pegi3s/cga process_logs.sh /working_dir /working_dir/logs/<timestamp>/tasks
    
    (where <timestamp> is the date of the pipeline run you want to analyze)
