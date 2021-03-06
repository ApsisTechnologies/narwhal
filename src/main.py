from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from os import environ
from mangum import Mangum

NARWHAL_DISABLE_DOCS = bool(environ.get('NARWHAL_DISABLE_DOCS') == 'true')

app_name = 'FastAPI'

# Disable docs based on
app = FastAPI(
  title=app_name,
  docs_url=None,
  redoc_url=None,
  openapi_url=None
) if NARWHAL_DISABLE_DOCS else \
  FastAPI(title=app_name)

# enable CORS
app.add_middleware(
  CORSMiddleware,
  allow_origins=['*'],
  allow_credentials=True,
  allow_methods=['*'],
  allow_headers=['*'],
)

@app.get('/')
async def hello():
  return {
    'Hello': app_name
  }

def handler(event, context):
    asgi_handler = Mangum(app)
    response = asgi_handler(event, context)

    return response
