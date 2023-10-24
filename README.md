# code-server-python
Code Server for Python

## usage

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
