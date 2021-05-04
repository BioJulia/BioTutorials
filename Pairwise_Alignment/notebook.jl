### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 6ed581f0-ac32-11eb-29ce-e7fee6d344dc
begin
	using Pkg
	Pkg.activate(".")
	Pkg.instantiate()
end

# ╔═╡ 1a680ba3-3856-4ab2-b0fd-bb53c7f3328a
using BioAlignments

# ╔═╡ 86f421cf-2926-4657-9702-2623e78552d5
using BioSequences

# ╔═╡ 24dfd243-7eab-4d32-a411-39e190aa85f6
md"""# Pairwise Alignment and Dotplot

Pairwise sequence alignment algorithms are provided by the BioAlignments.jl package. The sequence alignment is a kind of optimization problem to find the best scoring alignment. For example, matching two similar symbols gets a high (often positive) score and matching dissimilar symbols does a low (often negative) score.



The following two sequences are homologus protein sequences from [titin](https://en.wikipedia.org/wiki/Titin) of human and mouse. Titin is a component of muscle fiber and extremely long (~30,000 amino acids) compared to other protein sequences. So, the sequences used here are just part of them. The complete sequences can be found here:

- TITIN_HUMAN: http://www.uniprot.org/uniprot/Q8WZ42
- TITIN_MOUSE: http://www.uniprot.org/uniprot/A2ASS6
"""

# ╔═╡ 80c8671e-e3c6-41ea-9002-4e351ad8352a
titin_human = aa"""
EYTLLLIEAFPEDAAVYTCEAKNDYGVATTSASLSVEVPEVVSPDQEMPVYPPAIITPLQDTVTSEGQPA
RFQCRVSGTDLKVSWYSKDKKIKPSRFFRMTQFEDTYQLEIAEAYPEDEGTYTFVASNAVGQVSSTANLS
LEAPESILHERIEQEIEMEMKEFSSSFLSAEEEGLHSAELQLSKINETLELLSESPVYPTKFDSEKEGTG
PIFIKEVSNADISMGDVATLSVTVIGIPKPKIQWFFNGVLLTPSADYKFVFDGDDHSLIILFTKLEDEGE
YTCMASNDYGKTICSAYLKINSKGEGHKDTETESAVAKSLEKLGGPCPPHFLKELKPIRCAQGLPAIFEY
TVVGEPAPTVTWFKENKQLCTSVYYTIIHNPNGSGTFIVNDPQREDSGLYICKAENMLGESTCAAELLVL
LEDTDMTDTPCKAKSTPEAPEDFPQTPLKGPAVEALDSEQEIATFVKDTILKAALITEENQQLSYEHIAK
ANELSSQLPLGAQELQSILEQDKLTPESTREFLCINGSIHFQPLKEPSPNLQLQIVQSQKTFSKEGILMP
EEPETQAVLSDTEKIFPSAMSIEQINSLTVEPLKTLLAEPEGNYPQSSIEPPMHSYLTSVAEEVLSPKEK
TVSDTNREQRVTLQKQEAQSALILSQSLAEGHVESLQSPDVMISQVNYEPLVPSEHSCTEGGKILIESAN
PLENAGQDSAVRIEEGKSLRFPLALEEKQVLLKEEHSDNVVMPPDQIIESKREPVAIKKVQEVQGRDLLS
KESLLSGIPEEQRLNLKIQICRALQAAVA
"""

# ╔═╡ 02b64190-1f6b-4ad6-b872-a52a890912b0

titin_mouse = aa"""
EYTLLLIEAFPEDAAVYTCEAKNDYGVATTSASLSVEVPEVVSPDQEMPVYPPAIVTPLQDTVTSEGRPA
RFQCQVSGTDLKVSWYCKDKKIKPSRFFRMTQFEDTYQLEIAEAYPEDEGTYAFVANNAVGQVSSTATLR
LEAPESILHERIGQQIEMEMKEIASLLSAEEDFQTYSSDLRLPNANETLELLSEPPARSTQFDSRQEGAA
PVFIREISDVEISVEDVAKLSVTVTGCPKPKIQWFFNGMLLTPSADYKFVFDGDTHSLIILFTRFQDEGE
YTCLASNEYGKAVCSAHLRISPRGERSTEMESGEKKALEKPKGPCPPYFFKELKPVHCGPGIPAVFEYSV
HGEPAPTVLWFKEDMPLYTSVCYTIIHSPDGSGTFIVNDPQRGDSGLYLCKAQNLWGESTCAAELLVLPE
DTDVPDASCKEESTLGVPGDFLETSARGPLVQGVDSRQEITAFAEGTISKAALIAEETLQLSYERSVDDS
EVGTGVTIGAQKLPPVVLSTPQGTGELPSIDGAVHTQPGRGPPPTLNLQAVQAQTTLPKEATLQFEEPEG
VFPGASSAAQVSPVTIKPLITLTAEPKGNYPQSSTAAPDHALLSSVAAETLQLGEKKIPEVDKAQRALLL
SQSLAEGCVESLEVPDVAVSNMRSEPQVPFQHTCTEGKILMASADTLKSTGQDVALRTEEGKSLSFPLAL
EEKQVLLKEEQSEVVAVPTSQTSKSEKEPEAIKGVKEVREQELLSKETLFPSMPEEQRLHLKTQVRRALQ
AAVA
"""

# ╔═╡ 0c8307ab-0878-45b5-bea0-d6b4a30c2482
md"""
The similarity score between two symbols are described by a [substitution matrix](https://en.wikipedia.org/wiki/Substitution_matrix) and BioAlignments.jl provides some predefined matrices commonly seen in bioinformatics. BLOSUM62 is a substitution matrix for amino acids and sometimes used as a default matrix in some programs. The derivation method and the biological rationale are outlined in this article: https://en.wikipedia.org/wiki/BLOSUM."""

# ╔═╡ 49c1ffd7-99ef-4bfc-a9dd-7a55a960becd
BLOSUM62

# ╔═╡ fb18926c-e971-4370-b942-dadf0bdfcb65
md"The score in the matrix can be accessed using a pair of amino acids:"

# ╔═╡ bf632180-a598-40b6-a7ed-f99c7e0cb1ba
BLOSUM62[AA_R, AA_K]

# ╔═╡ 34d4b507-9f8a-4e95-82b2-d081a8dd6f3e
md"""
Two protein sequences are aligned to each other using the pairalign function, which takes an alignment optimization problem (`GlobalAlignment()`), two compared sequences (`titin_human`, `titin_mouse`) and scoring model (`model`). The algorithms implemented in this module can find the optimal sequence alignments between two sequences based on affine gap scoring model, in which inserting gaps of length k in a sequence alignment gets `gap_open + gap_extend * k` where `gap_open` and `gap_extend` are non-positive scores imposed on starting a new gap and extending a gap, respectively.
"""

# ╔═╡ f0afe55c-e996-4e02-a683-53771ddf377b
# Create a socring model from a substitution matrix and gap scores.
model = AffineGapScoreModel(BLOSUM62, gap_open=-11, gap_extend=-1)

# ╔═╡ c725e8cb-3207-4255-9c67-367caaaeb800
# Solve a pairwise-alignment optimization problem.
result = pairalign(GlobalAlignment(), titin_human, titin_mouse, model)

# ╔═╡ 0a1f9c62-7858-40f9-9699-f9064c1c1277
score(result)

# ╔═╡ Cell order:
# ╠═6ed581f0-ac32-11eb-29ce-e7fee6d344dc
# ╠═24dfd243-7eab-4d32-a411-39e190aa85f6
# ╠═1a680ba3-3856-4ab2-b0fd-bb53c7f3328a
# ╠═86f421cf-2926-4657-9702-2623e78552d5
# ╠═80c8671e-e3c6-41ea-9002-4e351ad8352a
# ╠═02b64190-1f6b-4ad6-b872-a52a890912b0
# ╟─0c8307ab-0878-45b5-bea0-d6b4a30c2482
# ╠═49c1ffd7-99ef-4bfc-a9dd-7a55a960becd
# ╟─fb18926c-e971-4370-b942-dadf0bdfcb65
# ╠═bf632180-a598-40b6-a7ed-f99c7e0cb1ba
# ╠═34d4b507-9f8a-4e95-82b2-d081a8dd6f3e
# ╠═f0afe55c-e996-4e02-a683-53771ddf377b
# ╠═c725e8cb-3207-4255-9c67-367caaaeb800
# ╠═0a1f9c62-7858-40f9-9699-f9064c1c1277
