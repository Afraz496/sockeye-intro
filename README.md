# A gentle introduction to Sockeye and cloud computing

We need to build an Apptainer first to make sure the libraries for `R` are Read-Write friendly. There is an example container file in this repo called `R_container.def`. 

On sockeye you will need to configure the dependencies first then you can run the corresponding software.

## Dependencies

In your allocated node write:

```bash
module load gcc/9.4.0
```

Then

```bash
module load apptainer/1.3.1
```

**Note**: If at any point, there are issues with version numbers, use the command `module spider <module name>`.

Once you load the Apptainer module, the next portion of this guide requires you to set up the apptainer using the provided `R_container.def` file:

## Apptainer setup

To set up your apptainer write the following command:

```bash
apptainer build R_container.sif R_container.def
```

Please make sure you are in the same directory is `R_container.def` for this to work. This must also be done on the root node, since there is no internet access on allocated nodes.

After this you can enable the apptainer shell:

```bash
apptainer shell R_container.sif
```

Then you should see

```bash
Apptainer
```

This means the apptainer is setup and ready.

## Running R on Sockeye

You can do a few checks to make sure `R` is setup:

```bash
Apptainer> R
```

You should spawn an R console. Now the next step would be how do we get R libraries setup? This is a bit painful as most of sockeye infrastructure is **read-only**. So the workaround we use is to write our R libraries in scratch.

First navigate to your designated scratch folder (you can do this in the Apptainer, it doesn't matter)

```bash
cd /scratch/st-ACCOUNT
```

Then make the following directories

```bash
mkdir R
cd R
mkdir libs
```

You should have a full path to your R Libs now: `/scratch/st-ACCOUNT/R/libs`

## Editing the R script to support installing libraries

Note that your R script doesn't know where libraries are. There are 2 workarounds:

1. `libPaths()` which is at the start of your script
2. `R_LIBS_USER` an environment variable which you can change globally

We will be using option 1. In your `seir_model.R` replace lines 1 and 2 with your `R lib` path that you made in the previous step. Then replace the corresponding libpaths line so `R` has a way of accessing the libraries.

## Running SBATCH and other jobs

Now that we have made it to the end of our arduous setup, we can run `sbatch` and shell scripts. This repo comes with custom scripts, you can modify these at your discretion.

To run the sequential `sbatch`:

```bash
sbatch /arc/project/st-ACCOUNT/sockeye-intro/run_seir.sh
```

**Note**: you can only run this from `/scratch/st-ACCOUNT`! Make sure you navigated there before you ran the script.

To run the parallel `sbatch`:

```bash
sbatch /arc/project/st-ACCOUNT/sockeye-intro/run_seir_parallel.sh
```
