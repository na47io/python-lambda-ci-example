# python-lambda-ci-example

This repo demonstrates a CI-ready(-ish) python handler.

`build.dockerfile` is a builder image, `test.dockerfile` runs the tests.

I made this to avoid using [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/using-sam-cli.html). More like SOY CLI...

Useful for deploying a "generic" lambda handler, when you don't know / don't control the upstream event source. This might be the only option if you want to hit an internal endpoint that does not speak Lambda.

## Requirements

You only need `docker`. The images use [uv](https://github.com/astral-sh/uv/tree/main) to go fast.

## Build

Zipped functions have faster coldstarts than their docker-image counterparts.

First, create an image with the build artifact (note the `builder` tag):

```bash
docker build . -f docker/build.dockerfile -t builder
```

then extract the artifact into your host:

```bash
docker run --rm -v $(pwd)/output:/awslambda/output builder
```

__NB__ you might need to create the `output` directory on your host.

Deploy the zip file by hand or using your favourite IAC tool.

## Test

~~Lazily~~ Pragmatically, I don't attempt to test the handler inside the Lambda runtime.

Instead:

1. Run `pytest` with a fake event
2. hope for the best.

At the time of writing local lambda runtimes are limited and usually not worth the time anyway.

```bash
docker build . -f docker/test.dockerfile -t test && docker run --rm test
```

Good luck!
