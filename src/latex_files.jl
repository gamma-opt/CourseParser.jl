
function latex_files(dir::String, output = "./pdfs")  
    for lecture_folder in readdir(dir)
        if isdir(lecture_folder) && occursin("Lecture_", lecture_folder)
            println("Compiling $lecture_folder...")
            handout = lecture_folder * "-slide_handout.tex"
            annotated = lecture_folder * "-slide_annotated.tex"
            note = lecture_folder * "-notes.tex" 
            cd(lecture_folder)
            latex_file(output, handout)
            latex_file(output, annotated)
            latex_file(output, note)
            cd("..")    
        end 
    end
end    

function latex_file(output::String, latex_file::String)    
    !isdir(output) && mkdir(output)
    
    command = `pdflatex -file-line-error -interaction=batchmode -synctex=1 -output-directory=$(output) $(latex_file)`
    run(command)

    # Removes intermediate files from latex compilation
    for file in readdir(output)
        if !occursin(".pdf", file)
            rm(joinpath(output,file))
        end
    end
end
