# Consensus and Profile

🤔 [Problem link](https://rosalind.info/problems/cons/)

!!! warning "The Problem". 

    A matrix is a rectangular table of values divided into rows and columns.   
    An m×n matrix has m rows and n columns.   
    Given a matrix A, we write Ai,j.  
    to indicate the value found at the intersection of row i and column j.  

    Say that we have a collection of DNA strings,   
    all having the same length n.   
    Their profile matrix is a 4×n matrix P in which P1,    
    j represents the number of times that 'A' occurs in the jth position of one of the strings,   
    P2,j represents the number of times that C occurs in the jth position,   
    and so on (see below).

    A consensus string c is a string of length n
    formed from our collection by taking the most common symbol at each position;   
    the jth symbol of c therefore corresponds to the symbol having the maximum value 
    in the j-th column of the profile matrix.     
    Of course, there may be more than one most common symbol, 
    leading to multiple possible consensus strings.  

    ### DNA Strings
    A T C C A G C T
    G G G C A A C T
    A T G G A T C T
    A A G C A A C C
    T T G G A A C T
    A T G C C A T T
    A T G G C A C T

    ### Profile

    A   5 1 0 0 5 5 0 0
	C   0 0 1 4 2 0 6 1
    G   1 1 6 3 0 1 0 0
    T   1 5 0 0 0 1 1 6

    Consensus	A T G C A A C T

    Given:     
    A collection of at most 10 DNA strings of equal length (at most 1 kbp) in FASTA format.

    Return:   
    A consensus string and profile matrix for the collection. 
    (If several possible consensus strings exist,   
    then you may return any one of them.)

    Sample Dataset
    >Rosalind_1
    ATCCAGCT
    >Rosalind_2
    GGGCAACT
    >Rosalind_3
    ATGGATCT
    >Rosalind_4
    AAGCAACC
    >Rosalind_5
    TTGGAACT
    >Rosalind_6
    ATGCCATT
    >Rosalind_7
    ATGGCACT

    Sample Output
    ATGCAACT
    A: 5 1 0 0 5 5 0 0
    C: 0 0 1 4 2 0 6 1
    G: 1 1 6 3 0 1 0 0
    T: 1 5 0 0 0 1 1 6


The first thing we will need to do is read in the input fasta.  
In this case, we will not be reading in an actual fasta file,   
but a set of strings in fasta format.
If we were reading in an actual fasta file,  
we could use the [FASTX.jl](https://github.com/BioJulia/FASTX.jl) package to help us with that.  

Since the task required here is something that was already demonstrated in the [GC-content tutorial](./05-gc.md),  
we can borrow the function from that tutorial.

```julia

fake_file = IOBuffer("""
    >Rosalind_1
    ATCCAGCT
    >Rosalind_2
    GGGCAACT
    >Rosalind_3
    ATGGATCT
    >Rosalind_4
    AAGCAACC
    >Rosalind_5
    TTGGAACT
    >Rosalind_6
    ATGCCATT
    >Rosalind_7
    ATGGCACT
    """
)

function parse_fasta(buffer)
    records = [] # this is a Vector of type `Any`
    record_name = ""
    sequence = ""
    for line in eachline(buffer)
        if startswith(line, ">")
            !isempty(record_name) && push!(records, (record_name, sequence))
            record_name = lstrip(line, '>')
            sequence = ""
        else
            sequence *= line
        end
    end
    push!(records, (record_name, sequence))
    return records
end

records = parse_fasta(fake_file)
```

Once the fasta is read in, we can iterate over each read and store its nucleotide sequence in a data matrix.

From there, we can generate the profile matrix.  
We'll need to sum the number of times each nucleotide appears at a particular row of the data matrix.  

Then, we can identify the most common nucleotide at each column of the data matrix,   
which represents each index of the consensus string.  
After we have done this for all columns of the data matrix,   
we can generate the consensus string.  


```julia
using DataFrames

function consensus(fasta_string)
    
    # extract strings from fasta
    records = parse_fasta(fasta_string)

    # make a vector of just strings
    data_vector = last.(records)

    # convert data_vector to matrix where each column is a char and each row is a string
    data_matrix = reduce(vcat, permutedims.(collect.(data_vector)))

    # make profile matrix

    ## Is it possible to do this in a more efficient vectorized way? I wanted to see if we could do countmap() for each column in a simple way that would involve looping over each column. I think this ended up being more efficient since we are just looping over each of the nucleotides

    consensus_matrix_list = Vector{Int64}[] 
    for nuc in ['A', 'C', 'G', 'T']
        nuc_count = vec(sum(x->x==nuc, data_matrix, dims=1))
        push!(consensus_matrix_list, nuc_count)
    end

    consensus_matrix = vcat(consensus_matrix_list)

    # convert matrix to DF and add row names for nucleotides
    consensus_df = DataFrame(consensus_matrix, ["A", "C", "G", "T"])


    # make column with nucleotide with max value 
    # argmax returns the index or key of the first one encountered
    nuc_max_df = transform(consensus_df, AsTable(:) => ByRow(argmax) => :MaxColName)

    # return consensus string
    return join(nuc_max_df.MaxColName)

end

consensus(fake_file)
```

As mentioned in the problem description above,   
it is possible that there can be multiple consensus strings,    
as some nucleotides may appear the same number of times  
in each column of the data matrix. 

If this is the case,   
the function we are using (`argmax`) returns the nucleotide with the most occurences that it first encounters. 

The way our function is written,  
we first scan for 'A', 'C', then 'G' and 'T',   
so the final consensus string will be biased towards more A's, then C's, G's and T's.  
This simply based on which nucleotide counts it will encounter first in the profile matrix.

