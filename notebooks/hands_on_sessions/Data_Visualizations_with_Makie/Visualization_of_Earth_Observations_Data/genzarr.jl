using YAXArrays, Zarr, NetCDF
ds_raw = open_dataset("/Users/lalonso/Documents/DEEPCUBE/28PCV/28PCV0221.nc")
nir = ds_raw["nir"]
red = ds_raw["red"]
ndvi = (nir.data .- red.data) ./ (nir.data .+ red.data)
ds_raw.properties
n = 128
axlist = [
    RangeAxis("lon", range(-16.771841978214407, -16.7367133279811, length=128)),
    RangeAxis("lat", range(12.80406631534978, 12.839010347630571, length=128)),
    RangeAxis("time", ds_raw["time"][1:n]),
    ]

newyax = YAXArray(axlist, ndvi[:,:,1:n], ds_raw.properties)
savecube(newyax, "ndvi.zarr",driver=:zarr, overwrite=true)
