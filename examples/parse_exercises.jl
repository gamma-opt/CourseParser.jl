using CourseParser

exercise_path = joinpath(dirname(@__DIR__), "examples", "exercises")

cd(exercise_path) 
generate_skeleton("Exercise1.jl")
generate_solution("Exercise1.jl")

cd(dirname(@__DIR__))