using Zarr, YAXArrays, Rasters, YAXArrayBase
using CairoMakie

s1cube = Cube("data/s1_hidalgo_ascending.zarr")

"""
dB(x)
Convert x into the logarithmic dB scale
"""
function dB(x)
    if ismissing(x)
        return missing
    elseif x <= 0
        return oftype(x,NaN)
    else
    10 * log10(x)
    end
end
#dB(x::AbstractArray) = dB.(x)

s1db = map(dB, s1cube)

using Shapefile, Extents
using TableOperations: TableOperations
using PlotUtils: optimize_ticks

"""
maskcube(cube, mask)
Select all pixels from cube which lay inside of the polygons in a Shapefile.Handle shp.
This assumes that mask and cube are two YAXArrays with the same spatial extent. 
This returns a cube with a `Sample` Axis. 
"""
function maskcube(cube, shp;rasterizekw...)
bbox = Extent((X=extrema(cube.lon), Y=extrema(cube.lat)))
res = step(cube.lon.values)
shpras = rasterize(shp; to=bbox, res=res, fill=:ID, rasterizekw...)
d = DimArray(shpras, metadata=Dict("shape" => shp))
m = yaxconvert(YAXArray, d)
renameaxis!(m, :X=>"lon")
renameaxis!(m, :Y=>"lat")
ctiterator = CubeTable(Sample=m)
#This should work for all subtables and the resulting cubes should be merge.
ct = ctiterator[1]
#    for ct in ctiterator
#ctfiltered = TableOperations.filter.(x -> !ismissing(x.Sample), ct)
idcubes = map(shp.Id) do id
    ctid = TableOperations.filter(x-> (ismissing(x.Sample) ? false : id == x.Sample), ct)
    #@show ctid
    masked = cube[ctid]
    Symbol("ID_$id") => renameaxis!(masked, "Sample"=> CategoricalAxis("Sample_$(id)", ["$(p)_$i" for (i,p) in enumerate(masked.Sample.values)]))

end
Dataset(;(;idcubes...)...)
#    end
end


pol = "VH"
forestshp = Shapefile.Table("data/hidalgo_forest_2017_2018.shp")
forestds = maskcube(s1db, forestshp)
forestcube = forestds.ID_2[Polarisation=pol]
dates = s1cube.Time.values
dateticks = optimize_ticks(dates[1], dates[end])[1]

figts = Figure();

axfor = Axis(figts[1,1])

lines!.(axfor,(datetime2unix.(dates),), eachrow(forestcube[:,:]))
axfor.xticks = (datetime2unix.(dateticks), Dates.format.(dateticks, "mm/dd/yyyy"))

figts



changeshp = Shapefile.Table("data/hidalgo_change_2017_2018.shp")
changeds = maskcube(s1db, changeshp)
changecube = changeds.ID_2[Polarisation=pol]

axch = Axis(figts[2,1])
lines!.(axch, (datetime2unix.(dates),),eachrow(changecube[:,:,1]))
axch.xticks = (datetime2unix.(dateticks), Dates.format.(dateticks, "mm/dd/yyyy"))

figts

linkyaxes!(axfor, axch)
figts

tsfor = forestcube[1,:]

using Statistics
using NaNMath

q5(x) = quantile(, [0.05,0.95])

forestpercentiles = mapslices(q5, forestcube, dims="Time")
renameaxis!(forestpercentiles, "OutAxis1" => CategoricalAxis("Percentiles", [.5,.95]))
changepercentiles = mapslices(q5, changecube, dims="Time")
renameaxis!(changepercentiles, "OutAxis1" => CategoricalAxis("Percentiles", [.5,.95]))

function quant(out, pix,threshold)
    ts = filter(a->!ismissing(a) && !isnan(a),     pix)
    if isempty(ts)
       out .= [missing, missing]
       return
    end
   out .= quantile(ts, [threshold, 1-threshold])
end 


outax = CategoricalAxis("Quantiles", ["Low Bound", "High Bound"])
q5cube = mapCube(quant, s1db, 0.05, indims=InDims("Time"), outdims=OutDims(outax))

comprange(cube) = map((h,l) -> h-l,cube[Quantile="High"], cube[Quantile="Low"])
prange = comprange(q5cube)
zoomlon = (-98.62624, -98.60349)
zoomlat = (20.60937 , 20.62426)
q5zoom = q5cube[lon=zoomlon, lat=zoomlat]

prangezoom = comprange(q5zoom )
heatmap(q5zoom.lon, q5zoom.lat, prangezoom[Polarisation="VH"][:,:])
heatmap(q5cube.lon, q5cube.lat, q5cube[Polarisation="VH", Quantiles="High"][:,:])

heatmap(q5zoom.lon, q5zoom.lat, q5zoom[Polarisation="VH", Quantiles="Low"][:,:])

plotmap(cube) = heatmap(cube.lon, cube.lat, cube[:,:])
plotmap!(ax, cube) = heatmap!(ax, cube.lon, cube.lat, cube[:,:])

# Explore RQA


# Play Around with the example function 3

function stepfun(x, m)
    ts2 = zero(x)
    ts2[1:div(end,3)] .= rand.(Normal(m,1))
    ts2[div(end,3):end] .= rand.(Normal(0,1))
    ts2 
end

tsstep = stepfun(1.:1000, 3)
tsstep = trendfun(1.0:0.02:40, 4)

using RecurrenceAnalysis

rp1 = RecurrenceMatrix(tsstep, 0.2)
rp2 = RecurrenceMatrix(tsstep, 2)

fig = Figure()
ax1 = Axis(fig[1,1]; width=w)
lines!(ax1, tsstep)

fig
axrp = Axis(fig[2,1], aspect=DataAspect();width=w)
heatmap!(axrp, grayscale(rp1), xticks=false, yticks=false,ylabel="Time stamp", xlabel = "Time stamp")
fig
linkxaxes!(axrp, ax1)
fig
heatmap(grayscale(rp2), xticks=false, yticks=false,ylabel="Time stamp", xlabel = "Time stamp")


trendfun(x, slope) = sin.(x) .+ slope .* x .* 0.02

ts1 = trendfun(1.0:0.02:40, 3)

lines(ts1)

# # Recurrence Quantification Analysis

# With these recurrence plots we can now compute different metrics with different meanings. 
# For example there is the recurrence rate of the plot

recurrencerate(rp1)
recurrencerate(rp2)

rrates = recurrencerate.([RecurrenceMatrix(tsstep, epsilon) for epsilon in 0.0:0.2:9])

lines(rrates)

# Another one is the trend which is the correlation between the density of a diagonal and the distance to the main diagonal

trend(rp1)

rqatrends = trend.([RecurrenceMatrix(tsstep, epsilon) for epsilon in 0.0:0.2:9])

## Exploration phase

tsstep4 = stepfun(1.:1000,7)
rqatrends4 = trend.([RecurrenceMatrix(tsstep4, epsilon) for epsilon in 0.0:0.2:9])

findmin(rqatrends)
findmin(rqatrends4)

lines(rqatrends)
lines!(rqatrends4)
current_figure()
## Let's do that now on the actual Sentinel-1 data

# First we can do it only on our extracted data

forestcube

figs1rqa = Figure()
epsilon = 2.0
rpsforest = RecurrenceMatrix.([forestcube[i,:] for i in 1:size(forestcube, 1)], epsilon)
rpsumforest =sum(grayscale.(rpsforest))
heatmap(rpsumforest)

rpschange = RecurrenceMatrix.([changecube[i,:] for i in 1:size(changecube, 1)], epsilon)
rpsumchange =sum(grayscale.(rpschange))
heatmap(rpsumchange)

changetrends = trend.(rpschange)
foresttrends = trend.(rpsforest)

plot(changetrends, color=:orange)
plot!(foresttrends, color=:green)
current_figure()


using Distributed


function trend!(out, xin, threshold) 
    rp = RecurrenceMatrix(xin, threshold)
    out .= trend(rp)

end

trendcube = mapCube(trend!, s1db, 3, indims=InDims("Time"), outdims=OutDims())

plotmap(trendcube[Polarisation=pol])

trendzoom = trendcube[lon=zoomlon, lat=zoomlat]

plotmap(trendzoom[Polarisation=pol])

figmap = Figure()
axprange = Axis(figmap[1,1])
axtrend = Axis(figmap[2,1])

plotmap!(axprange, prangezoom[Polarisation=pol])
plotmap!(axtrend, trendzoom[Polarisation=pol])

figmap

## Play around with the threshold values and see, whether there is a good threshold