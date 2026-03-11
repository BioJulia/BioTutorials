+++
title = "Sequence Input/Output"
rss_descr = "Reading in FASTA, FASTQ, and FAI files using FASTX.jl"
+++

# Sequence Input/Output

In this chapter, we'll talk about how to read in sequence files using the `FASTX.jl` module.   
More information about the `FASTX.jl` package can be found at https://biojulia.dev/FASTX.jl/stable/  
and with the built-in documentation you can access directly within the Julia REPL. 

```julia
julia> using FASTX
julia> ?FASTX
```

If `FASTX` is not already in your environment,   
it can be easily added from the Julia Registry.

To demonstrate how to use this package,   
let's try to read in some real-world data!   

The `FASTX` package can read in three file types: `fasta`, `fastq`, and `fai`.

### FASTA files
FASTA files are text files containing biological sequence data.       
They have three parts: name, description, and sequence.

The template of a sequence record is:
```
>{description}
{sequence}
```

The identifier is the first part of the description until the first whitespace.     
If there is no white space, the name and description are the same.

Here is an example fasta:
```
>chrI chromosome 1
CCACACCACACCCACACACCCACACACCACACCACACACCACACCACACC
CACACACACACATCCTAACACTACCCTAACACAGCCCTAATCTA
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

FAI (FASTA index) files are used in conjunction with FASTA/FASTQ files.   
They are text files with TAB-delimited columns.  
They allow the user to access specific regions of the reference FASTA/FASTQ without reading in the entire sequence into memory.      
More information about fai index files can be found [here](https://www.htslib.org/doc/faidx.html).

```
NAME	Name of this reference sequence
LENGTH	Total length of this reference sequence, in bases
OFFSET	Offset in the FASTA/FASTQ file of this sequence's first base
LINEBASES	The number of bases on each line
LINEWIDTH	The number of bytes in each line, including the newline
QUALOFFSET	Offset of sequence's first quality within the FASTQ file

```

We will read in a FASTA file containing the _mecA_ gene.   
_mecA_ is an antibiotic resistance gene commonly found in Methicillin-resistant _Staphylococcus aureus_ (MRSA). 
It helps bacteria to break down beta-lactam antibiotics like methicillin.    
It is typically 2.1 kB long.  
This specific reference fasta was downloaded from NCBI [here](https://www.ncbi.nlm.nih.gov/nuccore/NG_047945.1?report=fasta). More information about this reference sequence can be found [here](https://www.ncbi.nlm.nih.gov/nuccore/NG_047945.1).  

First we'll open the file.   
Then we'll iterate over every record in the file and  
print out the sequence identifier, the sequence description and then the corresponding sequence.

```julia
julia> FASTAReader(open("assets/mecA.fasta")) do reader
           for record in reader
               println(identifier(record))
               println(description(record))
               println(sequence(record))
               println(length(sequence(record)))
           end
       end

NG_047945.1
NG_047945.1 Staphylococcus aureus TN/CN/1/12 mecA gene for ceftaroline-resistant PBP2a family peptidoglycan transpeptidase MecA, complete CDS
ATGAAAAAGATAAAAATTGTTCCACTTATTTTAATAGTTGTAGTTGTCGGGTTTGGTATATATTTTTATGCTTCAAAAGATAAAGAAATTAATAATACTATTGATGCAATTGAAGATAAAAATTTCAAACAAGTTTATAAAGATAGCAGTTATATTTCTAAAAGCGATAATGGTGAAGTAGAAATGACTGAACGTCCGATAAAAATATATAATAGTTTAGGCGTTAAAGATATAAACATTCAGGATCGTAAAATAAAAAAAGTATCTAAAAATAAAAAACGAGTAGATGCTCAATATAAAATTAAAACAAACTACGGTAACATTGATCGCAACGTTCAATTTAATTTTGTTAAAGAAGATGGTATGTGGAAGTTAGATTGGGATCATAGCGTCATTATTCCAGGAATGCAGAAAGACCAAAGCATACATATTGAAAATTTAAAATCAGAACGTGGTAAAATTTTAGACCGAAACAATGTGGAATTGGCCAATACAGGAACAGCATATGAGATAGGCATCGTTCCAAAGAATGTATCTAAAAAAGATTATAAAGCAATCGCTAAAGAACTAAGTATTTCTGAAGACTATATCAAACAACAAATGGATCAAAATTGGGTACAAGATGATACCTTCGTTCCACTTAAAACCGTTAAAAAAATGGATGAATATTTAAGTGATTTCGCAAAAAAATTTCATCTTACAACTAATGAAACAAAAAGTCGTAACTATCCTCTAGAAAAAGCGACTTCACATCTATTAGGTTATGTTGGTCCCATTAACTCTGAAGAATTAAAACAAAAAGAATATAAAGGCTATAAAGATGATGCAGTTATTGGTAAAAAGGGACTCGAAAAACTTTACGATAAAAAGCTCCAACATGAAGATGGCTATCGTGTCACAATCGTTGACGATAATAGCAATACAATCGCACATACATTAATAGAGAAAAAGAAAAAAGATGGCAAAGATATTCAACTAACTATTGATGCTAAAGTTCAAAAGAGTATTTATAACAACATGAAAAATGATTATGGCTCAGGTACTGCTATCCACCCTCAAACAGGTGAATTATTAGCACTTGTAAGCACACCTTCATATGACGTCTATCCATTTATGTATGGCATGAGTAACGAAGAATATAATAAATTAACCGAAGATAAAAAAGAACCTCTGCTCAACAAGTTCCAGATTACAACTTCACCAGGTTCAACTCAAAAAATATTAACAGCAATGATTGGGTTAAATAACAAAACATTAGACGATAAAACAAGTTATAAAATCGATGGTAAAGGTTGGCAAAAAGATAAATCTTGGGGTGGTTACAACGTTACAAGATATGAAGTGGTAAATGGTAATATCGACTTAAAACAAGCAATAGAATCATCAGATAACATTTTCTTTGCTAGAGTAGCACTCGAATTAGGCAGTAAGAAATTTGAAAAAGGCATGAAAAAACTAGGTGTTGGTGAAGATATACCAAGTGATTATCCATTTTATAATGCTCAAATTTCAAACAAAAATTTAGATAATGAAATATTATTAGCTGATTCAGGTTACGGACAAGGTGAAATACTGATTAACCCAGTACAGATCCTTTCAATCTATAGCGCATTAGAAAATAATGGCAATATTAACGCACCTCACTTATTAAAAGACACGAAAAACAAAGTTTGGAAGAAAAATATTATTTCCAAAGAAAATATCAATCTATTAACTGATGGTATGCAACAAGTCGTAAATAAAACACATAAAGAAGATATTTATAGATCTTATGCAAACTTAATTGGCAAATCCGGTACTGCAGAACTCAAAATGAAACAAGGAGAAACTGGCAGACAAATTGGGTGGTTTATATCATATGATAAAGATAATCCAAACATGATGATGGCTATTAATGTTAAAGATGTACAAGATAAAGGAATGGCTAGCTACAATGCCAAAATCTCAGGTAAAGTGTATGATGAGCTATATGAGAACGGTAATAAAAAATACGATATAGATGAATAACAAAACAGTGAAGCAATCCGTAACGATGGTTGCTTCACTGTTTTATTATGAATTATTAATAAGTGCTGTTACTTCTCCCTTAAATACAATTTCTTCATTT
2107
```
We confirmed that the length of the gene matches what we'd expect for _mecA_. 
In this case, there is only one sequence that spans the entire length of the gene.   
After this gene was sequenced, all of the reads were assembled together into a single consensus sequence.      
_mecA_ is a well-characterized gene, so there are no ambiguous regions, and there is no need for there to be multiple contigs  
(AKA for the gene to be broken up into multiple pieces, as we know exactly how the reads should be assembled together.).  


Let's try reading in a larger FASTQ file. 

The raw reads for a _Staphylococcus aureus_ isolate were sequenced with Illumina and uploaded to NCBI [here](https://trace.ncbi.nlm.nih.gov/Traces/index.html?run=SRR1050625).     
The link to download the raw FASTQ files can be found [here](https://trace.ncbi.nlm.nih.gov/Traces/index.html?run=SRR1050625).

The BioSample ID for this sample is `SAMN02360768`.
This ID refers to the physical bacterial isolate.  
The SRA sample accession number (an internal value used within the Sequence Read Archive) is `SRS515580`.    
Both values correspond to one another and are helpful identifiers. 

The SRR (sample run accession number) is the unique identifier within SRA   
and corresponds to the specific sequencing run.   
There are two sequencing runs and accession numbers for this sample,   
but we'll select one to download: `SRX392511`.  

This file can be downloaded on the command line using `curl`.  
> One of the nice things about julia is that it is 
> super easy to toggle between the julia REPL and 
> bash shell by typing `;` to access shell mode 
> from julia.  
> You can use the `backspace`/`delete` key to 
> quickly toggle back to the julia REPL.  

To download using the command line, type:
```
curl -L --retry 5 --retry-delay 2 \
  "https://trace.ncbi.nlm.nih.gov/Traces/sra-reads-be/fastq?acc=SRX392511" \
  | gzip -c > SRX392511.fastq.gz
```
Alternatively, command line code can be executed from within julia:

```julia
run(pipeline(
    `curl -L --retry 5 --retry-delay 2 "https://trace.ncbi.nlm.nih.gov/Traces/sra-reads-be/fastq?acc=SRX392511"`,
    `gzip -c`,
    "SRX392511.fastq.gz"
    )
)
```
This file is gzipped, so we'll need to account for that as we are reading it in.

Instead of printing out every record (this isn't super practical because it's a big file), let's save all the records into a vector.

```julia
using CodecZlib

records = []

FASTQReader(GzipDecompressorStream(open("assets/SRX392511.fastq.gz"))) do reader
           for record in reader
               push!(records, record)
           end
       end
```

We can see how many reads there are by looking at the length of `records`.

```julia
julia> length(records)
9852716
```

Let's take a look at what the first 10 reads look like:

```
julia> records[1:10]
10-element Vector{Any}:
 FASTX.FASTQ.Record("SRX392511.1 1 length=101", "AGGATTTTGTTATATTGTA…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRX392511.1 1 length=101", "AGCATAAATTTAAAAAAAA…", "$$$$$$$$$$$$$$$$$$$…")
 FASTX.FASTQ.Record("SRX392511.2 2 length=101", "TAGATTAAAATTCTCGTAT…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.2 2 length=101", "TAGATTAAAATTCTCGTAG…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.3 3 length=101", "GAGCAGTAGTATAAAATGA…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.3 3 length=101", "CCGACACAATTACAAGCCA…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.4 4 length=101", "GATTATCTAGTCATAATTC…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.4 4 length=101", "TTCGCCCCCCCAAAAGGCT…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.5 5 length=101", "ATAAAATGAACTTGCGTTA…", "???????????????????…")
 FASTX.FASTQ.Record("SRX392511.5 5 length=101", "TAACTTGTGGATAATTATT…", "???????????????????…")
 ```

 All of the nucleotides in these two reads have a quality score of `$`, which corresponds to a probabilty of error of 0.50119.
 This is not concerning, as it is typical for the first couple of reads to be low quality.    

 Let's calculate the average quality across all reads. 
 We'll do this by converting each PHRED score to its probability error,   
 and summing these values across all sequences in all reads.  
 Then, we can divide this sum by the total number of bases  
 to get the average probability error for the entire sequence. 
 It's important that we first convert the PHRED scores to the probability errors before averaging,   
because PHRED is a logarithmic transform of error probability.  
Therefore, simply averaging PHRED and then converting to error probability is not the same as converting PHRED to error probability and averaging that sum.  

```julia
function phred_to_prob(Q)
    # The formula is Pe = 10^(-Q/10)
    return 10^(-Q / 10.0)
end

# get sum of all error probabilities
total_error_prob = sum(
    sum(phred_to_prob(q) for q in FASTQ.quality_scores(record))
    for record in records
)
4.5100356107423276e7
# get total number of base pairs
total_bases = sum(length(FASTQ.quality_scores(record)) for record in records)
995124316

# get average error probability
total_error_prob/total_bases
0.045321328584059316
```

The average error probability is just 4.53%,   
meaning the majority of reads are high quality.  

 More information about how to convert ASCII values/PHRED scores to quality scores [here](https://people.duke.edu/~ccc14/duke-hts-2018/bioinformatics/quality_scores.html).  
 



 Now that we've learned how to read files in and manipulate them a bit,  
let's see if we can align the _mecA_ gene to the _Staphylococcus aureus_ genome.  
This will tell us if this _S. aureus_ is MRSA.  


