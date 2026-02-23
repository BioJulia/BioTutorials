# Consensus and Profile

🤔 [Problem link](https://rosalind.info/problems/cons/)

!!! warning "The Problem"
    A matrix is a rectangular table of values divided into rows and columns.   
    An m×n matrix has m rows and ncolumns.   
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
    (If several possible consensus strings exist, then you may return any one of them.)

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
In this case, we will not be reading in a fasta file,   
but a set of strings in fasta format.   
Once it is read in, we can iterate over the strings and store the strings in a data matrix.

From there, we can generate the profile matrix.  
We'll need to sum the number of times each nucleotide appears at a particular row of the data matrix.  

Then, we can identify the most common nucleotide at each column of the data matrix.  
After we have done this for all columns of the data matrix,   
we can generate the consensus string.  

It is possible that there can be multiple consensus strings,  
as some nucleotides may appear the same number of times  
in each column of the data matrix.  
If this is the case, we can return multiple consensus strings.


```julia

function consensus(fasta)
    # read in strings in fasta format

    data_matrix = []
    # iterate over strings and store in matrix

    # make consensus matrix


    # make consensus string











```