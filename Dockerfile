# get latest python base image from dockerhub
FROM python:latest

# set the author
LABEL org.opencontainers.image.authors="Raffaele Sury"

# get package listing, upgrade dist, install sudo, clean cache, delete list
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# create a user
RUN useradd --create-home worker
# change workdir to the newly created user folder
WORKDIR /home/worker

# set an argument with the path
ARG VIRTUAL_ENV=/opt/venv
# create venv there
RUN python3 -m venv $VIRTUAL_ENV
# prepend it to path to activate it
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# install dependencies (pytest in this case)
# we have to copy the requirements, by default it's copied with root access
# change it to be accessible
COPY ./requirements.txt ./requirements.txt
RUN pip install -r ./requirements.txt
# note: pip is now not installing stuff in a folder
# that in some base images might be under control of the distro's package manager
# which would make a mess, but in a venv. 
# In this base image, the latest python is in /usr/local/
# so it would not be a problem, but pip has no way to know that and would throw a warning.

# download, decompress exercism CLI and move it to the bin folder (already in path)
ARG USR_BIN=/usr/local/bin/
RUN wget https://github.com/exercism/cli/releases/download/v3.0.13/exercism-3.0.13-linux-x86_64.tar.gz && \
    tar zxvf exercism-3.0.13-linux-x86_64.tar.gz && \
    # directory needs to be created first, -p also creates the parents
    mkdir -p $USR_BIN && \
    mv exercism $USR_BIN && \
    rm  exercism-3.0.13-linux-x86_64.tar.gz

# set the working directory that will be used as exercism workspace
WORKDIR /home/worker/workspace

# Configure the CLI as in the Exercism guide
# (*) Make use of secrets feature to avoid exposing the token in the public Dockerfile, keep the built image private
# (*) Place your Exercism token in a token.txt text file
# (*) The docker build command needs to be given with the --secret id=mytoken,src=token.txt option to pass the token
# (*) With the --mount command we make the token available as "mytoken" in the default path
# (*) required=true should stop the show if the secret was not passed when you called the build
RUN --mount=type=secret,id=mytoken,required=true exercism configure --token=$(cat /run/secrets/mytoken) --workspace=/home/worker/workspace

# use user instead of running as root
USER worker

# keep the container up
ENTRYPOINT ["tail", "-f", "/dev/null"]