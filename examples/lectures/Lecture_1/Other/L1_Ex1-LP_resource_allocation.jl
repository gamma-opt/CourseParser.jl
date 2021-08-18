# Examples presented in class - Lecture 1
# LP Resource allocation

using JuMP, Cbc
# JuMP is for implementing math. programming models;
# Cbc is for solving them.

# Example 1 - resource allocation

# Problem data
i = 1:2 # i=1: Seattle; i=2: San Diego
j = 1:3 # j=1: New York; j=2: Chicago; j=3: Miami

C = [350 600] # Capacities of the factories
D = [325 300 275] # Demand of clients
T = [2.5 1.7 1.8
     3.5 1.9 1.4] # Transportation costs

# Model implementation
# Creates a model and informs the solver to be used
m = Model(solver = CbcSolver())

# Decision variable for the total transported
@variable(m, x[i,j] >= 0)

# Capacity constraint
@constraint(m, cap[i = 1:2], sum(x[i,j] for j = 1:3) <= C[i])
# Demand constraint
@constraint(m, dem[j = 1:3], sum(x[i,j] for i = 1:2) >= D[j])

# Total distribution cost that we want to minimise
@objective(m, Min, sum(T[i,j]*x[i,j] for i=1:2, j=1:3))

println(m) # Prints the mathematical model for debugging
solve(m) # Solve the model

# Prints the optimal solution
println("\nDistribution plan: \n", getvalue(x))