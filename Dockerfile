FROM didstopia/base:nodejs-12-steamcmd-ubuntu-18.04

LABEL maintainer="Didstopia <support@didstopia.com>"

# Fixes apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
    xvfb \
    telnet \
    expect && \
    rm -rf /var/lib/apt/lists/*

# Create the volume directories
WORKDIR /
RUN mkdir -p /steamcmd/valheim /app/.local/share/Valheim

# Add the steamcmd installation script
ADD install.txt /app/install.txt

# Copy scripts
ADD start.sh /app/start.sh

# Fix permissions
RUN chown -R 1000:1000 \
    /steamcmd \
    /app

# Run as a non-root user by default
ENV PGID 1000
ENV PUID 1000

# Expose necessary ports
EXPOSE 2456/tcp
EXPOSE 2456/udp
EXPOSE 2457/udp
EXPOSE 2457/udp

# Setup default environment variables for the server
ENV VALHEIM_SERVER_STARTUP_ARGUMENTS "-quit -batchmode -nographics -dedicated -public 1"
ENV VALHEIM_SERVER_NAME "Docker"
ENV VALHEIM_SERVER_PASSWORD "docker"
ENV VALHEIM_BRANCH "public"
ENV VALHEIM_START_MODE "0"
ENV VALHEIM_UPDATE_CHECKING "0"

# Define directories to take ownership of
ENV CHOWN_DIRS "/app,/steamcmd"

# Expose the volumes
VOLUME [ "/steamcmd/valheim", "/app/.local/share/Valheim" ]

# Start the server
CMD [ "bash", "/app/start.sh" ]
