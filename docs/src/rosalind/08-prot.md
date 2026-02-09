# Translating RNA into Protein

🤔 [Problem link](https://rosalind.info/problems/prot/)

!!! warning "The Problem"

    The 20 commonly occurring amino acids are abbreviated by using 20 letters from the English alphabet.  
    (all letters except for B, J, O, U, X, and Z).   
    Protein strings are constructed from these 20 symbols.   
    Henceforth, the term genetic string will incorporate protein strings along with DNA strings and RNA strings.  

    The RNA codon table dictates the details regarding the encoding of specific codons into the amino acid alphabet.

    Given: An RNA string s corresponding to a strand of mRNA.  
    (of length at most 10 kbp).

    Return: The protein string encoded by s.

    Sample Dataset
    ```
    AUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA
    ```

    Sample Output
    ```
    MAMAPRTEINSTRING
    ```

### DIY solution
Let's tackle this problem by writing our own solution,  
and then seeing how we can solve it with functions already available in BioJulia. 

First, we will check that this is a coding region by verifying that the string starts with a start codon (`AUG`).   
If not, we can still convert the string to protein,   
but we'll throw a warning to alert the user.  
There may be a frame shift,   
in which case the returned translation will be incorrect.

We'll also do a check that the string is divisible by three.   
If it is not, this will likely mean that there was a mutation in the string 
(addition or deletion).   
Again, we can still convert as much of the string as possible.   
However, we should alert the user that the result may be incorrect!

Next, we'll need to convert this string of mRNA to a string of proteins using the RNA codon table.  
We can convert the RNA codon table into a dictionary,   
which can map over our codons.
Alternatively, we could also import this from the BioSequences package,   
as this is already defined [there](https://github.com/BioJulia/BioSequences.jl/blob/b626dbcaad76217b248449e6aa2cc1650e95660c/src/geneticcode.jl#L132).

Then, we'll break the string into codons by slicing it every three characters.     
These codons can be matched against the RNA codon table to get the corresponding amino acid.   
We'll join all these amino acids together to form the final string.

Lastly, we'll need to deal with any three-character strings that don't match a codon.   
This likely means that there was a mutation in the input mRNA string!   
If we get a codon that doesn't match,   
we can return "X" for that amino acid,   
and continue translating the rest of the string.  
If we get a string of X's,   
that should signal to the user that there was some kind of frame shift. 


Now that we have established an approach,  
let's turn this into code!

```julia
using Test

rna = "AUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA"

# note: this can be created by hand
# or it can be accessed from the BioSequences package (see link above)
codon_table = Dict{String,Char}(
            "AAA" => 'K', "AAC" => 'N', "AAG" => 'K', "AAU" => 'N',
            "ACA" => 'T', "ACC" => 'T', "ACG" => 'T', "ACU" => 'T',
            "AGA" => 'R', "AGC" => 'S', "AGG" => 'R', "AGU" => 'S',
            "AUA" => 'I', "AUC" => 'I', "AUG" => 'M', "AUU" => 'I',
            "CAA" => 'Q', "CAC" => 'H', "CAG" => 'Q', "CAU" => 'H',
            "CCA" => 'P', "CCC" => 'P', "CCG" => 'P', "CCU" => 'P',
            "CGA" => 'R', "CGC" => 'R', "CGG" => 'R', "CGU" => 'R',
            "CUA" => 'L', "CUC" => 'L', "CUG" => 'L', "CUU" => 'L',
            "GAA" => 'E', "GAC" => 'D', "GAG" => 'E', "GAU" => 'D',
            "GCA" => 'A', "GCC" => 'A', "GCG" => 'A', "GCU" => 'A',
            "GGA" => 'G', "GGC" => 'G', "GGG" => 'G', "GGU" => 'G',
            "GUA" => 'V', "GUC" => 'V', "GUG" => 'V', "GUU" => 'V',
            "UAA" => '*', "UAC" => 'Y', "UAG" => '*', "UAU" => 'Y',
            "UCA" => 'S', "UCC" => 'S', "UCG" => 'S', "UCU" => 'S',
            "UGA" => '*', "UGC" => 'C', "UGG" => 'W', "UGU" => 'C',
            "UUA" => 'L', "UUC" => 'F', "UUG" => 'L', "UUU" => 'F',
        )

function translate_mrna(seq, codon_table)
    
    # check if starts with start codon
    if ! startswith(seq, "AUG")
        @warn "this sequence does not start with AUG"
    end
    # check if string is divisible by three
    if rem(length(seq), 3) != 0
        @warn "this sequence is not divisible by 3"
    end
    # separate string into codons
    codons = (join(chunk) for chunk in Iterators.partition(seq, 3))

    # map over codons with codon table, return X if not in codon_table
    aa_string = join(get(codon_table, c, "X") for c in codons)

    # return amino acid string
    return(aa_string)

end

translate_mrna(rna, codon_table)
```


### BioSequences Solution

An alternative way to approach this problem would be to leverage an already written,    
established function from the BioSequences package in BioJulia.

```julia
using BioSequences

rna =("AUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA") 

translate(rna"AUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA")

```

This function is straightforward to use,
especially in the case where the input mRNA has no ambiguous codons 
and is divisible by 3.   
However, there are also additional parameters  available for handling other types of strings.

For instance, the function defaults to using the standard genetic code.  
However, if a user wishes to use another codon chart  
(for example, yeast or invertebrate),   
there are others available on [BioSequences.jl](https://github.com/BioJulia/BioSequences.jl/blob/b626dbcaad76217b248449e6aa2cc1650e95660c/src/geneticcode.jl#L130) to choose from. 

By default, `allow_ambiguous_codons` is `true`.   
If a user gives the function a mRNA string with ambiguous codons that may not be found in the standard genetic code,  
these codons will be translated to the narrowest amino acid which covers all
non-ambiguous codons encompassed by the ambiguous codon.  
If this option is turned off,  
ambiguous codons will cause an error.

Additionally, `alternative_start` is `false` by default.  
If set to true, the starting amino acid will be Methionine regardless of what the first codon is.

Similar to our function, the BioSequences function also throws an error if the input mRNA string is not divisible by 3.