### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ 95fbaf62-8565-11ed-3e00-713b79517e68
begin
	using Pkg; Pkg.activate(".")
	using DelimitedFiles
	using DrWatson
	using NASAPrecipitation
	using NCDatasets
	using CairoMakie
	md"Activating JuliaEO Project for work do be done on notebook ..."
end

# ╔═╡ 4c27d994-631c-492f-b337-a2398b6cf859
md"
# 02 - Using NASAPrecipitation.jl
"

# ╔═╡ 56f922ce-2e9c-4a1a-aa27-7bac6089366e
begin
	crd = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
	cstlon = crd[:,1]
	cstlat = crd[:,2]
	md"Loading coastlines ..."
end

# ╔═╡ 42b7b4a7-ca4c-488a-9e96-c8d317244e1e
geo = GeoRegion("AR6_SEA")

# ╔═╡ 928753db-c668-4dd9-ba9f-5cac0b74f876
md"
## A. Define and Download a Dataset

To define and download a NASAPrecipitation dataset, we need to specify the kind of dataset (TRMM or IMERG, hourly or daily or monthly), the geographic region (GeoRegion) and the date.
"

# ╔═╡ 78f80039-22af-4d55-acf4-e7c781d364d6
npd = IMERGFinalDY(start=Date(2019,1,1),stop=Date(2019,1,1),path=datadir())

# ╔═╡ e5cdb42d-96fc-4d62-a1c1-587950e0f86f
download(npd,geo)

# ╔═╡ 10b65303-7e69-4ad0-bf25-81ebbf513c60
begin
	ds,lon,lat = read(npd,geo,Date(2019,1),lonlat=true)
	prcp = ds["precipitation"][:,:,15] * 86400
	close(ds)
end

# ╔═╡ db110895-23b0-4ac3-b938-14bfaa0187ce
begin
	f1 = Figure(resolution = (850, 400))
	ax1_1 = Axis(f1[1, 1], yticklabelcolor = :black)
	ax1_1.aspect = AxisAspect(62/29.5)
	limits!(geo.W-1,geo.E+1,geo.S-1,geo.N+1)
	co1 = heatmap!(ax1_1,
		lon,lat,prcp, colormap = :Blues,
		extendlow=:auto,extendhigh=:auto
	)
	lines!(ax1_1,cstlon,cstlat,color=:black)
	Colorbar(f1[1, 2], co1) 

	save("NASAPrecipitationExample.png",f1)
	f1
end

# ╔═╡ edb639f5-c51c-4ae1-b104-d77b25df2d8d
md"
## B. Extract Data for a Subregion
"

# ╔═╡ 4a13eb8b-736d-4d8c-ba86-9f6062119866
sgeo = PolyRegion(
	"TSTEXT", "GLB", "Test Extract NASAPrecipitation",
	[100,103,115,108,100,100],
	[-5,-6,-4,5,5,-5], savegeo=false
)

# ╔═╡ 4a89304d-5aaa-4125-935b-428dad202bff
extract(npd,sgeo,geo)

# ╔═╡ e68b55ff-22be-4a15-823e-ee1114e20573
begin
	rds,rlon,rlat = read(npd,sgeo,Date(2019,1),lonlat=true)
	rprcp = rds["precipitation"][:,:,15] * 86400
	close(rds)
end

# ╔═╡ 704af59e-8cde-49f4-b855-598f03b6c1a6
_,_,slon,slat = coordGeoRegion(sgeo)

# ╔═╡ e4f92972-5c68-4139-8604-c6facdbabb79
begin
	f2 = Figure(resolution = (850, 400))
	ax2_1 = Axis(f2[1, 1], yticklabelcolor = :black)
	ax2_1.aspect = AxisAspect(62/29.5)
	limits!(geo.W-1,geo.E+1,geo.S-1,geo.N+1)
	co2 = heatmap!(ax2_1,
		lon,lat,prcp, colormap = :Blues,
		extendlow=:auto,extendhigh=:auto
	)
	heatmap!(ax2_1,
		rlon,rlat,rprcp, colormap = :Reds,
		extendlow=:auto,extendhigh=:auto
	)
	lines!(ax2_1,cstlon,cstlat,color=:black)
	lines!(ax2_1,slon,slat,color=:red,linewidth=3)
	Colorbar(f2[1, 2], co2)
	
	save("extract.png",f2)
	f2
end

# ╔═╡ Cell order:
# ╟─4c27d994-631c-492f-b337-a2398b6cf859
# ╟─95fbaf62-8565-11ed-3e00-713b79517e68
# ╟─56f922ce-2e9c-4a1a-aa27-7bac6089366e
# ╠═42b7b4a7-ca4c-488a-9e96-c8d317244e1e
# ╟─928753db-c668-4dd9-ba9f-5cac0b74f876
# ╠═78f80039-22af-4d55-acf4-e7c781d364d6
# ╠═e5cdb42d-96fc-4d62-a1c1-587950e0f86f
# ╠═10b65303-7e69-4ad0-bf25-81ebbf513c60
# ╠═db110895-23b0-4ac3-b938-14bfaa0187ce
# ╟─edb639f5-c51c-4ae1-b104-d77b25df2d8d
# ╠═4a13eb8b-736d-4d8c-ba86-9f6062119866
# ╠═4a89304d-5aaa-4125-935b-428dad202bff
# ╟─e68b55ff-22be-4a15-823e-ee1114e20573
# ╟─704af59e-8cde-49f4-b855-598f03b6c1a6
# ╠═e4f92972-5c68-4139-8604-c6facdbabb79
