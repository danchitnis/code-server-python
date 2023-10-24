# code-server-python
Code Server for Python

## usage with docker

```bash
docker run -it -p 8080:8080 danchitnis/code-server-python
```

## usage with docker compose

first clone the repo

```bash
docker compose up
```

## Build image

```bash
docker compose build
```


## Build multi-arch image

```bash
docker buildx build --platform=linux/amd64,linux/arm64 -t {tag} . --push
```
