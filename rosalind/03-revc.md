+++
using Dates
date = Date("2026-01-04")
title = "Problem 3: Reverse Complement"
rss_descr = "Solving Rosalind problem REVC — computing the reverse complement of a DNA string — using base Julia and BioSequences.jl."
+++

# 😉 Problem 3: Reverse Complement

I know, I know, [not the *compliment*](https://www.grammarly.com/blog/complement-compliment/), but if you have a better emoji idea, let me know.

🤔 [Problem link](https://rosalind.info/problems/revc/)

> **The Problem**
>
> In DNA strings, symbols 'A' and 'T' are complements of each other, as are 'C' and 'G'.
>
> The reverse complement of a DNA string $s$ is the string $sc$ formed by reversing the symbols of $s$,
> then taking the complement of each symbol (e.g., the reverse complement of "GTCA" is "TGAC").
>
> _Given_: A DNA string $s$ of length at most 1000 bp.
>
> _Return_: The reverse complement $sc$ of $s$.
>
> **Sample Dataset**
>
> ```
> AAAACCCGGT
> ```
>
> **Sample Output**
>
> ```
> ACCGGGTTTT
> ```

This one is a bit tougher - we need to change each base coming in,
and then reverse the result. Actually, that second part is easy,
because julia has a built-in `reverse()` function that works for `String`s.

```julia
reverse("complement")  # "tnemelpmoc"
```

### Approach 1: using a `Dict`ionary

In my opinion, the easiest thing to do is to use a `Dict()`,
a data structure that allows arbitrary keys to look up arbitrary entries.

For example:

```julia
my_dictionary = Dict("thing1"=> "hello", "thing2" => "world!")

my_dictionary["thing1"]  # "hello"
my_dictionary["thing2"]  # "world!"
```

So, we just make a dictionary with 4 entries, one for each base.
Then, to apply this to every base in the sequence, we have a couple of options.
One is to use the `String()` constructor and a "comprehension" -
basically a `for` loop in a single phrase:

```julia
function revc(seq)
    comp_dict = Dict(
        'A'=>'T',
        'C'=>'G',
        'G'=>'C',
        'T'=>'A'
    )
    comp = String([comp_dict[base] for base in seq])
    return reverse(comp)
end
```

Here, the "comprehension" `[comp_dict[base] for base in seq]` is equivalent to something like

```julia
comp = Char[]
for base in seq
    push!(comp, comp_dict[base])
end
```

So let's see if it works!

```julia
input_dna = "AAAACCCGGT"
answer = "ACCGGGTTTT"

@assert revc(input_dna) == answer
```


### Approach 2: using `replace()` again

It turns out, the `replace()` function we used for the transcription problem
can be passed multiple `Pair`s of patterns to replace!

So we can just pass the pairs directly:

```julia
function revc2(seq)
    comp = replace(seq,
        'A'=>'T',
        'C'=>'G',
        'G'=>'C',
        'T'=>'A'
    )
    return reverse(comp)
end

@assert revc(input_dna) == revc2(input_dna)
```


### Approach 3: `BioSequences.jl`

This is a pretty common need in bioinformatics, so `BioSequences.jl` actually has a `reverse_complement()` function built-in.

```julia
using BioSequences

reverse_complement(LongDNA{2}(input_dna))  # ACCGGGTTTT
```


### Benchmarks

```julia
using BenchmarkTools

testseq = randdnaseq(100_000) #this is defined in BioSequences
testseq_str = string(testseq)

@benchmark revc($testseq_str)
@benchmark revc2($testseq_str)
@benchmark reverse_complement($testseq)
@benchmark reverse_complement(testseq_4bit) setup=(testseq_4bit = convert(LongDNA{4}, testseq))
```

### Conclusions

This one is a no-brainer! The `reverse_complement()` function is about 200x faster than the dictionary method, and about 1000x faster than `replace()` for both 2 bit and 4 bit DNA sequences.


## ⌛ Overall Conclusions

A lot of bioinformatics is essentially string manipulation.
Julia has a lot of useful functionality to work with `String`s
directly, but those methods often leave a lot of performance on the table.

`BioSequences.jl` provides some nice sequence types and incredibly efficient
data structures. We'll be seeing more of them in coming tutorials.
