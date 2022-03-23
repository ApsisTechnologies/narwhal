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
      g++

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

COPY --from=builder-image /opt/$USER/.venv .venv
ADD ./src .
ADD ./entrypoint.sh .
RUN chmod +x entrypoint.sh

# switch to non-root user
# NOTE: See Alpine Linux add user reference for details: https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user
RUN addgroup -S $USER && adduser -D -G $USER $USER
USER $USER

ENTRYPOINT /opt/app/entrypoint.sh $0 $@

CMD ["uvicorn", "main:app", "--proxy-headers", "--loop uvloop", "--workers 1", "--log-level warning", "--no-use-colors", "--host 0.0.0.0", "--port 8000"]
