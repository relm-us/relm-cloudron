# Relm on Cloudron

A docker container of Relm for [Cloudron](https://www.cloudron.io/).

NOTE: Work in progress. This container does not yet work with Cloudron.

See https://github.com/relm-us/relm/issues/30 for progress.

## Intro

Relm is a 3D world in a browser. This repository holds configuration to host it
in Cloudron, which is a solution for self-hosting apps on your server.

## Building & Testing the Docker Image

```sh
docker build -f Dockerfile.cloudron -t relm .
```

Before testing the image, set up a database, e.g. in another tab:

```sh
cd relm
docker compose up -d
```

Then run the relm container we built:

```sh
docker run -it --rm \
  -p 3000:3000 \
  -e DATABASE_URL=postgres://relm:relm@db.relm.orb.local:5432/relm \
  -e RELM_SERVER_URL=http://localhost:3000/api \
  -e RELM_UNSAFE_AUTOINIT=true \
  relm
```
