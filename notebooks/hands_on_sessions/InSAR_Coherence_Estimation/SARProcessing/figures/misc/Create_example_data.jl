
using SARProcessing, ArchGDAL

windowA = [[100 , 1500],[7600 , 20000]]
windowB = [[3*1506 , 3*1506+1600],[7500 , 20100]]


folder = "test/testData/largeFiles/EO_workshop/"

safefolderA = "test/testData/largeFiles/EO_workshop_full/S1A_IW_SLC__1SDV_20190622T015048_20190622T015115_027786_0322F1_7A8E.SAFE"
safefolderB = "test/testData/largeFiles/EO_workshop_full/S1B_IW_SLC__1SDV_20190628T014958_20190628T015025_016890_01FC87_FC0D.SAFE"

safefolderA2 = "test/testData/largeFiles/EO_workshop_full/S1A_IW_SLC__1SDV_20190704T015049_20190704T015116_027961_03283A_191E.SAFE"
safefolderB2 = "test/testData/largeFiles/EO_workshop_full/S1B_IW_SLC__1SDV_20190710T014959_20190710T015026_017065_0201B8_069B.SAFE"

polarisation = SARProcessing.VV
swath = 2



windows = [windowA, windowB, windowA, windowB]
safe_folder = [safefolderA, safefolderB, safefolderA2, safefolderB]
filename = ["S1A_IW_SLC__1SDV_20190622T015048.tiff","S1B_IW_SLC__1SDV_20190628T014958.tiff",
     "S1A_IW_SLC__1SDV_20190704T015049.tiff", "S1B_IW_SLC__1SDV_20190710T014959.tiff" ]
     
     
for i = 1:4
    swathSub = SARProcessing.load_tiff(
        SARProcessing.get_data_path_sentinel1(safe_folder[i], polarisation, swath), 
        windows[i], convertToDouble=false)
    
    ArchGDAL.create(
        folder*filename[i],
        driver = ArchGDAL.getdriver("GTiff"),
        width=size(swathSub)[2],
        height=size(swathSub)[1],
        nbands=1,
        dtype=eltype(swathSub)
        ) do newFile
            ArchGDAL.write!(newFile,  permutedims(swathSub, (2, 1)), 1)
        end
end



function load_test_slc_image(folder, image_number)
    tiffs = ["S1A_IW_SLC__1SDV_20190622T015048.tiff","S1B_IW_SLC__1SDV_20190628T014958.tiff",
     "S1A_IW_SLC__1SDV_20190704T015049.tiff", "S1B_IW_SLC__1SDV_20190710T014959.tiff" ]
    annotation_files = ["s1a-iw2-slc-vv-20190622t015048-20190622t015113-027786-0322f1-005.xml",
    "s1b-iw2-slc-vv-20190628t014958-20190628t015023-016890-01fc87-005.xml",
     "s1a-iw2-slc-vv-20190704t015049-20190704t015114-027961-03283a-005.xml",
     "s1b-iw2-slc-vv-20190710t014959-20190710t015024-017065-0201b8-005.xml"]

    tiff_file = tiffs[image_number]
    is_S1A = split(tiff_file,"_")[1] == "S1A"

    window = is_S1A ? [[100 , 1500],[7600 , 20000]] : [[3*1506 , 3*1506+1600],[7500 , 20100]]

    metadata = SARProcessing.Sentinel1MetaData(joinpath(folder, annotation_files[image_number]))
    index_start = (window[1][1],window[2][1])
    data = SARProcessing.load_tiff(joinpath(folder, tiff_file))

    return SARProcessing.Sentinel1SLC(metadata,index_start,data,false)
end

test = load_test_slc_image(folder,4);

SARProcessing.sar2gray(test.data[:,1:4:end])

