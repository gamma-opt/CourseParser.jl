using CourseParser, Suppressor

# Runs the .jl-file corresponding to the student submission and runs some tests on it.
# TODO: this is somewhat of a proof-of-concept. Would be nice if the tests could be read from a file and the results output to a file.
function test_submission(jl_file::AbstractString)
    @suppress include("preparation.jl")
    try
        @suppress include(jl_file)
    catch e
        println("Student $(student_name): notebook threw an error.")
        return
    end
    @suppress include("testing.jl")
    return tests
end



subdir = "\\Homework 1"
folders = get_folders((@__DIR__)*subdir)

notebooks = Dict{AbstractString, AbstractString}()

for folder in folders
    # This is ugly, but works even with non-ASCII characters (such as ä or ö), unlike the commented version below
    student_name = replace(folder[findall(x -> x=='\\', folder)[end]+1:findall(x -> x=='_', folder)[end-3]], r"_"=>"")
    # student_name = folder[findall(x -> x=='\\', folder)[end]+1:findall(x -> x=='_', folder)[end-3]-1]

    student_nb = find_notebook(folder)
    if student_nb == ""
        println("Student $(student_name) has no notebook or multiple notebooks.")
        continue
    else
        notebooks[student_name] = student_nb
    end
end

for (student_name, notebook) in notebooks
    jl_file = replace(notebook, ".ipynb" => ".jl")
    jl_file = ipynb_to_jl_keyword(notebook, jl_file, "THIS CELL WILL BE AUTOGRADED")
    tests = test_submission(jl_file)

    println(student_name)
    println("$(sum(tests))/$(length(tests)) tests passed.")
    println("")
end
