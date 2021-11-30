using Weave

```
Converts a file `exercise.jl` into `exercise_complete.ipynb`.
```
function generate_solution(file_name::AbstractString)
    lines = readlines(file_name, keep = true)
    solution_file = replace(file_name, ".jl" => "_solution.jl")

    open(solution_file, "w+") do f
    for line in lines
        if occursin("#%", line)
            new_line = replace(line, "#%" => "  ")
            write(f, new_line)
        else
            write(f, line)    
        end
    end
    end
    convert_doc(solution_file, replace(solution_file, ".jl" => ".ipynb"))
    rm(solution_file)
end 

```
Converts `exercise.jl` into `exercise_skeleton.ipynb`.
```
function generate_skeleton(file_name::AbstractString)
    lines = readlines(file_name, keep=true)
    skeleton_file = replace(file_name, ".jl" => "_skeleton.jl")

    open(skeleton_file, "w+") do f
        for line in lines
            occursin("#%", line) ? write(f, "\n") : write(f, line)    
        end
    end
    
    convert_doc(skeleton_file, replace(skeleton_file, ".jl" => ".ipynb"))
    rm(skeleton_file)
end 

```
Converts a file `exercise_complete.ipynb` into `exercise_complete.jl`. Use this to first generate skeleton
.jl scripts which will then require to have the solution cells marked with '##' and name corrected.
```
function generate_script_from_solution(file_name::AbstractString)
    script_file = replace(file_name, ".ipynb" => ".jl")
    convert_doc(file_name, script_file)
end

```
Converts a file `exercise_complete.ipynb` into `exercise.jl`. Use this to generate
.jl scripts which will have the solution lines marked with '#%'.

Assumes that inside each code cell, the parts that should be removed from the skeleton are
separated by lines corresponding to the parameter _keyword_.

Example input:
a = 1
b = 2
function addition(a,b)
#%
    return a+b
#%
end
```
function generate_processed_script_from_solution(file_name::AbstractString; keyword="#%")
    doc = Weave.WeaveDoc(file_name)
    for chunk in filter(chunk -> typeof(chunk) == Weave.CodeChunk, doc.chunks)
        flag = false
        new_content = ""
        for line in split(chunk.content,"\n")
            if flag
                if line == keyword
                    flag = false
                else
                    new_content *= "#% " * line * "\n"
                end
            else
                if line == keyword
                    flag = true
                else
                    new_content *= line * "\n"
                end
            end
        end
        if flag
            @warn("Unmatched " * keyword * " in code cell number $(chunk.number), cell is passed through as is!")
        else
            chunk.content = new_content
        end
    end

    converted = Weave._convert_doc(doc, "script")

    outfile = replace(file_name, ".ipynb" => ".jl")
    outfile = replace(outfile, "_complete" => "")
    open(outfile, "w") do f
        write(f, converted)
    end
    return outfile
end


```
Generates both skeleton and complete notebooks.
```
function generate_notebooks(file_name::AbstractString)
    generate_skeleton(file_name)
    generate_solution(file_name)
end
