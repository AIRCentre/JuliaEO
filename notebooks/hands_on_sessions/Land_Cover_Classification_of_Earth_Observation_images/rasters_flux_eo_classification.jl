### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ 63e20ecc-8cfe-11ed-2716-63cd8d825073
using Rasters, Flux, Plots, StatsBase , BSON, Printf, JuliennedArrays

# ╔═╡ 4b0b7995-4109-4582-8520-cf45486e0612
md"# Land cover classification of tiff files with Rasters.jl and Flux.jl"

# ╔═╡ 6a919b4c-100b-4322-8d7a-58fd6aa3e58e
md"Our dataset is made up of thousand of 64*64 images with 13 bands, that have been classified according to the type of land cover they contain"

# ╔═╡ 69b04773-39ed-4b1c-9829-e867b2227c4b
md"*Load the packages we need*"

# ╔═╡ bb374d60-443b-4003-b1f0-22fe15700409
md"### Set some variables for the session"

# ╔═╡ f2c0624a-4829-4acf-b61d-868a311aff2f
md"*Choose the number of land cover classes we will identify*"

# ╔═╡ 5059ef97-7a3b-4f9e-9564-c57ac3f110f0
nclasses = 5

# ╔═╡ dc83b90e-8e5f-4971-9410-e947c483fe42
md"Lets manually define the band names from the papter - they are not stored in the files and it's good to see what our data means in plot"

# ╔═╡ 25c96b6d-b5e1-4d6a-8503-a3c6e4d7bd1f
band_names = [
  :Aerosols,
  :B02_Blue,
  :B03_Green,
  :B04_Red,
  :B05_Red_edge,
  :B06_Red_edge,
  :B07_Red_edge,
  :B08_NIR,
  :B08A_Red_edge,
  :B09_Water_vapor,
  :B10_Cirrus,
  :B11_SWIR,
  :B12_SWIR,
]

# ╔═╡ e7a65846-39dd-44ca-985b-aa236f86a2a2
md"*Choose the fraction of samples to use, and the fraction of those for testing and validation*"

# ╔═╡ a96f2d55-95af-4089-b4b9-e700a5d59322
md"""
### Find our tiff files
"""

# ╔═╡ 9d01a67f-5a8d-4cff-9122-698abb3d18b0
md"*Set the path where the downloaded tif files are stored*"

# ╔═╡ 01131068-b4ec-4492-8310-7e1b953f3940
data_path = "/home/jovyan/data"

# ╔═╡ 400c0a19-5f12-47b8-b52d-9e9e08372209
md"*Get class names from the names of the directories*"

# ╔═╡ 9a7e9cdf-4b2f-479d-8b76-cad86614c693
class_names = readdir(data_path)[1:nclasses]

# ╔═╡ 47bba161-0a09-4e6a-bb21-b01d142be985
md"*Get the paths to the class folders:*"

# ╔═╡ a041ae3d-d8c8-4f84-8604-def44dbbbe83
class_paths = joinpath.(data_path, class_names)

# ╔═╡ dd8ac167-1416-427c-b87d-0522c61d0cd9
md"*Then get a list all the files in the selected class folders*"

# ╔═╡ 3c627000-8f24-4ca0-a597-e94b00ea745a
file_paths = [p for class_path in class_paths for p in readdir(class_path; join=true)]

# ╔═╡ c6c6f1fd-33a2-4645-933b-e2267286e070
md"""
## Plot some of the files

*Load and plot one of the rasters to see what we have.*
"""

# ╔═╡ 169daaaf-666a-4cdd-b934-1f59754f530c
Raster(first(file_paths)) |> plot

# ╔═╡ 9d3177b2-fc16-4fad-988b-ba6a701361ee
md"*By default band labels are just the same as the indices in the axis - which doesn't tell us very much.* 

*Lets use the proper band names as the lookup so we understand the data and access it by name*"

# ╔═╡ 7931eda0-8391-42c5-9605-530652c2fa23
r1 = set(Raster(first(file_paths)), Band => band_names)

# ╔═╡ 3fd5528f-63a2-4ab5-ae87-ed8e6ffc89a1
plot(r1)

# ╔═╡ 36dbaf99-0ae2-4ae2-ac60-c16797962c4a
md"""
*Thats a lot of bands and a lot of small plots!* A lot of them don't look very sharp for classifying with.

*Lets choose the most suitable ones*
"""

# ╔═╡ 5f64b5cb-e8ed-417d-89f0-0433476ad817
selected_bands = [:B02_Blue, :B03_Green, :B04_Red, :B08_NIR]

# ╔═╡ ce0b128c-62af-47e4-8545-b65ade110bf5
md"*Also calculate an* `nbands` *variable for use in our flux model later*"

# ╔═╡ 567a9461-93ad-4794-baf6-5c19af8bff7d
nbands = length(selected_bands)

# ╔═╡ e4e56ef2-7749-4f58-8949-d367aa3733de
md"*And index with them useing the* `Band` *dimension and the* `At` *selector*"

# ╔═╡ 4337c5bd-82e2-401c-aedb-a5c054b1a32f
r1[Band=At(selected_bands)] |> plot 

# ╔═╡ 082e3921-a028-4bb7-833b-609862a36792
md"### Sample some files for training and test data"

# ╔═╡ 592c3164-ca43-4cd7-89c0-41c6ab226c22
sample_prop = 0.1

# ╔═╡ a7c13fa5-a8eb-455b-9171-20008edb58bf
test_prop = 0.2

# ╔═╡ 1ca4ee45-708b-4d46-a9be-501778a1cffa
validate_prop = 0.1

# ╔═╡ 043b08d1-2181-47ee-8b92-f7b136a8d81a
md"*Sample a subset (or all) of the image paths*"

# ╔═╡ 8249f1a3-fd0c-4cb4-8090-35e5eeea2f18
sampled_paths = sample(file_paths, round(Int, length(file_paths) * sample_prop); replace=false)

# ╔═╡ 239a4641-094b-4162-be18-f19d95032e8b
md"*Get the classes for all images*"

# ╔═╡ 678fbbf6-42d0-4064-aed8-b0510ddaa15f
sampled_classes = map(basename ∘ dirname, sampled_paths)

# ╔═╡ 9bf85b2d-3d16-4caa-8829-faddb5812b41
md"*Sample some indices to use for test data*"

# ╔═╡ efcdc38a-4577-4c49-893f-1f2dc8477028
ntest = round(Int, test_prop * length(sampled_paths))

# ╔═╡ 372d6a2e-9cfc-41de-96b4-451b15fa2c23
test_indices = sample(eachindex(sampled_paths), ntest; replace=false)

# ╔═╡ cf42219e-7215-4ae8-94ff-2f6d83c922fc
md"*Now, sample some indices to use for validation data - that were not used for test data*"

# ╔═╡ dfd560bd-f524-4f0e-b807-e26a127822a9
nvalidate = round(Int, validate_prop * length(sampled_paths))

# ╔═╡ 92238d33-94ef-475c-945a-93c1b9e9b609
validate_indices = sample([i for i in eachindex(sampled_paths) if !(i in test_indices)], nvalidate; replace=false)

# ╔═╡ 1e1dc246-3f5b-4d72-bf34-16e891352637
md"*And use the remainder for training data*"

# ╔═╡ f0a33237-28fb-40c2-9d2a-841af78b9bc2
train_indices = [i for i in eachindex(sampled_paths) if !(i in test_indices) && !(i in validate_indices)]

# ╔═╡ 5f97a23f-9472-4911-9d50-1a04b657be58
sample_indices = (
    train=train_indices, 
    validate=validate_indices, 
    test=test_indices
)

# ╔═╡ 18cfb93c-d9bc-4bd9-9568-7e5a0c217049
md"*Define a function to build a series of lazy rasters that will load and subset on demand*"

# ╔═╡ c94c6293-77f5-444b-a40f-bbb6778e5ecd
function build_raster_series(paths, names, selected_bands)
    # Create a lazy RasterSeries. `duplicate_first` means we don't load
    # the meta data for any file but the first. We dont care about x/y coordinates
    # and the bands are identical for all.
    series = RasterSeries(paths, (:samples,); lazy=true, duplicate_first=true)
    # Edit the series a little, using `view` is lazy
    # the files are not actually loaded now
    broadcast(series, names) do raster, name
        # Set correct band names
		set(raster, Band => band_names) |>
		    # Reduce the number of bands, notice we use the `At` selector
            r -> view(r, Band(At(selected_bands))) |>
            # And make the raster name the class
            r -> rebuild(r; name)
    end
end

# ╔═╡ 8e8cec7e-2d1d-48af-a460-dca49fd8b017
md"""
*For all of our data sets build lists of file paths, classes, labels, and lazy raster files.*

*Using* `map` *and a* `do` *block means we only have to write one vesion of the code, and it applies to training, test, and validation datasets in the same way.*
"""

# ╔═╡ bc38026b-8f22-48ad-9541-e3be3c0c253f
data = map(sample_indices) do indices
    # Get the file path for our sampled indices
    paths = sampled_paths[indices]
    # Get the land cover class of each file
    classes = sampled_classes[indices]
	# Convert the class name to a `label`, here a number between 1 and 5
    labels = map(c -> findfirst(==(c), class_names), classes)
	# Use the paths and class names to build rasters for the selected bands
    rasters = build_raster_series(paths, classes, selected_bands)
    # Return a NamedTuple of all of this information
    return (; indices, paths, classes, labels, rasters)
end;

# ╔═╡ ff0021f4-9c2a-42a5-b01f-949f17007379
md"*Lets inspect the data, and plot some rasters to make sure it makes sense and is correctly labelled*"

# ╔═╡ 59f4ada2-45b0-4991-9df0-854e50e55919
keys(data)

# ╔═╡ 03b741e5-f88c-4180-96ee-4085ec5cab8b
data.train

# ╔═╡ c2537ba5-a769-4b7f-bd1a-8c0af0adcfa8
length(data.train.rasters)

# ╔═╡ fc101914-ae55-47c8-9e21-9593dad28ff0
typeof(data.train.rasters)

# ╔═╡ bc2bdf1b-8cd1-4c78-a0c2-45c0f020ec17
data.train.classes

# ╔═╡ 8052c7e4-c547-432a-b22e-08a05cf5cb99
data.train.labels

# ╔═╡ 5c61e3e2-7dbb-4312-a058-804b9e6eb1b0
t1 = data.train.rasters[1]

# ╔═╡ a464df41-d9cc-4ac7-b0f9-40f5e32a4c90
plot(t1)

# ╔═╡ e4d50aa5-7ab1-465e-8fdf-24a1493e83b6
data.train.classes[2]

# ╔═╡ 6bf7624c-750a-4ab3-b9bc-cb5b10acbf81
t2 = data.train.rasters[2]

# ╔═╡ 4098d835-f97e-4319-aa9c-ff83318c32b0
plot(data.validate.rasters[50])

# ╔═╡ 16d97eb7-bc0c-4e40-8aaf-869b0847619f
md"""
### Build Flux.jl ready datasets for training and testing
"""

# ╔═╡ 105793e6-6fac-49d9-a108-32ed9a7849af
batchsize = 64

# ╔═╡ 0b789ff3-49c4-419d-a940-dd7d5bf49de9
md"*Here we make the training data from the raster series. Notice we have to use `read` currently because DiskArrays.jl wont work properly inside `JulienedArrays.Align`.* 

*We also finish with a* `Float32` *broadcast - this is because the eltype of the rasters* `UInt16` *is not suitable for Flux.jl.*"

# ╔═╡ d5613844-e4fb-4057-bb30-997035e112ba
train_data = Float32.(Align(read(data.train.rasters), 1, 2, 3))

# ╔═╡ 55690763-1cfb-4c0c-9506-295a4cf0582e
md"*And convert the labels to onehot encoding*"

# ╔═╡ 8be923b3-58af-439f-b20a-78e92b9d221c
train_labels = Flux.onehotbatch(data.train.labels, 1:nclasses)

# ╔═╡ d4cf3d4e-7e1d-49ce-8fb5-8fbe6852e42a
md"*Use DataLoader to extract shuffled batches from our data when they're needed*"

# ╔═╡ b1b88fc6-8082-4bd8-811b-fded1d04d13f
train_set = Flux.Data.DataLoader((train_data, train_labels);
    batchsize, collate=true, shuffle=true,
); # |> gpu

# ╔═╡ f5cae703-954d-492e-a18e-857428370ec3
md"*Now set up the test data and labels, as one huge batch*"

# ╔═╡ d1dee3bc-7120-49ca-86ba-1c155847941b
test_data = Float32.(Align(read(data.test.rasters), 1, 2, 3))

# ╔═╡ 3ae669e1-16ee-49d7-81b5-42124ee8bac7
test_labels = Flux.onehotbatch(data.test.labels, 1:nclasses)

# ╔═╡ f887d0d0-d297-46f6-8a42-adfdac36e2d3
test_set = (test_data, test_labels) # |> gpu

# ╔═╡ a7cbde10-d746-412a-a91a-58ec9edaadc1
md"## Flux.jl model

*Define a Flux.jl Convolution Nerual Network (CNN) model:*"

# ╔═╡ 59010b93-03d7-4fe7-9bf6-741d320ee0ff
model = Chain(
    # Convolution layers
    # 1st convolution: on nbands * 64 * 64 layers
    Conv((7, 7), nbands => 32, relu; pad=(1, 1)),
    MaxPool((2, 2)),
    # 2nd convolution
    Conv((7, 7), 32 => 32, relu; pad=(1, 1)),
    MaxPool((2, 2)),
    # 3rd convolution
    Conv((7, 7), 32 => 64, relu; pad=(1, 1)),
    MaxPool((2, 2)),
    Dropout(0.25),
	# reshape the array
    Flux.flatten,
    Dense(64 * 4 * 4 => 500, relu),
    Dropout(0.25),
	# Finish with `nclasses` on the axis for each observation
    Dense(500 => nclasses),
    # Nicer properties for crossentropy loss
    softmax,
)

# ╔═╡ 25825628-463e-4449-97be-94e1608e1476
md"*Test that the model runs on our training data*"

# ╔═╡ 19c1f3ee-44b7-48c3-815c-13acf02d6a92
model(first(train_set)[1])

# ╔═╡ efc23a0f-adda-4384-bed8-8c71b62ded1a
md"*Load model and datasets onto GPU, if enabled*"

# ╔═╡ 43ead7dd-c056-4098-81f8-c56874b97e4a
md"*Define a loss function*

`loss` *calculates the crossentropy loss between our prediction* `y_hat` *and the labels* `y`"

# ╔═╡ cafca1df-3059-4391-8c37-e600c77e0a5b
function loss(x, y)   
   # x̂ = augment(x)
   ŷ = model(x)
   return crossentropy(ŷ, Flux.label_smoothing(y, 0.1))
end

# ╔═╡ 965303a0-06ac-49e5-9d3f-83e4a9faa861
augment(x) = x .+ 0.1f0 * randn(eltype(x), size(x))

# ╔═╡ bb09628d-86cb-40bd-acc1-4feb5a459edf
anynan(x) = any(y -> any(isnan, y), x)

# ╔═╡ 6114da78-c5fb-466d-a588-222e4cd90037
accuracy(x, y, model) = mean(Flux.onecold(cpu(model(x))) .== Flux.onecold(cpu(y)))

# ╔═╡ e86b60b2-7351-4915-842c-7e83557122d2
md"*Define number of epochs, learning rate and optimizer*"

# ╔═╡ 36b23d05-5fce-498c-a86d-b31e2357bd3b
nepochs = 10

# ╔═╡ 34a289ab-adeb-460a-8c9e-e29b78e3b431
learning_rate = 0.001

# ╔═╡ ed0edb59-e229-4cda-8ba1-b54a8496cc08
opt = Adam(learning_rate)

# ╔═╡ a2e4f62d-7e13-4394-8287-5a4a935f6edd
md"*First, lets try a single training iteration*"

# ╔═╡ 96438c0c-3b71-4a5e-8181-40fa55e3740b
Flux.train!(loss, Flux.params(model), train_set, opt)

# ╔═╡ f305afb6-f1b3-4e0d-a3fa-73105bf74c06
md"*Now we can run a training loop*"

# ╔═╡ 0195cfaf-a280-416f-a070-65b3ab2e3de1
let
	last_improvement = 0
	best_acc = 0.0
	savepath = "."

for epoch_idx in 1:nepochs
   
	Flux.testmode!(model, false)

   # Train for a single epoch
   Flux.train!(loss, Flux.params(model), train_set, opt)

   Flux.testmode!(model, true)
  
   # Terminate on NaN
   if anynan(Flux.params(model))
       @error "NaN params"
       break
   end

   # Calculate accuracy:
   acc = accuracy(test_set..., model)
  
   @info(@sprintf("[%d]: Test accuracy: %.4f", epoch_idx, acc))
   # If our accuracy is good enough, quit out.
   if acc >= 0.999
       @info(" -> Early-exiting: We reached our target accuracy of 99.9%")
       break
   end

   # If this is the best accuracy we've seen so far, save the model out
   if acc > best_acc
       @info(" -> New best accuracy $acc ! Saving model out to mnist_conv.bson")
       BSON.@save joinpath(savepath, "mnist_conv.bson") params=cpu.(Flux.params(model)) epoch_idx acc
       best_acc = acc
       last_improvement = epoch_idx
   end

   # If we haven't seen improvement in 5 epochs, drop our learning rate:
   if epoch_idx - last_improvement > 5 && opt.eta > 1e-6
       opt.eta /= 10.0
       @warn(" -> Haven't improved in a while, dropping learning rate to $(opt.eta)!")

       # After dropping learning rate, give it a few epochs to improve
       last_improvement = epoch_idx
   end

   if epoch_idx - last_improvement >= 10
       @warn(" -> We're calling this converged.")
       break
   end
end

end # let

# ╔═╡ 60ef6c38-3776-4ed2-a5ee-b86b9532764a
md"So this all seems to work. But does it actually train well?"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BSON = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
Flux = "587475ba-b771-5e3f-ad9e-33799f191a9c"
JuliennedArrays = "5cadff95-7770-533d-a838-a1bf817ee6e0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
Rasters = "a3a2b9e3-a471-40c9-b274-f788e487c689"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
BSON = "~0.3.6"
Flux = "~0.13.11"
JuliennedArrays = "~0.4.0"
Plots = "~1.38.1"
Rasters = "~0.5.0"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0"
manifest_format = "2.0"
project_hash = "1e2551166cb7622a3bb70ace15d29f059337a309"

[[deps.ASCIIrasters]]
git-tree-sha1 = "0cb0046798af8ac8561334c5a2a31f015e53c2b1"
uuid = "81770e7c-c736-4fa5-8129-46dd21831640"
version = "0.1.1"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.Accessors]]
deps = ["Compat", "CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Requires", "Test"]
git-tree-sha1 = "3fa8cc751763c91a5ea33331e523221009cb1e6f"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.23"

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

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

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

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[deps.BSON]]
git-tree-sha1 = "86e9781ac28f4e80e9b98f7f96eae21891332ac2"
uuid = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
version = "0.3.6"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "7fe6d92c4f281cf4ca6f2fba0ce7b299742da7ca"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.37"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

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

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "a56dff7bc49b5d5ac43d2c10eb2aef94becd5251"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.12.1"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRules]]
deps = ["Adapt", "ChainRulesCore", "Compat", "Distributed", "GPUArraysCore", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "Statistics", "StructArrays"]
git-tree-sha1 = "99a39b0f807499510e2ea14b0eef8422082aa372"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.46.0"

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

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

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

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "c5b6685d53f933c11404a3ae9822afe30d522494"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.2"

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

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

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

[[deps.FLoops]]
deps = ["BangBang", "Compat", "FLoopsBase", "InitialValues", "JuliaVariables", "MLStyle", "Serialization", "Setfield", "Transducers"]
git-tree-sha1 = "ffb97765602e3cbe59a0589d237bf07f245a8576"
uuid = "cc61a311-1640-44b5-9fba-1b764f453329"
version = "0.2.1"

[[deps.FLoopsBase]]
deps = ["ContextVariablesX"]
git-tree-sha1 = "656f7a6859be8673bf1f35da5670246b923964f7"
uuid = "b9860ae5-e623-471e-878b-f6a53c775ea6"
version = "0.1.1"

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

[[deps.Flux]]
deps = ["Adapt", "CUDA", "ChainRulesCore", "Functors", "LinearAlgebra", "MLUtils", "MacroTools", "NNlib", "NNlibCUDA", "OneHotArrays", "Optimisers", "ProgressLogging", "Random", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "Zygote"]
git-tree-sha1 = "518b553ec3776dde058aebd2750c109d04ee5593"
uuid = "587475ba-b771-5e3f-ad9e-33799f191a9c"
version = "0.13.11"

[[deps.FoldsThreads]]
deps = ["Accessors", "FunctionWrappers", "InitialValues", "SplittablesBase", "Transducers"]
git-tree-sha1 = "eb8e1989b9028f7e0985b4268dabe94682249025"
uuid = "9c68100b-dfe1-47cf-94c8-95104e173443"
version = "0.1.1"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "a69dd6db8a809f78846ff259298678f0d6212180"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.34"

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

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.Functors]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "993c2b4a9a54496b6d8e265db1244db418f37e01"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.4.1"

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

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "45d7deaf05cbb44116ba785d147c518ab46352d7"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.5.0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "6872f5ec8fd1a38880f027a26739d42dcda6691f"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.2"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "48832a7cacbe56e591a7bef690c78b9d00bcc692"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.17.1"

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

[[deps.IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "2e99184fca5eb6f075944b04c22edec29beb4778"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.7"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

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

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.JuliennedArrays]]
git-tree-sha1 = "d290d10d4aca892e2e09d3219658f3c562dab152"
uuid = "5cadff95-7770-533d-a838-a1bf817ee6e0"
version = "0.4.0"

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

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "088dd02b2797f0233d92583562ab669de8517fd1"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.14.1"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg", "TOML"]
git-tree-sha1 = "771bfe376249626d3ca12bcd58ba243d3f961576"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.16+0"

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

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[deps.MLStyle]]
git-tree-sha1 = "060ef7956fef2dc06b0e63b294f7dbfbcbdc7ea2"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.16"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "Compat", "DataAPI", "DelimitedFiles", "FLoops", "FoldsThreads", "NNlib", "Random", "ShowCases", "SimpleTraits", "Statistics", "StatsBase", "Tables", "Transducers"]
git-tree-sha1 = "266c67f773feb756474c2c4a7424ea5363290300"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.4.0"

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

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "4d5917a26ca33c66c8e5ca3247bd163624d35493"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.3"

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

[[deps.NNlib]]
deps = ["Adapt", "ChainRulesCore", "LinearAlgebra", "Pkg", "Random", "Requires", "Statistics"]
git-tree-sha1 = "03541c7a6dc3010cb2e33a01295f3cd35b5fd41e"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.8.15"

[[deps.NNlibCUDA]]
deps = ["Adapt", "CUDA", "LinearAlgebra", "NNlib", "Random", "Statistics"]
git-tree-sha1 = "538f90fc503946a3134a48e1026035fcf71248f4"
uuid = "a00861dc-f156-4864-bf3c-e6376f28a68d"
version = "0.2.5"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

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

[[deps.OneHotArrays]]
deps = ["Adapt", "ChainRulesCore", "Compat", "GPUArraysCore", "LinearAlgebra", "NNlib"]
git-tree-sha1 = "f511fca956ed9e70b80cd3417bb8c2dde4b68644"
uuid = "0b1bfda6-eb8a-41d2-88d8-f5af5cad476f"
version = "0.2.3"

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

[[deps.Optimisers]]
deps = ["ChainRulesCore", "Functors", "LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "e657acef119cc0de2a8c0762666d3b64727b053b"
uuid = "3bd65402-5787-11e9-1adc-39752487f4e2"
version = "0.2.14"

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

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

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

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "7a1a306b72cfa60634f03a911405f4e64d1b718b"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.0"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

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

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

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

[[deps.ShowCases]]
git-tree-sha1 = "7f534ad62ab2bd48591bdeac81994ea8c445e4a5"
uuid = "605ecd9f-84a6-4c9e-81e2-4798472b76a3"
version = "0.1.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

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

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

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

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "b03a3b745aa49b566f128977a7dd1be8711c5e71"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.14"

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

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f2fd3f288dfc6f507b0c3a2eb3bac009251e548b"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.22"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "e4bdc63f5c6d62e80eb1c0043fcc0360d5950ff7"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.10"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "c42fa452a60f022e9e087823b47e5a5f8adc53d5"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.75"

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

[[deps.Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "GPUArrays", "GPUArraysCore", "IRTools", "InteractiveUtils", "LinearAlgebra", "LogExpFunctions", "MacroTools", "NaNMath", "Random", "Requires", "SparseArrays", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "a6f1287943ac05fae56fa06049d1a7846dfbc65f"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.51"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

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
# ╟─4b0b7995-4109-4582-8520-cf45486e0612
# ╟─6a919b4c-100b-4322-8d7a-58fd6aa3e58e
# ╟─69b04773-39ed-4b1c-9829-e867b2227c4b
# ╠═63e20ecc-8cfe-11ed-2716-63cd8d825073
# ╟─bb374d60-443b-4003-b1f0-22fe15700409
# ╟─f2c0624a-4829-4acf-b61d-868a311aff2f
# ╠═5059ef97-7a3b-4f9e-9564-c57ac3f110f0
# ╟─dc83b90e-8e5f-4971-9410-e947c483fe42
# ╠═25c96b6d-b5e1-4d6a-8503-a3c6e4d7bd1f
# ╟─e7a65846-39dd-44ca-985b-aa236f86a2a2
# ╟─a96f2d55-95af-4089-b4b9-e700a5d59322
# ╟─9d01a67f-5a8d-4cff-9122-698abb3d18b0
# ╠═01131068-b4ec-4492-8310-7e1b953f3940
# ╟─400c0a19-5f12-47b8-b52d-9e9e08372209
# ╠═9a7e9cdf-4b2f-479d-8b76-cad86614c693
# ╟─47bba161-0a09-4e6a-bb21-b01d142be985
# ╠═a041ae3d-d8c8-4f84-8604-def44dbbbe83
# ╟─dd8ac167-1416-427c-b87d-0522c61d0cd9
# ╠═3c627000-8f24-4ca0-a597-e94b00ea745a
# ╟─c6c6f1fd-33a2-4645-933b-e2267286e070
# ╠═169daaaf-666a-4cdd-b934-1f59754f530c
# ╟─9d3177b2-fc16-4fad-988b-ba6a701361ee
# ╠═7931eda0-8391-42c5-9605-530652c2fa23
# ╠═3fd5528f-63a2-4ab5-ae87-ed8e6ffc89a1
# ╟─36dbaf99-0ae2-4ae2-ac60-c16797962c4a
# ╠═5f64b5cb-e8ed-417d-89f0-0433476ad817
# ╟─ce0b128c-62af-47e4-8545-b65ade110bf5
# ╠═567a9461-93ad-4794-baf6-5c19af8bff7d
# ╟─e4e56ef2-7749-4f58-8949-d367aa3733de
# ╠═4337c5bd-82e2-401c-aedb-a5c054b1a32f
# ╟─082e3921-a028-4bb7-833b-609862a36792
# ╠═592c3164-ca43-4cd7-89c0-41c6ab226c22
# ╠═a7c13fa5-a8eb-455b-9171-20008edb58bf
# ╠═1ca4ee45-708b-4d46-a9be-501778a1cffa
# ╟─043b08d1-2181-47ee-8b92-f7b136a8d81a
# ╠═8249f1a3-fd0c-4cb4-8090-35e5eeea2f18
# ╟─239a4641-094b-4162-be18-f19d95032e8b
# ╠═678fbbf6-42d0-4064-aed8-b0510ddaa15f
# ╟─9bf85b2d-3d16-4caa-8829-faddb5812b41
# ╠═efcdc38a-4577-4c49-893f-1f2dc8477028
# ╠═372d6a2e-9cfc-41de-96b4-451b15fa2c23
# ╟─cf42219e-7215-4ae8-94ff-2f6d83c922fc
# ╠═dfd560bd-f524-4f0e-b807-e26a127822a9
# ╠═92238d33-94ef-475c-945a-93c1b9e9b609
# ╟─1e1dc246-3f5b-4d72-bf34-16e891352637
# ╠═f0a33237-28fb-40c2-9d2a-841af78b9bc2
# ╠═5f97a23f-9472-4911-9d50-1a04b657be58
# ╟─18cfb93c-d9bc-4bd9-9568-7e5a0c217049
# ╠═c94c6293-77f5-444b-a40f-bbb6778e5ecd
# ╟─8e8cec7e-2d1d-48af-a460-dca49fd8b017
# ╠═bc38026b-8f22-48ad-9541-e3be3c0c253f
# ╟─ff0021f4-9c2a-42a5-b01f-949f17007379
# ╠═59f4ada2-45b0-4991-9df0-854e50e55919
# ╠═03b741e5-f88c-4180-96ee-4085ec5cab8b
# ╠═c2537ba5-a769-4b7f-bd1a-8c0af0adcfa8
# ╠═fc101914-ae55-47c8-9e21-9593dad28ff0
# ╠═bc2bdf1b-8cd1-4c78-a0c2-45c0f020ec17
# ╠═8052c7e4-c547-432a-b22e-08a05cf5cb99
# ╠═5c61e3e2-7dbb-4312-a058-804b9e6eb1b0
# ╠═a464df41-d9cc-4ac7-b0f9-40f5e32a4c90
# ╠═e4d50aa5-7ab1-465e-8fdf-24a1493e83b6
# ╠═6bf7624c-750a-4ab3-b9bc-cb5b10acbf81
# ╠═4098d835-f97e-4319-aa9c-ff83318c32b0
# ╟─16d97eb7-bc0c-4e40-8aaf-869b0847619f
# ╠═105793e6-6fac-49d9-a108-32ed9a7849af
# ╟─0b789ff3-49c4-419d-a940-dd7d5bf49de9
# ╠═d5613844-e4fb-4057-bb30-997035e112ba
# ╠═55690763-1cfb-4c0c-9506-295a4cf0582e
# ╠═8be923b3-58af-439f-b20a-78e92b9d221c
# ╟─d4cf3d4e-7e1d-49ce-8fb5-8fbe6852e42a
# ╠═b1b88fc6-8082-4bd8-811b-fded1d04d13f
# ╟─f5cae703-954d-492e-a18e-857428370ec3
# ╠═d1dee3bc-7120-49ca-86ba-1c155847941b
# ╠═3ae669e1-16ee-49d7-81b5-42124ee8bac7
# ╠═f887d0d0-d297-46f6-8a42-adfdac36e2d3
# ╟─a7cbde10-d746-412a-a91a-58ec9edaadc1
# ╠═59010b93-03d7-4fe7-9bf6-741d320ee0ff
# ╟─25825628-463e-4449-97be-94e1608e1476
# ╠═19c1f3ee-44b7-48c3-815c-13acf02d6a92
# ╟─efc23a0f-adda-4384-bed8-8c71b62ded1a
# ╟─43ead7dd-c056-4098-81f8-c56874b97e4a
# ╠═cafca1df-3059-4391-8c37-e600c77e0a5b
# ╠═965303a0-06ac-49e5-9d3f-83e4a9faa861
# ╠═bb09628d-86cb-40bd-acc1-4feb5a459edf
# ╠═6114da78-c5fb-466d-a588-222e4cd90037
# ╠═e86b60b2-7351-4915-842c-7e83557122d2
# ╠═36b23d05-5fce-498c-a86d-b31e2357bd3b
# ╠═34a289ab-adeb-460a-8c9e-e29b78e3b431
# ╠═ed0edb59-e229-4cda-8ba1-b54a8496cc08
# ╟─a2e4f62d-7e13-4394-8287-5a4a935f6edd
# ╠═96438c0c-3b71-4a5e-8181-40fa55e3740b
# ╟─f305afb6-f1b3-4e0d-a3fa-73105bf74c06
# ╠═0195cfaf-a280-416f-a070-65b3ab2e3de1
# ╠═60ef6c38-3776-4ed2-a5ee-b86b9532764a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
