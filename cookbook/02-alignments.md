+++
title = "Pairwise alignment"
rss_descr = "Align a gene against a reference genome using BioAlignments.jl"
+++

As mentioned in the previous [tutorial]("../01-sequences.md"), in this chapter, we will learn about alignments.    
We will explore pair-wise alignment as a tool to compare two copies of the _mecA_ gene found on NCBI.  

# Pairwise Alignment

On the most basic level, aligners take two sequences and use algorithms to try to "line them up" 
and look for regions of similarity.  

Pairwise alignment differs from multiple sequence alignment (MSA) because  
it only aligns two sequences, while MSAs align three or more.  

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
    - Example use case:
        - Comparing a particular gene from two closely related bacteria
        - Comparing alleles of a gene between two individuals
    - Not ideal when only one conserved region is shared

- `SemiGlobalAlignment`: local-to-global alignment
    - A modification of global alignment that allows the user to specify that gaps are  penalty-free at the beginning of one of the sequences and/or at the end of one of the sequences (more information can be found [here](https://www.cs.cmu.edu/~durand/03-711/2023/Lectures/20231001_semi-global.pdf)).
    - Example use case:
        - Aligning a contig to a chromosome to see where that contig belongs
        - Aligning a 150 bp Illumina read to a longer reference gene or chromosome segment
    - A simple way to think about it: “the query should align completely, but the reference may have unaligned flanks.”
- `LocalAlignment`: local-to-local alignment
    - Identifies high-similarity, conserved sub-regions within divergent sequences
    - Can occur anywhere in the alignment matrix
    - Maps the query sequence to the most similar region on the reference
    - Example use case:
        - Finding a conserved protein domain inside two otherwise divergent proteins
        - Aligning a short resistance-gene fragment to a genome to see whether that region is present
    - This is the right choice when you care about “where is the best shared region?” rather than “do these two full sequences match end-to-end?”
- `OverlapAlignment`: end-free alignment
    - A modification of global alignment where gaps at the beginning or end of sequences are permitted
    - Best when the biologically meaningful match is an end-to-end overlap between the two sequences, and terminal overhangs should not be penalized
    - Example use case:
        - Merging paired-end reads when the forward and reverse reads overlap
        - Stitching amplicons or long reads that share an overlapping end region
    - The key distinction from semi-global is that overlap alignment is especially for suffix/prefix-style overlaps between sequence ends, which is why it is so useful in assembly workflows.

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
Deletions are rare mutations, but if there's a deletion, the length of the deletion is variable.   
Longer deletions are less likely than short ones only because they change the structure of the encoded protein more.  

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

In this example, we'll compare two similar genes: mecA found in _S. aureus_ ([link to gene on NCBI here](https://www.ncbi.nlm.nih.gov/nuccore/NG_047945.1)), and a homologue, mecA1,  found on a _S. sciuri_ ([link to gene on NCBI here](https://www.ncbi.nlm.nih.gov/gene/?term=PBP2a+family+beta-lactam-resistant+peptidoglycan+transpeptidase+MecA1)).  
The two Staphs are closely related species in the same _Staphylococcaceae_ family. 

Because we are comparing homologous genes from two closely related species, we wouldn't expect too many differences.  
Although mecA1 doesn't confer resistance to beta-lactams in _S. sciuri_ like _mecA_ does to _S. aureus_,   
the gene should be mostly conserved. 
In fact, mecA1 is considered a pre-cursor to mecA.    
Research indicates that there is 80% nucleotide identity between the two genes.[1]. 
Due to the similarity in the genes we are comparing, it makes the most sense to run a global alignment.    

In this first example, we'll align two strings that contain the genes.  

#### Running Alignment on BioSequences Object

```julia
using BioAlignments

mecA = 
"ATGAAAAAGATAAAAATTGTTCCACTTATTTTAATAGTTGTAGTTGTCGGGTTTGGTATATATTTTTATGCTTCAAAAGATAAAGAAATTAATAATACTATTGATGCAATTGAAGATAAAAATTTCAAACAAGTTTATAAAGATAGCAGTTATATTTCTAAAAGCGATAATGGTGAAGTAGAAATGACTGAACGTCCGATAAAAATATATAATAGTTTAGGCGTTAAAGATATAAACATTCAGGATCGTAAAATAAAAAAAGTATCTAAAAATAAAAAACGAGTAGATGCTCAATATAAAATTAAAACAAACTACGGTAACATTGATCGCAACGTTCAATTTAATTTTGTTAAAGAAGATGGTATGTGGAAGTTAGATTGGGATCATAGCGTCATTATTCCAGGAATGCAGAAAGACCAAAGCATACATATTGAAAATTTAAAATCAGAACGTGGTAAAATTTTAGACCGAAACAATGTGGAATTGGCCAATACAGGAACAGCATATGAGATAGGCATCGTTCCAAAGAATGTATCTAAAAAAGATTATAAAGCAATCGCTAAAGAACTAAGTATTTCTGAAGACTATATCAAACAACAAATGGATCAAAATTGGGTACAAGATGATACCTTCGTTCCACTTAAAACCGTTAAAAAAATGGATGAATATTTAAGTGATTTCGCAAAAAAATTTCATCTTACAACTAATGAAACAAAAAGTCGTAACTATCCTCTAGAAAAAGCGACTTCACATCTATTAGGTTATGTTGGTCCCATTAACTCTGAAGAATTAAAACAAAAAGAATATAAAGGCTATAAAGATGATGCAGTTATTGGTAAAAAGGGACTCGAAAAACTTTACGATAAAAAGCTCCAACATGAAGATGGCTATCGTGTCACAATCGTTGACGATAATAGCAATACAATCGCACATACATTAATAGAGAAAAAGAAAAAAGATGGCAAAGATATTCAACTAACTATTGATGCTAAAGTTCAAAAGAGTATTTATAACAACATGAAAAATGATTATGGCTCAGGTACTGCTATCCACCCTCAAACAGGTGAATTATTAGCACTTGTAAGCACACCTTCATATGACGTCTATCCATTTATGTATGGCATGAGTAACGAAGAATATAATAAATTAACCGAAGATAAAAAAGAACCTCTGCTCAACAAGTTCCAGATTACAACTTCACCAGGTTCAACTCAAAAAATATTAACAGCAATGATTGGGTTAAATAACAAAACATTAGACGATAAAACAAGTTATAAAATCGATGGTAAAGGTTGGCAAAAAGATAAATCTTGGGGTGGTTACAACGTTACAAGATATGAAGTGGTAAATGGTAATATCGACTTAAAACAAGCAATAGAATCATCAGATAACATTTTCTTTGCTAGAGTAGCACTCGAATTAGGCAGTAAGAAATTTGAAAAAGGCATGAAAAAACTAGGTGTTGGTGAAGATATACCAAGTGATTATCCATTTTATAATGCTCAAATTTCAAACAAAAATTTAGATAATGAAATATTATTAGCTGATTCAGGTTACGGACAAGGTGAAATACTGATTAACCCAGTACAGATCCTTTCAATCTATAGCGCATTAGAAAATAATGGCAATATTAACGCACCTCACTTATTAAAAGACACGAAAAACAAAGTTTGGAAGAAAAATATTATTTCCAAAGAAAATATCAATCTATTAACTGATGGTATGCAACAAGTCGTAAATAAAACACATAAAGAAGATATTTATAGATCTTATGCAAACTTAATTGGCAAATCCGGTACTGCAGAACTCAAAATGAAACAAGGAGAAACTGGCAGACAAATTGGGTGGTTTATATCATATGATAAAGATAATCCAAACATGATGATGGCTATTAATGTTAAAGATGTACAAGATAAAGGAATGGCTAGCTACAATGCCAAAATCTCAGGTAAAGTGTATGATGAGCTATATGAGAACGGTAATAAAAAATACGATATAGATGAATAACAAAACAGTGAAGCAATCCGTAACGATGGTTGCTTCACTGTTTTATTATGAATTATTAATAAGTGCTGTTACTTCTCCCTTAAATACAATTTCTTCATTT"
mecA1 = "ATGAAAAAATTAATCATCGCCATCGTGATTGTAATCATCGCTGTTGGTTCAGGCGTATTCTTTTATGCATCTAAAGATAAGAAAATAAACGAAACAATTGATGCCATTGAAGATAAAAACGTTAAGCAAGTCTTTAAAAATAGTACTTACCAATCTAAAAACGATAATGGTGAAGTAGAAATGACAGACCGCCCTATTAAGATTTATGACAGTCTCGGCGTCAAAGATATCAACATTAAAGATCGTGATATCAAAAAGGTTTCGAAAAACAAAAAACAAGTCACAGCAAAGTATGAACTTCAAACGAATTACGGCAAAATTAATCGTGACGTTAAATTAAACTTTATTAAAGAAGATAAAGATTGGAAATTGGATTGGAATCAAAATGCCATTATTCCAGGCATGAAGAAAAATCAATCCATCAATATTGAACCATTGAAATCAGAACGAGGTAAGATTTTAGACAGGAACAATGTAGAGTTAGCCACTACAGGAACAACACATGAAGTTGGTATTGTTCCTAATAATGTTTCCACAAGTGATTACAAAGCAATCGCTGAAAAGTTAGACCTTTCAGAATCGTATATTAAACAGCAAACAGAACAGGATTGGGTTAAAGATGATACATTCGTCCCTCTCAAGACTGTTCAAGATATGAATCAAGATTTAAAGAATTTTGTTGAAAAGTATCATCTCACATCACAGGAAACAGAAAGTCGACAGTATCCGCTTGAAGAAGCAACAACGCACTTACTTGGATATGTTGGCCCTATTAATTCAGAAGAATTGAAGCAAAAAGCATTTAAAGGTTATAAAAAGGATGCCATCGTTGGTAAAAAAGGTATCGAAAAACTATACGATAAAGACCTTCAAAATAAAGACGGATACCGTGTCACAATAATTGATGATAATAATAAAGTTATTGATACATTAATAGAGAAAAAGAAAATAGACGGCAAAGATATTAAATTAACCATTGATGCTAGAGTCCAAAAAAGTATTTATAACAACATGAAAGATGACTACGGTTCGGGGACTGCTATTCATCCACAAACTGGTGAACTCTTAGCACTTGTCAGCACGCCATCTTATGATGTTTATCCATTTATGAATGGAATGAGCGATGAAGATTATAAGAAATTAACTGAAGATGATAAAGAGCCACTCCTTAATAAGTTCCAAATTACGACATCACCAGGTTCGACTCAAAAAATATTAACAGCCATGATTGGCTTAAACAATAAGACATTAGACGGCAAAACAAGTTATAAAATTAATGGAAAAGGTTGGCAAAAAGATAAATCTTGGGGTGACTACAACGTTACAAGATACGAAGTTGTGAATGCCGATATCGACTTAAAACAAGCTATTGAATCATCAGATAATATCTTCTTTGCGAGAGTTGCACTTGAATTAGGCAGCAAAAAATTCGAAGAAGGAATGAAACGCCTTGGTGTTGGTGAAGATATCCCGAGTGATTATCCATTCTACAATGCACAAATTTCAAATAAGAACTTAGATAATGAAATATTGTTAGCTGACTCAGGTTATGGCCAAGGTGAAATATTAATCAATCCTGTTCAAATTCTTTCAATATACAGCGCATTAGAGAACAAAGGTAATGTGAATGCACCACATGTACTCAAAGATACGAAAAATAAAGTCTGGAAGAAGAACATCATTTCCCAGGAAAATATTAAATTGTTAACAGACGGTATGCAACAAGTCGTGAACAAAACACATAGAGAAGATATTTATAGATCATATGCCAACTTAGTTGGTAAATCAGGTACAGCTGAACTCAAGATGAAACAAGGTGAGACAGGACAACAAATAGGTTGGTTCATTTCATATGATAAAGATAATCCAAATATAATGATGGCTATTAATGTGAAAGATGTACAAGATAAAGGCATGGCAAGTTACAATGCCAAAATATCTGGAAAAGTGTATGACGATTTATATGATAACGGTAAGAAAACGTATCGTATTGATAAATAA"
scoremodel = AffineGapScoreModel(EDNAFULL, gap_open=-5, gap_extend=-1);

res = pairalign(GlobalAlignment(), mecA, mecA1, scoremodel)  
  # run pairwise alignment
```


#### Running Alignment on FASTX files
In this next example, we'll repeat the same alignment,   
but read in the files directly from the FASTA files containing the gene.    
Running the alignment on strings is straightforward with short sequences,   but when comparing entire genes, simply reading in the file is easier.  
```julia
using BioSequences
using FASTX

# Write a function to get sequence out of a fasta file with 1 record
function fasta_sequence(fasta_path)
    record = open(FASTA.Reader, fasta_path) do reader
        first(reader)
    end
    seq = LongDNA{4}(String(FASTX.sequence(record)))
    return (seq)
end

mecA_fasta = fasta_sequence("assets/mecA.fasta")
mecA1_fasta = fasta_sequence("assets/mecA1.fasta")

res_fasta = pairalign(GlobalAlignment(), mecA_fasta, mecA1_fasta, scoremodel)  # run pairwise alignment
```


### Understanding how Alignments are Represented
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


#### Interpreting the Example Output
```
# run pairwise alignment

       res
PairwiseAlignmentResult{Int64, String, String}:
  score: 6375
  seq:    1 ATGAAAAAGATAAAA-ATTGTTCCA-CTT-ATTTTAAT-A-----GTTGTAGTTGTCGGG   51
            |||||||| || ||  || |  ||| | | ||| |||| |     ||||  |||  | ||
  ref:    1 ATGAAAAA-ATTAATCATCG--CCATCGTGATTGTAATCATCGCTGTTG--GTT--CAGG   53

  seq:   52 TTTGGTATATAT-TTTTATGCTTCAAAAGATAAAGAAATTAAT--AATACTATTGATGCA  108
                ||||   | |||||||| || |||||||| |||| |||   || || |||||||| 
  ref:   54 C---GTAT---TCTTTTATGCATCTAAAGATAA-GAAAATAAACGAA-ACAATTGATGCC  105

  seq:  109 ATTGAAGATAAAAA--TTTCAAACAAGT-TTATAAAGATAGCAGTTAT--ATTTCTAAAA  163
            ||||||||||||||  ||  || ||||| || |||| |||| | |||   ||  ||||||
  ref:  106 ATTGAAGATAAAAACGTT--AAGCAAGTCTT-TAAAAATAGTACTTACCAAT--CTAAAA  160

  seq:  164 GCGATAATGGTGAAGTAGAAATGACTGAACGTCCGATAAAAATATATAATAGTTTAGGCG  223
             |||||||||||||||||||||||| || || || || || || ||| | ||| | ||||
  ref:  161 ACGATAATGGTGAAGTAGAAATGACAGACCGCCCTATTAAGATTTATGACAGTCTCGGCG  220

  seq:  224 TTAAAGATATAAACATTCAGGATCGTAAAATAAAAAAAGTATCTAAAAATAAAAAACGAG  283
            | |||||||| |||||| | |||||| | || ||||| || || ||||| ||||||| ||
  ref:  221 TCAAAGATATCAACATTAAAGATCGTGATATCAAAAAGGTTTCGAAAAACAAAAAACAAG  280

  seq:  284 T-AGATGCTCAA--TATAAAATTAAAACAAACTACGGTAACATTGATCGCAACGTTCAAT  340
            | | | ||  ||  ||| || || |||| || ||||| || ||| ||||  ||||| |||
  ref:  281 TCACA-GC--AAAGTATGAACTTCAAACGAATTACGGCAAAATTAATCGTGACGTTAAAT  337

  seq:  341 TTAATTTTGTTAAAGAAGAT---GGTATGTGGAAGTTAGATTGGGATCATA--GCGTCAT  395
            | || ||| |||||||||||   |  || ||||| || |||||| |||| |  ||  |||
  ref:  338 TAAACTTTATTAAAGAAGATAAAG--AT-TGGAAATTGGATTGGAATCAAAATGC--CAT  392

  seq:  396 TATTCCAGGAATGCAGAAAGACCAAAGCATACA-TATTGAA--AATTTAAAATCAGAACG  452
            ||||||||| ||| ||||| | |||  ||| || |||||||  |  || |||||||||||
  ref:  393 TATTCCAGGCATGAAGAAAAATCAATCCAT-CAATATTGAACCA--TTGAAATCAGAACG  449

  seq:  453 TGGTAAAATTTTAGACCGAAACAATGTGGAATTGGCCAATACAGGAACAGCATATGA-GA  511
             ||||| ||||||||| | |||||||| || || |||| |||||||||| || |||| | 
  ref:  450 AGGTAAGATTTTAGACAGGAACAATGTAGAGTTAGCCACTACAGGAACAACACATGAAGT  509

  seq:  512 TAGGCATCGTTCCAAAGAATGTATCTAAAAAAGATTATAAAGCAATCGCTAAAGAACTAA  571
            | || || ||||| || ||||| || | ||  ||||| ||||||||||||   |||  ||
  ref:  510 T-GGTATTGTTCCTAATAATGTTTCCACAAGTGATTACAAAGCAATCGCT---GAA--AA  563

  seq:  572 GT-A----TTTCTGAA--GACTATATCAAACAACAAATGGATCAAAATTGGGT-ACAAGA  623
            || |    |||| |||  |  ||||| ||||| ||||  || ||  ||||||| | ||||
  ref:  564 GTTAGACCTTTCAGAATCG--TATATTAAACAGCAAACAGAACAGGATTGGGTTA-AAGA  620

  seq:  624 TGATACCTTCGTTCCACTTAAAACCGTTAAAAAAATGGATGAATATTTAAGTGA-TTTCG  682
            |||||| ||||| || || || || ||| || | ||| || || ||||||  || ||| |
  ref:  621 TGATACATTCGTCCCTCTCAAGACTGTTCAAGATATGAATCAAGATTTAAA-GAATTTTG  679

  seq:  683 CAAAAAAATTTCATCTTACA--ACTAATGAAACAAAAAGTCGTAAC--TATCCTCTAGAA  738
               |||| | |||||| |||  ||  | |||||| |||||||  ||  ||||| || |||
  ref:  680 TTGAAAAGTATCATCTCACATCAC--AGGAAACAGAAAGTCG--ACAGTATCCGCTTGAA  735

  seq:  739 AAAGCGACTTCACATCT-A-TTAGGTTATGTTGGTCCC-ATTAACTCTGAAGAATTAAAA  795
             |||| ||  | || || | || || |||||||| ||| ||||| || |||||||| || 
  ref:  736 GAAGCAACAACGCA-CTTACTT-GGATATGTTGG-CCCTATTAATTCAGAAGAATTGAAG  792

  seq:  796 CAAAAAGAATATAAAGGCTATAAAGATGATGC-AGTTATTGGTAAAAAGGG-ACTCGAAA  853
            ||||||| || |||||| |||||| | ||||| | |  |||||||||| || | ||||||
  ref:  793 CAAAAAGCATTTAAAGGTTATAAAAAGGATGCCA-TCGTTGGTAAAAAAGGTA-TCGAAA  850

  seq:  854 AACTTTACGATAAAAAGCTCCAACATGAAGATGGCTATCGTGTCACAATCGTTGACGATA  913
            |||| ||||||||| | || ||| || |||| || || |||||||||||  |||| ||||
  ref:  851 AACTATACGATAAAGACCTTCAAAATAAAGACGGATACCGTGTCACAATAATTGATGATA  910

  seq:  914 ATAGCAATACA---ATCGCACATACATTAATAGAGAAAAAGAAAAAAGATGGCAAAGATA  970
            |||   ||| |   || |   |||||||||||||||||||||||| ||| ||||||||||
  ref:  911 ATA---ATAAAGTTATTG---ATACATTAATAGAGAAAAAGAAAATAGACGGCAAAGATA  964

  seq:  971 TTCAACTAACTATTGATGCTAAAGTTCAAAAGAGTATTTATAACAACATGAAAAATGATT 1030
            || || |||| |||||||||| ||| ||||| ||||||||||||||||||||| |||| |
  ref:  965 TTAAATTAACCATTGATGCTAGAGTCCAAAAAAGTATTTATAACAACATGAAAGATGACT 1024

  seq: 1031 ATGGCTCAGGTACTGCTATCCACCCTCAAACAGGTGAATTATTAGCACTTGTAAGCACAC 1090
            | || || || |||||||| || || ||||| |||||| | ||||||||||| ||||| |
  ref: 1025 ACGGTTCGGGGACTGCTATTCATCCACAAACTGGTGAACTCTTAGCACTTGTCAGCACGC 1084

  seq: 1091 CTTCATATGACGTCTATCCATTTATGTATGGCATGAGTAACGAAGAATATAATAAATTAA 1150
            | || ||||| || |||||||||||| |||| |||||  | ||||| ||||| |||||||
  ref: 1085 CATCTTATGATGTTTATCCATTTATGAATGGAATGAGCGATGAAGATTATAAGAAATTAA 1144

  seq: 1151 CCGAAGATAAAAAAGAACCTCTGCTCAACAAGTTCCAGATTACAACTTCACCAGGTTCAA 1210
            | |||||| | ||||| || || || || |||||||| ||||| || ||||||||||| |
  ref: 1145 CTGAAGATGATAAAGAGCCACTCCTTAATAAGTTCCAAATTACGACATCACCAGGTTCGA 1204

  seq: 1211 CTCAAAAAATATTAACAGCAATGATTGGGTTAAATAACAAAACATTAGACGATAAAACAA 1270
            ||||||||||||||||||| |||||||| ||||| || || ||||||||||  |||||||
  ref: 1205 CTCAAAAAATATTAACAGCCATGATTGGCTTAAACAATAAGACATTAGACGGCAAAACAA 1264

  seq: 1271 GTTATAAAATCGATGGTAAAGGTTGGCAAAAAGATAAATCTTGGGGTGGTTACAACGTTA 1330
            ||||||||||  |||| |||||||||||||||||||||||||||||||  ||||||||||
  ref: 1265 GTTATAAAATTAATGGAAAAGGTTGGCAAAAAGATAAATCTTGGGGTGACTACAACGTTA 1324

  seq: 1331 CAAGATATGAAGTGGTAAATG--GTAATATCGACTTAAAACAAGCAATAGAATCATCAGA 1388
            ||||||| ||||| || ||||  |  ||||||||||||||||||| || |||||||||||
  ref: 1325 CAAGATACGAAGTTGTGAATGCCG--ATATCGACTTAAAACAAGCTATTGAATCATCAGA 1382

  seq: 1389 TAACATTTTCTTTGCTAGAGTAGCACTCGAATTAGGCAGTAAGAAATTTGAAAAAGGCAT 1448
            ||| || |||||||| ||||| ||||| ||||||||||| || ||||| ||| |||| ||
  ref: 1383 TAATATCTTCTTTGCGAGAGTTGCACTTGAATTAGGCAGCAAAAAATTCGAAGAAGGAAT 1442

  seq: 1449 GAAAAAACTAGGTGTTGGTGAAGATATACCAAGTGATTATCCATTTTATAATGCTCAAAT 1508
            ||||   || ||||||||||||||||| || |||||||||||||| || ||||| |||||
  ref: 1443 GAAACGCCTTGGTGTTGGTGAAGATATCCCGAGTGATTATCCATTCTACAATGCACAAAT 1502

  seq: 1509 TTCAAACAAAAATTTAGATAATGAAATATTATTAGCTGATTCAGGTTACGGACAAGGTGA 1568
            |||||| || || ||||||||||||||||| |||||||| |||||||| || ||||||||
  ref: 1503 TTCAAATAAGAACTTAGATAATGAAATATTGTTAGCTGACTCAGGTTATGGCCAAGGTGA 1562

  seq: 1569 AATACTGATTAACCCAGTACAGATCCTTTCAATCTATAGCGCATTAGAAAATAATGGCAA 1628
            |||| | || || || || || || |||||||| || ||||||||||| || || || ||
  ref: 1563 AATATTAATCAATCCTGTTCAAATTCTTTCAATATACAGCGCATTAGAGAACAAAGGTAA 1622

  seq: 1629 TATTAACGCACCTCACT-TATTAAAAGACACGAAAAACAAAGTTTGGAAGAAAAATATTA 1687
            | | || ||||| || | || | ||||| |||||||| ||||| |||||||| || || |
  ref: 1623 TGTGAATGCACCACA-TGTACTCAAAGATACGAAAAATAAAGTCTGGAAGAAGAACATCA 1681

  seq: 1688 TTTCCAAAGAAAATATCAA-TCTATTAACTGATGGTATGCAACAAGTCGTAAATAAAACA 1746
            ||||| | |||||||| || | | ||||| || ||||||||||||||||| || ||||||
  ref: 1682 TTTCCCAGGAAAATATTAAAT-TGTTAACAGACGGTATGCAACAAGTCGTGAACAAAACA 1740

  seq: 1747 CATAAAGAAGATATTTATAGATCTTATGCAAACTTAATTGGCAAATCCGGTACTGCAGAA 1806
            |||| |||||||||||||||||| ||||| |||||| |||| ||||| ||||| || |||
  ref: 1741 CATAGAGAAGATATTTATAGATCATATGCCAACTTAGTTGGTAAATCAGGTACAGCTGAA 1800

  seq: 1807 CTCAAAATGAAACAAGGAGAAACTGG-CAGACAAATTGGGTGGTTTATATCATATGATAA 1865
            ||||| ||||||||||| || || || || |||||| || ||||| || |||||||||||
  ref: 1801 CTCAAGATGAAACAAGGTGAGACAGGACA-ACAAATAGGTTGGTTCATTTCATATGATAA 1859

  seq: 1866 AGATAATCCAAACATGATGATGGCTATTAATGTTAAAGATGTACAAGATAAAGGAATGGC 1925
            |||||||||||| || ||||||||||||||||| |||||||||||||||||||| |||||
  ref: 1860 AGATAATCCAAATATAATGATGGCTATTAATGTGAAAGATGTACAAGATAAAGGCATGGC 1919

  seq: 1926 TAGCTACAATGCCAAAATCTCAGGTAAAGTGTATGATGAGCTATATGAGAACGGTAATAA 1985
             || |||||||||||||| || || ||||||||||| ||  ||||||| |||||||| ||
  ref: 1920 AAGTTACAATGCCAAAATATCTGGAAAAGTGTATGACGATTTATATGATAACGGTAAGAA 1979

  seq: 1986 AAAATACGATATAGATGAATAACAAAACAGTGAAGCAATCCGTAACGATGGTTGCTTCAC 2045
            ||                                      |||| ||             
  ref: 1980 AA--------------------------------------CGTATCG------------- 1988

  seq: 2046 TGTTTTATTATGAATTATTAATAAGTGCTGTTACTTCTCCCTTAAATACAATTTCTTCAT 2105
                 ||||  ||  ||  |||||                                    
  ref: 1988 -----TATT--GA--TA--AATAA------------------------------------ 2001

  seq: 2106 TT 2107
              
  ref: 2001 -- 2001
```

The score returned is entirely dependent on the scoring scheme 
(how we penalized gaps, gap extensions and rewarded matches). 
It is not an absolute number that we can compare from alignment to alignment.  
In our example, our score was influenced by -5 for the start of a gap, and -1 for a gap extension.  
If these values were to change, we would get a different score.  
However, generally, longer alignments produce larger scores (as there are more bases being compared).  

Overall, the two sequences are homologous over most of their length.  
There are many matches, but there are frequent small indels and substitutions.  
The biggest mismatch is in a section toward the end,   
where there are large stretches that are missing in the reference sequence (mecA1).  

### Citations

[1]: Rolo J, Worning P, Boye Nielsen J, Sobral R, Bowden R, Bouchami O, Damborg P, Guardabassi L, Perreten V, Westh H, Tomasz A, de Lencastre H, Miragaia M. Evidence for the evolutionary steps leading to mecA-mediated β-lactam resistance in staphylococci. PLoS Genet. 2017 Apr 10;13(4):e1006674. doi: 10.1371/journal.pgen.1006674. PMID: 28394942; PMCID: PMC5402963. [link to the source](10.1371/journal.pgen.1006674=).

