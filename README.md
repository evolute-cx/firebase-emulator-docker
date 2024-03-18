# firebase-emulator-docker

A dockerized firebase emulator setup, that _actually_ exports existing data when the container shuts down and re-imports data when the container starts up again \*

We created this image because https://hub.docker.com/r/spine3/firebase-emulator failed to export and restore emulator state and they didnt publish a configurable Dockerfile

\* In order to make this export/import work, a volume is needed - see below "Persisting data"

## How to use:

### docker-compose

1. Clone the repo
2. Enter your Firebase Project ID as environment variable `FB_PROJECT_ID` in the `docker-compose.yml`-File
3. cd into the cloned directory
4. Run `docker-compose up` in that directory to spin up the emulators (this has a volume definition for exporting and importing data - see "Persisting Data" to understand what this means 😉)

### docker run

you can use ordinary docker-commands like so:
(Important: You need to specify your Firebase Project ID with the environment variable `FB_PROJECT_ID`)

```sh
docker run -d \
  --name firebase-emulator \
  -e FB_PROJECT_ID=[your_project_id] \
  evolutecx/firebase-emulator:latest
```

### Supported architectures

From beginning of version `0.0.3` the pre-built images support `linux/amd64`, `linux/arm64`, `linux/ppc64le` and `linux/s390x` out of the box. By the time of this release this was all the architectures we could build for based on the latest node-18-alpine image.

Versions up to `0.0.2` only support `linux/amd64` (which results in poor performance when running on apple silicon chips) - the change from version 0.0.2 to 0.0.3 is actually only the multi-architecture build, nothing else, so upgrading to 0.0.3 should be safe.

The right architecture will be used during container creation.

If you need more architectures to be suppported let us know [on our github](https://github.com/evolute-cx/firebase-emulator-docker)

You can also build your own Image for more architectures

## Adresses

The emulators will be available under these addresses:

- Emulator UI: [http://localhost:4000](http://localhost:4000)
- Auth Emulator: [http://localhost:9099](http://localhost:9099)
- Firestore Emulator: [http://localhost:8080](http://localhost:8080)
- Functions Emulator: [http://localhost:5001](http://localhost:5001)
- Cloud Storage Emulator: [http://localhost:9199](http://localhost:9199)
- Realtime DB Emulator: [http://localhost:9000](http://localhost:9000)

## Changing Firebase Config/Ports

You can mount a custom firebase.json into the container to configure your firebase emulator.

This will give you the ability to change several configuration options, e.g. the ports the container is exposing.

In order to do this, create a custom firebase.json file and mount it into the `/firebase`-directory of the container, like so:

### With Docker:

        volumes:
          # Mounting a different firebase.json-config into the container to make it run on different ports
          - ${PWD}/dev/docker-compose/firebase-emulator/firebase_itest.json:/firebase/firebase.json

```sh
docker run -d \
  --name firebase-emulator \
  -v ./firebase_data:/firebase/data \
  -e FB_PROJECT_ID=[your_project_id] \
  evolutecx/firebase-emulator:latest
```

## Persisting Data

The container is configured in a way that it exports all data to `/firebase/data/export` on shutdown and re-imports it from there during startup.

In order to persist data between runs, a volume is needed.

IMPORTANT: The volume should mount to `/firebase/data` in the container, do NOT explicitly mount to `/firebase/data/export`, as the emulator will error with `Export failed: dest already exists`

### With Docker

Define a named volume that points to the `/firebase/data`-folder in the container.

```sh
docker run -d \
  --name firebase-emulator \
  -v ./firebase_data:/firebase/data \
  -e FB_PROJECT_ID=[your_project_id] \
  evolutecx/firebase-emulator:latest
```

### with docker-compose:

Make sure you define a volume-section for your service in your docker-compose file, like so:

```yaml
services:
  firebase-emulator:
    container_name: firebase-emulator
    build:
      context: .
      dockerfile: Dockerfile
    restart: always
    ports:
      - 4000:4000 #Emulator UI
      - 9099:9099 #Firebase Auth
      - 9199:9199 #Firebase Cloud Storage
      - 9000:9000 #Firebase Realtime database
    environment:
      - FB_PROJECT_ID=[YOUR_PROJECT_ID]
    volumes:
      - ./firebase-data:/firebase/data:rw # <- this stores data on shutdown to ./firebase-data/data/export on your host
```

## Building for more architectures

From beginning of version 0.0.3 the pre-built images support `linux/amd64`, `linux/arm64`, `linux/ppc64le` and `linux/s390x` out of the box. By the time of this release this was all the architectures we could build for based on the latest node-18-alpine image.

You can try building a new version of the image and pushing it to dockerhub yourself:
`docker buildx build --platform linux/amd64,linux/arm64,[other_architectures_you_want_to_support] -t [username]/[image]:[version] .`

More information here: [https://docs.docker.com/build/building/multi-platform/](https://docs.docker.com/build/building/multi-platform/)

## Contribution

Feel free to fork the repo and create Merge requests to our repo. Otherwise feel free to create an issue and we will have a look.
