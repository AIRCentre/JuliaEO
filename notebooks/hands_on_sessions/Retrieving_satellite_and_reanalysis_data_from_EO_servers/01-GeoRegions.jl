### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 95fbaf62-8565-11ed-3e00-713b79517e68
begin
	using Pkg; Pkg.activate(".")
	using DelimitedFiles
	using DrWatson
	using GeoRegions
	using NCDatasets
	using CairoMakie
	md"Activating JuliaEO Project for work do be done on notebook ..."
end

# ╔═╡ 4c27d994-631c-492f-b337-a2398b6cf859
md"
# 01 - Using GeoRegions.jl
"

# ╔═╡ 56f922ce-2e9c-4a1a-aa27-7bac6089366e
begin
	crd = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
	cstlon = crd[:,1]
	cstlat = crd[:,2]
	md"Loading coastlines ..."
end

# ╔═╡ 928753db-c668-4dd9-ba9f-5cac0b74f876
md"
## A. Let's Define a Rectangular Region

In this very basic example, let us define a Rectangular GeoRegion.  An example is given below.

Once you have defined this `GeoRegion`, let us then plot the bounds using Makie
"

# ╔═╡ 5d649db5-6a17-416f-93ec-df0cb93c6132
geo1 = RectRegion(
	"TST", "GLB", "Test GeoRegion",
	[30,20,50,10], savegeo = false
)

# ╔═╡ 7819f20b-fc22-4df6-baab-558881b64281
# Add your custom RectRegion here!
# geo2 = RectRegion(

# )

# ╔═╡ b7387381-c82a-4f9e-b9f1-d074f08dcf3e
begin
	blon1,blat1 = coordGeoRegion(geo1)
	# blon2,blat2 = coordGeoRegion(geo2)
	md"Finding the coordinates of the RectRegion boundaries"
end

# ╔═╡ 7c663b5a-fd80-4a69-b47f-b1b2088e9718
begin
	f1 = Figure(resolution = (800, 400))
	ax1_1 = Axis(f1[1, 1], yticklabelcolor = :black)
	ax1_1.aspect = AxisAspect(2)
	lines!(ax1_1,cstlon,cstlat,color=:black)
	limits!(0, 360, -90, 90)

	lines!(ax1_1,blon1,blat1,linewidth=5)
	# lines!(ax1_1,blon2,blat2,linewidth=5)

	f1
end

# ╔═╡ b299b005-949e-4e38-9117-8522d92ee0a0
md"
## B. What about non-rectilinear GeoRegions?

In geographical analysis, many of the regions we would like to analyze are not rectilinear in longitude-latitude.  However, GeoRegions.jl allows for the definition of _**simple**_ (i.e. non self-intersecting) polygon regions
"

# ╔═╡ 956cee99-e06e-4f0a-98bb-5f647bd6dc6f
poly1 = PolyRegion(
	"PLY1", "GLB", "Test PolyRegion",
	[60.0, 60.0, 75.0, 88.0, 100.0, 100.0, 95.0, 87.0, 79.0, 76.0, 70.0, 66.5, 60.0],
	[23.5, 30.0, 30.0, 26.0, 30.0, 19.5, 19.5, 19.5, 7.0, 7.0, 19.5, 23.5, 23.5],
	savegeo = false
)

# ╔═╡ 61d8c36c-5fc6-425a-a77b-973bbe8554a6
# Add your custom PolyRegion here!
# poly2 = PolyRegion(
#
# 	savegeo = false
# )

# ╔═╡ 1ddfcfc8-0c1a-470a-9c3c-85bfb228ed64
begin
	bplon1,bplat1,splon1,splat1 = coordGeoRegion(poly1)
	# bplon2,bplat2,splon2,splat2 = coordGeoRegion(poly2)
	md"Finding the coordinates of the PolyRegion boundaries"
end

# ╔═╡ 32903230-614e-49a2-96b7-bfaf54fe5e67
begin
	f2 = Figure(resolution = (800, 400))
	ax2_1 = Axis(f2[1, 1], yticklabelcolor = :black)
	ax2_1.aspect = AxisAspect(2)
	lines!(ax2_1,cstlon,cstlat,color=:black)
	limits!(0, 360, -90, 90)

	lines!(ax2_1,splon1,splat1,linewidth=5)
	# lines!(ax2_1,splon2,splat2,linewidth=5)

	f2
end

# ╔═╡ 50a9a12b-5536-4837-a01d-b7d2e3ccc88e
md"
## C. Data Extraction

Now we know how to define GeoRegions, let us use GeoRegions.jl to extract gridded data.
"

# ╔═╡ c19cb21a-9cf3-49fd-afb1-02741173c859
begin
	ds  = NCDataset(datadir("emask-GLBx0.25.nc"))
	lon = ds["longitude"][:]
	lat = ds["latitude"][:]
	lsm = ds["lsm"][:]
	oro = nomissing(ds["z"][:],NaN)
	close(ds)
	md"First, we load the data ..."
end

# ╔═╡ aa791a42-db56-4d5c-99d3-086bffb3457f
begin
	f3 = Figure(resolution = (850, 400))
	ax3_1 = Axis(f3[1, 1], yticklabelcolor = :black)
	ax3_1.aspect = AxisAspect(2)
	co = contourf!(ax3_1,lon,lat,oro,extendlow = :auto, extendhigh = :auto)
	lines!(ax3_1,cstlon,cstlat,color=:black)
	limits!(0, 360, -90, 90)
	Colorbar(f3[1, 2], co) 
	
	resize_to_layout!(f3)

	f3
end

# ╔═╡ 35549ab0-4153-4310-a43a-4622b81645cd
grd1 = RegionGrid(poly1,lon,lat)

# ╔═╡ 7fe403e2-e5bb-43f0-9ba8-1aa1d3b49b7e
#Code here for PolyRegion2

# ╔═╡ 8b5a97ff-c5eb-4a6c-96dd-ae78f1c357fd
begin
	noro1 = grd1.mask .* extractGrid(oro,grd1)
	# noro2 = grd2.mask .* extractGrid(oro,grd2)
	md"Extracting orographic data for PolyRegion1 ..."
end

# ╔═╡ f3f112f7-613d-422a-bdcf-8816e0e5e4e2
begin
	f4 = Figure(resolution = (850, 400))
	ax4_1 = Axis(f4[1, 1], yticklabelcolor = :black)
	ax4_1.aspect = AxisAspect(2)
	co4 = contourf!(ax4_1,
		grd1.lon,grd1.lat,noro1,
		extendlow = :auto, extendhigh = :auto
	)
	lines!(ax4_1,cstlon,cstlat,color=:black)
	limits!(0, 360, -90, 90)
	Colorbar(f4[1, 2], co4) 
	
	resize_to_layout!(f4)
	
	lines!(ax4_1,splon1,splat1,linewidth=5)
	# lines!(ax4_1,splon2,splat2,linewidth=5)

	f4
end

# ╔═╡ 4c04e185-5d3c-426a-ae2e-07998e1539d4
md"
## D. Downloading ETOPO Topography (New!)
"

# ╔═╡ 5116c08a-5a45-4d64-90bf-f523cd1abb0a
tmpgeo = RectRegion(
	"ORO", "GLB", "Test getLandSea GeoRegion",
	[14,-14,149,91], savegeo = false
)

# ╔═╡ ccfb3127-24e6-4480-b495-2c3e116e4608
lsd = getLandSea(tmpgeo,resolution=60)

# ╔═╡ aa87165c-fd37-4b17-bb5c-08ffc305b717
begin
	f5 = Figure(resolution = (800, 400))
	ax5_1 = Axis(f5[1, 1], yticklabelcolor = :black)
	ax5_1.aspect = AxisAspect(2)
	co5 = contourf!(ax5_1,
		lsd.lon,lsd.lat,lsd.oro./1000, levels = vcat(-5:5),
		colormap = :delta,
		extendlow = :auto, extendhigh = :auto
	)
	lines!(ax5_1,cstlon,cstlat,color=:black)
	limits!(90, 150, -15, 15)
	Colorbar(f5[1, 2], co5) 

	f5
end

# ╔═╡ Cell order:
# ╟─4c27d994-631c-492f-b337-a2398b6cf859
# ╟─95fbaf62-8565-11ed-3e00-713b79517e68
# ╟─56f922ce-2e9c-4a1a-aa27-7bac6089366e
# ╟─928753db-c668-4dd9-ba9f-5cac0b74f876
# ╠═5d649db5-6a17-416f-93ec-df0cb93c6132
# ╠═7819f20b-fc22-4df6-baab-558881b64281
# ╠═b7387381-c82a-4f9e-b9f1-d074f08dcf3e
# ╠═7c663b5a-fd80-4a69-b47f-b1b2088e9718
# ╟─b299b005-949e-4e38-9117-8522d92ee0a0
# ╠═956cee99-e06e-4f0a-98bb-5f647bd6dc6f
# ╠═61d8c36c-5fc6-425a-a77b-973bbe8554a6
# ╠═1ddfcfc8-0c1a-470a-9c3c-85bfb228ed64
# ╟─32903230-614e-49a2-96b7-bfaf54fe5e67
# ╟─50a9a12b-5536-4837-a01d-b7d2e3ccc88e
# ╠═c19cb21a-9cf3-49fd-afb1-02741173c859
# ╟─aa791a42-db56-4d5c-99d3-086bffb3457f
# ╠═35549ab0-4153-4310-a43a-4622b81645cd
# ╠═7fe403e2-e5bb-43f0-9ba8-1aa1d3b49b7e
# ╠═8b5a97ff-c5eb-4a6c-96dd-ae78f1c357fd
# ╟─f3f112f7-613d-422a-bdcf-8816e0e5e4e2
# ╟─4c04e185-5d3c-426a-ae2e-07998e1539d4
# ╠═5116c08a-5a45-4d64-90bf-f523cd1abb0a
# ╟─ccfb3127-24e6-4480-b495-2c3e116e4608
# ╟─aa87165c-fd37-4b17-bb5c-08ffc305b717
