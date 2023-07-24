# JuliaEO 2023     
## Global Workshop on Earth Observation with Julia     
Repo for resources such as:
 + [Website](https://aircentre.github.io/JuliaEO/ "Up-to-date program")
 + Documentation
 + Notebooks
 + Datasets

### Documentation
A folder with documents can be found above. It includes instructions on how to use Docker in the context of this workshop:
+ [Computer Configuration](https://github.com/AIRCentre/JuliaEO/blob/5d5d1071fdac2bd65e2dc2471d74976432321280/docs/README-Docker-Intro.md "Docker Image")

### Notebooks
Notebooks can be found above within the *notebooks* folder, organised by session.
You should be able to run most notebooks outside a Docker container. In case you aren't, try the following (default) [Docker image](https://doi.org/10.7910/DVN/OYBLGK). Some sessions might use different imahes, whcih will be documented with the session

<details>
 <summary> Simple Notebook Listing </summary>
<p>

This is not necessarily a complete or up-to-date list. It notably omits notebooks used from the [JuliaClimate notebook stack](https://github.com/JuliaClimate/Notebooks#readme). 

1. Plenary sessions

- `plenary_sessions/The_Power_of_JuliaGeo/juliageo.ipynb`
- `plenary_sessions/Julia_showcases_in_Oceanography/01-DIVAnd-data-preparation.ipynb`
- `plenary_sessions/Julia_showcases_in_Oceanography/03-DINCAE-tutorial.ipynb`
- `plenary_sessions/Julia_showcases_in_Oceanography/02-DIVAnd-example-analysis-azores.ipynb`
- `plenary_sessions/SARProcessing_vision_state_of_affairs_and_roadmap/placeholderfile.jl`
- `plenary_sessions/Raster_data_Reading_Manipulating_and_Visualising/rasters_demo.jl`

2. Hands sessions

- `hands_on_sessions/Processing_LiDAR_elevation_point_clouds_using_vector_data_in_Julia/spacelidar.ipynb`
- `hands_on_sessions/Processing_LiDAR_elevation_point_clouds_using_vector_data_in_Julia/geointerface.ipynb`
- `hands_on_sessions/Processing_LiDAR_elevation_point_clouds_using_vector_data_in_Julia/pointclouds.ipynb`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie no docker/hands-on-makie.ipynb`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie/hands-on-makie.ipynb`
- `hands_on_sessions/Data_Visualizations_with_Makie/Visualization_of_Earth_Observations_Data/Vis_EOD.ipynb`
- `hands_on_sessions/Datacubes_for_high-resolution_EO_data/handson.ipynb`
- `hands_on_sessions/hands_on_makie/hands-on-makie.ipynb`
- `hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/3_Object_detection.ipynb`
- `hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/1_Load_Image.ipynb`
- `hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/4_insar.ipynb`
- `hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/2_Speckle.ipynb`
- `hands_on_sessions/Julia_Use_Case_for_Change_Detection/userqa.ipynb`
- `hands_on_sessions/Julia_for_beginners/Julia_for_beginners.ipynb`

- `hands_on_sessions/Advanced_Geodata_Science_&_Geostatistical_Learning/hands_on_geostats/geodatascience.jl`
- `hands_on_sessions/Advanced_Geodata_Science_&_Geostatistical_Learning/hands_on_geostats/geostatslearn.jl`
- `hands_on_sessions/Advanced_Geodata_Science_&_Geostatistical_Learning/hands_on_geostats/geodatascience-docker.jl`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie no docker/widgets.jl`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie no docker/clima-plot.jl`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie/widgets.jl`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie/clima-plot.jl`
- `hands_on_sessions/Data_Visualizations_with_Makie/Visualization_of_Earth_Observations_Data/genzarr.jl`
- `hands_on_sessions/Datacubes_for_high-resolution_EO_data/placeholderfile.jl`
- `hands_on_sessions/Land_Cover_Classification_of_Earth_Observation_images/rasters_flux_eo_classification.jl`
- `hands_on_sessions/Retrieving_satellite_and_reanalysis_data_from_EO_servers/02-NASAPrecipitation.jl`
- `hands_on_sessions/Retrieving_satellite_and_reanalysis_data_from_EO_servers/01-GeoRegions.jl`
- `hands_on_sessions/RF_classification_using_marida/RF_classification_using_marida.jl`
- `hands_on_sessions/hands_on_makie/widgets.jl`
- `hands_on_sessions/hands_on_makie/clima-plot.jl`
- `hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/figures/misc/azores_image.jl`
- `hands_on_sessions/Working_with_SAR_and_InSAR_Data/SARProcessing/figures/misc/Create_example_data.jl`
- `hands_on_sessions/Julia_Use_Case_for_Change_Detection/userqa_full.jl`
- `hands_on_sessions/Julia_Use_Case_for_Change_Detection/plot_sentinel1.jl`

## Environment Files for Jupyter Notebooks

- `plenary_sessions/The_Power_of_JuliaGeo/Manifest.toml`
- `plenary_sessions/The_Power_of_JuliaGeo/Project.toml`
- `plenary_sessions/Julia_showcases_in_Oceanography/Manifest.toml`
- `plenary_sessions/Julia_showcases_in_Oceanography/Project.toml`
- `plenary_sessions/Data_science_big_data_and _cloud_native_solutions/Manifest.toml`
- `plenary_sessions/Data_science_big_data_and _cloud_native_solutions/Project.toml`
- `hands_on_sessions/Data_Visualizations_with_Makie/Plots_Animations_&_Graphics/hands_on_makie no docker/Project.toml`
- `hands_on_sessions/Data_Visualizations_with_Makie/Visualization_of_Earth_Observations_Data/Manifest.toml`
- `hands_on_sessions/Data_Visualizations_with_Makie/Visualization_of_Earth_Observations_Data/done_at_Workshop/Manifest.toml`
- `hands_on_sessions/Data_Visualizations_with_Makie/Visualization_of_Earth_Observations_Data/Project.toml`
- `hands_on_sessions/Datacubes_for_high-resolution_EO_data/Manifest.toml`
- `hands_on_sessions/Datacubes_for_high-resolution_EO_data/Project.toml`
- `hands_on_sessions/Retrieving_satellite_and_reanalysis_data_from_EO_servers/Manifest.toml`
- `hands_on_sessions/Retrieving_satellite_and_reanalysis_data_from_EO_servers/Project.toml`
- `hands_on_sessions/Julia_Use_Case_for_Change_Detection/Manifest.toml`
- `hands_on_sessions/Julia_Use_Case_for_Change_Detection/Project.toml`
- `hands_on_sessions/Julia_for_beginners/Manifest.toml`
- `hands_on_sessions/Julia_for_beginners/Project.toml`

## Links to the YouTube videos 

- [Julia for Beginners L. Alonso & S. Danisch](https://www.youtube.com/watch?v=5vvMRETv9fA&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=15)
- [Datacubes for High Resolution EO Data F. Cremer](https://www.youtube.com/watch?v=XuZGBmCYYSU&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=14)
- [Data Visualizations with Makie.jl L. Alonso & S. Danisch](https://www.youtube.com/watch?v=ocXFwzWnaM8&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=13)
- [Data Science, Big Data, and Cloud Native Solutions F. Gans & M. Klöwer](https://www.youtube.com/watch?v=oMxu_r1uqKY&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=12)
- [Advanced Geodata Science & Geostatistical Learning J. Hoffimann](https://www.youtube.com/watch?v=9dO941FSUd8&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=11)
- [Julia Showcases in Oceanography A. Barth & G. Forget](https://www.youtube.com/watch?v=zaWGrzp1aY8&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=16)
- [Land Cover Classification of Earth Observation Images R. Schouten](https://www.youtube.com/watch?v=uGqlap_kl-g&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=17)
- [Machine Learning with Geospatial Data, What Can Go Wrong J. Hoffimann](https://www.youtube.com/watch?v=_iIOqZNoMw4&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=18)
- [MBON, Ocean Biomes Monitoring, and Marine Ecosystem Modeling F. Muller Karger, A. Lima & G. Forget](https://www.youtube.com/watch?v=oz8Un-eLmWo&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=19)
- [Raster Data Reading, Manipulating, and Visualising R. Schouten](https://www.youtube.com/watch?v=NJbd2tYnLr8&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=20)
- [Julia Use Case for Change Detection F. Cremer](https://www.youtube.com/watch?v=kCBbvt8NEjo&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=21)
- [Regional Ocean Data G. Forget, A. Valente & E. Castanho](https://www.youtube.com/watch?v=Xf0tHBqhx7o&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=22)
- [Processing LiDAR elevation point clouds using vector data in Julia M. Pronk](https://www.youtube.com/watch?v=AW0gQdnUaxc&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=23)
- [Retrieving Satellite and Reanalysis Data from EO Servers N. Wong & A. Barth](https://www.youtube.com/watch?v=41QnwHyRmDg&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=24)
- [SAR Data Manipulation F. Cremer](https://www.youtube.com/watch?v=OvQ9ZyZ43TM&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=25)
- [SARProcessing jl: Background and Method S. Lupemba & E. Lippert](https://www.youtube.com/watch?v=AcbEtkvcyTg&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=26)
- [SARProcessing jl: Vision, State of Affairs, and Roadmap E Lippert, S Lupemba, K. Sorensen](https://www.youtube.com/watch?v=yVk8AzPd4OU&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=27)
- [Simulating Oceanic Pathways of Plastics, Pollutants, or Marine Ecosystems G. Forget](https://www.youtube.com/watch?v=XG3KdoOGA3s&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=28)
- [The Power of JuliaGeo M. Visser](https://www.youtube.com/watch?v=FDry8ly36o4&list=PL-3G0PUXakeY_XdNYhcJgsrnaO9-hL54z&index=29)


</p>
</details>

### Datasets
[Datasets](https://github.com/gdcc/Dataverse.jl#readme "Dataverse archive")

