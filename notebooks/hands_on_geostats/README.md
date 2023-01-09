# GeoStats.jl @ JuliaEO2023

Instructor: [Júlio Hoffimann](https://github.com/juliohm)

## Agenda

- [10min]: Introduction slides
- [45min]: Advanced geodata science
- [15min]: Coffee break & questions
- [45min]: Geostatistical learning

## Instructions

### During the event

1. [Download](https://github.com/juliohm/JuliaEO2023/archive/refs/heads/main.zip) the repository and unzip the folder
2. If you have Docker installed, change to the folder and run
```bash
$ docker run -v ${PWD}:/home/jovyan/geostats -p 8888:8888 gaelforget/notebooks:latest
```
3. Launch Pluto and open the notebook [geodatascience-docker.jl](geodatascience-docker.jl)

For more information, please follow the [event instructions](https://github.com/AIRCentre/JuliaEO/blob/main/docs/README-Docker-Intro.md).

### After the event

To run all notebooks after the live session, folow the steps below instead:

1. Install `Julia v1.9.0-beta2` (or `Julia v1.9.0` when it is released)
2. Install `Pluto v0.19.19` from the Julia REPL
```julia
] add Pluto@0.19.19
```
3. Launch Pluto and open the notebooks [geodatascience.jl](geodatascience.jl) and [geostatslearn.jl](geostatslearn.jl)
