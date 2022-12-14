### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ e73b05fe-e0e9-44b0-94be-5b8dfb95020c
using Rasters, Plots, DataFrames, RasterDataSources,Shapefile, Downloads, GeoInterface, Dates, Statistics

# ╔═╡ 7e37d7d6-8d0b-11ed-0b52-0d441581efc3
md"# Rasters.jl: an overview"

# ╔═╡ 510daae7-583b-4147-bd28-b6ee80c02bfa
md"A high-level package for working with GDAL files like GeoTIFF, multidimensional NetCDF, and other geospatial rasterss in a generalised, consistent way.

Rasters is built on other geospatial tools, and owes most to DimensionalData.jl, ArchGDAL.jl, NCDatasets.jl, GeoInterface.jl, DiskArrays.jl, PolygonInbounds.jl, and RasterDataSources.jl.
"

# ╔═╡ a9d8695f-594c-4b2f-9c28-13de91315c11
md"*Set this environment variable here, or preferably in you startup.jl file*"

# ╔═╡ d866391b-875e-44f3-bfc4-4be683f969bb
#ENV["RASTERDATASOURCES_PATH"] = "." # Or use a better path in your system

# ╔═╡ 096d8e7d-7cad-4104-993e-6846c66fbc10
plot(RasterStack(WorldClim{BioClim}, (5, 7, 8, 12))) # Warm up all the packages

# ╔═╡ e10aa610-3729-4794-9e02-d8b7e3bc9e33
md"## Loading files as Raster and RasterStack"

# ╔═╡ a1ea960b-d028-4ff5-bd53-02beea08731f
md"*First lets load a single file with* `Raster`. *We'll use RasterDataSources.jl to download something generic*"

# ╔═╡ 02022644-8059-4ff3-a1d0-ee23b8be9c77
bio5_path = RasterDataSources.getraster(WorldClim{BioClim}, 5)

# ╔═╡ 32de662d-5302-477d-81bd-ad2686e23a95
bio5_raster = Raster(bio5_path)

# ╔═╡ 25689a92-da13-432d-96df-93fc2ecfe5ac
plot(bio5_raster)

# ╔═╡ 86ba527c-43d2-400d-9b38-887ba42ccd0e
md"*Now lets load multiple files as with shared dimensions as a* `RasterStack`"

# ╔═╡ 52633439-4781-461a-866b-4179a231e08c
bioclim_paths = RasterDataSources.getraster(WorldClim{BioClim}, (5, 7, 8, 12))

# ╔═╡ 34dd6242-f4f2-45ea-b5dd-2a90150f3e5a
bioclim_stack = RasterStack(bioclim_paths)

# ╔═╡ af3e2aca-339c-47e0-9678-821cd9cd68cf
plot(bioclim_stack)

# ╔═╡ b9929e9d-e554-4fbc-94a7-85f1fe5e89c5
md"*Rasters.jl has a shorthand syntax for getting files with RasterDataSources.jl: we can just use the* `getraster` *arguments and keywords directly in* `Raster` *or* `RasterStack`."

# ╔═╡ 2e3ff278-990a-49b7-a739-c799b9111bb0
RasterStack(WorldClim{BioClim}, (5, 7, 8, 12))

# ╔═╡ 6464df4a-ce8a-4dae-ac56-1eb524237979
md"""
## Dimensions wrappers and Selectors

Dimension wrappers (from DimensionalData.jl) let us refer to the axis of an array by name. They usually hold some data related to it - a lookup array or values to index into it with. We use them to match some metadata or instructions with the axes of the array.
"""

# ╔═╡ 556913d0-3911-4d15-89c9-810a5daeafbe
md"*We can select regions using IntervalSets.jl `..` elipses inside dimension wrappers. Here we select madagascar*"

# ╔═╡ 7a0fdd14-7113-4d00-9c3d-2cf0f3ef882a
madagascar_bioclim = bioclim_stack[X(42 .. 51), Y(-27 .. -11)]

# ╔═╡ 45043d71-117a-4ae7-b927-4e24a88cfd23
plot(madagascar_bioclim)

# ╔═╡ 3ce85175-bbc4-435a-94e5-949f4b015fac
md"*Here* `X` *holds a `ClosedInterval` from IntervalSets.jl.*"

# ╔═╡ 659c9701-4246-4d43-8655-739767b76dc7
X(1 .. 10) |> typeof

# ╔═╡ 79934755-b312-4355-9fde-44bf85dac5a8
md"*Lets look at dimensions in the* `Raster`"

# ╔═╡ 0219a0d4-5f2c-4147-8fe4-80ef98c69390
dims(madagascar_bioclim, X)

# ╔═╡ c9a73384-db89-4784-a7c1-8f06f0c4d5fa
md"*The* `X` *dimension attached to the* `RasterStack` *holds a* `Projected` *lookup array. That just means a regular* `AbstractVector` *of values that correspond to each index of of the corresponding axis the array, with known coordinate reference system*"

# ╔═╡ 37066e8c-101f-4808-bf8a-a3f518347bf5
dims(madagascar_bioclim, X) |> typeof

# ╔═╡ bc30b2ee-c355-4a40-a183-d546acbc3777
md"## Rasters are just Arrays"

# ╔═╡ f2744f32-c17f-4090-bee4-c5da175552a5
md"*Lets look at the type hierarchy of a raster*"

# ╔═╡ 97becbfd-d674-463b-99d6-5ae873f3b487
rainfall = Raster(WorldClim{Climate}, :prec; month=Jan)

# ╔═╡ 2c65f474-2fdf-408e-a886-f83fe70c8eb1
supertype(typeof(rainfall))

# ╔═╡ 3c622226-8a0e-48de-96d8-ed7c4b3ec408
supertype(supertype(typeof(rainfall)))

# ╔═╡ c50d5d91-6564-4886-927f-f57c910644db
supertype(supertype(supertype(typeof(rainfall))))

# ╔═╡ e3b8852a-d27f-44ae-b788-67cd83aa9ad4
md"*Lets look at the parent array this `Raster` wraps*"

# ╔═╡ 9c50e332-913d-45ba-8d5a-d663b205a728
parent(rainfall)

# ╔═╡ 14e6d6e6-722e-4549-9abd-4210ce8a86e9
md"*We can do most basic array operations with a raster*"

# ╔═╡ 4c46b98e-f65a-423a-a385-7d5424afba73
maximum(skipmissing(rainfall))

# ╔═╡ 16e43dc7-4792-4785-bf48-31a47a055d56
md"*Often we want to replace the missing values with* `missing` *first (this will be automatid soon)*"

# ╔═╡ 4ff2b54f-5eee-49fb-94a8-f3dd4425e6a9
rainfall1 = replace_missing(rainfall)

# ╔═╡ df585a97-e2e6-4779-ac74-7e83c464b7ab
md"*Then we can just apply julia broadcasts or most other* `AbstractArray` *operations freely - like converting this rainfall to meters with a broadcast:*"

# ╔═╡ 3c9a4647-83a1-4fdc-b6b0-3756d7e68f3c
rainfall_in_meters = rainfall1 .* 0.001

# ╔═╡ ac1a751c-2469-469f-b218-806730068873
maximum(skipmissing(rainfall_in_meters))

# ╔═╡ c554679c-7264-4bf9-aeef-77689c9710bc
mean(skipmissing(rainfall_in_meters))

# ╔═╡ ec2158bd-9c3c-4f0d-adc9-91aa996163cc
md"""
## Metadata tracking

As well as being arrays, Rasters have additional metadata, like a name, dimension wrappers, lookups, and crs.

These are maintained through most operations - a `Raster` tries very hard to continue being a `Raster` even after passing through external methods in Base and other packages.
"""

# ╔═╡ 705db144-a41f-4cfe-aba3-43d1dc04a051
md"*Rasters have DimensionalData.jl dimension metadata*"

# ╔═╡ dc5b9ee6-700c-426e-b941-d717343c106c
dims(rainfall)		

# ╔═╡ f7b0660c-02a3-4921-9ec8-e923a52c74e2
md"*Dimension metadata will survive through any arbitrary broadcast*"

# ╔═╡ c65922a1-0628-4c89-b910-10fb6a523173
dims(rainfall .* 10)

# ╔═╡ a866ebee-1cdc-496d-98af-3a9df0faa5e8
md"*A known `missingval` (we do not always want to replace this with* `missing`*)*" 

# ╔═╡ 298e01ae-2ae5-4dcd-b7f9-f7d8254cae7d
missingval(rainfall)

# ╔═╡ 5d1a94cb-5e5d-4c80-a081-f07946bd08b3
md"*And often a coordinate reference system*"

# ╔═╡ 8a33ee9c-65ab-4339-a2b8-abf21770b906
crs(rainfall)

# ╔═╡ 94cb332b-7c96-4647-9043-f28da3199048
md"*Lets try and break it*"

# ╔═╡ 78bf364a-1373-47ff-9537-16d8ba73bd81
messed_up_raster = rotl90(permutedims(rainfall[Band(1)]))

# ╔═╡ e52ad1c3-a94a-4cda-9db5-db84e010e5c7
plot(messed_up_raster)

# ╔═╡ 0e07b190-40b0-4b62-b28e-e1ccb79a2403
md"*If we plot the* `parent` *array*"

# ╔═╡ 81f5c481-1816-4802-b7d0-4178764a7c22
heatmap(parent(messed_up_raster))

# ╔═╡ c46115f7-f08f-4479-9491-5c19b3c896b2
write("messed_up_raster.nc", messed_up_raster)

# ╔═╡ e7f1d47c-2892-4df7-aca2-b4e5537f96dc
messed_up_raster2 = Raster("messed_up_raster.nc")

# ╔═╡ 4bae9571-69f0-4640-9539-82c34581bfda
plot(messed_up_raster2)

# ╔═╡ 84abd843-1ad7-4163-bd31-640e9e8d2cad
md"""
### Lazyness

When rasters are loaded with* `lazy=true`*, data wont be in memory until you need it - so you can easily work with larger-than-memory data.
"""

# ╔═╡ 4774917d-4d33-42ea-b378-2816b82bcce8
shrubs_lazy_raster = Raster(EarthEnv{LandCover}, :shrubs; lazy=true)

# ╔═╡ 08af4c71-c48d-4d67-aa49-f63a5391d93e
md"*Lets check the parent array type:*"

# ╔═╡ 04b73298-72b3-4625-86fc-f5c6ca716ba7
typeof(parent(shrubs_lazy_raster))

# ╔═╡ 89790228-19c5-4e7e-a622-8bec6ccfa338
broadcasted_lazy_raster = replace_missing(shrubs_lazy_raster) .* 0.01

# ╔═╡ 932e1ed3-ae59-45b8-aee8-e5aa7d835363
typeof(parent(broadcasted_lazy_raster))

# ╔═╡ 1a5488b8-ebfd-4661-9166-40a0f8b24bbe
md"*How big would this file be in memory??*"

# ╔═╡ 5d0138b0-0fbf-4df2-a6e1-799dca2e0568
prod(size(shrubs_lazy_raster)) * sizeof(Float64) / 1e9

# ╔═╡ d9f2f975-74ba-4cd1-950f-d9949fca1738
md"Lets plot it"

# ╔═╡ fcce0626-bfdf-4b3d-b424-54151ded69a0
plot(broadcasted_lazy_raster; max_res=500)

# ╔═╡ 75927183-96e8-4931-bf79-9161a0711643
md"## Working with larger than memory data"

# ╔═╡ 2c52edd1-eff7-4338-bae8-e376d30bf6d1
landcover = RasterStack(EarthEnv{LandCover}; lazy=true)

# ╔═╡ d3362b4d-4fac-4d9b-9d2b-b885a664719f
md"*How many GB of memory will these landcover files take as Float64?*"

# ╔═╡ 85c71d74-6865-48e8-b9e0-83d590e08113
prod(size(landcover[:barren])) * length(landcover) * sizeof(Float64) / 1e9

# ╔═╡ 8ac1096e-008d-4f07-a5c6-7a72a0bddf50
md"*Lets convert to `Float64` to see what happens!* 

*When we use* `map` *or* `iterate` *over a* `RasterStack` *we are iterating over its* `Raster` *layers. Here we* `map` *over the stack and then broadcast the* `Float64` *constructor over each layer.*"

# ╔═╡ c2df1841-1951-470d-9741-63899a97eb13
float64_landcover = map(rast -> Float64.(rast), landcover)

# ╔═╡ 5c63e1cc-6585-495a-b481-93b5d59cf5ac
md"""
Seems fine?

These files are not actually in memory yet, and havent been converted to Float64 - because broadcasts with DiskArrays.jl are also lazy.

They not even open yet - the inner `FileArray` still just holds a `String`. This means we can work like this with thousands of files without hitting the operating systems open file limit.
"""

# ╔═╡ 76af6839-f9de-4684-9f3a-077041dda4a1
md"*Now select and plot some smaller region*"

# ╔═╡ 0771874c-a5ed-4223-889c-d624cd427619
terciera_selectors = X(-27.4 .. -27), Y(38.6 .. 38.9)

# ╔═╡ 254f14dd-b7b7-4224-a380-707f3c305f92
terciera_landcover = view(float64_landcover, terciera_selectors...)

# ╔═╡ 32eb1de6-c049-4735-9099-8d6a2f2c8a7b
plot(terciera_landcover; size=(1200, 500))

# ╔═╡ aa13b7b3-a56a-4801-872d-73fd7a7a5b70
md"*Only the chunks of data for this region have been read and converted to* `Float64`"

# ╔═╡ bd699aef-6bbd-43ac-9978-2269495aeea9
md"## Tables.jl integration"

# ╔═╡ cd3f8c3c-57bf-4211-97cd-a3887ab6fdab
DataFrame(madagascar_bioclim)

# ╔═╡ 8e7dbe82-07ba-41fd-95b1-d79a4232ce46
md"Lets get that with more sensible missing values, using `replace_missing`"

# ╔═╡ ac4d2ef2-5679-4fd7-beba-907f786ad6ca
biodf = DataFrame(replace_missing(madagascar_bioclim))

# ╔═╡ e35747da-c4fb-4387-b51a-9a766bb34a4a
filter(x -> !ismissing(x.bio7), biodf)

# ╔═╡ ef6037bd-fd44-421b-a5cb-8c2df15199be
md"## Rasterization of GeoInterface.jl compatible geometries"

# ╔═╡ 7a9272d8-0b86-458c-b356-2d796b5ecc43
md"*First get some country border data*"

# ╔═╡ 155a0673-3af6-498b-b055-c4a4803b660e
begin
	# Download the shapefile
	shapefile_url = "https://github.com/nvkelso/natural-earth-vector/raw/master/10m_cultural/ne_10m_admin_0_countries.shp"
	shapefile_name = "country_borders.shp"
	isfile(shapefile_name) || Downloads.download(shapefile_url, shapefile_name)
end

# ╔═╡ 468c973a-ed57-4d00-97cc-bed70fc27dff
borders = Shapefile.Table(shapefile_name) |> DataFrame

# ╔═╡ a63aefe6-a527-475e-9ba2-46d7bedea7f7
indonesia_border = filter(x -> x.SOV_A3 == "IDN", borders).geometry[1]

# ╔═╡ bc6495e9-5d25-48c9-98f1-36752e520424
md"*Rasterize the border polygon*"

# ╔═╡ dedc696a-f30d-4697-97af-9eb570a96834
indonesia = rasterize(indonesia_border; res=0.1, missingval=0, fill=1, boundary=:touches)

# ╔═╡ 58e1fbdb-1054-4f3c-8584-f85f96736506
md"*And plot*"

# ╔═╡ 30afe939-ab9c-4da5-bb0b-3bdaccdaf420
p = plot(indonesia; color=:spring)

# ╔═╡ ddb66e26-4458-4bb6-a53b-a577eafc9a10
plot!(p, indonesia_border; fillalpha=0, linewidth=0.6)

# ╔═╡ daea5e31-8638-43ed-9dcf-593c1e9a3afa
md"## Masking, cropping and mosaic"

# ╔═╡ 9b0e22db-98a4-4e85-b904-407c1a1d2998
md"""
*Lets* `mask` *scandinavia from the global dataset using their border polygons, then trim the missing values.*
"""

# ╔═╡ 6a6f648b-dd04-4a4e-8e6a-bfdeac550538
md"*First get the borders*"

# ╔═╡ a573ebdd-2160-44d8-8efc-724315c8a548
begin
	denmark_border = filter(x -> x.ISO_A3_EH == "DNK", borders).geometry[1]
	sweden_border = filter(x -> x.ISO_A3_EH == "SWE", borders).geometry[1]
	norway_border = filter(x -> x.ISO_A3_EH == "NOR", borders).geometry[1]
end

# ╔═╡ b74895b4-cce1-4767-8897-6f31b0cac0aa
climate = RasterStack(WorldClim{Climate}, (:tmin, :tmax, :prec, :wind); month=Jan)[Band(1)]

# ╔═╡ da854aed-1f5e-4e99-b160-eaec74ab155e
plot(climate)

# ╔═╡ d868b861-8886-43d9-89b3-fa8cee0bb621
plot(climate.tmin[X(0..150), Y(25..75)]; size=(2000, 1000))

# ╔═╡ 9a7a9d6e-e374-4e36-98cd-2c20e60c167d
savefig("climate.png")

# ╔═╡ 46420e87-5991-495d-8dcc-1356ea0e6461
denmark_climate = mask(climate; with=denmark_border)

# ╔═╡ 040f7fdc-10db-4f1f-ab1b-ef2b68ba361f
plot(denmark_climate)

# ╔═╡ 6615194e-6db0-4e98-8b04-e415c799b8a5
md"It seems that Denmark is very small! Lets trim all the whitespace so we can see it"

# ╔═╡ 2ec46814-86d1-431d-b06c-c78a1ee75bb6
trim(denmark_climate) |> plot

# ╔═╡ 7676af8d-432e-4f03-8b4a-27179c516afb
md"*Lets make a funcion to apply this to all the borders, and add a little padding around the outside*"

# ╔═╡ 03a76017-7346-4837-8d42-4a3736cfc237
mask_trim(climate, poly) = trim(mask(climate; with=poly); pad=10)

# ╔═╡ b3ea89e1-55bf-481c-95f5-efb185d6b08e
begin
	denmark = mask_trim(climate, denmark_border)
	sweden = mask_trim(climate, sweden_border)
	norway = mask_trim(climate, norway_border)
end

# ╔═╡ 1a5412c6-b0dd-4a6b-8788-b06c74033249
plot(norway)

# ╔═╡ cb05252c-0b22-41d1-8a82-9fcb3ca0d7de
md"*The Norway polygon includes some islands in the souther hemisphere. Lets select a smaller region from the raster first*"

# ╔═╡ b60371c5-3bce-4e56-9975-4e5812fd9f4f
norway_region = climate[X(0..40), Y(55..73)]

# ╔═╡ 6b7944d9-702b-4409-a80b-1c67fec186fc
norway1 = mask_trim(norway_region, norway_border)

# ╔═╡ 87239b3f-6175-4680-9a8d-6d048f9a77d5
plot(norway1)

# ╔═╡ 78378a2d-d04b-4d25-9815-1c914b154bef
md"*Better! now we can join them all into climate maps of scandinavia*"

# ╔═╡ 763d622a-7e02-4555-a88f-3460e42fc066
scandinavia_climate = mosaic(first, denmark, sweden, norway1)

# ╔═╡ ec1d7053-eb72-44bf-9523-8ceb4663e447
plot(scandinavia_climate)

# ╔═╡ a023219b-e7a5-4874-8bee-9e92dee7dfd4
md"*Now lets save this to a file. We can write directly as netcdf, or save as four tif files.*"

# ╔═╡ 3954edf8-5228-4490-8c27-d95a6d2de990
write("scandinavia.nc", scandinavia_climate)

# ╔═╡ da2ee38d-276e-4872-96de-95d96107e6b6
write("scandinavia.tif", scandinavia_climate)

# ╔═╡ 7ba44f6c-285c-4cca-9109-beadbe07c472
md"""
## Zonal statistics

Rasters.jl makes it easy to calculate zonal statistics from Raster or RasterStack and polygon regions.

The `zonal` function has been benchmarked at 7 - 10 times the performance of rasterio in Python.

To demonstrate `zonal`, we'll calculate some national-level climate statistics.
"""

# ╔═╡ 4851b6a0-e971-4d87-b038-9cc09f0c1b2b
md"*First lets download the rest of the natural earth dataset to go with the shapes*"

# ╔═╡ ef43781a-1c3c-4733-a94b-4b696c9b1474
dbf_url = "https://github.com/nvkelso/natural-earth-vector/raw/master/10m_cultural/ne_10m_admin_0_countries.dbf"

# ╔═╡ f109ba99-0ea0-4a70-945f-31bec830b6c0
dbf_name = "country_borders.dbf"

# ╔═╡ 4b3dde90-afdb-4ce1-8c79-3d3c53997ecc
isfile(dbf_name) || Downloads.download(dbf_url, dbf_name)

# ╔═╡ bebee726-5ec9-40c8-930c-9b24218a4d58
countries = Shapefile.Table(shapefile_name) |> DataFrame

# ╔═╡ faa16e37-9869-4f7e-8430-783e92765a9b
md"*Set the month we want to analyse climate for*"

# ╔═╡ 8a086cba-8fd4-4d54-b38a-1e7c39429bb7
month = Jan

# ╔═╡ ebe8f82e-06f3-4ca9-9b78-88fac466c89d
md"*Download and read a climate raster stack from WorldClim*"

# ╔═╡ 9ee7c76c-9449-4000-b7e9-88054c74a269
wc = RasterStack(WorldClim{Climate}; month, lazy=false)

# ╔═╡ 5b884821-1bfa-4c5b-8b3e-1687912cb1b7
plot(wc)

# ╔═╡ 00f007ae-bd4e-41d0-bbdc-1ac524dbe8fc
md"*Calculate the mean of all climate variables for all countries*"

# ╔═╡ 561f3fd3-de45-4b44-9b48-2105a3241415
climate_stats = zonal(mean, wc; of=countries, boundary=:touches) |> DataFrame

# ╔═╡ e75bd093-3735-4ca8-81f9-d5b3ca4dc4fe
md"*Add the country name column (aand fix some string errors in the table)*"

# ╔═╡ 05340750-8a53-44f1-a1df-661b559fd594
insertcols!(climate_stats, 1, :country => first.(split.(countries.ADMIN, r"[^A-Za-z ]")))

# ╔═╡ c5b68073-07c6-4b98-8ff3-9cb620fa129f
md"*Now lets find the coldest minumums and warmest maximums, by country*"

# ╔═╡ d276f8cf-3b52-4cb4-aa0d-d3be3070fe4a
coldest_mean_minimum = sort(climate_stats, :tmin)

# ╔═╡ 83deff26-545c-4369-acc9-075160bf8fd4
warmest_mean_maximum = sort(DataFrames.subset(climate_stats, :tmax => x -> .!(ismissing.(x) .| isnan.(x))), :tmax; rev=true)

# ╔═╡ 3361eb1d-7304-4197-b0f5-f0243a1d435c
md"""
## In progress...

- GRIB file reading for meteorology people
- Makie.jl plotting with zoom and lazy loading of large data
- Rasterization over many geometries using any custom reducing functions
- Polygonization of rasters
- ???

We are still in the phase where design changes are possible.
If there is anything you want to change or need, make a github issue - most reasonable requests will be implemented.

Great ideas with no github issue are unlikely to be implemented!!

Likewise for bugs or poor performance: *Always* report any problems as a github issue, with some simple code to demonstrate the problem.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
GeoInterface = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
RasterDataSources = "3cb90ccd-e1b6-4867-9617-4276c8b2ca36"
Rasters = "a3a2b9e3-a471-40c9-b274-f788e487c689"
Shapefile = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"

[compat]
DataFrames = "~1.4.4"
Downloads = "~1.6.0"
GeoInterface = "~1.0.1"
Plots = "~1.38.1"
RasterDataSources = "~0.5.5"
Rasters = "~0.5.0"
Shapefile = "~0.8.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "4acb8bfc5ccf6299c747e2da2179bcc8caf169ae"

[[deps.ASCIIrasters]]
git-tree-sha1 = "0cb0046798af8ac8561334c5a2a31f015e53c2b1"
uuid = "81770e7c-c736-4fa5-8129-46dd21831640"
version = "0.1.1"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArchGDAL]]
deps = ["CEnum", "ColorTypes", "Dates", "DiskArrays", "Extents", "GDAL", "GeoFormatTypes", "GeoInterface", "GeoInterfaceRecipes", "ImageCore", "Tables"]
git-tree-sha1 = "70908bb727c9a0ba863c5145aa48ee838cc29b84"
uuid = "c9ce4bd3-c3d5-55b8-8973-c0e20141b8c3"
version = "0.9.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "14c3f84a763848906ac681f94cf469a851601d92"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.28"

[[deps.Arrow_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Lz4_jll", "Pkg", "Thrift_jll", "Zlib_jll", "boost_jll", "snappy_jll"]
git-tree-sha1 = "d64cb60c0e6a138fbe5ea65bcbeea47813a9a700"
uuid = "8ce61222-c28f-5041-a97a-c2198fb817bf"
version = "10.0.0+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CFTime]]
deps = ["Dates", "Printf"]
git-tree-sha1 = "ed2e76c1c3c43fd9d0cb9248674620b29d71f2d1"
uuid = "179af706-886a-5703-950a-314cd64e0468"
version = "0.1.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBFTables]]
deps = ["Printf", "Tables", "WeakRefStrings"]
git-tree-sha1 = "f5b78d021b90307fb7170c4b013f350e6abe8fed"
uuid = "75c7ada1-017a-5fb6-b8c7-2125ff2d6c93"
version = "1.0.0"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d4f69885afa5e6149d0cab3818491565cf41446d"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DimensionalData]]
deps = ["Adapt", "ArrayInterfaceCore", "ConstructionBase", "Dates", "Extents", "IntervalSets", "IteratorInterfaceExtensions", "LinearAlgebra", "Random", "RecipesBase", "SparseArrays", "Statistics", "TableTraits", "Tables"]
git-tree-sha1 = "cd395bbd3b49cc666128e01f42652336a2607718"
uuid = "0703355e-b756-11e9-17c0-8b28908087d0"
version = "0.24.0"

[[deps.DiskArrays]]
deps = ["OffsetArrays"]
git-tree-sha1 = "27ebdcf03ca847fa484f28273db57de3c8514920"
uuid = "3c3547ce-8d99-4f5e-a174-61eb10b00ae3"
version = "0.3.8"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FieldMetadata]]
git-tree-sha1 = "c279c6eab9767a3f62685e5276c850512e0a1afd"
uuid = "bf96fef3-21d2-5d20-8afa-0e7d4c32a885"
version = "0.3.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "9a0472ec2f5409db243160a8b030f94c380167a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Flatten]]
deps = ["ConstructionBase", "FieldMetadata"]
git-tree-sha1 = "d3541c658c7e452fefba6c933c43842282cdfd3e"
uuid = "4c728ea3-d9ee-5c9a-9642-b6f7d7dc04fa"
version = "0.4.3"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GDAL]]
deps = ["CEnum", "GDAL_jll", "NetworkOptions", "PROJ_jll"]
git-tree-sha1 = "aa6f8ca2f7a0eb46f4d8353eb725c717de40da6e"
uuid = "add2ef01-049f-52c4-9ee2-e494f65e021a"
version = "1.5.1"

[[deps.GDAL_jll]]
deps = ["Arrow_jll", "Artifacts", "Expat_jll", "GEOS_jll", "HDF5_jll", "JLLWrappers", "LibCURL_jll", "LibPQ_jll", "Libdl", "Libtiff_jll", "NetCDF_jll", "OpenJpeg_jll", "PROJ_jll", "Pkg", "SQLite_jll", "Zlib_jll", "Zstd_jll", "libgeotiff_jll"]
git-tree-sha1 = "aa913bff49c25482fe3db2c357cb5f8127a6d2ba"
uuid = "a7073274-a066-55f0-b90d-d619367d196c"
version = "301.600.200+0"

[[deps.GEOS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f4c0cafb093b62d5a5d8447a9b2306555385c0d9"
uuid = "d604d12d-fa86-5845-992e-78dc15976526"
version = "3.11.0+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "387d2b8b3ca57b791633f0993b31d8cb43ea3292"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.3"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "5982b5e20f97bff955e9a2343a14da96a746cd8c"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.3+0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "434166198434a5c2fcc0a1a59d22c3b0ad460889"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.1"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeoInterfaceRecipes]]
deps = ["GeoInterface", "RecipesBase"]
git-tree-sha1 = "29e1ec25cfb6762f503a19495aec347acf867a9e"
uuid = "0329782f-3d07-4b52-b9f6-d3137cf03c7a"
version = "1.0.0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HDF5]]
deps = ["Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires", "UUIDs"]
git-tree-sha1 = "b5df7c3cab3a00c33c2e09c6bd23982a75e2fbb2"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.16.13"

[[deps.HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "4cc2bb72df6ff40b055295fdef6d92955f9dede8"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.2+2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "fd9861adba6b9ae4b42582032d0936d456c8602d"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.6.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "0cf92ec945125946352f3d46c96976ab972bde6f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "16c0cc91853084cb5f58a78bd209513900206ce6"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.4"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "82aec7a3dd64f4d9584659dc0b62ef7db2ef3e19"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.2.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.Kerberos_krb5_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "60274b4ab38e8d1248216fe6b6ace75ae09b0502"
uuid = "b39eb1a6-c29a-53d7-8c32-632cd16f18da"
version = "1.19.3+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibPQ_jll]]
deps = ["Artifacts", "JLLWrappers", "Kerberos_krb5_jll", "Libdl", "OpenSSL_jll", "Pkg"]
git-tree-sha1 = "a299629703a93d8efcefccfc16b18ad9a073d131"
uuid = "08be9ffa-1c94-5ee5-a977-46a84ec9b350"
version = "14.3.0+1"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg"]
git-tree-sha1 = "110897e7db2d6836be22c18bffd9422218ee6284"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.12.0+0"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NCDatasets]]
deps = ["CFTime", "DataStructures", "Dates", "NetCDF_jll", "NetworkOptions", "Printf"]
git-tree-sha1 = "bf3e94c52b7e00935131ae5edc1b45c745502332"
uuid = "85f8d34a-cbdd-5861-8df4-14fed0d494ab"
version = "0.12.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetCDF_jll]]
deps = ["Artifacts", "HDF5_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "072f8371f74c3b9e1b26679de7fbf059d45ea221"
uuid = "7243133f-43d8-5620-bbf4-c2c921802cf3"
version = "400.902.5+1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "76374b6e7f632c130e78100b166e5a48464256f8"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.4.0+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "df6830e37943c7aaa10023471ca47fb3065cc3c4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PROJ_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Libtiff_jll", "Pkg", "SQLite_jll"]
git-tree-sha1 = "fcb3f39ae1184a056ecc415863d46d2109aa6947"
uuid = "58948b4f-47e0-5654-a9ad-f609743f8632"
version = "900.100.0+0"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6466e524967496866901a78fca3f2e9ea445a559"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "5b7690dd212e026bbab1860016a6601cb077ab66"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.2"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "02ecc6a3427e7edfff1cebcf66c1f93dd77760ec"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.1"

[[deps.PolygonInbounds]]
git-tree-sha1 = "8d50c96f4ba5e1e2fd524116b4ef97b29d5f77da"
uuid = "e4521ec6-8c1d-418e-9da2-b3bc4ae105d6"
version = "0.2.0"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "96f6db03ab535bdb901300f88335257b0018689d"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RasterDataSources]]
deps = ["ASCIIrasters", "Dates", "DelimitedFiles", "HTTP", "JSON", "URIs", "ZipFile"]
git-tree-sha1 = "f660e7f9dfc027aaa8fa05ba277d5e2615513ea9"
uuid = "3cb90ccd-e1b6-4867-9617-4276c8b2ca36"
version = "0.5.5"

[[deps.Rasters]]
deps = ["Adapt", "ArchGDAL", "ColorTypes", "ConstructionBase", "CoordinateTransformations", "Dates", "DimensionalData", "DiskArrays", "Extents", "FillArrays", "Flatten", "GeoFormatTypes", "GeoInterface", "HDF5", "Missings", "Mmap", "NCDatasets", "PolygonInbounds", "ProgressMeter", "RasterDataSources", "RecipesBase", "Reexport", "Requires", "Setfield"]
git-tree-sha1 = "3b196779cc33c628e8a92eab306e05fef2eb868e"
uuid = "a3a2b9e3-a471-40c9-b274-f788e487c689"
version = "0.5.1"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "18c35ed630d7229c5584b945641a73ca83fb5213"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.2"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "2c761a91fb503e94bd0130fcf4352166c3c555bc"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.40.0+1"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Shapefile]]
deps = ["DBFTables", "Extents", "GeoFormatTypes", "GeoInterface", "GeoInterfaceRecipes", "RecipesBase", "Tables"]
git-tree-sha1 = "2f400236c85ba357dfdc2a56af80c939dc118f02"
uuid = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
version = "0.8.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "6954a456979f23d05085727adb17c4551c19ecd1"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.12"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Thrift_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "boost_jll"]
git-tree-sha1 = "fd7da49fae680c18aa59f421f0ba468e658a2d7a"
uuid = "e0b8ae26-5307-5830-91fd-398402328850"
version = "0.16.0+0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "e4bdc63f5c6d62e80eb1c0043fcc0360d5950ff7"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.10"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.boost_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7a89efe0137720ca82f99e8daa526d23120d0d37"
uuid = "28df3c45-c428-5900-9ff8-a3135698ca75"
version = "1.76.0+1"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libgeotiff_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "Libtiff_jll", "PROJ_jll", "Pkg"]
git-tree-sha1 = "13dfba87a1fe301c4b40f991d0ec990bbee59bbe"
uuid = "06c338fa-64ff-565b-ac2f-249532af990e"
version = "100.700.100+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.snappy_jll]]
deps = ["Artifacts", "JLLWrappers", "LZO_jll", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "985c1da710b0e43f7c52f037441021dfd0e3be14"
uuid = "fe1e1685-f7be-5f59-ac9f-4ca204017dfd"
version = "1.1.9+1"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─7e37d7d6-8d0b-11ed-0b52-0d441581efc3
# ╟─510daae7-583b-4147-bd28-b6ee80c02bfa
# ╠═e73b05fe-e0e9-44b0-94be-5b8dfb95020c
# ╟─a9d8695f-594c-4b2f-9c28-13de91315c11
# ╠═d866391b-875e-44f3-bfc4-4be683f969bb
# ╠═096d8e7d-7cad-4104-993e-6846c66fbc10
# ╟─e10aa610-3729-4794-9e02-d8b7e3bc9e33
# ╟─a1ea960b-d028-4ff5-bd53-02beea08731f
# ╠═02022644-8059-4ff3-a1d0-ee23b8be9c77
# ╠═32de662d-5302-477d-81bd-ad2686e23a95
# ╠═25689a92-da13-432d-96df-93fc2ecfe5ac
# ╟─86ba527c-43d2-400d-9b38-887ba42ccd0e
# ╠═52633439-4781-461a-866b-4179a231e08c
# ╠═34dd6242-f4f2-45ea-b5dd-2a90150f3e5a
# ╠═af3e2aca-339c-47e0-9678-821cd9cd68cf
# ╠═b9929e9d-e554-4fbc-94a7-85f1fe5e89c5
# ╠═2e3ff278-990a-49b7-a739-c799b9111bb0
# ╟─6464df4a-ce8a-4dae-ac56-1eb524237979
# ╟─556913d0-3911-4d15-89c9-810a5daeafbe
# ╠═7a0fdd14-7113-4d00-9c3d-2cf0f3ef882a
# ╠═45043d71-117a-4ae7-b927-4e24a88cfd23
# ╟─3ce85175-bbc4-435a-94e5-949f4b015fac
# ╠═659c9701-4246-4d43-8655-739767b76dc7
# ╟─79934755-b312-4355-9fde-44bf85dac5a8
# ╠═0219a0d4-5f2c-4147-8fe4-80ef98c69390
# ╟─c9a73384-db89-4784-a7c1-8f06f0c4d5fa
# ╠═37066e8c-101f-4808-bf8a-a3f518347bf5
# ╟─bc30b2ee-c355-4a40-a183-d546acbc3777
# ╟─f2744f32-c17f-4090-bee4-c5da175552a5
# ╠═97becbfd-d674-463b-99d6-5ae873f3b487
# ╠═2c65f474-2fdf-408e-a886-f83fe70c8eb1
# ╠═3c622226-8a0e-48de-96d8-ed7c4b3ec408
# ╠═c50d5d91-6564-4886-927f-f57c910644db
# ╟─e3b8852a-d27f-44ae-b788-67cd83aa9ad4
# ╠═9c50e332-913d-45ba-8d5a-d663b205a728
# ╟─14e6d6e6-722e-4549-9abd-4210ce8a86e9
# ╠═4c46b98e-f65a-423a-a385-7d5424afba73
# ╟─16e43dc7-4792-4785-bf48-31a47a055d56
# ╠═4ff2b54f-5eee-49fb-94a8-f3dd4425e6a9
# ╟─df585a97-e2e6-4779-ac74-7e83c464b7ab
# ╠═3c9a4647-83a1-4fdc-b6b0-3756d7e68f3c
# ╠═ac1a751c-2469-469f-b218-806730068873
# ╠═c554679c-7264-4bf9-aeef-77689c9710bc
# ╟─ec2158bd-9c3c-4f0d-adc9-91aa996163cc
# ╟─705db144-a41f-4cfe-aba3-43d1dc04a051
# ╠═dc5b9ee6-700c-426e-b941-d717343c106c
# ╟─f7b0660c-02a3-4921-9ec8-e923a52c74e2
# ╠═c65922a1-0628-4c89-b910-10fb6a523173
# ╟─a866ebee-1cdc-496d-98af-3a9df0faa5e8
# ╠═298e01ae-2ae5-4dcd-b7f9-f7d8254cae7d
# ╟─5d1a94cb-5e5d-4c80-a081-f07946bd08b3
# ╠═8a33ee9c-65ab-4339-a2b8-abf21770b906
# ╟─94cb332b-7c96-4647-9043-f28da3199048
# ╠═78bf364a-1373-47ff-9537-16d8ba73bd81
# ╠═e52ad1c3-a94a-4cda-9db5-db84e010e5c7
# ╟─0e07b190-40b0-4b62-b28e-e1ccb79a2403
# ╠═81f5c481-1816-4802-b7d0-4178764a7c22
# ╠═c46115f7-f08f-4479-9491-5c19b3c896b2
# ╠═e7f1d47c-2892-4df7-aca2-b4e5537f96dc
# ╠═4bae9571-69f0-4640-9539-82c34581bfda
# ╟─84abd843-1ad7-4163-bd31-640e9e8d2cad
# ╠═4774917d-4d33-42ea-b378-2816b82bcce8
# ╟─08af4c71-c48d-4d67-aa49-f63a5391d93e
# ╠═04b73298-72b3-4625-86fc-f5c6ca716ba7
# ╠═89790228-19c5-4e7e-a622-8bec6ccfa338
# ╠═932e1ed3-ae59-45b8-aee8-e5aa7d835363
# ╟─1a5488b8-ebfd-4661-9166-40a0f8b24bbe
# ╠═5d0138b0-0fbf-4df2-a6e1-799dca2e0568
# ╟─d9f2f975-74ba-4cd1-950f-d9949fca1738
# ╠═fcce0626-bfdf-4b3d-b424-54151ded69a0
# ╟─75927183-96e8-4931-bf79-9161a0711643
# ╠═2c52edd1-eff7-4338-bae8-e376d30bf6d1
# ╟─d3362b4d-4fac-4d9b-9d2b-b885a664719f
# ╠═85c71d74-6865-48e8-b9e0-83d590e08113
# ╟─8ac1096e-008d-4f07-a5c6-7a72a0bddf50
# ╠═c2df1841-1951-470d-9741-63899a97eb13
# ╟─5c63e1cc-6585-495a-b481-93b5d59cf5ac
# ╟─76af6839-f9de-4684-9f3a-077041dda4a1
# ╠═0771874c-a5ed-4223-889c-d624cd427619
# ╠═254f14dd-b7b7-4224-a380-707f3c305f92
# ╠═32eb1de6-c049-4735-9099-8d6a2f2c8a7b
# ╟─aa13b7b3-a56a-4801-872d-73fd7a7a5b70
# ╟─bd699aef-6bbd-43ac-9978-2269495aeea9
# ╠═cd3f8c3c-57bf-4211-97cd-a3887ab6fdab
# ╟─8e7dbe82-07ba-41fd-95b1-d79a4232ce46
# ╠═ac4d2ef2-5679-4fd7-beba-907f786ad6ca
# ╠═e35747da-c4fb-4387-b51a-9a766bb34a4a
# ╟─ef6037bd-fd44-421b-a5cb-8c2df15199be
# ╟─7a9272d8-0b86-458c-b356-2d796b5ecc43
# ╠═155a0673-3af6-498b-b055-c4a4803b660e
# ╠═468c973a-ed57-4d00-97cc-bed70fc27dff
# ╠═a63aefe6-a527-475e-9ba2-46d7bedea7f7
# ╟─bc6495e9-5d25-48c9-98f1-36752e520424
# ╠═dedc696a-f30d-4697-97af-9eb570a96834
# ╟─58e1fbdb-1054-4f3c-8584-f85f96736506
# ╠═30afe939-ab9c-4da5-bb0b-3bdaccdaf420
# ╠═ddb66e26-4458-4bb6-a53b-a577eafc9a10
# ╟─daea5e31-8638-43ed-9dcf-593c1e9a3afa
# ╟─9b0e22db-98a4-4e85-b904-407c1a1d2998
# ╟─6a6f648b-dd04-4a4e-8e6a-bfdeac550538
# ╠═a573ebdd-2160-44d8-8efc-724315c8a548
# ╠═b74895b4-cce1-4767-8897-6f31b0cac0aa
# ╠═da854aed-1f5e-4e99-b160-eaec74ab155e
# ╠═d868b861-8886-43d9-89b3-fa8cee0bb621
# ╠═9a7a9d6e-e374-4e36-98cd-2c20e60c167d
# ╠═46420e87-5991-495d-8dcc-1356ea0e6461
# ╠═040f7fdc-10db-4f1f-ab1b-ef2b68ba361f
# ╟─6615194e-6db0-4e98-8b04-e415c799b8a5
# ╠═2ec46814-86d1-431d-b06c-c78a1ee75bb6
# ╟─7676af8d-432e-4f03-8b4a-27179c516afb
# ╠═03a76017-7346-4837-8d42-4a3736cfc237
# ╠═b3ea89e1-55bf-481c-95f5-efb185d6b08e
# ╠═1a5412c6-b0dd-4a6b-8788-b06c74033249
# ╟─cb05252c-0b22-41d1-8a82-9fcb3ca0d7de
# ╠═b60371c5-3bce-4e56-9975-4e5812fd9f4f
# ╠═6b7944d9-702b-4409-a80b-1c67fec186fc
# ╠═87239b3f-6175-4680-9a8d-6d048f9a77d5
# ╟─78378a2d-d04b-4d25-9815-1c914b154bef
# ╠═763d622a-7e02-4555-a88f-3460e42fc066
# ╠═ec1d7053-eb72-44bf-9523-8ceb4663e447
# ╟─a023219b-e7a5-4874-8bee-9e92dee7dfd4
# ╠═3954edf8-5228-4490-8c27-d95a6d2de990
# ╠═da2ee38d-276e-4872-96de-95d96107e6b6
# ╟─7ba44f6c-285c-4cca-9109-beadbe07c472
# ╟─4851b6a0-e971-4d87-b038-9cc09f0c1b2b
# ╠═ef43781a-1c3c-4733-a94b-4b696c9b1474
# ╠═f109ba99-0ea0-4a70-945f-31bec830b6c0
# ╠═4b3dde90-afdb-4ce1-8c79-3d3c53997ecc
# ╠═bebee726-5ec9-40c8-930c-9b24218a4d58
# ╟─faa16e37-9869-4f7e-8430-783e92765a9b
# ╠═8a086cba-8fd4-4d54-b38a-1e7c39429bb7
# ╟─ebe8f82e-06f3-4ca9-9b78-88fac466c89d
# ╠═9ee7c76c-9449-4000-b7e9-88054c74a269
# ╠═5b884821-1bfa-4c5b-8b3e-1687912cb1b7
# ╟─00f007ae-bd4e-41d0-bbdc-1ac524dbe8fc
# ╠═561f3fd3-de45-4b44-9b48-2105a3241415
# ╟─e75bd093-3735-4ca8-81f9-d5b3ca4dc4fe
# ╠═05340750-8a53-44f1-a1df-661b559fd594
# ╟─c5b68073-07c6-4b98-8ff3-9cb620fa129f
# ╠═d276f8cf-3b52-4cb4-aa0d-d3be3070fe4a
# ╠═83deff26-545c-4369-acc9-075160bf8fd4
# ╠═3361eb1d-7304-4197-b0f5-f0243a1d435c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
