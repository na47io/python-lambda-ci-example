FROM python:3.12-slim-bullseye
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# install zip
RUN apt-get update && apt-get install -y zip

COPY . .

WORKDIR /awslambda

# Set up the virtual environment
RUN uv venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN mkdir output
VOLUME /output

RUN mkdir -p package/awslambda && \
    cp main.py package/awslambda/ && \
    cp __init__.py package/awslambda/ && \
    uv pip install --target package -r requirements.txt && \
    cd package && \
    zip -r ../lambda.zip . && \
    cd .. && \
    rm -rf package

# To get the artifact out of the builder image
# > docker run --rm -v $(pwd)/output:/hello_world/output builder
CMD cp lambda.zip output/lambda_function.zip


