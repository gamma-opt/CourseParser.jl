#' 
#' # Testing exercise generation
#' #' 
#' This would be the text for the exercise... The main document that we maintain is the complete notebook and in each code cell, the parts that should be removed in the skeleton are separated with lines containing only #%
#' $Ax = b$
#' 
#+ 

println("Hello!")

#TODO
#% # Solution
#% using JuMP
#% m = Model()



#+ 

using Cbc
function solve_model(m)
    #TODO
#%     optimize!(m)
end


