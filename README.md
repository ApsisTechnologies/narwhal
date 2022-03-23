![alt Narwhal logo](logo.png)

# Narwhal: Fast & Secure Python Microservices

Narwhal is a framework to speed up development and deployment of Python microservices.

Narwhal is based on [FastAPI](https://fastapi.tiangolo.com/) application written in [Python](https://www.python.org/) that can be easily deployed as an ultra-lightweight Docker container, making it ideal for deploying your app on [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html), [AWS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html), [Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/), [Google Cloud Run](https://cloud.google.com/run) or your favorite container runtime environment.

# Main Features

- Uses [FastAPI](https://fastapi.tiangolo.com/uk/deployment/server-workers/) as server framework. 🚀️

- Pre-configured to use [uvicorn](https://www.uvicorn.org/) and [uvloop](https://github.com/MagicStack/uvloop) for lightning-fast performance. ⚡️

- Uses [Poetry](https://python-poetry.org/docs/) for simple dependency management. ✨️

- Hot reloading for fast development. 🪄️

- Super lightweight container images thanks to [multi-stage](https://docs.docker.com/develop/develop-images/multistage-build/) Docker build and [Alpine Linux](https://www.alpinelinux.org/about/) (starts at ~70MiB). 🪶️

- Docker image pre-configured to run as a non-root user by default for extra safety. 🔒️

# Dependencies

Make sure you have the following dependencies installed to run in development mode:

- Poetry
- Docker
- Make (for running various pre-configured commands)

# Getting started

## Clone the project

```bash
$ git clone git@github.com:ApsisTechnologies/narwhal.git
```
## Run in development mode

```bash
$ cd narwhal

# start local server on localhost, port 8000
$ make dev
```
## Run as a Docker container

```bash
# run container, also on localhost, port 8000
$ make serve
```

# Notes

### Application source code

The `src` directory contains the application code which is deployed onto the container image.

You'll need to modify `Dockerfile` if you wanted to include other source code locations in your app.

### Automatically-generated OpenAPI documentation

FastAPI provides several OpenAPI doc endpoints at the following routes:

- `/docs`: OpenAPI/Swagger docs.
- `/redoc`: [Redoc](https://redocly.com/redoc/) docs.
- `/openapi.json`: OpenAPI .json spec file.

You can disable these endpoints by passing `NARWHAL_DISABLE_DOCS=true` as an environment variable.

When building the container via `make build` command, these endpoints are disabled by default.

### Docker image naming

The name of the Docker image is derived from the `name` and `version` fields inside `pyproject.toml`. The `Makefile` configuration extracts these fields automatically and passes them to Docker to tag the image as `"<project name>:<project version>"`.

### CORS support

The application is pre-configured to support [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) headers.

### Header proxying

The Docker image passes `--proxy-headers` as a `uvicorn` parameter so that your app can run behind a server that takes care of HTTPS. If this is not the case for your app you'll need to modify `Dockerfile` to remove this flag.

### Non-root image user

Most Linux images run as root by default which is a dangerous practice. The image comes pre-configured to run as a non-root user, only using `root` user access during the build stages.

See `Dockerfile` for more details.

### Modifying Python version

This project uses Python v3.9 by default. To modify this you can modify the line `ARG PYTHON_VERSION=3.9` inside `Dockerfile`.
