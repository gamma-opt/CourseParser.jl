using Weave

```
Converts a notebook infile into a Julia file outfile,
only including the code cells that have the specified keyword in them.
```
function ipynb_to_jl_keyword(infile::AbstractString, outfile::AbstractString, keyword::AbstractString)
    # Validation
    (lowercase(splitext(infile)[2]) == ".ipynb") || throw(ArgumentError("$infile not valid, should end with .ipynb"))
    (lowercase(splitext(outfile)[2]) == ".jl") || throw(ArgumentError("$outfile not valid, should end with .jl"))

    # Convert notebook to Weave document
    doc = Weave.WeaveDoc(infile)
    # Include only code chunks, as other chunks aren't relevant for grading
    doc.chunks = filter(chunk -> typeof(chunk) == Weave.CodeChunk, doc.chunks)
    # Include only the chunks with the keyword in them
    doc.chunks = filter(chunk -> occursin(keyword,chunk.content), doc.chunks)

    # Convert Weave document to .jl-file and write to file
    converted = Weave._convert_doc(doc, "script")
    open(outfile, "w") do f
        write(f, converted)
    end
    return outfile
end

# Returns a list of folders in a directory.
function get_folders(dir::AbstractString)
    # Get paths of all files in the directory
    filepaths = readdir(dir,join=true)

    # List only the folders
    folders = filter(isdir, filepaths)

    println("Found $(length(folders)) folders")
    return folders
end


# Finds the path of the notebook inside a folder. If number of notebooks is not 1, returns an empty string.
function find_notebook(folder::AbstractString)
    # Get paths of all files in the directory
    filepaths = readdir(folder,join=true)
    # Find all .ipynb-files, excluding the checkpoint folder
    notebooks = filter(x -> (occursin(r".ipynb", x) && !occursin(r".ipynb_checkpoints", x)), filepaths)

    # Check the number of notebooks found
    if length(notebooks) == 1
        return notebooks[1]
    else
        return ""
    end
end
