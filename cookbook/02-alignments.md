+++
title = "Pairwise alignment"
rss_descr = "Align a gene against a reference genome using BioAlignments.jl"
+++

# Pairwise Alignment

On the most basic level, aligners take two sequences and use algorithms to try and "line them up" 
and look for regions of similarity.  

Pairwise alignment differs from multiple sequence alignment (MSA) because. 
it only aligns two sequences, while MSA's align three or more.  
In a pairwise alignment, there is one reference sequence, and one query sequence,   
though this may not always be specified by the user.  


### Running the Alignment
There are two main parameters for determining how we wish to perform our alignment:     
the alignment type and score/cost model.  

The alignment type specifies the alignment range (is the alignment local or global?)  
and the score/cost model explains how to score insertions and deletions.   

#### Alignment Types
Currently, four types of alignments are supported:
- GlobalAlignment: global-to-global alignment
    - Aligns sequences end-to-end 
    - Best for sequences that are already very similar
- SemiGlobalAlignment: local-to-global alignment
    - a modification of global alignment that allows the user to specify that gaps will be penalty-free at the beginning of one of the sequences and/or at the end of one of the sequences (more information can be found [here](https://www.cs.cmu.edu/~durand/03-711/2023/Lectures/20231001_semi-global.pdf)).
- LocalAlignment: local-to-local alignment
    - Identifies high-similarity, conserved sub-regions within divergent sequences
    - Can occur anywhere in the alignment matrix
- OverlapAlignment: end-free alignment
    - a modification of global alignment where gaps at the beginning or end of sequences are permitted

Alignment type can also be a distance of two sequences:
- EditDistance
- LevenshteinDistance
- HammingDistance

The alignment type should be selected based on what is already known about the sequences the user is comparing  
(Are they very similar and we're looking for a couple of small differences?   
Are we expecting the query to be a nearly exact match within the reference?).   
and what you may be optimizing for  
(Speed for a quick and dirty analysis?   
Or do we want to use more resources to do a fine-grained comparison?).  

Now that we have a good understanding of how `pairalign` works, 

```julia
res = pairalign(GlobalAlignment(), s1, s2, scoremodel)  # run pairwise alignment

```


### Understanding how alignments are represented
The output of an alignment is a series of `AlignmentAnchor` objects.  
This data structure gives information on the position of the start of the alignment,   
sections where nucleotides match, as well as where there may be deletions or insertions.  

Below is an example Alignment:
```julia
julia> Alignment([
           AlignmentAnchor(0,  4, 0, OP_START),
           AlignmentAnchor(4,  8, 4, OP_MATCH),
           AlignmentAnchor(4, 12, 8, OP_DELETE)
       ])
```
In this example, the alignment starts at the 0 position for the query sequence and 4th position for the reference sequence.  
The next nucleotides are a match in the query and reference sequence.     
The last 8 nucleotides in the alignment are missing/deleted in the query sequence.  

To understand more about the output of the alignment created using BioAlignments.jl,   
more information can be found [here](https://biojulia.dev/BioAlignments.jl/stable/alignments/).  