using SARProcessing, Images,Statistics

azores_path = "test/testData/largeFiles/S1A_IW_SLC__1SDV_20220918T074920_20220918T074947_045056_056232_62D6.SAFE/measurement/s1a-iw3-slc-vv-20220918t074921-20220918t074946-045056-056232-006.tiff";


azores_path_VH = "test/testData/largeFiles/S1A_IW_SLC__1SDV_20220918T074920_20220918T074947_045056_056232_62D6.SAFE/measurement/s1a-iw3-slc-vh-20220918t074921-20220918t074946-045056-056232-003.tiff";

complex_image = SARProcessing.load_tiff(azores_path,[[9200,10400],[6000,16600]])

complex_image = complex_image[:,1:4:end] 

# VV image
img = SARProcessing.sar2gray(complex_image, p_quantile = 0.98)

# Phase example
Images.Gray.((angle.(complex_image) .+pi)./(2*pi))


complex_image_VH = SARProcessing.load_tiff(azores_path_VH,[[9200,10400],[6000,16600]])

complex_image_VH = complex_image_VH[:,1:4:end] 

#VH image
img = SARProcessing.sar2gray(complex_image_VH, p_quantile = 0.98)


function plot_vv_vh(image_VV,image_VH; p_quantile = 0.98)
    min_value_VV = minimum(reshape(image_VV,:))
    factor_VV = quantile(reshape(image_VV,:),p_quantile) - min_value_VV
    VV_scaled = (image_VV .- min_value_VV) ./ factor_VV

    min_value_VH = minimum(reshape(image_VH,:))
    factor_VH = quantile(reshape(image_VH,:),p_quantile) - min_value_VH
    VH_scaled = (image_VH .- min_value_VH) ./ factor_VH

    return Images.Colors.RGB.(VV_scaled,VH_scaled,VV_scaled) 
end

## POL sar plot
plot_vv_vh(abs2.(complex_image),abs2.(complex_image_VH))