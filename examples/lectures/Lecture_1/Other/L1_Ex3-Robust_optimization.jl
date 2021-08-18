# Examples presented in class - Lecture 1
# Example 3 - Robust Knapsack Problem

using Distributions, ECOS, LaTeXStrings
# Distributions includes probability distributions,
# ECOS is a solver that we need because of the stucture of the problem
# LatexStrings is to write LaTeX in our plots

N = 18

#Input data
value = [50, 40, 70, 55, 80, 35, 65, 50, 60, 85, 20, 45, 55, 25, 80, 45, 45, 65]
weight_average = [3.5, 4, 5.5, 5, 6, 4.5, 6, 4, 5.5, 7, 5, 4.5, 7, 3.5, 5.5, 3.5, 4, 6.5]
weight_stdev = weight_average*0.3

#Randomly generating initial data using normal distribution
weight_data = Array{Float64}(100,N)
for j= 1:N
   weight_data[:,j] = rand(Normal(weight_average[j], weight_stdev[j]), 100)
end

#Input data: weight limit (capacity)
capacity = 20

# Protection elipsoid: adds 50% of weight as a protection level
P = 0.5*weight_average

# Declaring the model and solving it as a function.
function solve_robust_model(N, value, weight_average, P, Γ)
    m = Model(solver = ECOSSolver()) #creates the model, select the solver

    @variable(m, 0 <= x[1:N] <= 1 ) # creates the binary variables x, one for each item

    @constraint(m, sum(weight_average[j]*x[j] for j = 1:N) + Γ*norm(P'*x) <= capacity) # declare the knapsack constraint

    @objective(m, Max, sum(value[j]*x[j] for j = 1:N)) # declare the objective function

    solve(m)

    return getvalue(x)
end

# This function simulates the item selection againts feasibility.
function feasibility_estimate(solution, repetitions)
    feasible_count = 0
    actual_weight = zeros(18)
    for n= 1:repetitions
        for j= 1:N
           # generate random weights according to distribution
           actual_weight[j] = rand(Normal(weight_average[j], weight_stdev[j]))
        end
        #if total weight more than capacity => problem infeasible.
        if actual_weight'*solution <= capacity
            feasible_count += 1
        end
    end
    return feasible_count/repetitions
end

# generate a range of Gammas to try
Γ_range = linspace(0,1,10)

# storing the results of each run
feas = []
total_value = []
Γ_used = []

# for each Gamma, solve te model and store the results
for Γ in Γ_range
    println(Γ)
    x = solve_robust_model(N, value, weight_average, P, Γ)
    push!(Γ_used, Γ)
    push!(feas, feasibility_estimate(x,5000))
    push!(total_value, value'x)
end

# plotting the results from simulation
p1 = plot(Γ_used, feas, xlabel = L"\Gamma", ylabel = "feas. prob.", legend=false)
p2 = plot(Γ_used, total_value, xlabel = L"\Gamma", ylabel = "total value", legend=false, color=:orange)
plot(p1,p2, layout = (2,1))


