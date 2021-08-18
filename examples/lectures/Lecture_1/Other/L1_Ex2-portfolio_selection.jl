# Examples presented in class - Lecture 1
# Example 2 - portfolio optimisation

using Ipopt, Plots
# Ipopt is for solving nonlinear problems - different technology
# Plots is for plotting (!)

# Read the daily prices data from a .csv file.
data = readcsv("prices.csv")
#First row has the names of the stocks
stock_names = data[1, 1:end-2]
#Last two columns has data and US$ rate
prices_data = data[2:end, 1:end-2]

#Having a peek at the data
cs = plot(prices_data, label = stock_names)

#Returns are calculated as (p(t+1) - p(t))/p(t-1)
returns_data = diff(prices_data) ./ prices_data[1:end-1,:]

#Number of days and stocks in data
T, n =  size(returns_data)
#Calculates expected return and covariance
μ, Σ =  mean(returns_data, 1), cov(returns_data)
# Input form the model: minimum average return required.
r_min = 0.2

port = Model(solver=IpoptSolver())

#allocation variables
@variable(port, 0 <= x[1:n] <= 1);

#notice the division by T to correct the average
@constraint(port, sum(μ[j]*x[j] for j=1:n) >= r_min/T);

@objective(port, Min , sum(x[i]*Σ[i,j]*x[j] for i=1:n,j=1:n));

solve(port);

alloc = getvalue(x)
# Should be the same as r_min
ret = μ*alloc*T
# Looking at risk as the st. deviation of the returns.
risk = sqrt(alloc'*Σ*alloc*T)

# Organising the data for plotting. In an array, they are
# considered different series (with different colours)
stock_names = convert(Array{String}, stock_names)
alloc = convert(Array{Float64}, alloc)
# plots a pie chart
pie(stock_names, alloc, legend = false)