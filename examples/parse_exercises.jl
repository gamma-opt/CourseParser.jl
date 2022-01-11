using CourseParser

exercise_path = joinpath(dirname(@__DIR__), "examples", "exercises")

cd(exercise_path)
generate_skeleton("Exercise1_complete.ipynb")

cd(dirname(@__DIR__))
