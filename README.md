# firebase-emulator-docker

A dockerized firebase emulator setup, that _actually_ exports existing data when the container shuts down and re-imports data when the container start up again \*

We created this image because https://hub.docker.com/r/spine3/firebase-emulator failed to export and restore emulator state

\* In order to make this export/import work a named volume is needed - see below "Persisting data"

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

## Adresses

The emulators will be available under these addresses:

- Emulator UI: [http://localhost:4000](http://localhost:4000)
- Auth Emulator: [http://localhost:9099](http://localhost:9099)
- Firestore Emulator: [http://localhost:8080](http://localhost:8080)
- Functions Emulator: [http://localhost:5001](http://localhost:5001)
- Cloud Storage Emulator: [http://localhost:9199](http://localhost:9199)
- Realtime DB Emulator: [http://localhost:9000](http://localhost:9000)

## Persisting Data

In order to persist data between runs, a volume is needed.
The container is configured in a way that it exports all data to /firebase/data on shutdown and re-imports it from there during startup.

### With Docker

Define a named volume that points to the `/firebase`-folder in the container.
IMPORTANT: It has to be a named volume, not a bind mount. A bind mount will not work because firebase will complain about the folder destination existing already

```sh
docker run -d \
  --name firebase-emulator \
  -v firebase_data:/firebase \
  -e FB_PROJECT_ID=[your_project_id] \
  evolutecx/firebase-emulator:latest
```

### with docker-compose:

Make sure you define a volume-section in your docker-compose file, like so:

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
      - firebase_data:/firebase # <- this makes sure the data gets persisted

volumes:
  firebase_data: # <- you also need this
```

## ToDo:

Things that we will implement soon:

- [ ] Dynamic Port Configuration