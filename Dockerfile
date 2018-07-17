FROM node:10.6.0
LABEL maintainer="n@noeljackson.com"
# defaults
ARG SERVER="build/server.js"

# The official image has verbose logging; change it to npm's default
ENV NPM_CONFIG_LOGLEVEL notice

# Add packages
ENV PACKAGES="libpng-dev python make g++"
RUN apk add --no-cache $PACKAGES

# Add temporary packages, and build the NPM packages/binaries
ENV EPHEMERAL_PACKAGES="autoconf automake g++ libtool make nasm python python-dev git"
RUN apk add --no-cache --virtual .tmp $EPHEMERAL_PACKAGES \
  && apk del .tmp

# Set registry
RUN npm config set registry http://registry.npmjs.org/

# Create app directory
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app
# Install app dependencies (package.json)

# Install
ONBUILD ADD package*.json /usr/src/app/
ONBUILD RUN npm i

# Add PM2, for Node process management
RUN npm i -g pm2

# Copy App
ONBUILD ADD . /usr/src/app/

# buildargs
ONBUILD ARG NODE_ENV
ONBUILD ENV NODE_ENV=$NODE_ENV
ONBUILD ENV SERVER=$SERVER
ONBUILD ARG HOST
ONBUILD ENV HOST=$HOST
ONBUILD ARG PORT
ONBUILD ENV PORT $PORT

# build
ONBUILD RUN npm run clean
ONBUILD RUN npm run build

# Start the server by default
ENTRYPOINT ["pm2-runtime","-i","max"]
CMD ["${SERVER}"]
