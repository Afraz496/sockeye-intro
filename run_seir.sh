#!/bin/bash
#SBATCH --job-name=seir_batch
#SBATCH --account=st-ashapi01-1        # Allocation code
#SBATCH --ntasks=1                     # Number of tasks (processes) per job
#SBATCH --nodes=1                      # Number of nodes
#SBATCH --cpus-per-task=8              # CPUs per task
#SBATCH --time=1:00:00                # Time limit hrs:min:sec
#SBATCH --mem=4G                       # Memory per job
#SBATCH --output=logs/array_%A_%a.out  # Standard output
#SBATCH --error=logs/array_%A_%a.err   # Standard error
#SBATCH --partition=skylake            # Partition name

# Load Apptainer module (if required)
module load apptainer

# Define path to Apptainer container
CONTAINER_PATH="/arc/project/st-ACCOUNTNAME/math_modeling_to_purge/sockeye-intro/R_container.sif"

# Bind directories (change if needed)
BIND_DIR="/arc/project/st-ACCOUNTNAME/math_modeling_to_purge/sockeye-intro"

# Define argument arrays
num_simulations=(10 20 30)
time_steps=(100 150 200)

# Loop through parameter combinations and run jobs inside Apptainer
for sims in "${num_simulations[@]}"; do
    for steps in "${time_steps[@]}"; do
        echo "Running SEIR model with $sims simulations and $steps days..."
        
        # Run inside Apptainer
        apptainer exec --bind "$BIND_DIR:/mnt" "$CONTAINER_PATH" \
            Rscript /mnt/seir_model.r "$sims" "$steps"
    done
done
