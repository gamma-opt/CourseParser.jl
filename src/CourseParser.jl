module CourseParser

include("weave_exercises.jl")
include("latex_files.jl")

export generate_solution,
       generate_skeleton,
       generate_script_from_solution,
       generate_processed_script_from_solution,
       generate_notebooks

export latex_files,
       latex_file        

end # module
