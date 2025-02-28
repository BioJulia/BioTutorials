```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
# Cribbed from DimensionalData.jl
layout: home

hero:
  name: "Bio Tutorials"
  text: "Doing Biology with Julia"
  tagline: Tutorials
  actions:
    - theme: brand
      text: Getting Started
      link: /getting_started/juliainstallation
    - theme: alt
      text: Overview
      link: /overview
    - theme: alt
      text: View on Github
      link: https://github.com/BioJulia/BioJuliaDocs
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
