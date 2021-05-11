
function latex_slides(dir::String, output = "./build"; handout=false)  
    for name in readdir(dir)
        if isdir(name) && "lecture" in name
            println("Compiling $name...")
            handout ? latex_file = name * "-slides_handout.tex" : latex_file = name * "-slides.tex"
            latex_slide(output, latex_file)    
        end 
    end
end    

function latex_slide(output::String, latex_file::String) 
    command = "pdflatex -file-line-error -interaction=nonstopmode -synctex=1 -output-directory=$(output) $(latex_file)"
    run(command)
end