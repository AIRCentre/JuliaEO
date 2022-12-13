
# `JuliaEO/2023` Intro to using Docker for workshop

- date : 2022/12/13
- presenter : Gael Forget

## Summary

- why Docker for this?
	- custom & controlled environment for attendees & speakers
	- ability to run speaker notebooks ahead of time & later on
	- portable environment on your computer, cluster, or cloud service
	- **our immediate use case : run docker image on your laptop at workshop**
- what's Docker? 
	- <https://docs.docker.com/get-started/overview/>
	- _Docker provides the ability to package and run an application in a loosely isolated environment called a container._
	- _An image is a read-only template with instructions for creating a Docker container._
	- _A container is a runnable instance of an image. You can create, start, stop, move, or delete a container using the Docker API or CLI._
- Before workshop (users & devs):
	- [install Docker desktop](https://docs.docker.com/get-docker/) (includes CLI)
	- try out `jupyter/base-notebook:latest` (see below)
	- try out `gaelforget/notebooks:latest` (see below)
- Before workshop (devs):
	- share notebook that runs within container
	- (if needed) provide further image customization
	- (if needed) provide data sets separately
- At workshop (users & devs)
	- (as needed) add data sets onto containers via `docker run`
	- run demos and particpate in hands-on session within container(s)
	- **minimize disruptions related to computer environments**

## Commands

1. Open `terminal window` and `Docker desktop`. 
2. Try out base Jupyter notebook image. In terminal window type:
	- `docker run -p 8888:8888 jupyter/base-notebook:latest`
3. Open URL from terminal window in web-browser
	- `http://127.0.0.1:8888/lab?token=1f8f...a63b` 
4. repeat with the `JuliaClimate/Notebooks` image:
	- `docker run -p 8888:8888 gaelforget/notebooks:latest`
5. repeat with mounting a data set folder
	- `docker run -v $(PWD)/MBON_datasets:/home/jovyan/MBON_datasets -p 88...latest`
	- `docker run -v $(PWD)/worldcover2021:/home/jovyan/worldcover2021 -p 88...latest`
	- docker run -v -p 8888:8888 gaelforget/notebooks:latest`

## Notes / Tips

- Copy token from `docker run` immediately. 
	- Will facilitate restarting container and notebooks.
- Pause & restart via `Docker desktop`.
	- Restarting is when you will need the token.
- File system. 
	- Only the mounted folder (see `docker run -v ...` command above) will be available from the host (read and write) 
	- Within the container, files will persist through pause & restart. This includes the `work` folder.
	- At any time files can be downloaded from container to host. Do this as backup to avoid losing work.
