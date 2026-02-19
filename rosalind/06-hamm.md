+++
using Dates
date = Date("2026-01-01")
title = "Problem 6: Counting Point Mutations"
rss_descr = "Solving Rosalind problem HAMM — computing the Hamming distance between two DNA strings — using base Julia, BioAlignments.jl, and Distances.jl."
+++

# 🔬 Problem 6: Counting Point Mutations

🤔 [Problem link](https://rosalind.info/problems/hamm/)

> **The Problem**
>
> Given two strings s and t of equal length,
> the Hamming distance between s and t, denoted dH(s,t),
> is the number of corresponding symbols that differ in s and t.
>
> _Given_: Two DNA strings s and t of equal length (not exceeding 1 kbp).
>
> _Return_: The Hamming distance dH(s,t).
>
> **Sample Dataset**
>
> ```
> GAGCCTACTAACGGGAT
> CATCGTAATGACGGCCT
> ```
>
> **Sample Output**
>
> ```
> 7
> ```

To calculate the Hamming Distance between two strings/sequences,
the two strings/DNA sequences must be the same length.

The simplest way to solve this problem is to compare the corresponding values in each string for each index and then sum the mismatches.
This is the fastest and most idiomatic Julia solution, as it leverages vector math.

```julia
ex_seq_a = "GAGCCTACTAACGGGAT"
ex_seq_b = "CATCGTAATGACGGCCT"

count(i-> ex_seq_a[i] != ex_seq_b[i], eachindex(ex_seq_a))  # 7
```

### For Loop

Another way we can approach this would be to use a for-loop.
For loops are traditionally slower and clunkier (especially in Python).
However, Julia can often optimize for-loops like this,
which is one of the things that makes it so powerful.

```julia
function hamming(seq_a, seq_b)
    if isempty(seq_a)
        throw(ErrorException("empty sequences"))
    end
    if length(seq_a) != length(seq_b)
        throw(ErrorException("sequences have different lengths"))
    end

    mismatches = 0
    for i in 1:length(seq_a)
        if seq_a[i] != seq_b[i]
            mismatches += 1
        end
    end
    return mismatches
end

hamming(ex_seq_a, ex_seq_b)  # 7
```

## BioAlignments method

Instead of writing your own function, an alternative would be to use the readily-available Hamming Distance [function](https://github.com/BioJulia/BioAlignments.jl/blob/0f3cc5e1ac8b34fdde23cb3dca7afb9eb480322f/src/pairwise/algorithms/hamming_distance.jl#L4) in the `BioAlignments.jl` package.

```julia
using BioAlignments

bio_hamming = BioAlignments.hamming_distance(Int64, ex_seq_a, ex_seq_b)
bio_hamming[1]  # 7

@assert hamming(ex_seq_a, ex_seq_b) == bio_hamming[1]
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

### Distances.jl method

Another package that calculates the Hamming distance is the [Distances package](https://github.com/JuliaStats/Distances.jl).
We can call its `hamming` function on our two test sequences:

```julia
using Distances

Distances.hamming(ex_seq_a, ex_seq_b)  # 7
```

## Benchmarking

Let's test to see which method is the most efficient!

```julia
using BenchmarkTools
using BioSequences

testseq1 = string(randdnaseq(100_000))
testseq2 = string(randdnaseq(100_000))

@benchmark hamming($testseq1, $testseq2)
@benchmark BioAlignments.hamming_distance(Int64, $testseq1, $testseq2)
@benchmark Distances.hamming($testseq1, $testseq2)
```

The BioAlignments method takes up a much larger amount of memory,
and nearly three times as long to run.
However, it also generates an `AlignmentAnchor` data structure each time the function is called,
so this is not a fair comparison.
The `Distances` package is the winner here, which makes sense,
as it uses a vectorized approach.
