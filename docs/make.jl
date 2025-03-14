using Documenter
using DocumenterVitepress

ROSALIND_PAGES = [
            "rosalind/index.md",
            "rosalind/01-dna.md",
            "rosalind/02-rna.md",
            "rosalind/03-revc.md",
            "rosalind/04-fib.md",
            "rosalind/05-gc.md",
        ]

makedocs(
    sitename = "BioTutorials",
    authors = "Kevin Bonham and Contributors",
    modules = Module[],
    clean = false,
    doctest = true,
    draft = false,
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "https://github.com/BioJulia/BioTutorials",
        # md_output_path = ".", # remove when pushing
        build_vitepress = haskey(ENV, "CI")
    ),
    pages = [
        "Rosalind.info" =>  ROSALIND_PAGES
       ]
)

deploydocs(
    repo = "https://github.com/BioJulia/BioTutorials.git",
    target = "build",
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true,
)
