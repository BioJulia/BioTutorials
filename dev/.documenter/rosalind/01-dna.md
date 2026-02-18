
# 🧬 Problem 1: Counting DNA nucleotides {#Problem-1:-Counting-DNA-nucleotides}

🤔 [Problem link](https://rosalind.info/problems/dna/)

::: tip Note

For each of these problems, you are strongly encouraged to read through the problem descriptions, especially if you&#39;re somewhat new to molecular biology. We will mostly not repeat the background concepts in these notebooks, except where they are relevant to the solutions.

:::

::: warning The Problem

A string is simply an ordered collection of symbols selected from some alphabet and formed into a word; the length of a string is the number of symbols that it contains.

An example of a length 21 DNA string (whose alphabet contains the symbols &#39;A&#39;, &#39;C&#39;, &#39;G&#39;, and &#39;T&#39;) is &quot;ATGCTTCAGAAAGGTCTTACG.&quot;

**Given**: A DNA string `s` of length at most 1000 nt.

**Return**: Four integers (separated by spaces) counting the respective number of times that the symbols &#39;A&#39;, &#39;C&#39;, &#39;G&#39;, and &#39;T&#39; occur in `s` .

**Sample Dataset**

```
AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC
```


**Sample Output**

```
20 12 17 21
```


:::

Let&#39;s see how it&#39;s done!

### DNA sequences are `String`s of `Char`s {#DNA-sequences-are-Strings-of-Chars}

In julia, single characters and strings, which are made up of multiple characters, have different types. `Char` and `String` respectively.

They are also written differently - single quotes for a `Char`, and double quotes for a `String&#39;.

```julia
chr = 'a'
str = "A"
typeof(chr)
```


```ansi
Char
```


```julia
typeof(str)
```


```ansi
String
```


In many ways, a `String` can be thought of as a vector of `Char`s, and many julia functions that operate on collections like `Vector`s will work on `String`s. We can also loop over the contents of a string, which will treat each `Char` separately.

```julia
for c in "banana"
	@info c
end
```


```ansi
[36m[1m[ [22m[39m[36m[1mInfo: [22m[39mb
[36m[1m[ [22m[39m[36m[1mInfo: [22m[39ma
[36m[1m[ [22m[39m[36m[1mInfo: [22m[39mn
[36m[1m[ [22m[39m[36m[1mInfo: [22m[39ma
[36m[1m[ [22m[39m[36m[1mInfo: [22m[39mn
[36m[1m[ [22m[39m[36m[1mInfo: [22m[39ma
```


### Approach 1: counting in loops {#Approach-1:-counting-in-loops}

One relatively straightforward way to approach this problem is to set a variable to `0` for each base, then loop through the sequence, adding `1` to the appropriate variable at each character.

I&#39;ll also stick this into a function, so we can easily reuse the code.

```julia
function countbases(seq) # here `seq` is an "argument" for the function
	a = 0
	c = 0
	g = 0
	t = 0
	for base in seq
		if base == 'A'
			a += 1 # this is equivalent to `a = a + 1`
		elseif base == 'C'
			c += 1
		elseif base == 'G'
			g += 1
		elseif base == 'T'
			t += 1
		else
			# it is often a good idea to try to handle possible mistakes explicitly
			error("Base $base is not supported")
		end
	end
	return (a, c, g, t)
end

countbases("AAA")
```


```ansi
(3, 0, 0, 0)
```


Now let&#39;s see if it works on the example dataset. Remember, we should be getting the answer `20 12 17 21`

```julia
answer = "20 12 17 21"
input_dna = "AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC"
countbases(input_dna)
```


```ansi
(20, 12, 17, 21)
```


Well, the formatting is just a bit different - The julia type is a `Tuple`, which is surrounded by parentheses. To fix this, we can use the `join` function.

```julia
@assert join(countbases(input_dna), " ") == answer
```


### Approach 2: using `count()` {#Approach-2:-using-count}

Another approach is to use the built-in `count()` function, which takes a &quot;predicate&quot; function as the first argument and an iterable collection as the second argument. The predicate function must take each element of the collection, and return either `true` or `false`. The `count()` function then returns the number of elements that returned `true`.

For example, if I define the `lessthan5()` function to return `true` if a value is less than 5, I can then use it as a predicate to count the number of values in a `Vector` of numbers that are less than 5.

```julia
function lessthan5(num)
	return num < 5
end

count(lessthan5, [1, 5, 6, -3, 3])
```


```ansi
3
```


Often, we don&#39;t want to have to define a simple function like `lessthan5()` for every predicate we want to test, especially if they will only be used once. Instead, we can use an &quot;anonymous&quot; function (also sometimes called &quot;lambdas&quot;) as the first argument.

In julia, anonymous functions have the syntax `arg -> func. body`. In other words, the same expression above could be written as:

```julia
count(num -> num < 5,  [1, 5, 6, -3, 3])
```


```ansi
3
```


Here, `num -> num < 5` is identical to the definition for `lessthan5(num)`.

So, now we can write a different formulation of `countbases()` using `count()`:

```julia
function countbases2(seq)
	a = count(base-> base == 'A', seq)
	c = count(base-> base == 'C', seq)
	g = count(base-> base == 'G', seq)
	t = count(base-> base == 'T', seq)
	return (a,c,g,t)
end
```


```ansi
countbases2 (generic function with 1 method)
```


```julia
@assert countbases2(input_dna) == countbases(input_dna)
```


::: tip Tip

Even though this approach is quite a bit more suscinct, it might end up being a bit slower than `countbases`, since it has to loop over the sequence 4 times instead of just once.

Sometimes, you need to make trade-offs between clarity and efficiency. One of the great things about `julia` is that a lot of ways of approaching the same problem are often possible, and often fast (or they can be made fast).

:::

### Approach 3: using BioSequences.jl {#Approach-3:-using-BioSequences.jl}

The `BioSequences.jl` package is designed to efficiently work with biological sequences like DNA sequences. `BioSequences.jl` efficiently encodes biological sequences using special types that are not `Char` or `String`s.

```julia
using BioSequences

seq = LongDNA{2}(input_dna)

sizeof(input_dna)
```


```ansi
70
```


```julia
sizeof(seq)
```


```ansi
16
```


Counting individual nucleotides isn&#39;t the most common operation, but `BioSequences.jl` has some [advanced searching](https://biojulia.github.io/BioSequences.jl/stable/sequence_search/) functionality built-in. It&#39;s a bit overkill for this task, but for completeness:

```julia
function countbases3(seq)
	a = count(==(DNA_A), seq)
	c = count(==(DNA_C), seq)
	g = count(==(DNA_G), seq)
	t = count(==(DNA_T), seq)
	return (a,c,g,t)
end

@assert countbases3(seq) == countbases2(input_dna)
```


### Benchmarking {#Benchmarking}

Julia programmers like speed, so let&#39;s benchmark our approaches!

```julia
using BenchmarkTools

testseq = randdnaseq(100_000) #this is defined in BioSequences
testseq_str = string(testseq)

@benchmark countbases($testseq_str)
```


```ansi
BenchmarkTools.Trial: 6627 samples with 1 evaluation per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m734.079 μs[22m[39m … [35m908.885 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 0.00%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m750.791 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m751.077 μs[22m[39m ± [32m  8.227 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.00% ± 0.00%

  [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▆[34m█[39m[32m▆[39m[39m▁[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m 
  [39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▂[39m▃[39m▅[39m▆[39m▆[39m▅[39m▃[39m▂[39m▁[39m▂[39m▄[39m█[39m█[34m█[39m[32m█[39m[39m█[39m▅[39m▃[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m [39m▂
  734 μs[90m           Histogram: frequency by time[39m          782 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m0 bytes[39m, allocs estimate[90m: [39m[33m0[39m.
```


```julia
@benchmark(countbases2($testseq_str))
```


```ansi
BenchmarkTools.Trial: 10000 samples with 1 evaluation per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m246.700 μs[22m[39m … [35m619.496 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 0.00%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m246.731 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m249.683 μs[22m[39m ± [32m 10.599 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.00% ± 0.00%

  [34m█[39m[39m▅[39m [39m [39m▂[39m [39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m▄[39m▅[39m▃[39m▂[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁
  [34m█[39m[39m█[39m▆[39m▅[39m█[39m█[39m▇[32m▄[39m[39m▅[39m▁[39m▃[39m▃[39m▅[39m▃[39m▁[39m▁[39m█[39m█[39m█[39m█[39m█[39m█[39m▇[39m▇[39m▆[39m▆[39m▆[39m▅[39m▅[39m▄[39m▅[39m▃[39m▅[39m▄[39m▄[39m▅[39m▅[39m▅[39m▄[39m▆[39m▅[39m▅[39m▅[39m▄[39m▄[39m▄[39m▄[39m▅[39m▆[39m▅[39m▅[39m▄[39m▅[39m▆[39m▅[39m▆[39m▅[39m▅[39m▄[39m▄[39m▄[39m [39m█
  247 μs[90m        [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m        273 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m0 bytes[39m, allocs estimate[90m: [39m[33m0[39m.
```


```julia
@benchmark countbases3($testseq)
```


```ansi
BenchmarkTools.Trial: 10000 samples with 4 evaluations per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m8.005 μs[22m[39m … [35m 13.242 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 0.00%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m8.033 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m8.102 μs[22m[39m ± [32m381.502 ns[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.00% ± 0.00%

  [39m█[34m▆[39m[39m [32m [39m[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▁[39m▁[39m [39m [39m▁
  [39m█[34m█[39m[39m▄[32m▁[39m[39m▄[39m▄[39m█[39m▅[39m▁[39m▃[39m▁[39m▁[39m▁[39m▃[39m▄[39m▆[39m▅[39m▅[39m▄[39m▅[39m▃[39m▄[39m▃[39m▃[39m▄[39m▃[39m▁[39m▅[39m▃[39m▃[39m▄[39m▁[39m▄[39m▃[39m▅[39m▄[39m▁[39m▄[39m▅[39m▃[39m▁[39m▃[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▃[39m▄[39m▇[39m█[39m█[39m█[39m [39m█
  8 μs[90m         [39m[90mHistogram: [39m[90m[1mlog([22m[39m[90mfrequency[39m[90m[1m)[22m[39m[90m by time[39m      9.98 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m0 bytes[39m, allocs estimate[90m: [39m[33m0[39m.
```


Interestingly, on my system, `countbases2()` is actually faster than `countbases()`, at least for this longer sequence. This may be because [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) lets the calls to `count()` work in parallel.

But, as you can see, `countbases3()` is even faster. Let me make one more function that mimics the behavior of the original `countbases()` but uses `BioSequences.jl` instead.

```julia
function countbases4(seq)
	a = 0
	c = 0
	g = 0
	t = 0
	for base in seq
		if base == DNA_A
			a += 1 # this is equivalent to `a = a + 1`
		elseif base == DNA_C
			c += 1
		elseif base == DNA_G
			g += 1
		elseif base == DNA_T
			t += 1
		else
			# it is often a good idea to try to handle possible mistakes explicitly
			error("Base $base is not supported")
		end
	end
	return (a, c, g, t)
end

@benchmark countbases4($testseq)
```


```ansi
BenchmarkTools.Trial: 6216 samples with 1 evaluation per sample.
 Range [90m([39m[36m[1mmin[22m[39m … [35mmax[39m[90m):  [39m[36m[1m771.318 μs[22m[39m … [35m896.542 μs[39m  [90m┊[39m GC [90m([39mmin … max[90m): [39m0.00% … 0.00%
 Time  [90m([39m[34m[1mmedian[22m[39m[90m):     [39m[34m[1m803.037 μs               [22m[39m[90m┊[39m GC [90m([39mmedian[90m):    [39m0.00%
 Time  [90m([39m[32m[1mmean[22m[39m ± [32mσ[39m[90m):   [39m[32m[1m802.957 μs[22m[39m ± [32m  6.252 μs[39m  [90m┊[39m GC [90m([39mmean ± σ[90m):  [39m0.00% ± 0.00%

  [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m▅[34m█[39m[39m▅[39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m [39m 
  [39m▂[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▁[39m▂[39m▂[39m▃[39m▄[39m▆[39m▅[39m▄[39m▃[39m▂[39m▂[39m▃[39m▆[39m█[34m█[39m[39m█[39m█[39m▅[39m▃[39m▃[39m▃[39m▃[39m▃[39m▃[39m▃[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m▂[39m [39m▃
  771 μs[90m           Histogram: frequency by time[39m          824 μs [0m[1m<[22m

 Memory estimate[90m: [39m[33m0 bytes[39m, allocs estimate[90m: [39m[33m0[39m.
```

