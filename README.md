# JuliaEO - Earth Observation with Julia Workshop
Repository (datasets, code, etc.), and landing page for the workshop. Contains the **up-to-date-program**.

The communication Slack channel ***juliaeo2023***  
Channel ID: ***C0480TAQJ9Y***

<p align="center">
  <img src="/Users/igaszczesniak/Desktop/AIRcentre-01-scaled.jpg" height="200"><br>

**Date**: 9-13 January 2023     
**Place**: [Science and Technology Park](https://terinovazores.pt/), on [Terceira Island](https://exploreterceira.com), in the [Azores](https://en.wikipedia.org/wiki/Azores).     
**Type**: In-person, full-week, technical and networking.  
**Accommodation**: Speakers will be hosted in [Hotel do Caracol](https://www.hoteldocaracol.com)**** in Angra do Heroísmo, Terceira Island. 
 

*The AIR Centre provides a shuttle for each workshop day in the morning and afternoon. The evening networking event will be held in the Historic Centre of the Town of [Angra do Heroísmo](https://en.wikipedia.org/wiki/Angra_do_Hero%C3%ADsmo) ​​inscribed on the UNESCO World Heritage List.*

## Introduction  

The following training workshop aims at providing quality computer programming skills to the staff members of the AIR Centre's [Earth Observation Laboratory (EO Lab)](https://www.aircentre.org/eo-lab/) located on Terceira Island, in the Azores. The EO Lab is only three years old, and much of its staff is at the beginning of their career, while others are transitioning from older programming languages/methods/paradigms. The shift from graphical user interface GUI-based work to computer coding (programming) is fundamental to support both *replicable research* and the upscaling of solutions to *prototypes* and *proofs-of-concept*, which better permeate the economy.

To simulate collaboration beyond the training, the workshop is presential (full week). However, for a wider reach, we aim to deliver several sessions online.

The topics to be covered include acquisition, processing, visualisation, and classification of Earth Observation data, using the [Julia programming language](https://julialang.org/).



The open-source Julia language is relatively recent. It was created at the [Massachusetts Institute of Technology (MIT)](https://www.mit.edu), first released in 2012, and reached the v1.0 milestone in 2018. Julia has a vocation for high-performance scientific computing, making it today's ideal choice to work on resource-intensive datasets such as the Earth Observation ones.

The training workshop will emphasize practical activities including the use of novel datasets, libraries/packages, automated workflows, Artificial Intelligence (AI), and classification algorithms. Theory-oriented sessions will introduce the concepts and hands-on activities.

Beyond the direct advantages of the staff training, the concentration of talent in one event responds to a long-term vision of the EO Lab to embed itself and its staff members into "lower-level" scientific networks, creating new opportunities for collaboration and contributing to shaping the agenda.

Mutual benefits arising from the collaboration of the AIR Centre and the Julia community are:

* Capacity building for AIR Centre's staff and other invited institutions. 
* Create collaboration opportunities between the participants and speakers.
* Create the potential to extend the Portuguese contribution to the scientific community.
* Bringing together the two communities around Julia: developers and end-users.
* Opening new avenues for collaboration on both software and science.
* Contributing to strengthening the open source / science community.
* Creating an axis of collaboration to study the Azores region using Earth Observation, numerical models, and data products, possibly with the goal of co-advising students.
* Finding new prospective contributors to Julia packages; helping developers build up their user community; identifying needs and desired new features.
* Providing additional exposure for the products and activity of the AIR Centre; via US and EU growing Julia communities.



## Program   

The workshop will encompass different levels of expertise, from beginner to advanced, with a focus on Earth Observation concepts and programming skills. Our idea is to provide a single track of sessions in the morning and more detailed parallel sessions in the afternoon and to split people evenly on the double track part. There are three types of activities:

* **Plenary sessions (45’)** - Cross-disciplinary training focused on theory and high-level concepts. These include the presentation of novel EO datasets i.e. satellite data, ocean models, and model products; processing & visualization techniques as well as available tools and packages. The first goal is to learn about new datasets and sources, libraries, packages, techniques, and implementation details. A secondary aim of this module is to identify gaps in the EO domain and opportunities to close those gaps using the Julia programming language. 

* **Hands-on sessions (1h55’)** - The modules will focus on concrete goals in data acquisition, processing & visualization techniques for example. They are designed to bridge between concepts and real-life application through extended tutorials. Attendees will get an introduction, through these tutorials, to performing common geospatial tasks using Julia geospatial tools and common geospatial libraries and packages.
 
* **General hackathons (1h)** - Session that brings together Julia developers and AIR Centre EO Lab staff in order to enhance collaboration on EO applications and software development. The goal is to organize the last module of the day in the common room and enable everyone to work on intermediate & advanced level aspects according to their specific interests. 


### Day 1 – 09.01.2023 

**8:30** Shuttle (Hotel - Terinov)

**9:00 – 9:15** Welcome speech and program presentation

**9:15 – 10:00** Plenary session 1 The Power of JuliaGeo *M. Visser*

**10:00 – 10:20** Coffee break

**10:20 – 12:15** Hands-on session 1 Julia for beginners *L. Kilpatrick*

**12:15 – 13:15** Lunch break

**13:15 – 14:00** Plenary session 2 Raster data manipulation: downloading, reading, and visualising *R. Schouten*

**14:00 – 15:55** Hands-on session 2.1 Retrieving remote sensing indices and Masking *M. Visser*

**14:00 – 15:55** Hands-on session 2.2 Classification of EO images *R. Schouten*

**15:55 – 16:15** Coffee break

**16:15 – 17:15** General hackathon: Performing Land Cover/Land Use Classification

**17:30** Shuttle (Terinov - Hotel)

**20:00** Networking event

-------------------------------------------------------------

### Day 2 – 10.01.2023

**8:30** Shuttle (Hotel - Terinov)

**9:00 – 9:45** Plenary session 1 SAR data manipulation *F. Cremer*

**9:45 – 10:05** Coffee break

**10:05 – 12:00** Hands-on session 1 Makie.jl – Plotting, animations, & graphics *S. Danisch, L. Alonso*

**12:00 – 13:00** Lunch break

**13:00 – 13:45** Plenary session 2.1 Visualise your data on the map -  How to manipulate vector/raster data and spatial reference systems *M. Visser*

**13:00 – 13:45** Plenary session 2.2  SARProcessing.jl – Possibilities and Challenges *S. Lupemba*

**13:45 – 15:40** Hands-on session 2.1 Julia Use Case for Change Detection *F. Cremer*

**13:45 – 15:40** Hands-on session 2.2 InSAR Coherence estimation *E. Lippert*

**15:40 – 16:00** Coffee break

**16:00 – 17:00** General hackathon: Natural hazards monitoring (Building new features for SARProcessing.jl if possible)

**17:15** Shuttle (Terinov - Hotel)

**19:30** Opening dinner

-------------------------------------------------------------

### Day 3 – 11.01.2023

**8:30** Shuttle (Hotel - Terinov)

**9:00 – 9:45** Plenary session 1 Julia showcases in Oceanography *A. Barth*

**19:45 – 10:05** Coffee break

**10:05 – 12:00** Hands-on session 1 Climate models, accessing reanalysis data, and running model simulations using Julia *G. Forget*

**12:00 – 13:00** Lunch break

**13:00 – 14:00** General hackathon: Characterization of Marine Ecosystems from Space

**14:15** Shuttle (Terinov - Hotel)

-------------------------------------------------------------

### Day 4 – 12.01.2023

**8:30** Shuttle (Hotel - Terinov)

**9:00 – 9:45** Plenary session 1 Data science, big data, and cloud native solutions *F. Gans?*

**9:45 – 10:05** Coffee break

**10:05 – 12:00** Hands-on session 1 High-performance geostatistics in Julia *J. Hoffimann*

**12:00 – 13:00** Lunch break

**13:00 – 13:45** Plenary session 2.1 Using gridded climate data for trend estimation and classification *G. Forget*

**13:00 – 13:45** Plenary session 2.2 JuliaEarth applications *J. Hoffimann*

**13:45 – 15:40** Hands-on session 2.1 Simulating oceanic pathways of plastics, pollutants, or marine ecosystems *G. Forget*

**13:45 – 15:40** Hands-on session 2.2 Estimation of water storage in medium and small reservoirs *M. Pronk*

**15:40 – 16:00** Coffee break

**16:00 – 17:00** General hackathon: Climate Change – Trends time series analysis and anomalous events 

**17:15** Shuttle (Terinov - Hotel)

-------------------------------------------------------------

### Day 5 – 13.01.2023

**8:30** Shuttle (Hotel - Terinov)

**9:00 – 9:45** Plenary session 1 SARProcessing.jl – vision, state of affairs, and roadmap *E. Lippert, S. Lupemba, I. Szczesniak*

**19:45 – 10:05** Coffee break

**10:05 – 12:00** Hands-on session 1.1 Datacubes for high-resolution EO data *F. Cremer, F. Gans?*

**10:05 – 12:00** Hands-on session 1.2 Retrieving Bio-Geophysical parameters from space *N. Wong?, A. Barth*

**12:00 – 13:00** Lunch break

**13:00 – 13:15** Workshop closure/farewell speech 

**13:30 Shuttle** (Terinov - Hotel)


## Speakers Bios'
The following 14 speakers have been selected from the Julia community to participate in this training event. The speakers involve a mix of seasoned and young/aspiring scientists.
The selection was based on the level of skill and commitment demonstrated, with contributions to the EO software packages which are most needed for AIR Centre's current work and future development.


### Júlio Hoffimann
Dr. Júlio has more than 10 years of experience in advanced statistical theories for geosciences. He is creator and lead developer of the GeoStats.jl project, as well as various other open source projects that are widely used by geoscientists around the world.

* LinkedIn: [link](https://www.linkedin.com/in/j%C3%BAlio-hoffimann-834936116)
* Gitgub: [link](https://github.com/juliohm)
* ORCID: [link](https://orcid.org/0000-0003-2789-297X)

### Simon Kok Lupemba

Junior Remote Sensing Scientist at EUMETSAT working in the scatterometry team. I support the quality monitoring, calibration and validation of operational scatterometer products and also prototype and maintain processing software for the extraction of products.

I am a MSc graduate in Earth and Space Physics and Engineering from DTU and I have hands-on experience working with SAR data from my studies. Most of my academic projects focused on processing SAR images e.g. speckle filtering, interferometric coherence and automated flood mapping. I have implemented InSAR coherence processing in Julia (programming language) without using commercial software or SAR related libraries.

I have also worked as an IT-consultant at Netcompany for 2 years where I was involved with support, maintenance and development of medium-sized public IT projects. My regular tasks included; defining and estimating tasks, developing new features, fixing existing bugs and providing general support.

* LinkedIn: [link](www.linkedin.com/in/simon-kok-lupemba)
* Gitgub: [link](https://github.com/lupemba)


## Outcomes 
* Capacity building of the AIR Centre and other institutions invited.
* Establish relationships with, and expand the Julia community. 
* Establish the AIRCentre as an active member of that community. 
* Contribute to the development of existing packages.
* Identify opportunities for the creation of new packages.
* Strengthen the scientific community/network around the Atlantic/world.
* Seeding future collaborations.


## FAQ

1. Is the a fee to attend the workshop? *No.*
2. Do I need to register to attend the workshop?     
*Yes. If you (your institution) received an invitation, please write to juliaeo@aircentre.org and request access to the form to register.*     
3. Does the AIR Centre provide transfers from the airport to the hotel? *Yes but for the speakers only.*
4. How to access the Slack channel? *Type juliaeo2023 in the Slack search bar.*
