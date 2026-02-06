# Counting Point Mutations

🤔 [Problem link](https://rosalind.info/problems/hamm/)

!!! warning "The Problem"

    Given two strings s and t of equal length,   
    the Hamming distance between s and t, denoted dH(s,t),   
    is the number of corresponding symbols that differ in s and t.  


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


To calculate the Hamming Distance between two strings/sequences,   
the two strings/DNA sequences must be the same length.  

The simplest way to solve this problem is to compare the corresponding values in each string for each index and then sum the mismatches.   
This is the fastest and most idiomatic Julia solution, as it leverages vector math.

Let's give this a try!

```julia
ex_seq_a = "GAGCCTACTAACGGGAT"
ex_seq_b = "CATCGTAATGACGGCCT"

count(i-> ex_seq_a[i] != ex_seq_b[i], eachindex(ex_seq_a))
```

### For Loop

Another way we can approach this would be to use the for-loop.  
For loops are traditionally slower and clunkier (especially in Python).  
However, Julia can often optimize for-loops like this,  
which is one of the things that makes it so powerful.   
It has multiple processing units that can run the same task parallelly. 

We can calculate the Hamming Distance by looping over the characters in one of the strings   
and checking if the corresponding character at the same index in the other string matches. 
 
Each mismatch will cause 1 to be added to a `counter` variable.   
At the end of the loop, we can return the total value of the `counter` variable.  



```julia
ex_seq_a = "GAGCCTACTAACGGGAT"
ex_seq_b = "CATCGTAATGACGGCCT"

function hamming(seq_a, seq_b)
    # check if the strings are empty
    if isempty(seq_a)
        throw(ErrorException("empty sequences"))
    end

    # check if the strings are different lengths
    if length(seq_a) != length(seq_b)
        throw(ErrorException(" sequences have different lengths"))
    end

    mismatches = 0
    for i in 1:length(seq_a)
        if seq_a[i] != seq_b[i]
            mismatches += 1
            end
    end
    return mismatches
end

hamming(ex_seq_a, ex_seq_b)
    
```


## BioAlignments method

Instead of writing your own function, an alternative would be to use the readily-available Hamming Distance [function](https://github.com/BioJulia/BioAlignments.jl/blob/0f3cc5e1ac8b34fdde23cb3dca7afb9eb480322f/src/pairwise/algorithms/hamming_distance.jl#L4) in the `BioAlignments.jl` package. 

```julia
using BioAlignments

ex_seq_a = "GAGCCTACTAACGGGAT"
ex_seq_b = "CATCGTAATGACGGCCT"

bio_hamming = BioAlignments.hamming_distance(Int64, ex_seq_a, ex_seq_b)

bio_hamming[1]

```

```julia
# Double check that we got the same values from both ouputs 
@assert calcHamming(ex_seq_a, ex_seq_b) == bio_hamming[1]
```


 The BioAlignments `hamming_distance` function requires three input variables --   
 the first of which allows the user to control the `type` of the returned hamming distance value. 
 
 In the above example, `Int64` is provided as the first input variable,   
 but `Float64` or `Int8` are also acceptable inputs.   
 The second two input variables are the two sequences that are being compared.

 There are two outputs of this function:   
 the actual Hamming Distance value and the Alignment Anchor.  
 The Alignment Anchor is a one-dimensional array (vector) that is the same length as the length of the input strings. 
 
 Each value in the vector is also an AlignmentAnchor with three fields:   
 sequence position, reference position, and an operation code   
 ('0' for start, '=' for match, 'X' for mismatch). 
 
 The Alignment Anchor for the above example is:
 ```
 AlignmentAnchor[
    AlignmentAnchor(0, 0, '0'),  
    AlignmentAnchor(1, 1, 'X'),   
    AlignmentAnchor(2, 2, '='),   
    AlignmentAnchor(3, 3, 'X'),   
    AlignmentAnchor(4, 4, '='),   
    AlignmentAnchor(5, 5, 'X'),   
    AlignmentAnchor(7, 7, '='),   
    AlignmentAnchor(8, 8, 'X'),   
    AlignmentAnchor(9, 9, '='),   
    AlignmentAnchor(10, 10, 'X'),   
    AlignmentAnchor(14, 14, '='),   
    AlignmentAnchor(16, 16, 'X'),   
    AlignmentAnchor(17, 17, '=')]
 ```

 ### Distances.Jl method

 Another package that calculates the Hamming distance is the [Distances package](https://github.com/JuliaStats/Distances.jl).   
 We can call its `hamming` function on our two test sequences:



```julia
using Distances

ex_seq_a = "GAGCCTACTAACGGGAT"
ex_seq_b = "CATCGTAATGACGGCCT"

Distances.hamming(ex_seq_a, ex_seq_b)
```

## Benchmarking

Let's test to see which method is the most efficient!  
Did the for-loop slow us down?

```julia
using BenchmarkTools

testseq1 = string(randdnaseq(100_000)) # this is defined in BioSequences

testseq2 = string(randdnaseq(100_000))


@benchmark hamming($testseq1, $testseq2)

@benchmark BioAlignments.hamming_distance(Int64, $testseq1, $testseq2)

@benchmark Distances.hamming($testseq1, $testseq2)
```

The BioAlignments method takes up a much larger amount of memory,  
and nearly three times as long to run.    
However, it also generates an `AlignmentAnchor` data structure each time the function is called,   
so this is not a fair comparison.     
The `Distances` package is the winner here,which makes sense,    
as it uses a vectorized approach.



