### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 36b08d61-06b4-42ae-82ec-2db97892b540
begin
	import Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 7f75459b-888d-4350-be34-de447d229fa5
begin
	# Poor man's Project.toml
	Pkg.add(["Images", "ImageMagick", "PlutoUI", "ImageFiltering"])
	
	using Images
	using PlutoUI
	using ImageFiltering
	
	# these are "Standard Libraries" - they are included in every environment
	using Statistics
	using LinearAlgebra
end

# ╔═╡ c6dc2da7-f65e-4e80-a7d8-70632771b260
using Markdown 

# ╔═╡ df9e872a-59d4-4b0c-938b-1e5534459a60
using InteractiveUtils

# ╔═╡ e76fe107-967d-4ea6-a88e-db0e6fbee0aa
# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ eb5c03b2-8ec4-45a9-b601-44ff8a58c2a1
function shrink_image(image, ratio=5)
	(height, width) = size(image)
	new_height = height ÷ ratio - 1
	new_width = width ÷ ratio - 1
	list = [
		mean(image[
			ratio * i:ratio * (i + 1),
			ratio * j:ratio * (j + 1),
		])
		for j in 1:new_width
		for i in 1:new_height
	]
	reshape(list, new_height, new_width)
end

# ╔═╡ 9166f3da-eb75-446d-94fb-3f39873668b7
Sy, Sx = Kernel.sobel()

# ╔═╡ f9da4a55-6813-4d65-a9a9-5caba6e45643
(collect(Int.(8 .* Sy)), collect(Int.(8 .* Sx)))

# ╔═╡ a904111a-3a42-4193-a50f-bd08e5968f19
function convolve(M, kernel)
    height, width = size(kernel)
    
    half_height = height ÷ 2
    half_width = width ÷ 2
    
    new_image = similar(M)
	
    # (i, j) loop over the original image
	m, n = size(M)
    @inbounds for i in 1:m
        for j in 1:n
            # (k, l) loop over the neighbouring pixels
			accumulator = 0 * M[1, 1]
			for k in -half_height:-half_height + height - 1
				for l in -half_width:-half_width + width - 1
					Mi = i - k
					Mj = j - l
					# First index into M
					if Mi < 1
						Mi = 1
					elseif Mi > m
						Mi = m
					end
					# Second index into M
					if Mj < 1
						Mj = 1
					elseif Mj > n
						Mj = n
					end
					
					accumulator += kernel[k, l] * M[Mi, Mj]
				end
			end
			new_image[i, j] = accumulator
        end
    end
    
    return new_image
end

# ╔═╡ 03dd2977-2b7f-42f8-805a-7118e1a0756f
function show_colored_array(array)
		pos_color = RGB(0.36, 0.82, 0.8)
		neg_color = RGB(0.99, 0.18, 0.13)
		to_rgb(x) = max(x, 0) * pos_color + max(-x, 0) * neg_color
		to_rgb.(array) / maximum(abs.(array))
end

# ╔═╡ 8633d549-78e6-403a-96e6-ea0933743a2e
function least_edgy(E)
	least_E = zeros(size(E))
	dirs = zeros(Int, size(E))
	least_E[end, :] .= E[end, :] # the minimum energy on the last row is the energy
	                             # itself

	m, n = size(E)
	# Go from the last row up, finding the minimum energy
	for i in m-1:-1:1
		for j in 1:n
			j1, j2 = max(1, j-1), min(j+1, n)
			e, dir = findmin(least_E[i+1, j1:j2])
			least_E[i,j] += e
			least_E[i,j] += E[i,j]
			dirs[i, j] = (-1,0,1)[dir + (j==1)]
		end
	end
	least_E, dirs
end

# ╔═╡ f15b4bf3-edca-4aef-99ec-3cf904edfd17
function get_seam_at(dirs, j)
	m = size(dirs, 1)
	js = fill(0, m)
	js[1] = j
	for i=2:m
		js[i] = js[i-1] + dirs[i-1, js[i-1]]
	end
	tuple.(1:m, js)
end

# ╔═╡ c31b6aaa-8c4f-40a7-a05b-05d39cb6ba76
function mark_path(img, path)
	img′ = copy(img)
	m = size(img, 2)
	for (i, j) in path
		# To make it easier to see, we'll color not just
		# the pixels of the seam, but also those adjacent to it
		for j′ in j-1:j+1
			img′[i, clamp(j′, 1, m)] = RGB(1,0,1)
		end
	end
	img′
end

# ╔═╡ ed8860a2-9ffc-4b6c-a256-e0b683a1d9eb
function pencil(X)
	f(x) = RGB(1-x,1-x,1-x)
	map(f, X ./ maximum(X))
end

# ╔═╡ e058f45a-708a-4c4c-80b3-627930ea93d3
function rm_path(img, path)
	img′ = img[:, 1:end-1] # one less column
	for (i, j) in path
		img′[i, 1:j-1] .= img[i, 1:j-1]
		img′[i, j:end] .= img[i, j+1:end]
	end
	img′
end

# ╔═╡ c5356622-b6c6-47d6-a678-33ca215a2edd
brightness(c::AbstractRGB) = 0.3 * c.r + 0.59 * c.g + 0.11 * c.b

# ╔═╡ 4b6286fe-4dce-4d55-a3b4-3197399f082e
function edgeness(img)
	Sy, Sx = Kernel.sobel()
	b = brightness.(img)

	∇y = convolve(b, Sy)
	∇x = convolve(b, Sx)

	sqrt.(∇x.^2 + ∇y.^2)
end

# ╔═╡ e130968f-bab9-4373-bcbd-c1499ec6043d
function shrink_n(img, n)
	imgs = []
	marked_imgs = []

	e = edgeness(img)
	for i=1:n
		least_E, dirs = least_edgy(e)
		_, min_j = findmin(@view least_E[1, :])
		seam = get_seam_at(dirs, min_j)
		img = rm_path(img, seam)
		# Recompute the energy for the new image
		# Note, this currently involves rerunning the convolution
		# on the whole image, but in principle the only values that
		# need recomputation are those adjacent to the seam, so there
		# is room for a meanintful speedup here.
#		e = edgeness(img)
		e = rm_path(e, seam)

 		push!(imgs, img)
 		push!(marked_imgs, mark_path(img, seam))
	end
	imgs, marked_imgs
end

# ╔═╡ 28e22d44-f54e-41a1-a72b-12bb164ee6c0
function hbox(x, y, gap=16; sy=size(y), sx=size(x))
	w,h = (max(sx[1], sy[1]),
		   gap + sx[2] + sy[2])
	
	slate = fill(RGB(1,1,1), w,h)
	slate[1:size(x,1), 1:size(x,2)] .= RGB.(x)
	slate[1:size(y,1), size(x,2) + gap .+ (1:size(y,2))] .= RGB.(y)
	slate
end

# ╔═╡ 6508fe70-82ca-49b0-b209-ce0333e52d53


# ╔═╡ 1a09214b-6c8c-4d5c-982d-4d1714719be5
md"""
# Seam Carving
1. We use convolution with Sobel filters for "edge detection".
2. We use that to write an algorithm that removes "uninteresting"
   bits of an image in order to shrink it.
"""

# ╔═╡ 211b28eb-7887-491e-a1b7-4d66c4eba327
img = load("C:\\Users\\Ksenia\\!ComputationalThinkingMIT\\ImgData\\test_dog_img.jpg")

# ╔═╡ 93fabe81-1e49-45a6-b47b-579a91987bfc
least_e, dirs = least_edgy(edgeness(img))

# ╔═╡ d2a280a3-47b2-42cb-b0bd-a2b1cef4c042
reduce((x,y)->x*y*"\n",
	reduce(*, getindex.(([" ", "↙", "↓", "↘"],), dirs[1:25, 1:60].+3), dims=2, init=""), init="") |> Text

# ╔═╡ 9b715ee2-1085-4e6e-9be0-b8c714c0f899
@bind start_column Slider(1:size(img, 2))

# ╔═╡ f5c52a9e-1eb3-43d1-8531-01e0f9e2aceb
path = get_seam_at(dirs, start_column)

# ╔═╡ 6bc2c558-c3dd-4e42-ac77-5728d4805c4f
e = edgeness(img);

# ╔═╡ 2201437b-1955-4016-a86c-977801f5bf90
n_examples = min(200, size(img, 2))

# ╔═╡ 19eb81a6-eb5a-4182-a7d8-74d46dbb167f
carved, marked_carved = shrink_n(img, n_examples)

# ╔═╡ 53ac8a9b-e30f-4ee7-907e-26f0a0311493
# @bind n Slider(1:length(carved))

# ╔═╡ b290fa19-9b6d-45dc-ae3a-2bc096d104e7
@bind n Slider(108:length(carved))


# ╔═╡ 807c2ef0-095f-4de3-a00b-c90a54d29554
begin
	hbox(img, marked_carved[n], sy=size(img))
end

# ╔═╡ ebc39b3b-c6bf-491a-bbe0-c7f1a8a23547
begin
	img_brightness = brightness.(img)
	∇x = convolve(img_brightness, Sx)
	∇y = convolve(img_brightness, Sy)
	hbox(show_colored_array(∇x), show_colored_array(∇y))
end

# ╔═╡ 0341ee91-0722-4ac1-a599-09cebbdb1681
begin
	edged = edgeness(img)
	# hbox(img, pencil(edged))
	hbox(img, Gray.(edgeness(img)) / maximum(abs.(edged)))
end

# ╔═╡ 7c43e3a7-86da-440c-b45b-adbc11724fd1
hbox(mark_path(img, path), mark_path(show_colored_array(least_e), path))

# ╔═╡ 6972ec22-cf01-42ee-82f7-208c92233df6
let
	hbox(mark_path(img, path), mark_path(pencil(e), path));
end

# ╔═╡ 2d40eae6-4ce9-4ca1-9e1c-6bf486cc7588
let
	# least energy path of them all:
	_, k = findmin(least_e[1, :])
	path = get_seam_at(dirs, k)
	hbox(
		mark_path(img, path),
		mark_path(show_colored_array(least_e), path)
	)
end

# ╔═╡ 705d9dfc-bd68-465a-93ad-e14843444180
hbox(img, marked_carved[n], sy=size(img))

# ╔═╡ c56b8fc0-ebb6-4106-b36f-cee5296f8022
vbox(x,y, gap=16) = hbox(x', y')'

# ╔═╡ 1fde4b23-377e-4fd6-8f72-a77024c9777f
let
	∇y = convolve(brightness.(img), Sy)
	∇x = convolve(brightness.(img), Sx)
	# zoom in on the clock
	vbox(
		hbox(img[300:end, 1:300], img[300:end, 1:300]), 
	 	hbox(show_colored_array.((∇x[300:end,  1:300], ∇y[300:end, 1:300]))...)
	)
end

# ╔═╡ b89c9220-7dd2-4fab-83c6-6fe20d1b6e57
[size(img) size(carved[n])]

# ╔═╡ 50da1e71-e675-47d0-947b-2349431ba4a2


# ╔═╡ Cell order:
# ╠═c6dc2da7-f65e-4e80-a7d8-70632771b260
# ╠═df9e872a-59d4-4b0c-938b-1e5534459a60
# ╟─e76fe107-967d-4ea6-a88e-db0e6fbee0aa
# ╠═36b08d61-06b4-42ae-82ec-2db97892b540
# ╠═7f75459b-888d-4350-be34-de447d229fa5
# ╟─eb5c03b2-8ec4-45a9-b601-44ff8a58c2a1
# ╠═9166f3da-eb75-446d-94fb-3f39873668b7
# ╠═f9da4a55-6813-4d65-a9a9-5caba6e45643
# ╟─a904111a-3a42-4193-a50f-bd08e5968f19
# ╟─4b6286fe-4dce-4d55-a3b4-3197399f082e
# ╟─03dd2977-2b7f-42f8-805a-7118e1a0756f
# ╟─8633d549-78e6-403a-96e6-ea0933743a2e
# ╟─f15b4bf3-edca-4aef-99ec-3cf904edfd17
# ╟─c31b6aaa-8c4f-40a7-a05b-05d39cb6ba76
# ╟─ed8860a2-9ffc-4b6c-a256-e0b683a1d9eb
# ╟─e058f45a-708a-4c4c-80b3-627930ea93d3
# ╟─e130968f-bab9-4373-bcbd-c1499ec6043d
# ╟─c5356622-b6c6-47d6-a678-33ca215a2edd
# ╟─28e22d44-f54e-41a1-a72b-12bb164ee6c0
# ╠═6508fe70-82ca-49b0-b209-ce0333e52d53
# ╟─1a09214b-6c8c-4d5c-982d-4d1714719be5
# ╠═211b28eb-7887-491e-a1b7-4d66c4eba327
# ╠═93fabe81-1e49-45a6-b47b-579a91987bfc
# ╠═d2a280a3-47b2-42cb-b0bd-a2b1cef4c042
# ╠═9b715ee2-1085-4e6e-9be0-b8c714c0f899
# ╠═f5c52a9e-1eb3-43d1-8531-01e0f9e2aceb
# ╠═6bc2c558-c3dd-4e42-ac77-5728d4805c4f
# ╠═2201437b-1955-4016-a86c-977801f5bf90
# ╠═19eb81a6-eb5a-4182-a7d8-74d46dbb167f
# ╠═53ac8a9b-e30f-4ee7-907e-26f0a0311493
# ╠═b290fa19-9b6d-45dc-ae3a-2bc096d104e7
# ╠═807c2ef0-095f-4de3-a00b-c90a54d29554
# ╠═ebc39b3b-c6bf-491a-bbe0-c7f1a8a23547
# ╠═0341ee91-0722-4ac1-a599-09cebbdb1681
# ╠═7c43e3a7-86da-440c-b45b-adbc11724fd1
# ╠═6972ec22-cf01-42ee-82f7-208c92233df6
# ╠═2d40eae6-4ce9-4ca1-9e1c-6bf486cc7588
# ╠═705d9dfc-bd68-465a-93ad-e14843444180
# ╠═c56b8fc0-ebb6-4106-b36f-cee5296f8022
# ╠═1fde4b23-377e-4fd6-8f72-a77024c9777f
# ╠═b89c9220-7dd2-4fab-83c6-6fe20d1b6e57
# ╠═50da1e71-e675-47d0-947b-2349431ba4a2
