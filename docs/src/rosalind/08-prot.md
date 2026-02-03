# Translating RNA into Protein

🤔 [Problem link](https://rosalind.info/problems/prot/)

!!! warning "The Problem"

    The 20 commonly occurring amino acids are abbreviated by using 20 letters from the English alphabet (all letters except for B, J, O, U, X, and Z). Protein strings are constructed from these 20 symbols. Henceforth, the term genetic string will incorporate protein strings along with DNA strings and RNA strings.

    The RNA codon table dictates the details regarding the encoding of specific codons into the amino acid alphabet.

    Given: An RNA string s corresponding to a strand of mRNA (of length at most 10 kbp).

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
Let's first tackle this problem by writing our own solution. 

First, we will check that this is a coding region by verifying that the string starts with a start codon (`AUG`). If not, we can still convert the string to protein, but we'll throw an error. There may be a frame shift, in which case the returned translation will be incorrect.

We'll also do a check that the string is divisible by three. If it is not, this will likely mean that there was a mutation in the string (addition or deletion). Again, we can still convert as much of the the string as possible. However, we should alert the user that this result may be incorrect!

We need to convert this string of DNA to a string of proteins using the RNA codon table. We can convert the RNA codon table into a dictionary, which can map over our codons.

Then, we'll break the string into codons by slicing at every three characters. These codons can be matched to the strings into the RNA codon table to get the corresponding amino acid. We'll append this amino acid to a string.

We'll need to deal with any three-character strings that don't match a codon. This likely means that there was a mutation in the input DNA string! If we get a codon that doesn't match, we can return "X" for that amino acid, and continue translating the rest of the string. However, if we get a string X's, that will definitely signal to us that there was some kind of frame shift. 

Now that we have established an approach, let's turn this into code!

```julia

dna = "AUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA"

# note: this can be created by hand
# or it can be accessed using 
codon_table = rna_codon_table = {
    # Phenylalanine (F)
    'UUU': 'F', 'UUC': 'F',
    # Leucine (L)
    'UUA': 'L', 'UUG': 'L', 'CUU': 'L', 'CUC': 'L', 'CUA': 'L', 'CUG': 'L',
    # Isoleucine (I)
    'AUU': 'I', 'AUC': 'I', 'AUA': 'I',
    # Methionine (M) - Start Codon
    'AUG': 'M',
    # Valine (V)
    'GUU': 'V', 'GUC': 'V', 'GUA': 'V', 'GUG': 'V',
    # Serine (S)
    'UCU': 'S', 'UCC': 'S', 'UCA': 'S', 'UCG': 'S', 'AGU': 'S', 'AGC': 'S',
    # Proline (P)
    'CCU': 'P', 'CCC': 'P', 'CCA': 'P', 'CCG': 'P',
    # Threonine (T)
    'ACU': 'T', 'ACC': 'T', 'ACA': 'T', 'ACG': 'T',
    # Alanine (A)
    'GCU': 'A', 'GCC': 'A', 'GCA': 'A', 'GCG': 'A',
    # Tyrosine (Y)
    'UAU': 'Y', 'UAC': 'Y',
    # Stop Codons (*)
    'UAA': '*', 'UAG': '*', 'UGA': '*',
    # Histidine (H)
    'CAU': 'H', 'CAC': 'H',
    # Glutamine (Q)
    'CAA': 'Q', 'CAG': 'Q',
    # Asparagine (N)
    'AAU': 'N', 'AAC': 'N',
    # Lysine (K)
    'AAA': 'K', 'AAG': 'K',
    # Aspartic Acid (D)
    'GAU': 'D', 'GAC': 'D',
    # Glutamic Acid (E)
    'GAA': 'E', 'GAG': 'E',
    # Cysteine (C)
    'UGU': 'C', 'UGC': 'C',
    # Tryptophan (W)
    'UGG': 'W',
    # Arginine (R)
    'CGU': 'R', 'CGC': 'R', 'CGA': 'R', 'CGG': 'R', 'AGA': 'R', 'AGG': 'R',
    # Glycine (G)
    'GGU': 'G', 'GGC': 'G', 'GGA': 'G', 'GGG': 'G'
}


# check if starts with start codon

# check if string is divisible by three

# separate string into codons, map over with codon table

# dealing with codons not in codon_table

# return amino acid string

```


### Biojulia Solution

An alternative way to approach this problem would be to leverage an already written, established function from BioJulia.

```julia



```