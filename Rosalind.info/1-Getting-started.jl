### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 072db8c0-d3c1-11ed-18fa-bff69835f8cd
using PlutoUI

# ╔═╡ 4f2e0acf-5ac8-400a-82da-c66c7b07c467
using BioSequences

# ╔═╡ 41defb0d-7c92-46af-a4e2-35edac47a690
using BenchmarkTools

# ╔═╡ 76df740a-a130-41f3-8c3e-1f24729cc41b
md"""
# Getting Started with Rosalind.info Problems

If you're just learning bioinformatics,
or diving into a new programming language with an interest in biology,
[Rosalind.info](https://rosalind.info/) is a fantastic resource!
It has a series of problems that get progressively harder,
and introduce different concepts.

These tutorial notebooks will take you through how to solve many of the problems,
both using functionality from the Base julia language,
as well as using functionality from the BioJulia family of packages.

Once you've signed up for an account at rosalind.info, come on back here,
and we'll get started!
"""

# ╔═╡ 82d06ce9-e588-4312-87c1-d1c97263958a
md"""
##  🧬 Problem 1: Counting DNA nucleotides

🤔 [Problem link](https://rosalind.info/problems/dna/)

!!! note
	For each of these problems, you are strongly encouraged
	to read through the problem descriptions,
	especially if you're somewhat new to molecular biology.
	We will mostly not repeat the background concepts in these notebooks,
	except where they are relevant to the solutions.

"""

# ╔═╡ 943cd6d5-6339-4851-b663-c9c0ef77e7eb
PlutoUI.TableOfContents()

# ╔═╡ fb80d512-6cbe-4b02-919e-6c557729bb42
md"""
This section contains the code for counting each letter ('A', 'C', 'G', or 'T'),
and showing the counts, in that order.

You can enter a DNA sequence (as long as it only contains those 4 letters)
here, and the counts will be displayed below.
Note, the current values represent the demo input provided in the problem:

$(@bind input_dna TextField((50,3); default = "AGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC"))
"""

# ╔═╡ f810b26d-a7cb-44d4-af35-c82fc3791ff6
md"""
Let's see how it's done!
"""

# ╔═╡ fe8daef1-b3e9-4cca-94bb-8a1dec71f0f7
md"""
### DNA sequences are `String`s of `Char`s

In julia, single characters and strings,
which are made up of multiple characters, have different types.
`Char` and `String` respectively.

They are also written differently - single quotes for a `Char`,
and double quotes for a `String'.
"""

# ╔═╡ 05b5fb9f-d2d3-4917-8ac4-1b14d746fe9c
chr = 'a'

# ╔═╡ 4173f591-4232-4918-ae09-a3de449d42fe
str = "A"

# ╔═╡ 024cd6e2-23e4-4490-b482-641f490db2cc
typeof(chr)

# ╔═╡ 75f92ac2-a747-470e-aec1-8f0c906248a7
typeof(str)

# ╔═╡ 62004c70-e76a-4da2-92a1-d7c4b8b22aa7
md"""
In many ways, a `String` can be thought of as a vector of `Char`s,
and many julia functions that operate on collections like `Vector`s
will work on `String`s.
We can also loop over the contents of a string,
which will treat each `Char` separately.
"""

# ╔═╡ 7ae2154e-c161-4d45-a476-d3fa79757f2d
for c in "banana"
	@info c
end

# ╔═╡ 755014bc-470f-469f-a508-df3f372f228b
md"""
### Approach 1: counting in loops

One relatively straightforward way to approach this problem
is to set a variable to `0` for each base,
then loop through the sequence, adding `1` to the appropriate
variable at each character.

I'll also stick this into a function,
so we can easily reuse the code.
"""

# ╔═╡ c39e25c7-0071-4be0-8fe1-38eb5e2e4263
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
	

# ╔═╡ f0a203b4-7262-4fba-92b1-8bc535f1222a
md"""
✅ The answer is: **$(join(countbases(input_dna), ' '))**!
"""

# ╔═╡ 8ab5eb1c-a991-4c1e-a3b9-f412ec2579a4
countbases("AAA")

# ╔═╡ 6db22a7e-3f50-4ad0-adc0-ee3a4f53dc91
countbases(input_dna) # `input_dna` stores what was entered into the box above

# ╔═╡ 2368c64a-3ce7-4194-8182-56b5fdefcc96
md"""
### Approach 2: using `count()`

Another approach is to use the built-in `count()` function,
which takes a "predicate" function as the first argument
and an iterable collection as the second argument.
The predicate function must take each element of the collection,
and return either `true` or `false`.
The `count()` function then returns the number of elements
that returned `true`.

For example, if I define the `lessthan5()` function
to return `true` if a value is less than 5,
I can then use it as a predicate to count the number of values
in a `Vector` of numbers that are less than 5.
"""

# ╔═╡ 8146ba26-b7a2-4776-85ee-a16f4d28177b
function lessthan5(num)
	return num < 5
end

# ╔═╡ de67bd68-2a68-4739-b815-c203079f3826
count(lessthan5, [1, 5, 6, -3, 3])

# ╔═╡ 538f6a28-90c0-4f3e-ae94-9ef143cb54d0
md"""
Often, we don't want to have to define a simple function like `lessthan5()`
for every predicate we want to test, esepcially if they will only be used once.
Instead, we can use an "anonymous" function (also sometimes called "lambdas")
as the first argument.

In julia, anonymous functions have the syntax `arg -> func. body`.
In other words, the same expression above could be written as:
"""

# ╔═╡ 1ac75946-02b9-43e5-a878-b8c961ed08a4
count(num -> num < 5,  [1, 5, 6, -3, 3])

# ╔═╡ 7a21f39d-add6-4f8e-9407-ca8baa7b08a5
md"""
Here, `num -> num < 5` is identical to the definition for `lessthan5(num)`.

So, now we can write a different formulation of `countbases()` using `count()`:
"""

# ╔═╡ 7824b8ef-f5f5-49fa-9751-f1cf762283fe
function countbases2(seq)
	a = count(base-> base == 'A', seq)
	c = count(base-> base == 'C', seq)
	g = count(base-> base == 'G', seq)
	t = count(base-> base == 'T', seq)
	return (a,c,g,t)
end
	

# ╔═╡ ae34b79a-f04f-4a29-839a-06c96972f8ec
countbases2(input_dna) == countbases(input_dna)

# ╔═╡ b2d6550e-33f5-4031-b018-f5618bc9b763
md"""
!!! tip
	Even though this approach is quite a bit more suscinct,
	it might end up being a bit slower than `countbases`, since
	it has to loop over the sequence 4 times instead of just once.

	Sometimes, you need to make trade-offs between clarity and efficiency.
	One of the great things about `julia` is that a lot of ways of approaching
	the same problem are often possible, and often fast (or they can be made fast).
"""

# ╔═╡ 45b6ad47-0618-4433-9b9f-7809de3cbe32
md"""
### Approach 3: using BioSequences.jl

The `BioSequences.jl` package is designed to efficiently work
with biological sequences like DNA sequences.
`BioSequences.jl` efficiently encodes biological sequences using
special types that are not `Char` or `String`s.
"""

# ╔═╡ c30d7552-6a79-4f94-97c8-c890c780ce3d
seq = LongDNA{2}(input_dna)

# ╔═╡ dbaf67d6-ba52-4e06-92f0-ea96fff08658
sizeof(input_dna)

# ╔═╡ 02ebb987-bb0b-4070-89ff-b39bc74338a1
sizeof(seq)

# ╔═╡ a8385030-4de5-4fd8-89ba-737f5d720a43
md"""
Counting individual nucleotides isn't the most common operation,
but `BioSequences.jl` has some [advanced searching](https://biojulia.github.io/BioSequences.jl/stable/sequence_search/) functionality
built-in. It's a bit overkill for this task, but for completeness:
"""

# ╔═╡ 6892dd16-194f-4832-bcd8-2fbb26b081c2
function countbases3(seq)
	a = count(==(DNA_A), seq)
	c = count(==(DNA_C), seq)
	g = count(==(DNA_G), seq)
	t = count(==(DNA_T), seq)
	return (a,c,g,t)
end

# ╔═╡ dff4bf6c-137e-44da-b201-fff7fb0b777d
countbases3(seq) == countbases2(input_dna)

# ╔═╡ 32798077-3ad2-4ca8-85b5-8e5ab9c12bf9
md"""
### Benchmarking

Julia programmers like speed,
so let's benchmark our approaches!

"""

# ╔═╡ 95373362-00eb-461c-b043-e4f61eacdf84
testseq = randdnaseq(100_000)

# ╔═╡ 0dd66cd4-2ef9-478a-86de-61f0ad5a6c84
testseq_str = string(testseq)

# ╔═╡ d187e8fa-2fa4-4b44-9e4f-ff12e6f97ccd
@benchmark countbases($testseq_str)

# ╔═╡ 57b42a4c-5ae6-413d-892f-ffd32651d7ca
@benchmark(countbases2($testseq_str))

# ╔═╡ e6a5e5cd-124b-4fb1-b1b0-544c27201f78
@benchmark countbases3($testseq)

# ╔═╡ 85ba5566-8292-433d-bea8-4994dafd223e
md"""
Interestingly, on my system, `countbases2()` is actually faster than `countbases()`,
at least for this longer sequence. This may be bacause [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) lets the calls to `count()` work in parallel.

But, as you can see, `countbases3()` is even faster. Let me make one more function that mimics the behavior of the original `countbases()` but uses `BioSequences.jl` instead.
"""

# ╔═╡ b32129ac-07c4-40bb-82e0-8773af956bd5
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

# ╔═╡ 6ce1a73f-0b2b-45bc-a19a-67f40b4d27ac
@benchmark countbases4($testseq)

# ╔═╡ 281f2869-21f3-4a8c-9744-91b5d644c5c4
md"""
## ✍️ Problem 2: Transcription

🤔 [Problem link](https://rosalind.info/problems/rna/)

Enter your DNA to transcribe here:

$(@bind input_rna TextField((50,3); default = "GATGGAACTTGACTACGTAAATT"))
"""

# ╔═╡ e9456da2-2a65-40c8-a8c8-35f655b79635
md"""
### Approach 1 - string `replace()`

This one is pretty straightforward, as described.
All we need to do is replace any `'T'`s with `'U'`s.
Happily, julia has a handy `replace()` function
that takes a string, and a `Pair` that is `pattern => replacement`.
In principle, the pattern can be a literal `String`,
or even a regular expression. But here, we can just use a `Char`.

I'll also write the function using julia's one-line function definition syntax:
"""

# ╔═╡ 4760025e-b111-460b-8cf6-4d168c5dd4c6
simple_transcribe(seq) = replace(seq, 'T'=> 'U')

# ╔═╡ 62435b78-20bb-41e3-b9d0-8f8c2e376664
md"""
As always, there are lots of ways you *could* do this.
This function won't hanndle poorly formatted sequences,
for example. Or rather, it will handle them, even though it shouldn't:
"""

# ╔═╡ 49c46fd4-bda8-4a45-9feb-40f9973acd48
md"""
### Approach 2 - BioSequences `convert()`

As you might expect, `BioSequences.jl` has a way to do this as well.
`BioSequences.jl` doesn't just use a `String` to represent sequences,
there are special types that can efficiently encode nucleic acid
or amino acid sequences.
In some cases, eg DNA or RNA with no ambiguous bases, using as few as 2 bits
per base.
"""

# ╔═╡ f8ea3c52-2a10-41a7-b721-042e28686a33
dna_seq = LongDNA{2}(input_rna)

# ╔═╡ e322c9eb-b337-4984-a2d0-bd778d4ec728
simple_transcribe(seq::LongDNA{N}) where N = convert(LongRNA{N}, seq)

# ╔═╡ 8f33d625-2857-421c-ba27-ccc5eb6a3837
md"""
✅ The answer is: $(simple_transcribe(input_rna))
"""

# ╔═╡ a00c305d-1bfd-4421-88a1-43b4d20ff993
simple_transcribe("This Is QUITE silly")

# ╔═╡ 2bdc52a3-a42f-41ba-a6ee-09b6b5323a20
md"""
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
"""

# ╔═╡ 192d1957-86a9-4188-b544-96b085d03f2b
simple_transcribe(dna_seq)

# ╔═╡ c3fc2e23-75e0-4add-bdfb-19b366dd60aa
md"""
### Benchmarks
"""

# ╔═╡ f0e4083c-940a-4237-9930-1e2131d1f7d7
@benchmark simple_transcribe($testseq)

# ╔═╡ 29ff77ca-d7c8-4838-a7ef-77a69943484f
@benchmark simple_transcribe(x) setup=(x=LongDNA{2}(testseq))

# ╔═╡ ff5198bf-ad93-4c1f-b127-15e07dce13a9
@benchmark simple_transcribe(x) setup=(x=LongDNA{4}(testseq))

# ╔═╡ 1956d6f3-de4a-48c3-8856-8a4b529aaeca
md"""
### Conclusions

I'm actually a little surprised that the `replace()` method does so well,
but there you have it. The `BioJulia method is about 2x faster on a 2-bit sequence
(that is, if there's no ambiguity), but about the same speed on 4-bit sequences.
"""

# ╔═╡ 01290bd7-1ce9-4223-8cb1-fb5e122831af


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
BioSequences = "7e6ae17a-c86d-528c-b3b9-7f778a29fe59"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.2"
BioSequences = "~3.1.3"
PlutoUI = "~0.7.50"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "fcff54ffafa620feff21401e4e674b157e87fb4a"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BioSequences]]
deps = ["BioSymbols", "Random", "SnoopPrecompile", "Twiddle"]
git-tree-sha1 = "c96ede1c34ac948b108f11e4d9ae66df13d57454"
uuid = "7e6ae17a-c86d-528c-b3b9-7f778a29fe59"
version = "3.1.3"

[[deps.BioSymbols]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "2052c3ec7c41b69efa0e9ff7e2734aa6658d4c40"
uuid = "3c28c6f8-a34d-59c4-9654-267d177fcfa9"
version = "5.1.2"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.Twiddle]]
git-tree-sha1 = "29509c4862bfb5da9e76eb6937125ab93986270a"
uuid = "7200193e-83a8-5a55-b20d-5d36d44a0795"
version = "1.1.2"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─76df740a-a130-41f3-8c3e-1f24729cc41b
# ╟─82d06ce9-e588-4312-87c1-d1c97263958a
# ╟─072db8c0-d3c1-11ed-18fa-bff69835f8cd
# ╟─943cd6d5-6339-4851-b663-c9c0ef77e7eb
# ╟─fb80d512-6cbe-4b02-919e-6c557729bb42
# ╟─f0a203b4-7262-4fba-92b1-8bc535f1222a
# ╟─f810b26d-a7cb-44d4-af35-c82fc3791ff6
# ╠═fe8daef1-b3e9-4cca-94bb-8a1dec71f0f7
# ╠═05b5fb9f-d2d3-4917-8ac4-1b14d746fe9c
# ╠═4173f591-4232-4918-ae09-a3de449d42fe
# ╠═024cd6e2-23e4-4490-b482-641f490db2cc
# ╠═75f92ac2-a747-470e-aec1-8f0c906248a7
# ╟─62004c70-e76a-4da2-92a1-d7c4b8b22aa7
# ╠═7ae2154e-c161-4d45-a476-d3fa79757f2d
# ╟─755014bc-470f-469f-a508-df3f372f228b
# ╠═c39e25c7-0071-4be0-8fe1-38eb5e2e4263
# ╠═8ab5eb1c-a991-4c1e-a3b9-f412ec2579a4
# ╠═6db22a7e-3f50-4ad0-adc0-ee3a4f53dc91
# ╟─2368c64a-3ce7-4194-8182-56b5fdefcc96
# ╠═8146ba26-b7a2-4776-85ee-a16f4d28177b
# ╠═de67bd68-2a68-4739-b815-c203079f3826
# ╟─538f6a28-90c0-4f3e-ae94-9ef143cb54d0
# ╠═1ac75946-02b9-43e5-a878-b8c961ed08a4
# ╟─7a21f39d-add6-4f8e-9407-ca8baa7b08a5
# ╠═7824b8ef-f5f5-49fa-9751-f1cf762283fe
# ╠═ae34b79a-f04f-4a29-839a-06c96972f8ec
# ╟─b2d6550e-33f5-4031-b018-f5618bc9b763
# ╟─45b6ad47-0618-4433-9b9f-7809de3cbe32
# ╠═4f2e0acf-5ac8-400a-82da-c66c7b07c467
# ╠═c30d7552-6a79-4f94-97c8-c890c780ce3d
# ╠═dbaf67d6-ba52-4e06-92f0-ea96fff08658
# ╠═02ebb987-bb0b-4070-89ff-b39bc74338a1
# ╟─a8385030-4de5-4fd8-89ba-737f5d720a43
# ╠═6892dd16-194f-4832-bcd8-2fbb26b081c2
# ╠═dff4bf6c-137e-44da-b201-fff7fb0b777d
# ╟─32798077-3ad2-4ca8-85b5-8e5ab9c12bf9
# ╠═41defb0d-7c92-46af-a4e2-35edac47a690
# ╠═95373362-00eb-461c-b043-e4f61eacdf84
# ╠═0dd66cd4-2ef9-478a-86de-61f0ad5a6c84
# ╠═d187e8fa-2fa4-4b44-9e4f-ff12e6f97ccd
# ╠═57b42a4c-5ae6-413d-892f-ffd32651d7ca
# ╠═e6a5e5cd-124b-4fb1-b1b0-544c27201f78
# ╟─85ba5566-8292-433d-bea8-4994dafd223e
# ╠═b32129ac-07c4-40bb-82e0-8773af956bd5
# ╠═6ce1a73f-0b2b-45bc-a19a-67f40b4d27ac
# ╟─281f2869-21f3-4a8c-9744-91b5d644c5c4
# ╟─8f33d625-2857-421c-ba27-ccc5eb6a3837
# ╟─e9456da2-2a65-40c8-a8c8-35f655b79635
# ╠═4760025e-b111-460b-8cf6-4d168c5dd4c6
# ╟─62435b78-20bb-41e3-b9d0-8f8c2e376664
# ╠═a00c305d-1bfd-4421-88a1-43b4d20ff993
# ╟─49c46fd4-bda8-4a45-9feb-40f9973acd48
# ╠═f8ea3c52-2a10-41a7-b721-042e28686a33
# ╠═e322c9eb-b337-4984-a2d0-bd778d4ec728
# ╟─2bdc52a3-a42f-41ba-a6ee-09b6b5323a20
# ╠═192d1957-86a9-4188-b544-96b085d03f2b
# ╟─c3fc2e23-75e0-4add-bdfb-19b366dd60aa
# ╠═f0e4083c-940a-4237-9930-1e2131d1f7d7
# ╠═29ff77ca-d7c8-4838-a7ef-77a69943484f
# ╠═ff5198bf-ad93-4c1f-b127-15e07dce13a9
# ╟─1956d6f3-de4a-48c3-8856-8a4b529aaeca
# ╠═01290bd7-1ce9-4223-8cb1-fb5e122831af
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
