## Valheim server that runs inside a Docker container
[![Docker Automated build](https://img.shields.io/docker/automated/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server/)
[![Docker build status](https://img.shields.io/docker/build/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server/)
[![Docker Pulls](https://img.shields.io/docker/pulls/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server/)
[![Docker stars](https://img.shields.io/docker/stars/didstopia/valheim-server.svg)](https://hub.docker.com/r/didstopia/valheim-server)

**NOTE: Work in progress! Valheim was just released to early access, so please give us time to get this working!**

This image will always install/update to the latest steamcmd and Valheim server, all you have to do to update your server is to redeploy the container.

Also note that the entire /steamcmd/valheim can be mounted on the host system, which would avoid having to reinstall the game when updating or recreating the container.

### How to run the server
1. Optionally set the ```VALHEIM_SERVER_STARTUP_ARGUMENTS``` environment variable to match your preferred server arguments (defaults are set to ```"-quit -batchmode -nographics -dedicated -public 1"```)
2. Mount ```/steamcmd/valheim``` and ```/app/.config/unity3d/IronGate/Valheim``` somewhere on the host to keep your data safe (first path has the server files, while the second path has the config and save files)

You can control the startup mode by using ```VALHEIM_START_MODE```. This determines if the server should update and then start (mode 0), only update (mode 1) or only start (mode 2)) The default value is ```"0"```.

One additional feature you can enable is fully automatic updates, meaning that once a server update hits Steam, it'll restart the server and trigger the automatic update. You can enable this by setting ```VALHEIM_UPDATE_CHECKING``` to ```"1"```.  
You can also use a different branch via environment variables. For example, to install the latest experimental version, you would simply set ```VALHEIM_BRANCH``` to ```latest_experimental``` (this is set to ```public``` by default).

### License

See [LICENSE](LICENSE)
