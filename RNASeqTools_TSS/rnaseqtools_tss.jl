# # RNASeq data analysis using RNASeqTools
#
# Requirements:
#
# * Julia 1.8.5
# * RNASeqTools 0.3.4
# * sra-tools 3.0.3
# * samtools 1.6
# * bwa-mem2 2.2.1
#
# In this tutorial, we will first download a few files (genome, annotation, sequencing reads) with sra-tools. 
# We will then align the reads to the genome using bwa-mem2. We will then use the various Packages from BioJulia 
# through the interface of RNASeqTools to load the alignments file, compute the coverage from it and do some 
# simple signal detection in the coverage.

using Pkg
Pkg.add(url="https://github.com/maltesie/RNASeqTools#v0.3.4")

using RNASeqTools

# ## Downloading the data
#
# Our data will be from V. Cholerae, we need a genome and its annotation: First go to [NCBI](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_013085075.1/),
# after clicking Download, select .fasta and .gff and click Download again. Then extract the content of the archive 
# directory /ncbi_dataset/data/GCF_013085075.1/ into the folder containing this notebook. The folder should then
# look like:
#
# ```
# RNASeqTools_TSS
#   ├── GCF_013085075.1_ASM1308507v1_genomic.fna
#   ├── genomic.gff
#   ├── Manifest.toml
#   ├── Project.toml
#   ├── rnaseqtools_tss.ipynb
#   └── rnaseqtools_tss.jl
# ```
# NCBI stores reads in its internal format SRA, we can use prefetch and fastq-dump from the sra-tools to 
# download reads and convert them to the fastq format. The reads in sample SRR1602510 come from a TEX-treated 
# sample and can be used to identify primary transcription start sites.

download_prefetch(["SRR1602510"], @__DIR__)

# ## Aligning reads with bwa-mem
#
# RNASeqTools provides a wrapper to bwa-mem2. We will use the genome file from the NCBI dataset downloaded earlier.
# align_mem also calls samtools to sort and index the .bam file and creates a .log file containing a useful report
# from samtools stats

align_mem(joinpath(@__DIR__, "SRR1602510_1.fastq.gz"), joinpath(@__DIR__, "GCF_013085075.1_ASM1308507v1_genomic.fna"))

# ## Annotation of alignments and exploration of the data
#
# To annotate the alignments, we need to read the alignments file and the annotation file, then we can 
# explore the annotated alignments.

## read features with types ["rRNA", "tRNA", "CDS"] from the .gff file nad use ["ID", "Name", "locus_tag"] parameters to name the feature
ann = Features(joinpath(@__DIR__, "genomic.gff"), ["rRNA", "tRNA", "CDS"]; name_keys=["ID", "Name", "locus_tag"])

## add annotations for the regions upstream ("5UTR") and downstream ("3UTR") of each "CDS"
addutrs!(ann; cds_type="CDS", five_type="5UTR", five_length=200, three_type="3UTR", three_length=100) 

#fill all regions without annotation with "IGR"
addigrs!(ann; igr_type="IGR")

alignments = AlignedReads(joinpath(@__DIR__, "SRR1602510_1.bam"))

#annotate each alignment with the feature with the largest overlap.
annotate!(alignments, ann)

println("The first 5 alignments with annotation:\n")
for (i, aln) in enumerate(alignments)
    show(aln)
    i>=5 && break
end

#count for each annotation type the number of alignments with a matching annotation
counter = Dict(t=>0 for t in types(ann))
for aln in alignments
    for fragment in aln
        counter[type(fragment)] += 1
    end
end
println("\nFrom $(length(alignments)) mapped fragments, $(counter["IGR"]) map to intergenic regions, $(counter["rRNA"]) to ribosomal RNA and $(counter["tRNA"]) to tRNAs.")

# ## Computation of coverage and potential TSS from it

#coverage is computed with a default normalization of 1/Million reads
forward_file, reverse_file = compute_coverage(joinpath(@__DIR__, "SRR1602510_1.bam"))
coverage = Coverage(forward_file, reverse_file)

#if we dont want to put the coverage into files first, we can compute it directly from the alignments:
coverage = Coverage(alignments)

# Now we can call peaks in the difference along the coverage as positions of putative TSS. The maxdiffpositions
# function computes maxima in the difference along the coverage with a minimum step parameter and a 
# minimum ratio towards the background within a certain region around the maximum.

tss_features = maxdiffpositions(coverage; min_diff=5, min_ratio=1.3, compute_within=3)
println("Found $(length(tss_features)) putative TSS\nThe first 5 TSS according to the set parameters:\n")
for (i, tss) in enumerate(tss_features)
    show(tss)
    i>=5 && break
end

#maxdiffpositions returns a Features struct that can be saved to disc into a .gff file:
write(joinpath(@__DIR__, "tss.gff"), tss_features)
