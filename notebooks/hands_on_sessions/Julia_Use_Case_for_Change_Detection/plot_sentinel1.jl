using YAXArrays
using GLMakie
using Statistics
using ImageCore

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

function selectposclick(ax, selpos)
    fig = ax.parent
    on(events(ax.scene).mousebutton, priority = 0) do event
        if event.button == Mouse.middle
            if event.action == Mouse.press
                pos = mouseposition(ax.scene)
                pos_px = Makie.mouseposition_px(fig.scene)
                @show pos
                if in(pos_px, ax.scene.px_area[])
                    @show selpos, "In Area"
                    selpos[] = (first(pos), last(pos))
                    @show selpos, "after update"
                end
            end
        end

        return Consume(false)
    end
end


function timestats(cube;path=tempname(), kwargs...)

    indims = InDims("Time")
    funcs = ["Mean", "5th Quantile", "25th Quantile", "Median", "75th Quantile", "95th Quantile",
            "Standard Deviation", "Minimum", "Maximum",
            "Skewness", "Kurtosis", "Median Absolute Deviation"]

    stataxis = CategoricalAxis("Stats", funcs)
    od = OutDims(stataxis, backend=:zarr, path=path, overwrite=true)
    stats = mapCube(ctimestats!, cube, indims=indims, outdims=od, kwargs...)
end

function ctimestats!(xout, xin)
    x = collect(skipmissing(xin))
    ts = x[.!isnan.(x)]
    m = mean(ts)
    T = eltype(m)
    stats = Vector{T}(undef,12)
    if isempty(ts)
        stats .= NaN
    else
        stats[1] = m
        stats[2:6] = quantile(ts, [0.05,0.25,0.5, 0.75,0.95])
        stats[7] = std(ts)
        stats[8] = minimum(ts)
        stats[9] = maximum(ts)
        stats[10] = skewness(ts)
        stats[11] = kurtosis(ts)
        stats[12] = mad(ts, normalize=true)
    end
    xout .=stats
end

function scaleRGB(reddata, greendata, bluedata)

    redscale = scaleminmax(quantile(filter(!isnan, vec(reddata)), [0.02, .98])...)
    greenscale = scaleminmax(quantile(filter(!isnan, vec(greendata)), [0.02,0.98])...)
    bluescale = scaleminmax(quantile(filter(!isnan, vec(bluedata)), [0.02,0.98])...)
    
    return colorview(RGB, redscale.(reddata), greenscale.(greendata), bluescale.(bluedata))
end


function plot_sentinel_1(s1cube, orgstats)
    fig = Figure( fontsize=36)
    axrgb = Axis(fig[1,1]; yticklabelrotation=Float32(π/2), title="RGB of three different times", aspect=1)
    axstats = Axis(fig[1,2]; title="RGB of the Temporal Statistics", aspect=1)
    selpos= Observable((middle(s1cube.lon.values), middle(s1cube.lat.values)))


    buttons = fig[1,3] = GridLayout(tellheight=false)
    polmenu = Menu(buttons[1,2], options=getAxis("Polarisation", s1cube).values)#
    pol = polmenu.selection


    tstatsfuncs = orgstats.Stats.values
    Label(buttons[1,1], text="Red:", tellwidth=false)
    redmenu = Menu(buttons[2,1], options = orgstats.Stats.values)

    Label(buttons[3,1], text="Green:", tellwidth=false)
    greenmenu = Menu(buttons[4,1], options = tstatsfuncs, tellwidth=false)
    Label(buttons[5,1], text="Blue:", tellwidth=false)
    bluemenu = Menu(buttons[6,1], options = tstatsfuncs)
    redmenu.i_selected = 3
    red = redmenu.selection
    greenmenu.i_selected = 4
    green = greenmenu.selection
    bluemenu.i_selected = 5
    blue = bluemenu.selection
    
    statsrgb = lift(pol, red, green, blue) do pol, r, g, b
        reddata = subsetcube(orgstats; :Stats=>r,:Polarisation=>pol)[:,:]
        greendata = subsetcube(orgstats; :Stats=>g,:Polarisation=>pol)[:,:]
        bluedata = subsetcube(orgstats; :Stats=>b,:Polarisation=>pol)[:,:]
        replace!(reddata, missing => NaN )
        replace!(greendata, missing => NaN )
        replace!(bluedata, missing => NaN )
        rgbdata = rotr90(scaleRGB(reddata, greendata, bluedata)')
        @show size(rgbdata)
        #meanlim = quantile(skipmissing(meandata), [0.02,.98])
        #@show meanlim
        #greenmap = heatmap!(axmean, μ.Lon.values, μ.Lat.values, greendata, colormap=:greens, transparancy=true)#, colorrange=meanlim)
        #bluemap = heatmap!(axmean, μ.Lon.values, μ.Lat.values, bluedata, colormap=:blues, transparancy=true)#, colorrange=meanlim)
        rgbdata
    end
    rgbmap = image!(axstats, orgstats.lon, orgstats.lat, statsrgb,interpolate=false)#, colorrange=meanlim)

    orgrgb= lift(pol) do pol
        s1pol = s1cube[Polarisation=pol]
        reddata = replace!(s1vh[Time=DateTime(2018, 3,1)][:,:], missing => NaN );
        greendata = replace!(s1vh[Time=DateTime(2018,6,1)][:,:], missing => NaN );
        bluedata = replace!(s1vh[Time=DateTime(2018,10,1)][:,:], missing => NaN );
        rgbdata = rotr90(scaleRGB(reddata, greendata, bluedata)')
    end
    image!(axrgb, s1cube.lon, s1cube.lat, orgrgb ,interpolate=false)#, colorrange=meanlim)

    linkaxes!(axrgb, axstats)
    hideydecorations!(axstats)

    axts = Axis(fig[2, 1:3])

    selectposclick(axrgb, selpos)
    selectposclick(axstats, selpos)
    tsdata = lift(pol, selpos) do pol, pos
        ts = dB.(s1cube[Polarisation=pol, lon=first(pos), lat=last(pos)][:])

    end

    scatter!(axts, tsdata)
    on(pol) do p
        autolimits!(axts)
    end
    fig
end
