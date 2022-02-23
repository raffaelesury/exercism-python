# get latest python base image from dockerhub
FROM python:latest

# set the author
LABEL org.opencontainers.image.authors="Raffaele Sury"

# get package listing, upgrade dist, clean cache, delete list
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download, decompress exercism and move it to the bin folder, should already be in $PATH
RUN wget https://github.com/exercism/cli/releases/download/v3.0.13/exercism-3.0.13-linux-x86_64.tar.gz && \
    tar zxvf exercism-3.0.13-linux-x86_64.tar.gz && \
    mv exercism /usr/local/bin/

# set working directory in the container
WORKDIR /workspace

# Configure the CLI as in the Exercism guide
# (*) Make use of secrets feature to avoid exposing the token in the public Dockerfile, keep the built image private
# (*) Place your Exercism token in a token.txt text file
# (*) The docker build command needs to be given with the --secret id=mytoken,src=token.txt option to pass the token
# (*) With the --mount command we make the token available as "mytoken" in the default path
# (*) required=true should stop the show if the secret was not passed when you called the build
RUN --mount=type=secret,id=mytoken,required=true exercism configure --token=$(cat /run/secrets/mytoken) --workspace=/workspace

ENTRYPOINT ["tail", "-f", "/dev/null"]