module BioTutorials

function build(dir)
    isdir(dir) || throw(ArgumentError("Provide path to directory with tutorial file"))
    files = filter(f-> splitext(f)[2] == ".jl", readdir(dir; join=true))
    file = length(files) == 1 ? first(files) : throw(ArgumentError("Tutorial directory must have exactly one .jl file"))

    c = Cmd([
        "julia", "--project=@.", "-e",
        """
        using Literate; using Pkg; Pkg.activate("$dir"); Pkg.instantiate(); Literate.notebook("$file", "$dir")
        """
    ])
    run(c)
end

end