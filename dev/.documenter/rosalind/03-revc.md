
## 😉 Problem 3 - Getting the complement {#Problem-3-Getting-the-complement}

I know, I know, [not the _compliment_](https://www.grammarly.com/blog/complement-compliment/), but if you have a better emoji idea, let me know.

::: warning The Problem

In DNA strings, symbols &#39;A&#39; and &#39;T&#39; are complements of each other, as are &#39;C&#39; and &#39;G&#39;.

The reverse complement of a DNA string $s$ is the string $sc$ formed by reversing the symbols of $s$, then taking the complement of each symbol (e.g., the reverse complement of &quot;GTCA&quot; is &quot;TGAC&quot;).

_Given_: A DNA string $s$ of length at most 1000 bp.

_Return_: The reverse complement $sc$ of $s$.

**Sample Dataset**

```txt
AAAACCCGGT
```


**Sample Output**

```txt
ACCGGGTTTT
```


:::

This one is a bit tougher - we need to change each base coming in, and then reverse the result. Actually, that second part is easy, becuase julia has a built-in `reverse()` function that works for `String`s.

```julia
reverse("complement")
```


```ansi
"tnemelpmoc"
```


### Approach 1: using a `Dict`ionary {#Approach-1:-using-a-Dictionary}

In my opinion, the easiest thing to do is to use a `Dict()`, a data structure that allows arbitrary keys to look up arbitrary entries.

For example:

```julia
my_dictionary = Dict("thing1"=> "hello", "thing2" => "world!")


my_dictionary["thing1"]
```


```ansi
"hello"
```


```julia
my_dictionary["thing2"]
```


```ansi
"world!"
```


So, we just make a dictionary with 4 entries, one for each base. Then, to apply this to every base in the sequence, we have a couple of options. One is to use the `String()` constructor and a &quot;comprehension&quot; -  basically a `for` loop in a single phrase:

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


```ansi
revc (generic function with 1 method)
```


Here, the &quot;comprehension&quot; `[comp_dict[base] for base in seq]` is equivalent to something like

```julia
comp = Char[]
for base in seq
	push!(comp, comp_dict[base])
end
```


So let&#39;s see if it works!

```julia
input_dna = "AAAACCCGGT"
answer = "ACCGGGTTTT"

@assert revc(input_dna) == answer
```


### Approach 2: using `replace()` again {#Approach-2:-using-replace-again}

It turns out, the `replace()` function we used for the transcription problem can be passed mulitple `Pair`s of patterns to replace!

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


### Approach 3: `BioSequences.jl` {#Approach-3:-BioSequences.jl}

This is a pretty common need in bioinformatics, so `BioSequences.jl` actually has a `reverse_complement()` function built-in.

```julia
using BioSequences

reverse_complement(LongDNA{2}(input_dna))
```


```ansi
10nt DNA Sequence:
ACCGGGTTTT
```


### Once more, benchmarks {#Once-more,-benchmarks}

```julia
using BenchmarkTools


testseq = randdnaseq(100_000) #this is defined in BioSequences
testseq_str = string(testseq)


@benchmark revc($testseq_str)
```


```ansi
BenchmarkTools.Trial: 5785 samples with 1 evaluation per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m765.140 μs[22m[39m … [35m  2.516 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 67.53%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m786.359 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m854.080 μs[22m[39m ± [32m147.633 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m2.17% ±  6.56%

  [39m▅[39m█[34m▅[39m[39m [39m [39m [39m [32m [39m[39m [39m▁[39m [39m [39m▄[39m▅[39m▄[39m▂[39m [39m [39m [39m▁[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁
  [39m█[39m█[34m█[39m[39m█[39m▇[39m▇[39m▅[32m▅[39m[39m▇[39m█[39m█[39m▇[39m█[39m█[39m█[39m█[39m▇[39m▆[39m▆[39m█[39m█[39m▅[39m▅[39m▄[39m▄[39m▄[39m▄[39m▅[39m▃[39m▂[39m▄[39m▅[39m▇[39m▆[39m▅[39m▄[39m▅[39m▅[39m▅[39m▅[39m▄[39m▅[39m▃[39m▅[39m▄[39m▄[39m▃[39m▄[39m▄[39m▄[39m▄[39m▅[39m▃[39m▅[39m▂[39m▂[39m▅[39m▅[39m▅[39m▄[39m▅[39m [39m█
  765 μs[90m        [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m       1.51 ms [0m[1m<[22m

 Memory estimate[90m: [39m[33m586.51 KiB[39m, allocs estimate[90m: [39m[33m9[39m.
```


```julia
@benchmark revc2($testseq_str)
```


```ansi
BenchmarkTools.Trial: 1549 samples with 1 evaluation per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m3.158 ms[22m[39m … [35m 4.807 ms[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 33.25%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m3.204 ms              [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m3.224 ms[22m[39m ± [32m87.295 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.09% ±  1.31%

  [39m [39m [39m▂[39m▆[39m▄[39m▄[39m [39m [39m [39m█[34m▇[39m[39m▃[39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m 
  [39m▂[39m▃[39m█[39m█[39m█[39m█[39m█[39m▆[39m█[39m█[34m█[39m[39m█[39m▆[39m▄[32m▄[39m[39m▃[39m▃[39m▃[39m▃[39m▃[39m▃[39m▇[39m▇[39m▆[39m▄[39m▃[39m▄[39m█[39m▆[39m▅[39m▃[39m▃[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▁[39m▂[39m▂[39m▂[39m▂[39m▁[39m▁[39m▁[39m▁[39m▂[39m▁[39m▂[39m▂[39m [39m▃
  3.16 ms[90m        Histogram: frequency by time[39m        3.42 ms [0m[1m<[22m

 Memory estimate[90m: [39m[33m215.19 KiB[39m, allocs estimate[90m: [39m[33m5[39m.
```


```julia
@benchmark reverse_complement($testseq)
```


```ansi
BenchmarkTools.Trial: 10000 samples with 10 evaluations per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m1.966 μs[22m[39m … [35m199.327 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m 0.00% … 97.67%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m2.606 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m 0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m4.206 μs[22m[39m ± [32m  7.455 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m15.95% ± 10.19%

  [39m█[34m▇[39m[39m▃[32m▁[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▃[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁
  [39m█[34m█[39m[39m█[32m█[39m[39m▇[39m▅[39m▄[39m▅[39m▄[39m▃[39m▄[39m▁[39m▅[39m▃[39m▁[39m▅[39m▃[39m▄[39m▄[39m▄[39m▅[39m▄[39m▅[39m▁[39m▃[39m█[39m█[39m█[39m█[39m▆[39m▄[39m▄[39m▃[39m▁[39m▁[39m▃[39m▁[39m▁[39m▁[39m▃[39m▃[39m▁[39m▁[39m▁[39m▅[39m▄[39m▃[39m▅[39m▄[39m▅[39m▆[39m▅[39m▅[39m▅[39m▅[39m▅[39m▅[39m▄[39m▅[39m [39m█
  1.97 μs[90m      [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m      43.9 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m48.98 KiB[39m, allocs estimate[90m: [39m[33m4[39m.
```


```julia
@benchmark reverse_complement(testseq_4bit) setup=(testseq_4bit = convert(LongDNA{4}, testseq))
```


```ansi
BenchmarkTools.Trial: 10000 samples with 10 evaluations per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m1.785 μs[22m[39m … [35m203.404 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m 0.00% … 97.69%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m2.074 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m 0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m3.438 μs[22m[39m ± [32m  6.609 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m17.15% ± 10.43%

  [34m█[39m[39m▆[39m▃[32m▁[39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁
  [34m█[39m[39m█[39m█[32m█[39m[39m█[39m▇[39m▅[39m▃[39m▄[39m▄[39m▅[39m▅[39m▅[39m▅[39m▃[39m▁[39m▁[39m▃[39m▄[39m▄[39m▃[39m▁[39m▅[39m▅[39m▃[39m▁[39m▅[39m▃[39m▁[39m▅[39m█[39m█[39m█[39m▇[39m▅[39m▅[39m▅[39m▅[39m▁[39m▃[39m▁[39m▃[39m▁[39m▁[39m▅[39m▅[39m▅[39m▅[39m▄[39m▅[39m▅[39m▅[39m▅[39m▅[39m▄[39m▁[39m▅[39m▄[39m▆[39m [39m█
  1.79 μs[90m      [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m        37 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m48.98 KiB[39m, allocs estimate[90m: [39m[33m4[39m.
```


### Conclusions {#Conclusions}

This one is a no-brainer! The `reverse_complement()` function is about 200x faster than the dictionary method, and about 1000x faster than `replace()` for both 2 bit and 4 bit DNA sequences.

## ⌛ Overall Conclusions {#Overall-Conclusions}

A lot of bioinformatics is essentially string manipulation. Julia has a lot of useful functionality to work with `String`s directly, but those methods often leave a lot of performance on the table.

`BioSequences.jl` provides some nice sequence types and incredibly efficient data structures. We&#39;ll be seeing more of them in coming tutorials.
