### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 99c86c07-2ca9-4a48-9b0c-3512be94a200
using Markdown

# ╔═╡ ea836af2-d40d-400a-b54a-f2af1af03210
md"""
# Arrays
"""

# ╔═╡ aabc2d03-c4ad-4350-9c80-008c7372eb22
# ones(), zeros()
vector = zeros(Int, 10)

# ╔═╡ e7be1fdb-ab4c-4479-8a5b-5e97c7fa3894
vector[3]

# ╔═╡ ea8f45e1-efb1-4f96-990b-d95db7f79697
vector[3] = 2

# ╔═╡ c3ef9b58-913f-41a7-aed0-aee022167c58
vector

# ╔═╡ cb12b09f-29f6-480b-8c11-3f953453a063
vector[2:5]

# ╔═╡ fad131e9-5647-49be-9453-04ad241423db
vector[4:6] .= 4

# ╔═╡ 6f90595b-3cea-44a1-a085-fe396c6b6e51
vector

# ╔═╡ 1f1be056-7657-423a-a8af-985fceb8b2c6
v2 = vector[3:5]

# ╔═╡ 32db7aec-5a0b-4f60-baf8-ac2dfcc4ed3a
md"""
# Arrays views

view is like link to part of origin array
"""

# ╔═╡ dc9f6525-0ba9-4956-9bd1-73a6498c3bc6
z = view(vector, 3:5)

# ╔═╡ 6db04cb4-11bf-4e3c-95c0-f0252ace3956
z .= 9

# ╔═╡ 5add4020-d3e0-48c6-aa18-f50b31f5af01
vector

# ╔═╡ 34189325-6b48-42bd-a311-35b398ada6a6
# same is z (upper)
z2 = @view vector[3:5]

# ╔═╡ 4c726b26-ce98-4013-8427-238d3a558277
md"""
# Matrices: slices and views
"""

# ╔═╡ eb82321c-ea8c-46ff-9e4f-1f49a6b854dd
M = [5i + j for i=0:5, j = 1:4]

# ╔═╡ d39b6561-5628-44fa-aee7-1f634cf11cb1
M[3:5, 1:2]

# ╔═╡ fd8b5669-273c-454e-9e3e-27f302adf76b
view(M, 3:5, 1:2)

# ╔═╡ 1b725db3-6021-42d2-b0a1-14b54fbe05b9
# to not do a copy
@view M[3:5, 1:2]

# ╔═╡ e3f70009-0415-454b-ad07-fbe20ba6b91c
M2 = reshape(M, 3, 8)

# ╔═╡ 30d13e63-e765-4865-b81d-c3e613a2bf29
view(M2, 1:3, 1:2)

# ╔═╡ 55df7bba-783c-4731-8e81-e4790c17b402
# turn the matrix to a vector
vv = vec(M)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
"""

# ╔═╡ Cell order:
# ╠═99c86c07-2ca9-4a48-9b0c-3512be94a200
# ╟─ea836af2-d40d-400a-b54a-f2af1af03210
# ╠═aabc2d03-c4ad-4350-9c80-008c7372eb22
# ╠═e7be1fdb-ab4c-4479-8a5b-5e97c7fa3894
# ╠═ea8f45e1-efb1-4f96-990b-d95db7f79697
# ╠═c3ef9b58-913f-41a7-aed0-aee022167c58
# ╠═cb12b09f-29f6-480b-8c11-3f953453a063
# ╠═fad131e9-5647-49be-9453-04ad241423db
# ╠═6f90595b-3cea-44a1-a085-fe396c6b6e51
# ╠═1f1be056-7657-423a-a8af-985fceb8b2c6
# ╟─32db7aec-5a0b-4f60-baf8-ac2dfcc4ed3a
# ╠═dc9f6525-0ba9-4956-9bd1-73a6498c3bc6
# ╠═6db04cb4-11bf-4e3c-95c0-f0252ace3956
# ╠═5add4020-d3e0-48c6-aa18-f50b31f5af01
# ╠═34189325-6b48-42bd-a311-35b398ada6a6
# ╟─4c726b26-ce98-4013-8427-238d3a558277
# ╠═eb82321c-ea8c-46ff-9e4f-1f49a6b854dd
# ╠═d39b6561-5628-44fa-aee7-1f634cf11cb1
# ╠═fd8b5669-273c-454e-9e3e-27f302adf76b
# ╠═1b725db3-6021-42d2-b0a1-14b54fbe05b9
# ╠═e3f70009-0415-454b-ad07-fbe20ba6b91c
# ╠═30d13e63-e765-4865-b81d-c3e613a2bf29
# ╠═55df7bba-783c-4731-8e81-e4790c17b402
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
