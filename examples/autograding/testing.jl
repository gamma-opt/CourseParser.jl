(x_det,p_det,k_det,e_det,u_det) = solve_deterministic(ins, verbose = false)
xsol_det = value.(x_det)                          # Get optimal x values (reserved capacities)
xsol_det = round.(xsol_det.data, digits = 2)      # Round to 2 decimals
fval_det = dot(C, xsol_det)                       # Optimal cost of reserved capacities

## Solve the stochastic model
(x_sto, p_sto, k_sto, e_sto, u_sto) = solve_stochastic(ins, nS, Ps, D_sto, verbose = false)

xsol_sto = value.(x_sto)                          # Get optimal x values (reserved capacities)
xsol_sto = round.(xsol_sto.data, digits = 2)      # Round to 2 decimals
fval_sto = dot(C, xsol_sto)                       # Optimal cost of reserved capacities

tests = [fval_det ≈ 245066.76, fval_sto ≈ 281280.01]
