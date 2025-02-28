using Documenter
using DocumenterVitepress

makedocs(
    sitename = "BioTutorials",
    authors = "Kevin Bonham and Contributors",
    modules = Module[],
    clean = false,
    doctest = true,
    draft = false,
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "https://github.com/BioJulia/BioTutorials",
        md_output_path = ".",
        build_vitepress = haskey(ENV, "CI")
    ),
    pages = [
        "Rosalind.info" => [
            "rosalind/01-dna.md",
            "rosalind/02-rna.md",
            "rosalind/03-revc.md",

        ],
    ]
)

deploydocs(
    repo = "https://github.com/BioJulia/BioJuliaDocs.git",
    target = "build",
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true,
)
