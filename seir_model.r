#install.packages('deSolve', lib="###POINT THIS TO SCRATCH######")
#install.packages('tidyverse', lib="###POINT THIS TO SCRATCH######")

# i'm using mine as an example! Change libpaths here to get this script to work!! 
# Set library paths to ensure proper package installation
.libPaths(c("###SET ME TO YOUR SCRATCH LIBPATHS####", .libPaths()))
library(deSolve)
library(ggplot2)

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Default values if arguments are missing
num_simulations <- ifelse(length(args) >= 1, as.numeric(args[1]), 20)
time_steps <- ifelse(length(args) >= 2, as.numeric(args[2]), 180)

cat("Running SEIR model with", num_simulations, "simulations and", time_steps, "days.\n")

# SEIR model function
seir_model <- function(time, state, parameters) {
  S <- state[1]
  E <- state[2]
  I <- state[3]
  R <- state[4]
  
  beta <- parameters["beta"]
  sigma <- parameters["sigma"]
  gamma <- parameters["gamma"]
  N <- parameters["N"]
  
  dS <- -beta * S * I / N      # Susceptible to Exposed
  dE <- beta * S * I / N - sigma * E  # Exposed to Infected
  dI <- sigma * E - gamma * I  # Infected to Recovered
  dR <- gamma * I              # Recovered

  list(c(dS, dE, dI, dR))
}

# Parameters
N <- 1e6       # Total population
sigma <- 1/5.2 # Incubation rate (1/mean incubation period)
gamma <- 1/7   # Recovery rate (1/mean infectious period)
I0 <- 1        # Initial infections
E0 <- 10       # Initial exposed individuals
S0 <- N - I0 - E0 # Initial susceptible
R0 <- 0        # Initial recovered
time <- seq(0, time_steps, by = 1)  # Adjusted number of days

# Monte Carlo Simulations
set.seed(123)  # Ensure reproducibility
beta_values <- runif(num_simulations, 0.3, 0.5)  # Random transmission rates

# Store results
simulation_results <- data.frame()

# Loop through simulations
for (beta_sim in beta_values) {
  parameters <- c(beta = beta_sim, sigma = sigma, gamma = gamma, N = N)
  state <- c(S = S0, E = E0, I = I0, R = R0)
  
  out <- ode(y = state, times = time, func = seir_model, parms = parameters)
  out_df <- as.data.frame(out)
  out_df$Simulation <- paste0("R0=", round(beta_sim / gamma, 2))
  
  simulation_results <- rbind(simulation_results, out_df)
}
output_file <- paste0("seir_plot_", num_simulations, "_sims_", time_steps, "_days.png")
# Plot results
ggplot(simulation_results, aes(x = time, y = I, color = Simulation)) +
  geom_line(alpha = 0.3) +
  labs(title = paste("SEIR Model for", num_simulations, "Simulations over", time_steps, "Days"),
       x = "Days", y = "Number of Infected Individuals") 
  ggsave(output_file, width = 8, height = 5, dpi = 300)

cat("Plot saved as:", output_file, "\n")