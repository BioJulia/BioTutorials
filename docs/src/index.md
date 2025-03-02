```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
# Cribbed from DimensionalData.jl
layout: home

hero:
  name: "BioJulia"
  text: "Tutorials"
  tagline: "Doing biology with Julia"
  actions:
    - theme: brand
      text: Basic Tutorals
      link: /rosalind/index
    - theme: alt
      text: BioJulia documentation
      link: https://github.com/BioJulia/BioJuliaDocs
    - theme: alt
      text: Source code on github
      link: https://github.com/BioJulia/BioTutorials
features:
  - title: Rosalind.info Problems
    details: These are still a work in progress
    link: https://biojulia.dev/BioTutorials
  - title: BioSequences.jl
    details: Optimized types for working with biological sequences (eg DNA, RNA, proteins)
    link: https://biojulia.dev/BioSequences.jl
  - title: Automa.jl
    details: Efficient state-machine generation to quickly and correctly parse bespoke file formats
    link: https://biojulia.dev/Automa.jl
  - title: BioMakie.jl
    details: Visualize sequences and 3D proteins with ease
    link: https://biojulia.dev/BioMakie.jl
    icon: <img width="64" height="64" src="https://github.com/MakieOrg/Makie.jl/blob/master/docs/src/assets/logo.png"/>
  - title: SingleCellProjections.jl
    details: More cells? No Problem! Get UMAPs and other projections of your singlg cell data using the power of Sparse Matrices
    link: https://biojulia.dev/SingleCellProjections.jl
---
```
