# running 2 containers in same network

docker network create nginx-network
docker run --name nginx1 --rm --network nginx-network -d nginx:alpine
docker run --name nginx2 --rm --network nginx-network -d nginx:alpine
docker exec -it nginx1 sh
ping nginx2

