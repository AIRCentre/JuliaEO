docker load -i hands_on_makie.tar
docker run --mount type=bind,source="$(pwd)"/hands_on_makie,target=/home/jovyan/hands_on_makie -p 8888:8888 sdanisch/clima:latest
