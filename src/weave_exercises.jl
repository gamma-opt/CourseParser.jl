using Weave


```
Converts `exercise.jl` into `exercise_skeleton.ipynb`.
```
function _generate_skeleton(file_name::AbstractString)
    lines = readlines(file_name, keep=true)
    skeleton_file = replace(file_name, ".jl" => "_skeleton.jl")

    open(skeleton_file, "w+") do f
        for line in lines
            startswith(strip(line), "#%") ? write(f, "\n") : write(f, line)
        end
    end

    convert_doc(skeleton_file, replace(skeleton_file, ".jl" => ".ipynb"))
    rm(skeleton_file)
end

```
Converts a file `exercise_complete.ipynb` into `exercise.jl`. Use this to generate
.jl scripts which will have the solution lines marked with '#%'.

Assumes that inside each code cell, the parts that should be removed from the skeleton are
separated by lines corresponding to the parameter _keyword_.
```
function _generate_script_from_solution(file_name::AbstractString; keyword="#%")
    doc = Weave.WeaveDoc(file_name)
    for chunk in filter(chunk -> typeof(chunk) == Weave.CodeChunk, doc.chunks)
        flag = false
        new_content = ""
        for line in split(chunk.content,"\n")
            if flag
                if strip(line) == keyword
                    flag = false
                else
                    new_content *= "#% " * line * "\n"
                end
            else
                if strip(line) == keyword
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
function generate_skeleton(file_name::AbstractString)
    jl_file = _generate_script_from_solution(file_name)
    _generate_skeleton(jl_file)
    rm(jl_file)
end
