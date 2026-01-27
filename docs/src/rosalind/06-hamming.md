# Counting Point Mutations

!!! warning "The Problem"

    Given two strings s and t of equal length, the Hamming distance between s and t, denoted dH(s,t), is the number of corresponding symbols that differ in s and t.

        Given: Two DNA strings s and t of equal length (not exceeding 1 kbp).

        Return: The Hamming distance dH(s,t).

    ***Sample Dataset***

    ```
    GAGCCTACTAACGGGAT
    CATCGTAATGACGGCCT
    ```

    ***Sample Output***

    ```
    7
    ```


To calculate the Hamming Distance between two strings/sequences, the two strings/DNA sequences must be the same length. We can calculate the Hamming Distance by looping over the characters in one of the strings and checking if the corresponding character at the same index in the other string matches. Each mismatch will cause 1 to be added to a `counter` variable. At the end of the loop, we can return the total value of the `counter` variable.

Let's give this a try!

```julia
SampleSeqA = "GAGCCTACTAACGGGAT"
SampleSeqB = "CATCGTAATGACGGCCT"

function calcHamming(SeqA, SeqB)
    SeqLength = length(SeqA)

    # check if the strings are empty
    if SeqLength == 0
        return 0
    end

    mismatches = 0
    for i in 1:SeqLength
        if SeqA[i] != SeqB[i]
            mismatches += 1
            end
    end
    return mismatches
end

calcHamming(SampleSeqA, SampleSeqB)
    
```



## BioAlignments method

Instead of writing your own function, an alternative would be to use the readily-available Hamming Distance [function](https://github.com/BioJulia/BioAlignments.jl/blob/0f3cc5e1ac8b34fdde23cb3dca7afb9eb480322f/src/pairwise/algorithms/hamming_distance.jl#L4) in the `BioAlignments.jl` package. 

```julia
using BioAlignments

seqA = "GAGCCTACTAACGGGAT"
seqB = "CATCGTAATGACGGCCT"

BioAlignmentsHamming = BioAlignments.hamming_distance(Int64, "GAGCCTACTAACGGGAT", "CATCGTAATGACGGCCT")

BioAlignmentsHamming[1]

```

```julia
# Double check that we got the same values from both ouputs 
@assert calcHamming(SampleSeqA, SampleSeqB) == BioAlignmentsHamming[1]
```


 The BioAlignments `hamming_distance` function requires three input variables -- the first of which allows the user to control the `type` of the returned hamming distance value. In the above example, `Int64` is provided as the input variable, but `Float64` or `Int8` are also acceptable inputs.

 The second two input variables are the two sequences that are being compared.

 There are two outputs of this function: the actual Hamming Distance value and the Alignment Anchor. The Alignment Anchor is a a one-dimensional array (vector) that is the same length as the length of the input strings. Each value in the vector is also an AlignmentAnchor with three fields: sequence position, reference position, and an operation code ('0' for start, '=' for match, 'X' for mismatch). 
 
 The Alignment Anchor for the above example is 
 ```
 AlignmentAnchor[AlignmentAnchor(0, 0, '0'), AlignmentAnchor(1, 1, 'X'), AlignmentAnchor(2, 2, '='), AlignmentAnchor(3, 3, 'X'), AlignmentAnchor(4, 4, '='), AlignmentAnchor(5, 5, 'X'), AlignmentAnchor(7, 7, '='), AlignmentAnchor(8, 8, 'X'), AlignmentAnchor(9, 9, '='), AlignmentAnchor(10, 10, 'X'), AlignmentAnchor(14, 14, '='), AlignmentAnchor(16, 16, 'X'), AlignmentAnchor(17, 17, '=')]

 ```


