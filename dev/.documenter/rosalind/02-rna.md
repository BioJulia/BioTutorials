
## ✍️ Problem 2: Transcription {#Problem-2:-Transcription}

🤔 [Problem link](https://rosalind.info/problems/rna/)

::: warning The Problem

An RNA string is a string formed from the alphabet containing &#39;A&#39;, &#39;C&#39;, &#39;G&#39;, and &#39;U&#39;.

Given a DNA string $t$ corresponding to a coding strand, its transcribed RNA string $u$ is formed by replacing all occurrences of &#39;T&#39; in $t$ with &#39;U&#39; in $u$.

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


:::

### Approach 1 - string `replace()` {#Approach-1-string-replace}

```julia
input_dna = "GATGGAACTTGACTACGTAAATT"
answer = "GAUGGAACUUGACUACGUAAAUU"
```


```ansi
"GAUGGAACUUGACUACGUAAAUU"
```


This one is pretty straightforward, as described. All we need to do is replace any `'T'`s with `'U'`s. Happily, julia has a handy `replace()` function that takes a string, and a `Pair` that is `pattern => replacement`. In principle, the pattern can be a literal `String`, or even a regular expression. But here, we can just use a `Char`.

I&#39;ll also write the function using julia&#39;s one-line function definition syntax:

```julia
input_dna == "GATGGAACTTGACTACGTAAATT"

simple_transcribe(seq) = replace(seq, 'T'=> 'U')

@assert simple_transcribe(input_dna) == answer
```


As always, there are lots of ways you _could_ do this. This function won&#39;t hanndle poorly formatted sequences, for example. Or rather, it will handle them, even though it shouldn&#39;t:

### Approach 2 - BioSequences `LongRNA` {#Approach-2-BioSequences-LongRNA}

As you might expect, `BioSequences.jl` has a way to do this as well. `BioSequences.jl` doesn&#39;t just use a `String` to represent sequences, there are special types that can efficiently encode nucleic acid or amino acid sequences. In some cases, eg DNA or RNA with no ambiguous bases, using as few as 2 bits per base.

```julia
using BioSequences

dna_seq = LongDNA{2}(input_dna)


simple_transcribe(seq::LongDNA{N}) where N = LongRNA{N}(seq)

rna_seq = simple_transcribe(dna_seq)
```


```ansi
23nt RNA Sequence:
GAUGGAACUUGACUACGUAAAUU
```


```julia
@assert String(rna_seq) == answer
```


```julia
simple_transcribe("This Is QUITE silly")
```


```ansi
"Uhis Is QUIUE silly"
```


A couple of things to note here. First, I&#39;m taking advantage of julia&#39;s multiple dispatch system. Instead of writing a separate function name for dealing with a `LongDNA` from `BioSequences.jl`, I wrote a new _method_ for the same function by adding `::LongDNA{N}` to the argument.

This tells julia to call this version of `simple_transcribe()` whenever the argument is a `LongDNA`. Otherwise, it will fall back to the original (julia always uses the method that is most specific for its arguments).

The last thing to note is the `{N} ... where N`. This is just a way that we can use any DNA alphabet (2 bit or 4 bit), and get similar behavior.

### Benchmarks {#Benchmarks}

```julia
using BenchmarkTools

testseq = randdnaseq(100_000) #this is defined in BioSequences
testseq_str = string(testseq)


@benchmark simple_transcribe($testseq)
```


```ansi
BenchmarkTools.Trial: 10000 samples with 10 evaluations per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m2.285 μs[22m[39m … [35m178.439 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m 0.00% … 96.07%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m3.594 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m 0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m6.128 μs[22m[39m ± [32m  9.825 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m14.40% ± 10.43%

  [39m▆[34m█[39m[39m▅[39m▃[32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▃[39m▂[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁
  [39m█[34m█[39m[39m█[39m█[32m█[39m[39m▇[39m▅[39m▅[39m▄[39m▃[39m▅[39m▄[39m▃[39m▅[39m▄[39m▄[39m▄[39m▅[39m▅[39m▅[39m▄[39m▅[39m▆[39m▆[39m█[39m█[39m█[39m▇[39m▄[39m▅[39m▃[39m▃[39m▄[39m▅[39m▄[39m▄[39m▄[39m▄[39m▄[39m▄[39m▁[39m▃[39m▄[39m▄[39m▅[39m▄[39m▄[39m▄[39m▄[39m▄[39m▄[39m▄[39m▅[39m▄[39m▅[39m▅[39m▄[39m▅[39m▅[39m [39m█
  2.29 μs[90m      [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m      56.6 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m48.98 KiB[39m, allocs estimate[90m: [39m[33m4[39m.
```


```julia
@benchmark simple_transcribe(x) setup=(x=LongDNA{2}(testseq))
```


```ansi
BenchmarkTools.Trial: 10000 samples with 10 evaluations per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m1.002 μs[22m[39m … [35m233.592 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m 0.00% … 97.51%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m1.782 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m 0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m2.500 μs[22m[39m ± [32m  5.366 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m15.87% ±  8.53%

  [39m▃[39m▇[34m█[39m[39m▆[39m▃[32m▂[39m[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▂[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▂
  [39m█[39m█[34m█[39m[39m█[39m█[32m█[39m[39m█[39m█[39m▇[39m▅[39m▄[39m▄[39m▁[39m▁[39m▁[39m▃[39m▃[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▃[39m▃[39m█[39m█[39m▇[39m▄[39m▇[39m▅[39m▁[39m▃[39m▁[39m▃[39m▃[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▃[39m▁[39m▁[39m▁[39m▁[39m▃[39m [39m█
  1 μs[90m         [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m      19.9 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m24.54 KiB[39m, allocs estimate[90m: [39m[33m4[39m.
```


```julia
@benchmark simple_transcribe(x) setup=(x=LongDNA{4}(testseq))
```


```ansi
BenchmarkTools.Trial: 10000 samples with 9 evaluations per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m1.768 μs[22m[39m … [35m205.885 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m 0.00% … 96.33%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m3.593 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m 0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m5.356 μs[22m[39m ± [32m  9.099 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m14.86% ± 10.05%

  [39m▆[39m▇[34m█[39m[39m▅[32m▃[39m[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▂[39m▂[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▂
  [39m█[39m█[34m█[39m[39m█[32m█[39m[39m█[39m▇[39m▇[39m▅[39m▆[39m▅[39m▄[39m▁[39m▅[39m▄[39m▅[39m▃[39m▁[39m▁[39m▄[39m▃[39m▃[39m▃[39m▄[39m▃[39m▄[39m█[39m█[39m█[39m█[39m▇[39m▅[39m▄[39m▄[39m▃[39m▁[39m▃[39m▄[39m▄[39m▅[39m▅[39m▆[39m▄[39m▅[39m▄[39m▅[39m▃[39m▄[39m▃[39m▄[39m▃[39m▁[39m▄[39m▁[39m▄[39m▁[39m▃[39m▅[39m▃[39m [39m█
  1.77 μs[90m      [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m      52.4 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m48.98 KiB[39m, allocs estimate[90m: [39m[33m4[39m.
```


### Conclusions {#Conclusions}

I&#39;m actually a little surprised that the `replace()` method does so well, but there you have it. The `BioJulia method is about 2x faster on a 2-bit sequence (that is, if there&#39;s no ambiguity), but about the same speed on 4-bit sequences.
