FROM node:10.7.0
LABEL maintainer="n@noeljackson.com"

ENV NODE_ENV production
ENV NPM_CONFIG_LOGLEVEL notice
ENV PACKAGES="libpng-dev python make g++"
RUN apt-get install $PACKAGES

# Add temporary packages, and build the NPM packages/binaries
ENV TMP_PKGS="autoconf automake g++ libtool make nasm python python-dev git"

# Set registry
RUN npm config set registry http://registry.npmjs.org/

# Create app directory
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app
# Install app dependencies (package.json)

# Install
ONBUILD ADD package*.json /usr/src/app/
ONBUILD RUN apt-get install --virtual .tmp $TMP_PKGS && npm i && apt-get remove $TMP_PACKAGES

# Add PM2, for Node process management
RUN npm i -g pm2

# Copy App
ONBUILD ADD . /usr/src/app/

# You would use this image as a builder image, and would set entrypoint and command like below.
#ENTRYPOINT ["pm2-runtime","-i","max"]
#CMD ["${SERVER}"]
