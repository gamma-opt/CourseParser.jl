# CourseParser.jl
 Parsing scripts for optimisation courses. Convert complete jupyter notebooks into skeletons. Utilises `.jl` scripts as intermediate files.
 
 Consider that complete notebooks have all the answers. Code lines that are to be hidden in the skeleton must be in between `#%` markers. Those are removed when generating the skeleton and replace with a comment `"# TODO: add your code here"`. Example:
 
Complete notebook:
```julia
## Objective: Minimize the total costs
#%
@objective(model, Min,
      sum(C[i] * x[i] for i in I) +
      sum(H[i] * k[i,t] + M[i]*p[i,t] for t in T, i in I)
)
#%

## Constraints
#%

## Supply balance constraint
## (T=1): First period do not count with previous stocks
@constraint(model, SupBal1[i in I, t in [1]], p[i,t] == sum(e[i,j,t] for j in J) + k[i,t])
## (T>1): All periods but the first are balanced with the storage levels decided in the previous periods
@constraint(model, SupBal2[i in I, t in T[T.>1]], p[i,t] + k[i,t-1] == sum(e[i,j,t] for j in J) + k[i,t])

#%
```
Becomes the following skeleton:

```julia

## Objective: Minimize the total costs
# TODO: add your code here


    
## Constraints
# TODO: add your code here


```


