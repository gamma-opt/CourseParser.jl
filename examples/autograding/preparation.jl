using JuMP
using Cbc
using Random
Random.seed!(2)         # Control random number generation
using LinearAlgebra
using Statistics

# This structure will ease the passing of the specific instance for the functions
# that generate and solve the optimization model.
mutable struct Instance
    nI     # Number of suppliers
    nJ     # Number of demand points
    nT     # Number of periods
    I      # Supplier range
    J      # Demand points range
    T      # Periods range
    C      # Unit capacity costs per supplier
    H      # Unit storage cost per supplier
    M      # Production cost per supplier
    D      # Client demands in all periods
    Q      # Unit costs of unfulfilled demand
    F      # Unit costs to fulfil demands
end

## Problem data
nI = 25                                # Number of suppliers
nJ = 25                                # Number of demand points
nT = 10                                # Number of periods
I_range = 1:nI                         # Supplier range
J = 1:nJ                               # Demand points range
T = 1:nT                               # Periods range

## Generate random data for the problem
C = rand(20:200, nI)                   # Unit capacity costs per supplier
H = rand(1:4, nI)                      # Unit storage cost per supplier
M = rand(10:40, nI)                    # Production cost per supplier
D = rand(nJ,nT).*rand(100:500, nJ)     # Client demands in all periods
Q = rand(5000:10000, nJ)               # Unit costs of unfulfilled demand
F = rand(3:45, (nI,nJ))                # Unit costs to fulfil demands

# This packages the problem instance information into a single structure.
ins = Instance(nI, nJ, nT, I_range, J, T, C, H, M, D, Q, F);

## Generating the demand scenarios
function create_scenarios(ins::Instance, nS)

    ## Renaming for making the implementation clearer
    nJ = ins.nJ
    nT = ins.nT
    J = ins.J
    T = ins.T
    D = ins.D

    S  = 1:nS                 # scenario set
    Ps = repeat([1/nS],nS )   # scenario probability

    ## d_sto: Stochastic demand
    D_sto = zeros(nS, size(D)[1], size(D)[2])

    ## Creating the Monte Carlo simulation
    α = mean.(D[j,:] for j in J)         # Average demand per supply node (D_{j0})
    μ = round.(0.05 * rand(nJ), digits=5) # Expected demand growth
    σ = 0.05                             # Max variability
    ϵ = randn(nS,nJ,nT)                  # This is the variability, following a standard normal

    ## Assigning stochastic values
    for s in S
        for j in J
            D_sto[s,j,1] = (1 + μ[j] + σ * ϵ[s,j,1]) * α[j]
            for t in T[T.>1]
                D_sto[s,j,t] =  (1 + μ[j] + σ * ϵ[s,j,t]) * D_sto[s,j,t-1]
            end
        end
    end
    return D_sto, Ps
end;

## Considering 50 scenarios for this study
nS = 50
D_sto, Ps = create_scenarios(ins, nS);
