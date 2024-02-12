# We chose node-18 since currently firebase functions work on node-18
# As from now node-20 is currently in "preview" for firebase functions
# But if you want to run the beta you can change node:18-alpine to node:20-alpine
# https://firebase.google.com/docs/functions/manage-functions#set_nodejs_version
FROM node:18-alpine 

# Install JDK
RUN apk add --no-cache openjdk11

# Install the firebase cli
RUN npm install -g firebase-tools
RUN npm cache clean --force

# Install and setup all the Firebase emulators
RUN firebase setup:emulators:database
RUN firebase setup:emulators:firestore
RUN firebase setup:emulators:storage
# RUN firebase setup:emulators:pubsub     # this crashes the container
RUN firebase setup:emulators:ui

# Copying everything (=the firebase configuration to the workdir)
COPY . /firebase

# Mount your firebase project directory to /firebase when running the container
# This is the folder containing the firebase.json
WORKDIR /firebase

# Expose the emulator ports
# If you use non standard ports change them to the ones in your firebase.json
# TODO: Make ports configurable via ENV variables
#       AUTH    STORE   RLTDB   UI      PUBSUB  emulator ports
EXPOSE  9099    9199    8080    4000    8085

CMD ["sh", "-c", "firebase emulators:start --import=/firebase/data/ --export-on-exit=/firebase/data/ --project=${FB_PROJECT_ID}"]
