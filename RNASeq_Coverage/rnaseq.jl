### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 1befb410-ac49-11eb-200d-8ff653b0decc
begin
	using Pkg
	Pkg.activate(pwd())
	Pkg.instantiate()
end

# ╔═╡ d0c1d1a5-197f-467f-8490-7a74e9cd4352
using XAM

# ╔═╡ c4656d53-044c-4046-b4ab-fa9b1c8a9258
md"""
# RNA-Seq Coverage

In this tutorial we uses a public RNA-Seq data downloaded from the Sequence Read Archive (SRA): http://trace.ncbi.nlm.nih.gov/Traces/sra/?run=SRR1238088. Paired-end FASTQ sequence files were extracted from the archive file and aligned to the reference genome as follows:

```sh
$ fastq-dump --gzip --skip-technical --readids --split-files SRR1238088.sra
$ hisat2 -x ../TAIR/TAIR10 -1 SRR1238088_1.fastq.gz -2 SRR1238088_2.fastq.gz | samtools view -b - >SRR1238088.bam
$ samtools sort -O bam -T tmp SRR1238088.bam >SRR1238088.sort.bam
$ samtools index SRR1238088.sort.bam
$ rm SRR1238088.bam
```

The size of the sorted BAM file is about 1.9GB and its summary is shown below:
"""

# ╔═╡ 3c58372a-83e6-4b9d-998c-fb31cd6fa26c


# ╔═╡ Cell order:
# ╠═1befb410-ac49-11eb-200d-8ff653b0decc
# ╠═d0c1d1a5-197f-467f-8490-7a74e9cd4352
# ╟─c4656d53-044c-4046-b4ab-fa9b1c8a9258
# ╠═3c58372a-83e6-4b9d-998c-fb31cd6fa26c
