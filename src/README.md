# Short API reference

## weave_exercises.jl
This file contains a function for converting a complete notebook to a skeleton, and two internal functions used by this function. The usage is demonsrated in an [example script.](../main/examples/parse_exercises.jl)
&nbsp;

&nbsp;

```julia
function _generate_script_from_solution(file_name::AbstractString; keyword="#%")
```
Takes a notebook named `file_name` and for each cell, looks for blocks that are between two lines matching `keyword` and adds `#%` to the beginning of each line within such blocks. Returns a path to a Julia file generated from the modified notebook.
&nbsp;

&nbsp;

```julia
function _generate_skeleton(file_name::AbstractString)
```
Takes a Julia file named `file_name`, removes all lines starting with `#%` and converts the result into a skeleton notebook. 
&nbsp;

&nbsp;

```julia
function generate_skeleton(file_name::AbstractString)
```
Combines the two previous functions, converting a notebook into a skeleton notebook and removing the intermediate Julia file.
