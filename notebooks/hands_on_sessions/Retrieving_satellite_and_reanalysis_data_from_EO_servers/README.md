# JuliaEO 2023, Day 5, Session 1.2

This repository contains the required Project.toml, notebooks and data for Day 5, Session 1.2 of the JuliaEO 2023 workshop.

## Setup

### 1. Repository Setup

First, clone this repository using
> git clone https://github.com/natgeo-wong/JuliaEO2023.git

Next, instantiate and install the required packages with the following steps:
> cd JuliaEO2023
> 
> ]activate .
> 
> instantiate

After these steps, you should have the required packages (and exactly the same versions that I have.)

### 2. EarthData Setup

If you have not created an EarthData account with NASA, please do so (required for NASAPrecipitation.jl downloads, more information [here](https://natgeo-wong.github.io/NASAPrecipitation.jl/dev/download.html)).

1. Create a `.dodsrc` file in your home directory:
    > `HTTP.COOKIEJAR=<home-directory>/.urs_cookies`
    > 
    > `HTTP.NETRC=<home-directory>/.netrc`
2. Create a `.netrc` file in your home directory containing the following Earthdata login information:
    > machine urs.earthdata.nasa.gov login JuliaEO2023 password JuliaEO2023password

### 3. Pluto Notebooks

I prefer to use Pluto notebooks over Jupyter notebooks due to their responsiveness and reactivity.  To install the Pluto.jl package:
> ]add Pluto

## Run notebooks
Run Pluto notebooks using the following command:
> using Pluto
>
> Pluto.run()
