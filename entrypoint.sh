#!/bin/sh

set -e

# activate our virtual environment here
. /opt/app/.venv/bin/activate

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
    exec /opt/.aws-lambda-rie/aws-lambda-rie python3.9 -m awslambdaric $1
else
    exec python3.9 -m awslambdaric $1
fi

