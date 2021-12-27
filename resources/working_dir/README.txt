|------------------------------------
|
|   1. Running the full pipeline
|
|------------------------------------

- Edit the "s-locus-finder.params" file to set the appropriate pipeline parameters. It is mandatory to update the "host_working_dir" path.

- Copy your files to "data" (genomes) and "reference_data".

- Then run:

    ./run.sh /path/to/project-directory "-n 1"
    
Where "-n 1" indicates that 1 is the maximum number of parallel tasks that can be executed.

The "run.sh" script executes the neccessary "docker run" command to run the Compi-Docker image.

|------------------------------------
|
|   2. Running parts of the pipeline
|
|------------------------------------

- As described in the manual (https://www.sing-group.org/compi/docs/partial_execution.html#partial-execution) or in the help command (docker run --rm pegi3s/s-locus-finder help), Compi provides many parameters to run specific parts of the pipeline.

- For instance, to run a single task:

    ./run.sh /path/to/project-directory "--single-task check-protocols"
    
- For instance, to run all tasks from beginning until the "pre-processing" task (included):
    
    ./run.sh /path/to/project-directory "--until pre-processing"
