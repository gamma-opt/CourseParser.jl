#' 
#' # Testing exercise generation
#' #' 
#' This would be the text for the exercise... Works exactly like in a notebook. We mark with 2  
#' hashtags () lines to be present only in the solution.
#' $Ax = b$
#' 
#+ 

# TODO
println("Hello!")

# Solution
using JuMP
m = Model()

#' 
#' 
#' 
#+ 

# TODO

# Solution 2
using Cbc
optimize!(m)
