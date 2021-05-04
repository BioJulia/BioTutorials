### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 62b78f0a-ac44-11eb-3362-d922dbc1465f
using PlutoUI

# ╔═╡ 4bef39cf-eee2-43c0-a552-2850220681c3
@bind seq TextField()

# ╔═╡ 62a5a437-0ef6-48cd-8d78-8a88a3dc7ce9
dna_complements = (
	a = 't',
	c = 'g',
	g = 'c',
	t = 'a')	

# ╔═╡ 2674daaa-7579-483c-b939-381b359d3b9a
complement(base::Symbol) = dna_complements[base]

# ╔═╡ 69ae124e-288b-4514-b6ee-5891c8b27423
complement(base::Char) = complement(Symbol(lowercase(base)))

# ╔═╡ a03623a6-16d5-47f3-869b-8bcb7d17bd02
complement(sequence::AbstractString) = string((complement(sequence[i]) for i in eachindex(sequence))...)

# ╔═╡ 39b26467-4f93-40a3-ae45-bdc8ec7c699e
reverse_complement(sequence) = reverse(complement(sequence))

# ╔═╡ f54ad0e0-6e19-4b73-a392-78139bf5627a
reverse_complement(seq)

# ╔═╡ Cell order:
# ╠═62b78f0a-ac44-11eb-3362-d922dbc1465f
# ╠═4bef39cf-eee2-43c0-a552-2850220681c3
# ╠═f54ad0e0-6e19-4b73-a392-78139bf5627a
# ╠═62a5a437-0ef6-48cd-8d78-8a88a3dc7ce9
# ╠═2674daaa-7579-483c-b939-381b359d3b9a
# ╠═69ae124e-288b-4514-b6ee-5891c8b27423
# ╠═a03623a6-16d5-47f3-869b-8bcb7d17bd02
# ╠═39b26467-4f93-40a3-ae45-bdc8ec7c699e
