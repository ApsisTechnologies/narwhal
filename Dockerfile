ARG PYTHON_VERSION=3.9
ARG USER=app

####################################################
# BUILDER IMAGE
####################################################
FROM python:$PYTHON_VERSION-alpine AS builder-image

ARG APP_NAME=app

ENV POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1

# NOTE: uncomment this to install a specific Poetry version
# ENV POETRY_VERSION=1.1.12

ENV APP_PATH=/opt/$APP_NAME
ENV PATH=$POETRY_HOME/bin:$PATH

# install uvicorn dependencies (used to compile uvloop)
RUN apk update && \
    apk add \
      curl \
      make \
      g++ \
      cmake \
      autoconf \
      automake \
      libtool \
      libexecinfo-dev
      

# install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

WORKDIR $APP_PATH

ADD poetry.lock .
ADD pyproject.toml .

RUN poetry install --no-dev

####################################################
# App base image
####################################################
FROM python:$PYTHON_VERSION-alpine AS app-image-base

ARG USER

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONBUFFERED=1
ENV NARWHAL_DISABLE_DOCS=true

WORKDIR /opt/$USER

RUN apk update && \
    apk add \
    curl \
    libtool \
    libexecinfo-dev \
    libstdc++ \
    libcurl \
    build-base

COPY --from=builder-image /opt/$USER/.venv .venv
ADD ./src .
ADD ./entrypoint.sh .
RUN chmod +x entrypoint.sh

RUN mkdir -p /opt/.aws-lambda-rie && \
    curl -Lo /opt/.aws-lambda-rie/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie && \
    chmod +x /opt/.aws-lambda-rie/aws-lambda-rie


# switch to non-root user
# NOTE: See Alpine Linux add user reference for details: https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user
RUN addgroup -S $USER && adduser -D -G $USER $USER
USER $USER

ENTRYPOINT ["/opt/app/entrypoint.sh"]
CMD [ "main.handler" ]