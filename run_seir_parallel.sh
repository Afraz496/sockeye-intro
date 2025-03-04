#!/bin/bash
#SBATCH --job-name=seir_batch_parallel
#SBATCH --account=st-ashapi01-1        # Allocation code
#SBATCH --ntasks=1                     # Number of tasks (processes) per job
#SBATCH --nodes=1                      # Number of nodes
#SBATCH --cpus-per-task=8              # CPUs per task
#SBATCH --time=1:00:00                 # Time limit hrs:min:sec
#SBATCH --mem=4G                       # Memory per job
#SBATCH --array=0-8                    # Array range (9 jobs)
#SBATCH --output=logs/array_%A_%a.out  # Standard output
#SBATCH --error=logs/array_%A_%a.err   # Standard error
#SBATCH --partition=skylake            # Partition name

# Ensure logs directory exists
mkdir -p logs

# Load Apptainer module
module load apptainer

# Define path to Apptainer container
CONTAINER_PATH="/arc/project/st-ACCOUNTNAME/math_modeling_to_purge/sockeye-intro/R_container.sif"

# Bind directories
BIND_DIR="/arc/project/st-ACCOUNTNAME/math_modeling_to_purge/sockeye-intro"

# Define argument arrays
num_simulations=(10 20 30)
time_steps=(100 150 200)

# Compute total jobs
TOTAL_JOBS=${#num_simulations[@]}*${#time_steps[@]}

# Compute which parameters to use based on SLURM_ARRAY_TASK_ID
sim_idx=$(( SLURM_ARRAY_TASK_ID / ${#time_steps[@]} ))
step_idx=$(( SLURM_ARRAY_TASK_ID % ${#time_steps[@]} ))

sims=${num_simulations[$sim_idx]}
steps=${time_steps[$step_idx]}

echo "Running SEIR model with $sims simulations and $steps days (Job ID: $SLURM_ARRAY_TASK_ID)..."

# Run inside Apptainer
apptainer exec --bind "$BIND_DIR:/mnt" "$CONTAINER_PATH" \
    Rscript /mnt/seir_model.r "$sims" "$steps"
