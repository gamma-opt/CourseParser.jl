using Weave


```
Converts `exercise.jl` into `exercise_skeleton.ipynb`.
```
function _generate_skeleton(file_name::AbstractString)
    lines = readlines(file_name, keep=true)
    skeleton_file = replace(file_name, ".jl" => "_skeleton.jl")

    open(skeleton_file, "w+") do f
        for line in lines
            if !startswith(strip(line), "#%")
                write(f, line)
            end
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
function _generate_script_from_solution(file_name::AbstractString; if_keyword="#%", else_keyword="#%%")
    doc = Weave.WeaveDoc(file_name)
    for chunk in filter(chunk -> typeof(chunk) == Weave.CodeChunk, doc.chunks)
        indentlevel = 0
        if_flag = false
        else_flag = false
        new_content = ""
        for line in split(chunk.content,"\n")
            if if_flag
                if strip(line) == if_keyword
                    if !else_flag
                        new_content *= ("    "^indentlevel)*"# TODO: add your code here\n"
                    end
                    if_flag = false
                    else_flag = false
                elseif strip(line) == else_keyword
                    else_flag = true
                else
                    if else_flag
                        new_line = strip(chop(strip(line), head=1, tail=0))
                        new_content *= ("    "^indentlevel)*new_line * "\n"
                        if startswith(new_line, r"function |if |for |while")
                            indentlevel += 1
                        elseif strip(new_line) == "end"
                            indentlevel -= 1
                        end
                    else
                        new_content *= "#% " * line * "\n"
                    end
                end
            else
                if strip(line) == if_keyword
                    if_flag = true
                elseif strip(line) == else_keyword
                    @warn("Keyword " * else_keyword * " outside " * if_keyword * " in code cell number $(chunk.number), it will be ignored!")
                else
                    new_content *= line * "\n"
                    if startswith(strip(line), r"function |if |for |while")
                        indentlevel += 1
                    elseif strip(line) == "end"
                        indentlevel -= 1
                    end
                end
            end
        end
        if if_flag
            @warn("Unmatched " * if_keyword * " in code cell number $(chunk.number), cell is passed through as is!")
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
