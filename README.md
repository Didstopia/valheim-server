## Valheim server that runs inside a Docker container
[![Docker Automated build](https://img.shields.io/docker/automated/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server/)
[![Docker build status](https://img.shields.io/docker/build/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server/)
[![Docker Pulls](https://img.shields.io/docker/pulls/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server/)
[![Docker stars](https://img.shields.io/docker/stars/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server)

This image will always install/update to the latest steamcmd and Valheim server, all you have to do to update your server is to redeploy the container.

Also note that the entire /steamcmd/valheim can be mounted on the host system, which would avoid having to reinstall the game when updating or recreating the container.

### How to run the server

Minimal example usage (remember to specify the `:latest` tag, environment variables can be omitted to use the defaults):
```sh
docker run -d \
  --name valheim-server \
  --restart always \
  -e VALHEIM_SERVER_NAME="Didstopia Docker Server" \
  -e VALHEIM_SERVER_WORLD="docker" \
  -e VALHEIM_SERVER_PASSWORD="s3cr3t" \
  -p 2456-2458:2456-2458/udp \
  -v $(pwd)/valheim_data/saves:/app/.config/unity3d/IronGate/Valheim \
  -v $(pwd)/valheim_data/data:/steamcmd/valheim \
  didstopia/valheim-server:latest
```

NOTE: At the time of writing this, the Valheim server can NOT be started without a password!

Check the `Dockerfile` in the official repository for all the available environment variables, such as setting up server admins or controlling server visibility.

You can control the startup mode by using ```VALHEIM_START_MODE```. This determines if the server should update and then start (mode 0), only update (mode 1) or only start (mode 2)) The default value is ```"0"```.

One additional feature you can enable is fully automatic updates, meaning that once a server update hits Steam, it'll restart the server and trigger the automatic update. You can enable this by setting ```VALHEIM_UPDATE_CHECKING``` to ```"1"```.  
You can also use a different branch via environment variables. For example, to install the latest experimental version, you would simply set ```VALHEIM_BRANCH``` to ```experimental``` (this is set to ```public``` by default).

### License

See [LICENSE](LICENSE)
