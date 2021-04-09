
```
Converts exercise.jl into exercise_complete.ipynb..
```
function generate_solution(path::AbstractString)
    lines = readlines(path, keep = true)
    solution_file = replace(path, ".jl" => "_complete.jl")

    open(solution_file, "w+") do f
    for line in lines
        if occursin("##", line)
            new_line = lstrip(replace(line, "##" => ""))
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
Converts exercise.jl into exercise_skeleton.ipynb..
```
function generate_skeleton(path::AbstractString)
    lines = readlines(path, keep=true)
    skeleton_file = replace(path, ".jl" => "_skeleton.jl")

    open(skeleton_file, "w+") do f
    for line in lines
        occursin("##", line) ? continue : write(f, line)    
    end
    end
    
    convert_doc(skeleton_file, replace(skeleton_file, ".jl" => ".ipynb"))
    rm(skeleton_file)
end 