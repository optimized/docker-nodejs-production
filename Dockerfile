FROM node:lts
LABEL maintainer="n@noeljackson.com"

ENV NPM_CONFIG_LOGLEVEL notice
ENV PACKAGES="apt-utils libpng-dev python make g++"
RUN apt-get update
RUN apt-get -y install $PACKAGES

# Set registry
RUN npm config set registry http://registry.npmjs.org/
RUN npm i -g pm2 yarn lerna

# Create app directory
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app/

# Install app dependencies (package.json)
# Add temporary packages, and build the NPM packages/binaries
ENV TMP_PKGS="autoconf automake g++ libtool make nasm python git"
ONBUILD COPY . /usr/src/app/
ONBUILD RUN apt-get -y install $TMP_PKGS && \
            lerna bootstrap && yarn install && \
            apt-get remove $TMP_PACKAGES


# You would use this image as a builder image, and would set entrypoint and command like below.
#ENTRYPOINT ["pm2-runtime","-i","max"]
#CMD ["${SERVER}"]
