+++
title = "Pairwise alignment"
rss_descr = "Align a gene against a reference genome using BioAlignments.jl"
+++

# Pairwise Alignment

On the most basic level, aligners take two sequences and use algorithms to try to "line them up" 
and look for regions of similarity.  

Pairwise alignment differs from multiple sequence alignment (MSA) because  
it only aligns two sequences, while MSAs align three or more.  
In a pairwise alignment, there is one reference sequence and one query sequence,   
though this may not always be specified by the user.  


### Running the Alignment
There are two main parameters for determining how we want to perform our alignment:     
the alignment type and score/cost model.  

The alignment type specifies the alignment range (local vs global alignment)  
and the score/cost model explains how to score insertions and deletions.   

#### Alignment Types
Currently, four types of alignments are supported:
- `GlobalAlignment`: global-to-global alignment
    - Aligns sequences end-to-end 
    - Best for sequences that are already very similar
    - All of query is aligned to all of reference
- `SemiGlobalAlignment`: local-to-global alignment
    - A modification of global alignment that allows the user to specify that gaps are  penalty-free at the beginning of one of the sequences and/or at the end of one of the sequences (more information can be found [here](https://www.cs.cmu.edu/~durand/03-711/2023/Lectures/20231001_semi-global.pdf)).
- `LocalAlignment`: local-to-local alignment
    - Identifies high-similarity, conserved sub-regions within divergent sequences
    - Can occur anywhere in the alignment matrix
    - Maps the query sequence to the most similar region on the reference
- `OverlapAlignment`: end-free alignment
    - A modification of global alignment where gaps at the beginning or end of sequences are permitted

The alignment type should be selected based on what is already known about the sequences the user is comparing:   
- Are the two sequences very similar and we're looking for a couple of small differences?   
- Is the query expected to be a nearly exact match within the reference?  
- Are we looking at two sequences from wildly divergent organisms?   


### Cost Model

The cost model provides a way to calculate penalties for differences between the two sequences,  
and then finds the alignment that minimizes the total penalty.   
`AffineGapScoreModel` is the scoring model currently supported by `BioAlignments.jl`.  
It imposes an affine gap penalty for insertions and deletions,     
which means that it penalizes the opening of a gap more than a gap extending.  
This aligns (pun intended!!) with the biological principle that creating a gap is a rare event,   
while extending an already existing gap is less so.  

A user can also define their own `CostModel` instead of using `AffineGapScoreModel`.  
This will allow the user to define their own scoring scheme for penalizing insertions, deletions, and substitutions.  

After the cost model is defined, a distance metric is used to quantify and minimize the "cost" (difference) between the two sequences. 

These distance metrics are currently supported:
- `EditDistance`
- `LevenshteinDistance`
- `HammingDistance`

This is a complicated topic, and more information can be found in the BioAlignments documentation about the cost model [here](https://biojulia.dev/BioAlignments.jl/stable/pairalign/).  

Just like alignment type, the cost model should be selected based on what the user is optimizing for  
and what is known about the two sequences.    


### Calling BioAlignments to Run the Alignment

Now that we have a good understanding of how `pairalign` works, let's run an example!

```julia
using BioAlignments

s1 = 
s2 = 
scoremodel = AffineGapScoreModel(EDNAFULL, gap_open=-5, gap_extend=-1);

res = pairalign(GlobalAlignment(), s1, s2, scoremodel)  # run pairwise alignment

res
```


### Understanding how alignments are represented
The output of an alignment is a series of `AlignmentAnchor` objects.  
This data structure gives information on the position of the start of the alignment,   
sections where nucleotides match, as well as where there may be deletions or insertions.  

Below is an example alignment:
```julia
julia> Alignment([
           AlignmentAnchor(0,  4, 0, OP_START),
           AlignmentAnchor(4,  8, 4, OP_MATCH),
           AlignmentAnchor(4, 12, 8, OP_DELETE)
       ])
```
In this example, the alignment starts at position 0 for the query sequence and position 4 for the reference sequence.  
Although the Julia programming language typically uses 1-based indexing,   
this package uses position 0 to refer to the first position.  
The next nucleotides are a match in the query and reference sequences.     
The last 8 nucleotides in the alignment are deleted in the query sequence.  

To learn more about the output of the alignment created using BioAlignments.jl, see [here](https://biojulia.dev/BioAlignments.jl/stable/alignments/).    