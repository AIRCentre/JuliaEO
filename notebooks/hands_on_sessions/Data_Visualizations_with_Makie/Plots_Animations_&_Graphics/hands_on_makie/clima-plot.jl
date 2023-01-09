using ClimaCore
using Makie: GLTriangleFace

function load_time_series(n=9)
    files = readdir(joinpath(@__DIR__, "time-series"); join=true)
    r = round.(Int, range(1, stop=length(files), length=n))
    time_series = map(files[r]) do file
        reader = ClimaCore.InputOutput.HDF5Reader(file)
        return ClimaCore.InputOutput.read_field(reader, "diagnostics")
    end
end

if !isdefined(Base.@__MODULE__, :COLOR_LEVELS)
    const COLOR_LEVELS = Ref{Any}()
end

function nlevels(time_series)
    field = time_series[1].temperature
    return ClimaCore.Spaces.nlevels(axes(field))
end

function get_colorlevels(time_series)
    if !isassigned(COLOR_LEVELS)
        field = time_series[1].temperature
        nlevels = ClimaCore.Spaces.nlevels(axes(field))
        # Calculate a global color range per field type, so that the colorrange stays static when moving time/level.
        COLOR_LEVELS[] = Dict(
            map(propertynames(time_series[1])) do name
                vecs = [
                    extrema(
                        hcat(
                            vec.(
                                parent.(
                                    ClimaCore.level.(
                                        (getproperty(slice, name),),
                                        1:nlevels,
                                    )
                                )
                            )...,
                        ),
                    ) for slice in time_series
                ]
                name => reduce(
                    ((amin, amax), (bmin, bmax)) ->
                        (min(amin, bmin), max(amax, bmax)),
                    vecs,
                )
            end,
        )
    end
    return COLOR_LEVELS[]
end

getlayout(fig::Figure) = fig.layout
get_parent(x::Makie.GridPosition) = parent(x.layout)
getlayout(fig::Makie.GridPosition) = fig.layout
getlayout(gl::Makie.GridLayout) = gl

function simulation_plot(fig, time_series, projection, field, time, level, overlay_toggle)
    # Have a global color range
    colorrange = Observable((0.0, 1.0))
    ax = GeoAxis(fig[1, 1]; dest=projection)
    # Disable all interactions with the axis for now, since they're buggy :(
    foreach(name -> deregister_interaction!(ax, name), keys(interactions(ax)))

    # create a 3D plot without an axis for mapping the simulation on the sphere
    ax2 = LScene(fig[1, 2]; show_axis=false)

    colsize!(getlayout(fig), 1, Relative(3 / 4)) # Give the GeoAxis more space

    field_observable = Observable{Any}()

    map!(field_observable, field, time) do fieldname, idx
        return getproperty(time_series[idx], Symbol(fieldname))
    end
    color_range_per_field = get_colorlevels(time_series)
    # update=true, runs f immediately, otherwise f only runs when the input observable is triggered the first time
    on(field; update=true) do field_name
        # select the correct color range from the globally calcualted color ranges
        colorrange[] = color_range_per_field[Symbol(field_name)]
        return
    end

    # manually create the mesh for the 3D Sphere plot:

    field_slice = ClimaCore.level(field_observable[], 1)
    space = axes(field_slice)
    a, b, c = ClimaCore.Spaces.triangulate(space)
    triangles = GLTriangleFace.(a, b, c)
    cf = ClimaCore.Fields.coordinate_field(space)
    long, lat = vec.(parent.((cf.long, cf.lat)))
    vertices = Point2f.(long, lat)

    # plot level at slider, needs to be any since the  type changes (also the reason why we use map! instead of map)
    field_slice_observable = Observable{Any}()
    map!(ClimaCore.level, field_slice_observable, field_observable, level)

    # extract the scalar field
    scalars = map(field_slice_observable) do field_slice
        Float32.(vec(parent(field_slice)))
    end
    mesh!(
        ax,
        vertices,
        triangles;
        color=scalars,
        shading=false,
        colormap=:balance,
        colorrange=colorrange
    )
    # Create a toggable land overlay
    earth_overlay = poly!(ax, GeoMakie.land(), color=(:white, 0.5), transparency=true)
    translate!(earth_overlay, 0, 0, 100)
    connect!(earth_overlay.visible, overlay_toggle)
    plot!(ax2, field_slice_observable, colorrange=colorrange)
    fig
end

function gui_via_makie(time_series)
    sproj = ["wink2", "wintri", "poly", "qua_aut", "rouss", "rpoly", "sinu"]
    fig = Figure(resolution = (1600, 800))
    # One slot for menus + toggles
    toggles = fig[1, 1] = GridLayout()
    plots = fig[2, 1] = GridLayout()
    colgap!(plots, 0) # leave no space between plots
    # Define a few observables we need to create entries, which get connected to the widgets later
    projection = Observable(sproj[1])
    fields = collect(string.(propertynames(time_series[1])))
    # Two sliders for setting Time + Label
    toggles[1, :] = sliders = SliderGrid(
        fig,
        (label = "Time", range = 1:length(time_series)),
        (label = "Level", range = 1:nlevels(time_series)),
    )
    time_slider, level_slider = sliders.sliders
    # Need a sub gridlayout, to get the columns aligned with the sliders
    menu_items = toggles[2, :] = GridLayout()
    # Use labels to label toggle + menu
    menu_items[1, 1] = Label(fig, "earth overlay:", tellwidth = true)
    menu_items[1, 2] = overlay_toggle = Toggle(fig, active = true)

    menu_items[1, 3] = Label(fig, "field:", tellwidth = true)
    menu_items[1, 4] =
        field_selector = Menu(fig, options = fields, default = "temperature")

    menu_items[1, 5] = Label(fig, "projection:", tellwidth = true)
    menu_items[1, 6] = dest_proj = Menu(fig, options = sproj, default = projection[])
    projection_compl = map(x-> "+proj=" * x, dest_proj.selection)
    simulation_plot(plots, time_series, projection_compl, field_selector.selection, time_slider.value, level_slider.value, overlay_toggle.active)
    return fig
end