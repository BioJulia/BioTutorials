+++
title = "Sequence Input/Output"
rss_descr = "Reading in fasta files using FASTX.jl"
+++

# Sequence Input/Output

In this chapter, we'll talk about how to read in sequence files using the `FASTX.jl` module.   
More information about the `FASTX.jl` package can be found at https://biojulia.dev/FASTX.jl/stable/  
and with the built-in documentation. 

```julia
julia> using FASTX
julia> ?FASTX
```

If FASTX is not already in your environment,   
it can be easily added from the Julia Registry.

To demonstrate how to this package,   
let's try to read in some real-world data!   

The `FASTX` can read in 3 file types: fasta, fastq, and fai.

### FASTA files
FASTA files are text files containing biological sequence data.       
They have three parts: name, description, and sequence.

The template of a sequence record is:
```
>{description}
{sequence}
```

### FASTQ files
FASTQ files are also text-based files that contain sequences, along with a name and description. However, they also store sequence quality information (the Q is for quality!).

The template of a sequence record is:
```
@{description}
{sequence}
+{description}?
{qualities}
```

### FAI files

FAI (FASTA index) files are used in conjuction with FASTA/FASTQ files.   
They are text files with TAB-delimited columns.  
Each line contains information about each region sequence within the FASTA/FASTQ.     
More information about fai index files can be found [here](https://www.htslib.org/doc/faidx.html).

```
NAME	Name of this reference sequence
LENGTH	Total length of this reference sequence, in bases
OFFSET	Offset in the FASTA/FASTQ file of this sequence's first base
LINEBASES	The number of bases on each line
LINEWIDTH	The number of bytes in each line, including the newline
QUALOFFSET	Offset of sequence's first quality within the FASTQ file

```





We will read in a fasta file containing the _mecA_ gene.   
This gene was taken from NCBI [here](https://www.ncbi.nlm.nih.gov/gene?Db=gene&Cmd=DetailsSearch&Term=3920764#).

First we'll open the file, 
then we'll iterate over every record in the file and  
print out the sequence identifier, the sequence description and then the corresponding sequence.

```julia
julia> FASTAReader(open("assets/mecA.fasta")) do reader
           for record in reader
               println(identifier(record))
               println(description(record))
               println(sequence(record))
           end
       end

NC_007795.1:907598-908317
NC_007795.1:907598-908317 SAOUHSC_00935 [organism=Staphylococcus aureus subsp. aureus NCTC 8325] [GeneID=3920764] [chromosome=]
ATGAGAATAGAACGAGTAGATGATACAACTGTAAAATTGTTTATAACATATAGCGATATCGAGGCCCGTGGATTTAGTCGTGAAGATTTATGGACAAATCGCAAACGTGGCGAAGAATTCTTTTGGTCAATGATGGATGAAATTAACGAAGAAGAAGATTTTGTTGTAGAAGGTCCATTATGGATTCAAGTACATGCCTTTGAAAAAGGTGTCGAAGTCACAATTTCTAAATCTAAAAATGAAGATATGATGAATATGTCTGATGATGATGCAACTGATCAATTTGATGAACAAGTTCAAGAATTGTTAGCTCAAACATTAGAAGGTGAAGATCAATTAGAAGAATTATTCGAGCAACGAACAAAAGAAAAAGAAGCTCAAGGTTCTAAACGTCAAAAGTCTTCAGCACGTAAAAATACAAGAACAATCATTGTGAAATTTAACGATTTAGAAGATGTTATTAATTATGCATATCATAGCAATCCAATAACTACAGAGTTTGAAGATTTGTTATATATGGTTGATGGTACTTATTATTATGCTGTATATTTTGATAGTCATGTTGATCAAGAAGTCATTAATGATAGTTACAGTCAATTGCTTGAATTTGCTTATCCAACAGACAGAACAGAAGTTTATTTAAATGACTATGCTAAAATAATTATGAGTCATAACGTAACAGCTCAAGTTCGACGTTATTTTCCAGAGACAACTGAATAA
```

In this case, there is only one sequence.

Let's try reading in a larger fastq file. 

```julia



```



