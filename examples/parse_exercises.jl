using CourseParser

exercise_path = joinpath(dirname(@__DIR__), "examples", "exercises")

cd(exercise_path) 
generate_skeleton("Exercise1.jl")
generate_solution("Exercise1.jl")
generate_script_from_solution("Exercise1_complete.ipynb")

cd(dirname(@__DIR__))