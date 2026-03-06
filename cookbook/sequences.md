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
FASTQ files are also text-based files that contain sequences, along with a name and description.   
However, they also store sequence quality information (the Q is for quality!).

The template of a sequence record is:
```
@{description}
{sequence}
+{description}?
{qualities}
```

Here is an example record:
```
@FSRRS4401BE7HA
tcagTTAAGATGGGAT
+
###EEEEEEEEE##E#
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

The raw reads for a Staphylococcus aureus isolate was sequenced with Pac-Bio and uploaded to NCBI [here](https://trace.ncbi.nlm.nih.gov/Traces/?run=SRR12147540).   
The link to download the raw fastq's can be found [here](https://trace.ncbi.nlm.nih.gov/Traces/?run=SRR12147540).

The biosample ID for this sample is `SAMN14830786`.
This ID refers to the physical bacterial isolate.  

The SRA sample accession number (an internal value used within Sequence Read Archive) is `SRS6947643`.    

Both values correspond to one another and are helpful identifiers. 

The SRR (sample run accession number) is the unique identifier within SRA   
and corresponds to the specific sequencing run within SRA. 

In a later tutorial, we will discuss how we can download this file within julia with the SRR.

But for now, the file can be downloaded using curl 


```
curl -L --retry 5 --retry-delay 2 \
  "https://trace.ncbi.nlm.nih.gov/Traces/sra-reads-be/fastq?acc=SRR12147540" \
  | gzip -c > SRR12147540.fastq.gz
```
This file is gzipped, so we'll need to account for that as we are reading it in.

Instead of printing out every record (this isn't super practical because it's a big file), let's save all the records into a vector.

```julia
using CodecZlib

records = []

FASTQReader(GzipDecompressorStream(open("assets/SRR12147540.fastq.gz"))) do reader
           for record in reader
               push!(records, record)
           end
       end
```

We can see how many reads there are by looking at the length of `records`.

```julia
julia> length(records)
163528
```

Let's take a look at what the first 10 reads look like:

```
julia> records[1:10]
10-element Vector{Any}:
 FASTX.FASTQ.Record("SRR12147540.1  length=43", "TTTTTTTTCCTTTCTTTCT…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.2  length=40", "TTTGTTTTTTTTTGTTTTC…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.3  length=32", "TTTTTTTTTGTTCTTTGGT…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.4  length=40", "TTTTCTTTTCCTTCTTTTC…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.5  length=55", "TGTTGTTTGTGTCTCGTTT…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.6  length=166", "TTTCCTTTTTTTTCCTCTC…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.7  length=338", "TGACCACCTTAGAACTTGG…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.8  length=245", "ACGCCGCGGCCAAAGAACG…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.9  length=157", "TTTGTTTGCGCGGTCTCTT…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRR12147540.10  length=100", "TTCTTTCGCCTTTTTGCCT…", "$$$$$$$$$$$$$$$$$$$…")
 ```

 All of the nucleotides in all of the reads have a quality score of `$`, which corresponds to a probabilty of error of 0.50119.  
 More information about how to convert ASCII values to quality scores [here](https://people.duke.edu/~ccc14/duke-hts-2018/bioinformatics/quality_scores.html).  
 This would be quite poor if we were looking at Illumia data.  
 However, because of how Pacbio chemistry works,  
 the quality scores are often flattened and there is simply a placeholder value on this line.  
 This does not mean our reads are trash!  
 Now that we've learned how to read files in and manipulate them a bit,  
let's see if we can align the mecA gene to the Staphylococcus aureus genome.  


