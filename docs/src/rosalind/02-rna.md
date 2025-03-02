
## ✍️ Problem 2: Transcription

🤔 [Problem link](https://rosalind.info/problems/rna/)

!!! warning "The Problem"
    An RNA string is a string formed from the alphabet containing 'A', 'C', 'G', and 'U'.

    Given a DNA string $t$ corresponding to a coding strand,
    its transcribed RNA string $u$ is formed
    by replacing all occurrences of 'T' in $t$ with 'U' in $u$.

    _Given_: A DNA string $t$ having length at most 1000 nt.

    _Return_: The transcribed RNA string of $t$.

    **Sample Dataset**

    ```txt
    GATGGAACTTGACTACGTAAATT
    ```

    **Sample Output**

    ```txt
    GAUGGAACUUGACUACGUAAAUU
    ```

### Approach 1 - string `replace()`

```@example rna; output=false
input_dna = "GATGGAACTTGACTACGTAAATT"
answer = "GAUGGAACUUGACUACGUAAAUU"
```

This one is pretty straightforward, as described.
All we need to do is replace any `'T'`s with `'U'`s.
Happily, julia has a handy `replace()` function
that takes a string, and a `Pair` that is `pattern => replacement`.
In principle, the pattern can be a literal `String`,
or even a regular expression. But here, we can just use a `Char`.

I'll also write the function using julia's one-line function definition syntax:


```@example rna
input_dna == "GATGGAACTTGACTACGTAAATT"

simple_transcribe(seq) = replace(seq, 'T'=> 'U')

@assert simple_transcribe(input_dna) == answer
```

As always, there are lots of ways you *could* do this.
This function won't hanndle poorly formatted sequences,
for example. Or rather, it will handle them, even though it shouldn't:

### Approach 2 - BioSequences `convert()`

As you might expect, `BioSequences.jl` has a way to do this as well.
`BioSequences.jl` doesn't just use a `String` to represent sequences,
there are special types that can efficiently encode nucleic acid
or amino acid sequences.
In some cases, eg DNA or RNA with no ambiguous bases, using as few as 2 bits
per base.

```@example rna
using BioSequences

dna_seq = LongDNA{2}(input_dna)


simple_transcribe(seq::LongDNA{N}) where N = convert(LongRNA{N}, seq)

rna_seq = simple_transcribe(dna_seq)
```

```@example rna
@assert String(rna_seq) == answer
```

```@example rna
simple_transcribe("This Is QUITE silly")
```



A couple of things to note here. First,
I'm taking advantage of julia's multiple dispatch system.
Instead of writing a separate function name for dealing with
a `LongDNA` from `BioSequences.jl`, I wrote a new *method*
for the same function by adding `::LongDNA{N}` to the argument.

This tells julia to call this version of `simple_transcribe()`
whenever the argument is a `LongDNA`. Otherwise, it will fall back to the original
(julia always uses the method that is most specific for its arguments).

The last thing to note is the `{N} ... where N`. This is just a way
that we can use any DNA alphabet (2 bit or 4 bit), and get similar behavior.


### Benchmarks


```@example rna
using BenchmarkTools

testseq = randdnaseq(100_000) #this is defined in BioSequences
testseq_str = string(testseq)


@benchmark simple_transcribe($testseq)
```


```@example rna
@benchmark simple_transcribe(x) setup=(x=LongDNA{2}(testseq))
```

```@example rna
@benchmark simple_transcribe(x) setup=(x=LongDNA{4}(testseq))
```



### Conclusions

I'm actually a little surprised that the `replace()` method does so well,
but there you have it. The `BioJulia method is about 2x faster on a 2-bit sequence
(that is, if there's no ambiguity), but about the same speed on 4-bit sequences.

